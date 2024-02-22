using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/怪物出生UI和输入处理")]
    [Serializable]
    public class BornDisablePlayerInputAsset : BSActionAsset<ActionBornDisablePlayerInput>
    {
    }

    public class ActionBornDisablePlayerInput : BSAction<BornDisablePlayerInputAsset>
    {
        
        protected override void _OnEnter()
        {
           
            // DONE: 获取该timeline的Actor
            var actor = context.actor;
            var battle = context.battle;
            bool enableBornCamera = actor.bornCfg.ControlBornPerform;
            if (enableBornCamera)
            {
                // 全部隐藏所有UI
                BattleUtil.SetUIActive(false);
                
                // DONE: 强制设置玩家Idle状态.
                battle.player.ForceIdle();
                
                // DONE: 禁用男主AI
                battle.actorMgr.boy?.aiOwner.DisableAI(true, AISwitchType.ActionModule);

                var eventData = context.battle.eventMgr.GetEvent<EventBornCameraState>();
                eventData.Init(actor, BornCameraState.Start);
                context.battle.eventMgr.Dispatch(EventType.OnBornCameraState, eventData);
            }
        }

        protected override void _OnExit()
        {
            var actor = context.actor;
            var battle = context.battle;
            bool enableBornCamera = actor.bornCfg.ControlBornPerform;
            if (enableBornCamera)
            {
                // DONE: 恢复男主AI
                battle.actorMgr.boy?.aiOwner.DisableAI(false, AISwitchType.ActionModule);
                
                // 全部展示所有UI  
                BattleUtil.SetUIActive(true);
                var eventData = context.battle.eventMgr.GetEvent<EventBornCameraState>();
                eventData.Init(actor, BornCameraState.End);
                context.battle.eventMgr.Dispatch(EventType.OnBornCameraState, eventData);
            }
        }   
    }
}