using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("【关卡】刷新技能CD\nResetSkillCDInLevel")]
    public class FARefreshSkillCD : FlowAction
    {
        [Name("ActorId Girl=-1, Boy=-2")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<int> skillId = new BBParameter<int>();
        
        protected override void _Invoke()
        {
            int actorTypeId = actorId.GetValue();
            var target = BattleUtil.GetActorByIDType(actorTypeId);
            if (target == null)
            {
                _LogError($"节点【【关卡】刷新技能CD】配置错误. 关卡中不存在这样的角色, actorId={actorId.GetValue()}.");
                return;
            }
            
            if (target.skillOwner == null)
            {
                _LogError($"节点【【关卡】刷新技能CD】配置错误. 角色:{target.name}, configID:{target.config.ID}, 不存在技能组件SkillOwner");
                return;
            }

            var slot = target.skillOwner.GetSkillSlot(SkillSlotType.SkillID, skillId.GetValue());
            if (slot == null)
            {
                _LogError($"节点【【关卡】刷新技能CD】配置错误. 角色:{target.name}, actorId={actorId.GetValue()}, 不存在该技能: {skillId.GetValue()}.");
                return;
            }

            slot.SetRemainCD(0f);
            slot.SetEnergyFull();
            //通知按钮UI刷新
            // 如果是自定义启动， UI需要这条消息
            Battle.Instance.eventMgr.Dispatch(EventType.RefreshSkillUI, null);
        }
    }
}
