using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("判断是否可释放技能")]
    public class PlayActionModule : BattleAction
    {
        [Tooltip("动作模组ID")] public BBParameter<int> actionModuleID = new BBParameter<int>();

        [Tooltip("是否跳过该流程")] public BBParameter<bool> isSkip = new BBParameter<bool>();
        
        [Tooltip("是否等待动作模组结束")] public BBParameter<bool> waitFinish = new BBParameter<bool>();

        private Action _ActionOnActionModuleEnd;
        public PlayActionModule()
        {
            _ActionOnActionModuleEnd = _OnActionModuleEnd;
        }
        
        protected override void OnExecute()
        {
            if (isSkip.GetValue())
            {
                EndAction(true);
                return;
            }
            
            var moduleID = actionModuleID.GetValue();
            if (moduleID <= 0)
            {
                EndAction(true);
                return;
            }

            if (waitFinish.GetValue())
            {
                _actor.sequencePlayer.PlayFlowCanvasModule(moduleID, _ActionOnActionModuleEnd);
            }
            else
            {
                _actor.sequencePlayer.PlayFlowCanvasModule(moduleID);
                EndAction(true);
            }
        }

        private void _OnActionModuleEnd()
        {
            EndAction(true);
            ForceTick();
        }
    }
}
