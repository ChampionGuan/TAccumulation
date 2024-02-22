using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC出生镜头演出完成监听器\nListener:NPCBornPerformFinished")]
    public class OnNPCBornPerformComplete : FlowListener
    {
        [Name("actorSpawnId")]
        public BBParameter<int> actorInsId = new BBParameter<int>();

        private Action<EventBornCameraState> _actionOnBornCameraEnd;

        public OnNPCBornPerformComplete()
        {
            _actionOnBornCameraEnd = _OnBornCameraEnd;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventBornCameraState>(EventType.OnBornCameraState, _actionOnBornCameraEnd,"OnNPCBornPerformComplete._OnBornCameraEnd");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventBornCameraState>(EventType.OnBornCameraState, _actionOnBornCameraEnd);
        }

        private void _OnBornCameraEnd(EventBornCameraState eventBornCameraState)
        {
            if (IsReachMaxCount())
            {
                return;
            }

            if (eventBornCameraState.state != BornCameraState.End)
            {
                return;
            }

            var actor = eventBornCameraState.actor;
            if (actor == null)
            {
                return;
            }

            // DONE: 如果跳过了出生镜头则不算NPC出生镜头演出结束.
            if (!actor.bornCfg.ControlBornPerform)
            {
                return;
            }

            var spawnID = actorInsId.GetValue();
            if (actor.spawnID != spawnID)
            {
                return;
            }

            _Trigger();
        }
    }
}
