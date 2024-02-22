using System.Collections.Generic;
using PapeGames.Rendering;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3;
using X3Sequence;

namespace X3Battle
{
    public class ActionAnimMixer: BSAction
    {
        private GameObject _bindObj;
        private Animator _bindAnimator;
        private AnimGraphOwner _graphOwner;
        private Playable? _trackPlayable;
        private Sequencer _controlSequencer;

        private bool _interruptNeedHideObj;  // 打断时是否需要把节点设为visible=false
        private PostProcessVolume _ppvCom;
        private bool _interruptHasHidObj;  // 打断时是否有隐藏节点
        
        protected override void _OnInit()
        {
            // 需要打断通知
            needInterruptNotify = true;  
            
            // 关闭track生成原生playable
            var animTrack = GetTrackAsset<AnimationTrack>();

            var bindObj = GetTrackBindObj<GameObject>();
            var animator = bindObj?.GetComponent<Animator>();
            if (bindObj == null)
            {
                animator = GetTrackBindObj<Animator>();
                bindObj = animator?.gameObject;
            }
            _bindAnimator = animator;
            
            if (animator != null)
            {
                _bindObj = bindObj;
                _controlSequencer = new Sequencer($"{bindObj.name} {animTrack.name}'s controller");
                _CreateClipPlayableGraph();
            }

            var trackType = animTrack.extData.trackType;
            if ((trackType == TrackExtType.ChildAnim || trackType == TrackExtType.ChildHookEffectAnim) && _bindObj != null)
            {
                var ppvCom = _bindObj.GetComponent<PostProcessVolume>();
                if (ppvCom != null)
                {
                    _ppvCom = ppvCom;
                    _interruptNeedHideObj = true;
                }
            }
        }

        protected override void _OnEnabledChange()
        {
            if (_ppvCom != null)
            {
                _ppvCom.enabled = this.enabled;
            }
        }

        protected override void _OnDestroy()
        {
            if (_trackPlayable != null)
            {
                _graphOwner.DetachPlayable(_trackPlayable.Value);
                _trackPlayable.Value.Destroy();
                _trackPlayable = null;
            }

            if (_controlSequencer != null)
            {
                _controlSequencer.Destroy();
                _controlSequencer = null;
            }
        }
        
        protected override void _OnEnter()
        {
            if (_interruptNeedHideObj && _interruptHasHidObj)
            {
                _bindObj.SetVisible(true);
                _interruptHasHidObj = false;
            }
            
            var finishHold = track.sequencer.finishHold;  // 结束是否hold住
            _controlSequencer?.Start(curOffsetTime, finishHold);
            
            if (_graphOwner != null)
            {
                _graphOwner.Evaluate();
            }
            
        }

        protected override void _OnExit()
        {
            _controlSequencer?.Stop();
        }

        protected override void _OnInterruptNotify()
        {
            if (_interruptNeedHideObj && _bindObj.visibleSelf)
            {
                _bindObj.SetVisible(false);
                _interruptHasHidObj = true;
            }
        }

        protected override void _OnUpdate()
        {
            _controlSequencer?.SetTime(curOffsetTime, true);
            if (_graphOwner != null)
            {
                _graphOwner.Evaluate();
            }
        }

