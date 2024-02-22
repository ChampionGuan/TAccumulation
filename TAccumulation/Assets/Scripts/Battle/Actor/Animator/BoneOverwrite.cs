using PapeAnimation;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;
using X3.PlayableAnimator;
using X3;
using static X3.BoneOverwriteMixer;

namespace X3Battle
{
    public class BoneOverwrite
    {
        private AnimationMixerPlayable m_overwriteClipsPlayable;
        private Transform[] _transforms;
        private Transform[] _newParents;
        private BoneOverwriteMixer.BoneOverwriteMixerBehaviour _overwriteBehaviour;
        private List<AnimationClip> _overwriteClips;
        private int _curIndex;
        private PlayableGraph _graph;
        private AnimatorController _animCtrl;
        private Playable _curPlayable;
        private ScriptPlayable<BoneOverwriteMixerBehaviour> _overwritePlayable;

        public BoneOverwrite()
        {
            _overwriteClips = new List<AnimationClip>();
            _transforms = new Transform[0];
            _newParents = new Transform[0];
    }

        public void Init(Transform[] boneTransform, Transform[] newParents)
        {
            _transforms = boneTransform;
            _newParents = newParents;
        }

        public bool TrySetBoneTransform(Transform[] boneTransform, Transform[] newParents)
        {
            if (_transforms.Length == boneTransform.Length && _newParents.Length == newParents.Length)
            {
                bool result = false;
                for(int i = 0; i < _transforms.Length; i++)
                {
                    if (_transforms[i] != boneTransform[i])
                    {
                        result = true;
                        break;
                    }
                }

                for (int i = 0; i < _newParents.Length; i++)
                {
                    if (_newParents[i] != newParents[i])
                    {
                        result = true;
                        break;
                    }
                }
                if (!result)
                    return false;
            }

            _transforms = boneTransform;
            _newParents = newParents;
            return true;
        }

        public void AddOverwriteClip(AnimationClip clip)
        {
            if(!_overwriteClips.Contains(clip))
            {
                _overwriteClips.Add(clip);
                m_overwriteClipsPlayable = _RebuildClipsMixerPlayable(_graph, _animCtrl);
            }
            
        }

        public void RebuildPlayable(Animator animator, Playable originPlayable, Playable playableParent, AnimatorController ctrl, int index)
        {
            
            _graph = playableParent.GetGraph();
            _animCtrl = ctrl;
            m_overwriteClipsPlayable = _RebuildClipsMixerPlayable(_graph, _animCtrl); 
            playableParent.DisconnectInput(index);

            if (_overwritePlayable.IsValid())
            {
                var playable = _overwritePlayable.GetInput(0);
                playable.DisconnectInput(0);
                playable.DisconnectInput(1);
                _overwritePlayable.DisconnectInput(0);
            }

            _overwritePlayable = BoneOverwriteMixer.CreatePlayable(animator, _transforms, _newParents, originPlayable, m_overwriteClipsPlayable);
            _overwriteBehaviour = _overwritePlayable.GetBehaviour();
            playableParent.ConnectInput(index, _overwritePlayable, 0, 1);
        }

        public void EnableOverwrite(string clipName, bool enable)
        {
            int index = GetClipIndex(clipName);

            if (index != -1)
            {
                if (enable)
                {
                    m_overwriteClipsPlayable.SetInputWeight(index, 1);
                    _curPlayable = m_overwriteClipsPlayable.GetInput(index);
                    _curIndex = index;
                }
                else
                {
                    m_overwriteClipsPlayable.SetInputWeight(index, 0);
                    _curPlayable = Playable.Null;
                    _curIndex = -1;
                }
                _overwriteBehaviour.EnableOverwrite = enable;
            }
        }

        public void EnableTransformToNewParent(bool enable)
        {
            _overwriteBehaviour.EnableTransformToNewParent = enable;
        }

        public void Update()
        {
            if(!_curPlayable.IsNull())
            {
                _curPlayable.SetTime(_animCtrl.GetCurrentStateInfo(0).normalizedTime * _animCtrl.GetCurrentStateInfo(0).length);
            }
        }

        private int GetClipIndex(string clipName)
        {
            int index = -1;
            for(int i = 0; i < _overwriteClips.Count; i ++)
            {
                if (_overwriteClips[i].name == clipName)
                    index = i;
            }
            return index;
        }

        private AnimationMixerPlayable _RebuildClipsMixerPlayable(PlayableGraph graph, AnimatorController ctrl)
        {
            // TODO:后面优化下，先创建出空位
            var mixer = AnimationMixerPlayable.Create(graph, _overwriteClips.Count);
            for(int i = 0; i < _overwriteClips.Count; i ++)
            {
                var playable = ctrl.context.CreateClipPlayable(_overwriteClips[i]);
                mixer.ConnectInput(i, playable, 0, i == _curIndex ? 1 : 0);
            }
            return mixer;
        }
    }
}
