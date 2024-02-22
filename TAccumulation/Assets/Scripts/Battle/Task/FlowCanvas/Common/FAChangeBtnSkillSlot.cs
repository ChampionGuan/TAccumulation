using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("技能槽位映射变更\nFAChangeBtnSkillSlot")]
    public class FAChangeBtnSkillSlot : FlowAction
    {
        public PlayerBtnType PlayerBtnType = PlayerBtnType.Active;
        public ChangeSkillCdType changeSkillCdType = ChangeSkillCdType.KeepCd;
        public BBParameter<int> SkillID = new BBParameter<int>();

        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var target = _viActor?.GetValue();
            if (target == null)
            {
                _LogError($"节点【技能槽位映射变更 FAChangeSkillSlot】配置错误, 引脚参数【Actor】没有正确配置.");
                return;
            }

            if (target.skillOwner == null)
            {
                _LogError($"节点【技能槽位映射变更 FAChangeSkillSlot】配置错误, 引脚参数【Actor】没有SkillOwner组件.");
                return;
            }

            var playerBtnType = PlayerBtnType;
            var skillID = SkillID.GetValue();
            var slotId = target.skillOwner.GetSlotIDBySkillID(skillID);
            if (slotId == null)
            {
                _LogError($"节点【技能槽位映射变更 FAChangeSkillSlot】配置错误, 该角色{target.name} 身上没有没有【skillID={skillID}】的技能.");
                return;
            }
            
            var curSlotId = target.skillOwner.TryGetBaseSlotID(PlayerBtnType);
            if (curSlotId == null)
            {
                _LogError($"节点【技能槽位映射变更 FAChangeSkillSlot】配置错误, 该角色{target.name} 身上没有没有【PlayerBtnType={PlayerBtnType}】的技能.");
                return;
            }
            
            //清除CD
            var curSlot = target.skillOwner.GetSkillSlot(curSlotId.Value);
            if (curSlot != null && changeSkillCdType == ChangeSkillCdType.RefreshCd)
            {
                curSlot.SetRemainCD(0);
            }
            
            target.skillOwner.changeBtnSlotData.SetData(playerBtnType, slotId.Value);
        }
    }
}
