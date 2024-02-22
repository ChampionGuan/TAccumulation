using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PapeGames
{
    // 当运行时把Effect节点刷到世界上，位置为父节点当前位置+localPosition
    // 运行结束时把effect节点重新放到父节点上，位置为localPosition
    public class HookDetachPlayable : MountPlayableBehaviourBase
    {
        private const double frameTime = 0.033f;
        public TrackExtData trackExtData;
        
        private bool isPlay;
        // clip开始播放的时间
        private double startTime;
        private bool hasDetach;
        private bool needDetach;
        private Transform targetTransform;
        private Transform parentTransform;
        
        private Vector3 localPosition;
        private Quaternion localRotation;
        private Vector3 localScale;

        private Quaternion worldRotation;

        private void ResetFields()
        {
            localPosition = Vector3.zero;
            localRotation = Quaternion.identity;
            localScale = Vector3.zero;

            startTime = 0f;
            hasDetach = false;
            needDetach = false;
        }
        
        public void SetData(TrackExtData extData)
        {
            trackExtData = extData;
        }

        protected override void OnBehaviourPlay(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            startTime = playable.GetTime();
            isPlay = true;
            // 过滤掉跳帧、倒放、配置上不需要分离的情况
            if (startTime < frameTime && CheckDetachValid(behaviour))
            {
                needDetach = true;
                TryDetach(startTime);
            }

            if (NeedWorldRotate())
            {
                worldRotation = targetTransform.rotation;
            }
        }

        private bool NeedWorldRotate()
        {
            return trackExtData.isFollowActor && !trackExtData.isFollowRotate && targetTransform;
        }
        
        protected override void OnProcessFrame(PlayableBehaviour behaviour, Playable playable, FrameData info, object userData)
        {
            TryDetach(playable.GetTime());
            
            if (NeedWorldRotate())
            {
                targetTransform.rotation = worldRotation;
            }
        }

        protected override void OnBehaviourPause(PlayableBehaviour behaviour, Playable playable, FrameData info)
        {
            if (!isPlay)
            {
                return;
            }
            
            isPlay = false;
            TryUndetach();
            ResetFields();
        }

        // 尝试合并回父节点
        private void TryUndetach()
        {
            if (needDetach && hasDetach && !Application.isPlaying)
            {
                // 非运行模式会把信息刷回去
                targetTransform.parent = parentTransform;
                targetTransform.localPosition = localPosition;
                targetTransform.localRotation = localRotation;
                targetTransform.localScale = localScale;
                        
                trackExtData.localPosition = localPosition;
                trackExtData.localRotation = localRotation.eulerAngles;
                trackExtData.localScale = localScale;
            }
        }
        
        // 尝试分离父节点
        private void TryDetach(double currentTime)
        {
            if (needDetach && !hasDetach)
            {
                double offsetTime = currentTime - startTime - trackExtData.detachTime;
                if (offsetTime < 0)
                {
                    return;
                }

                if (Application.isPlaying)
                {
                    // 运行时直接分离
                    hasDetach = true;
                    targetTransform.parent = null;
                }
                else
                {
                    // 编辑器下 TimelineWindow.instance.state.referenceSequence.time
                    localPosition = targetTransform.localPosition;
                    localRotation = targetTransform.localRotation;
                    localScale = targetTransform.localScale;
                    
                    hasDetach = true;
                    targetTransform.parent = null;
                }
            }  
        }

        // 检测Clip是否满足条件，并设置targetTransform与parentTransform
        private bool CheckDetachValid(PlayableBehaviour behaviour)
        {
            Transform targetTrans = null;
            Transform parentTrans = null;
            if (trackExtData != null)
            {
                ActivationControlPlayable activePlayable = behaviour as ActivationControlPlayable;
                if (activePlayable != null && activePlayable.gameObject != null)
                {
                    targetTrans = activePlayable.gameObject.transform;
                    parentTrans = targetTrans.parent;
                    this.targetTransform = targetTrans;
                    this.parentTransform = parentTrans;
                }
                if (!trackExtData.isFollowActor && targetTrans != null && parentTrans != null)
                {
                    return true;
                }
            }
            return false;
        }
    }
}