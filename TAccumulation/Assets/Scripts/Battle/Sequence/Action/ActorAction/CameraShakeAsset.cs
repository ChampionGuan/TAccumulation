using System;
using UnityEngine.Timeline;
using X3.Impulse;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    [TimelineMenu("角色动作/震屏")]
    [Serializable]
    public class CameraShakeAsset : BSActionAsset<ActionCameraShake>
    {
        [LabelText("Asset")]
        public ImpulseBaseAsset asset;
        [LabelText("调用参数")]
        public ImpulseParameter parameter = new ImpulseParameter(ImpulseParameter.battleDefaluParameter);
        [LabelText("因打断而结束")]
        public bool isEndByInterrupt = false;
        [LabelText("因正常结束而结束")]
        public bool isEndByLine = false;
        [LabelText("clip期间是否仅怪物虚弱时触发")]
        public bool triggerOnWeak = false;
    }

    public class ActionCameraShake : BSAction<CameraShakeAsset>
    {
        protected ImpulseBaseAsset impulseEvent;
        private Action<EventWeakFull> _actionOnWeakFull;

        protected override void _OnInit()
        {
            if (clip.asset == null)
                return;

            base._OnInit();
            _actionOnWeakFull = _OnWeakFull;
            InstImpulseAsset();
        }

        void InstImpulseAsset()
        {
            impulseEvent = GameObject.Instantiate(clip.asset);
            impulseEvent.m_Param = clip.parameter;
        }

        protected override void _OnEnter()
        {
            if (!clip.triggerOnWeak)
            {
                using (ProfilerDefine.SequenceCameraShakeMarker.Auto())
                {
                    _AddImpulse();
                }
            }
            else
            {
                using (ProfilerDefine.SequenceCameraShakeAddListenerMarker.Auto())
                {
                    context.battle.eventMgr.AddListener<EventWeakFull>(EventType.WeakFull, _actionOnWeakFull, "CameraShakeAsset._OnWeakFull");
                }
            }
        }

        protected override void _OnExit()
        {
            context.battle.eventMgr.RemoveListener<EventWeakFull>(EventType.WeakFull, _actionOnWeakFull);
        }

        private void _OnWeakFull(EventWeakFull eventData)
        {
            _AddImpulse();
            context.battle.eventMgr.RemoveListener<EventWeakFull>(EventType.WeakFull, _actionOnWeakFull);
        }

        private void _AddImpulse()
        {
            if (clip.asset == null)
                return;

#if UNITY_EDITOR
            InstImpulseAsset();//策划:修改ProjectAsset就能重新Inst
#endif
            if (clip.asset.m_Duration == -1)//Asset为-1时 跟随Clip时长
            {
                impulseEvent.m_Duration = duration;
            }
            using (ProfilerDefine.SequenceCameraShakeAddMarker.Auto())
            {
                context.battle.cameraImpulse.AddActorImpulse(impulseEvent, context.actor, context.skill, clip.isEndByInterrupt, clip.isEndByLine);
            }
        }
    }
}