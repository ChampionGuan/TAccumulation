using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class BSCActorAnim :BSCBase, IReset
    {
        private List<AnimationTrack> _animationTracks = new List<AnimationTrack>(5);

        public void Reset()
        {
            _animationTracks.Clear();
        }
        
        protected override bool _OnBuild()
        {
            _EvalActorAnimTrack();
            return true;
        }
        
        private void _EvalActorAnimTrack()
        {
            // 找到AnimTrack
            _animationTracks.Clear();
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var timelineAsset = resCom.artAsset;
            if (timelineAsset == null)
            {
                return;
            }
            var allTracks = timelineAsset.GetOutputTracks();
            foreach (var track in allTracks)
            {
                if (track is AnimationTrack animTrack)
                {
                    if (animTrack.extData.trackType == TrackExtType.CreatureAnim)
                    {
                        _animationTracks.Add(animTrack);
                    }     
                }  
            }

            var actionContext = _battleSequencer.bsCreateData.bsActionContext;
            var skill = actionContext?.skill;
            var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            foreach (var animationTrack in _animationTracks)
            {
                var timelineClips = animationTrack.GetClipsArray();
                if (timelineClips.Length > 0)
                {
                    Actor bindActor = null;
                    var extData = animationTrack.extData;
                    if (bindCom.notBindCreator)
                    {
                        var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(extData);
                        if (roleType == TrackBindRoleType.Male)
                        {
                            bindActor = Battle.Instance.actorMgr.boy;
                        }
                        else if (roleType == TrackBindRoleType.Female)
                        {
                            bindActor = Battle.Instance.actorMgr.girl;
                        }
                    }
                    else
                    {
                        bindActor = _battleSequencer.bsCreateData.creatorActor;
                    }
                    
                    var sequenceTrack = new X3Sequence.Track(_battleSequencer.artSequencer, specialEnd: true, name: animationTrack.name);
                    //  支持轨道初始偏移
                    if (animationTrack.trackOffset == TrackOffset.ApplyTransformOffsets && (animationTrack.position != Vector3.zero || animationTrack.eulerAngles != Vector3.zero))
                    {
                        var action = new BSAActorAnimOffset();
                        action.SetData(bindActor, animationTrack.position, animationTrack.eulerAngles);
                        action.Init(sequenceTrack, 0, 0);
                        sequenceTrack.AddAction(action);
                    }
                    
                    // 目前援护技二阶段开始的动画需要delay
                    bool needDelay = timelineClips.Length > 1 && skill != null && skill.config.Type == SkillType.Support && bindActor != null && bindActor.IsBoy();
                    BSAActorAnim delayAction = null;
                    float maxTime = -1f;
                    
                    for (int i = 0; i < timelineClips.Length; i++)
                    {
                        var timelineClip = timelineClips[i];
                        if (timelineClip.asset is AnimationPlayableAsset animAsset)
                        {
                            var animClip = animAsset.clip;
                            if (animClip != null)
                            {
                                var animClipName = animClip.name;
                                var action = new BSAActorAnim();
                                action.SetData(bindActor, _battleSequencer, animClipName);
                                action.Init(sequenceTrack, (float)timelineClip.start, (float)timelineClip.duration, timelineClip.displayName);
                                sequenceTrack.AddAction(action);
                                if (maxTime < (float)timelineClip.start)
                                {
                                    maxTime = (float)timelineClip.start;
                                    delayAction = action;
                                }
                            }
                        }
                    }
                    delayAction?.ActiveDelay(needDelay);
                    
                    _battleSequencer.artSequencer.AddTrack(sequenceTrack);
                }
            }
        }
    }
}