using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("播放关卡动作模组\nPlayStageActionModule")]
    public class FAPlayStageActionModule : FlowAction
    {
        public BBParameter<int> actionModuleID = new BBParameter<int>();
        public BBParameter<Vector3> offsetPosition = new BBParameter<Vector3>();
        public BBParameter<Vector3> offsetEulerAngle = new BBParameter<Vector3>();

        private ValueInput<Actor> _viActor;
        private Action _stopAction;

        public FAPlayStageActionModule()
        {
            _stopAction = _StopAction;
        }
        
        protected override void _OnGraphStart()
        {
            var stage = Battle.Instance.actorMgr.stage;
            if (stage?.sequencePlayer == null)
            {
                return;
            }

            stage.sequencePlayer.CreateFlowCanvasModule(actionModuleID.GetValue(), notBindCreator: true);
        }
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }
        
        protected override void _Invoke()
        {
            var actor = _viActor.GetValue();
            if (actor == null)
            {
                actor = Battle.Instance.actorMgr.stage;
            }

            var stageActor = Battle.Instance.actorMgr.stage;
            
            // DONE: 设置Actor位置.
            Vector3 targetPos = actor.transform.position + offsetPosition.GetValue();
            Vector3 targetEuler = actor.transform.eulerAngles + offsetEulerAngle.GetValue();
            stageActor.transform.SetPosition(targetPos);
            stageActor.transform.SetEulerAngles(targetEuler);
            
            // DONE: 设置动作模组ID.
            stageActor.sequencePlayer.PlayFlowCanvasModule(actionModuleID.GetValue(), _stopAction);
        }

        private void _StopAction()
        {
            var stageActor = Battle.Instance.actorMgr.stage;
            stageActor.transform.SetPosition(stageActor.bornCfg.Position);
            stageActor.transform.SetForward(stageActor.bornCfg.Forward);
        }
    }
}