        private void _CreateClipPlayableGraph()
        {
            // 创建Graph
            _graphOwner = BattleUtil.EnsureComponent<AnimGraphOwner>(_bindObj);
            var animTrack = GetTrackAsset<AnimationTrack>();
            var usingX3Graph = animTrack.extData.trackType == TrackExtType.CreatureAnim;
            _graphOwner.TryInit(usingX3Graph);
            
            animTrack.isAdditive = false;  // 父track肯定是override的
            
            // 拿到父子节点
            List<AnimationTrack> flattenTracks = new List<AnimationTrack>();
            if (AnimationTrack.CanCompileClips(animTrack) && animTrack.extCanCompileSelf)
            {
                flattenTracks.Add(animTrack);
            }
            
            bool animatesRootTransform = animTrack.AnimatesRootTransform();
            var _hasMaterialSubTrack = false;
            float _maretialChildMaxDuration = 0;
            foreach (var subTrack in animTrack.GetChildTracks())
            {
                var child = subTrack as AnimationTrack;
                if (child != null && AnimationTrack.CanCompileClips(child))
                {
                    if (child.isMaretialTrack)
                    {
                        _hasMaterialSubTrack = true;
                        _maretialChildMaxDuration = _maretialChildMaxDuration > child.end ? _maretialChildMaxDuration : (float)child.end;
                    }
                    animatesRootTransform |= child.AnimatesRootTransform();
                    flattenTracks.Add(child);
                }
            }

            // 检测到有材质子轨的时候，禁掉AnimationMotionXToDeltaPlayable
            if (_hasMaterialSubTrack)
            {
                animatesRootTransform = false;
            }
            
            // figure out which mode to apply
            // 创建Track
            var graph = _graphOwner.graph.Value;
            var controlTrack = new X3Sequence.Track(_controlSequencer);
            AppliedOffsetMode mode = animTrack.GetOffsetMode(_bindObj, animatesRootTransform);
            var layerMixer = AnimationTrack.CreateGroupMixer(graph, flattenTracks.Count);
            for (int c = 0; c < flattenTracks.Count; c++)
            {
                var compiledTrackPlayable = flattenTracks[c].inClipMode ?
                    _CompileTrackPlayable(graph, flattenTracks[c], _bindObj, controlTrack, mode) :
                    // flattenTracks[c].CreateInfiniteTrackPlayable(graph, go, tree, mode);
                    _CreateInfiniteTrackPlayable(graph, flattenTracks[c], _bindObj, controlTrack, mode);
                
                // graph.Connect(compiledTrackPlayable, 0, layerMixer, c);
                layerMixer.ConnectInput(c, compiledTrackPlayable, 0);
                
                // layerMixer.SetInputWeight(c, flattenTracks[c].inClipMode ? 0 : 1);
                layerMixer.SetInputWeight(c, 1);
                if (flattenTracks[c].isAdditive)
                {
                    layerMixer.SetLayerAdditive((uint)c, true);       
                }
                if (flattenTracks[c].applyAvatarMask && flattenTracks[c].avatarMask != null)
                {
                    layerMixer.SetLayerMaskFromAvatarMask((uint)c, flattenTracks[c].avatarMask);
                }
            }

            // 创建RootMotionXPlayable
            bool requiresMotionXPlayable = animTrack.RequiresMotionXPlayable(mode, _bindObj);
            Playable mixer = layerMixer;
            // motionX playable not required in scene offset mode, or root transform mode
            if (requiresMotionXPlayable)
            {
                // If we are animating a root transform, add the motionX to delta playable as the root node
                var motionXToDelta = AnimationTrack.CreateAnimationMotionXToDeltaPlayable(graph, mode);
                
                // graph.Connect(mixer, 0, motionXToDelta, 0);
                motionXToDelta.ConnectInput(0, mixer, 0);
                
                motionXToDelta.SetInputWeight(0, 1.0f);
                mixer = (Playable)motionXToDelta;
            }
            
            // 将mixer绑定output输出，稳了删
            // var playableOutput = AnimationPlayableOutput.Create(graph, "MixerOutPut", _animator);
            // playableOutput.SetSourcePlayable(mixer);
            _graphOwner.AttachPlayable(mixer);
            _trackPlayable = mixer;
            
            // 将Track加入Controller
            _controlSequencer.AddTrack(controlTrack);
        }

        // 创建Clip类型轨道动画
        private Playable _CompileTrackPlayable(PlayableGraph graph, TrackAsset track, GameObject go, X3Sequence.Track controlTrack, AppliedOffsetMode mode)
        {
            var clips = track.GetClipsArray();
            var mixer = AnimationMixerPlayable.Create(graph, clips.Length);
            for (int i = 0; i < clips.Length; i++)
            {
                var c = clips[i];
                var asset = c.asset as PlayableAsset;
                if (asset == null)
                    continue;

                var animationAsset = asset as AnimationPlayableAsset;
                if (animationAsset != null)
                {
                    animationAsset.SetAppliedOffsetMode(mode);
                }
                
                // 首先尝试创建换手动画
                var source = X3TimelineUtility.TryCreateCustomAnimPlayable(graph, animationAsset, _bindAnimator);
                // 换手动画没有的情况下，创建普通动画
                if (source.Equals(Playable.Null))
                {
                    source = asset.CreatePlayable(graph, go);
                }
                
                if (source.IsValid())
                {
                    // 获取时长（不能像原生timeline一样无限长，限制最大值为timeline长度）
                    var finalDuration = c.extrapolatedDuration;
                    var sequencerDuration = GetSequenceDuration();
                    if (finalDuration > sequencerDuration)
                    {
                        finalDuration = sequencerDuration;
                    }
                    
                    // graph.Connect(source, 0, mixer, i);
                    mixer.ConnectInput(i, source, 0);
                    
                    var clip = new ActionAnimControl(c, source, mixer);
                    clip.Init(controlTrack,(float)c.extrapolatedStart, (float)finalDuration, c.displayName);
                    controlTrack.AddAction(clip);
                    _TryExpandDuration((float)(c.extrapolatedStart + finalDuration));
                }
            }
            return ApplyTrackOffset(graph, mixer, go, mode);
        }
        
        private Playable ApplyTrackOffset(PlayableGraph graph, Playable root, GameObject go, AppliedOffsetMode mode)
        {
            var animTrack = GetTrackAsset<AnimationTrack>();
            // offsets don't apply in scene offset, or if there is no root transform (globally or on this track)
            if (mode == AppliedOffsetMode.SceneOffsetLegacy || mode == AppliedOffsetMode.SceneOffset || mode == AppliedOffsetMode.NoRootTransform || !animTrack.AnimatesRootTransform())
            {
                return root;
            }
            
            var pos = animTrack.position;
            var rot = animTrack.rotation;
            
            var offsetPlayable = AnimationTrack.CreateAnimationOffsetPlayable(graph, pos, rot, 1);
            
            // graph.Connect(root, 0, offsetPlayable, 0);
            offsetPlayable.ConnectInput(0, root, 0);
                
            offsetPlayable.SetInputWeight(0, 1);

            return offsetPlayable;
        }

        // 创建Infinite类型轨道动画
        private  Playable _CreateInfiniteTrackPlayable(PlayableGraph graph, AnimationTrack animTrack, GameObject go, X3Sequence.Track controlTrack, AppliedOffsetMode mode)
        {
            if (animTrack.InfiniteClip == null)
            {
                return Playable.Null;
            }
            
            var mixer = AnimationMixerPlayable.Create(graph, 1);
            // In infinite mode, we always force the loop mode of the clip off because the clip keys are offset in infinite mode
            //  which causes loop to behave different.
            // The inline curve editor never shows loops in infinite mode.
            var playable = AnimationPlayableAsset.CreatePlayable(graph, animTrack.InfiniteClip, animTrack.infiniteClipOffsetPosition, animTrack.infiniteClipOffsetEulerAngles, false, mode, animTrack.InfiniteClipApplyFootIK, AnimationPlayableAsset.LoopMode.Off);
            if (playable.IsValid())
            {
                // 原生不限制时长，这里限制最大时长为timeline时长
                var finalDuration = (float)GetSequenceDuration();
                
                // 创建Infinite动画
                // graph.Connect(playable, 0, mixer, 0);
                mixer.ConnectInput(0, playable, 0);
                
                var clip = new ActionAnimInfinite(playable, mixer);
                clip.Init(controlTrack, 0, finalDuration, $"{animTrack.name} Infinite");
                controlTrack.AddAction(clip);
                _TryExpandDuration(finalDuration);
            }

            return ApplyTrackOffset(graph, mixer, go, mode);
        }
        
        // 尝试扩张自己的时长
        private void _TryExpandDuration(float newDuration)
        {
            if (this.duration < newDuration)
            {
                this._SetDuration((float)newDuration);
            }
        }
    }
}