using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("尝试激活QTE (CD中不生效)\nActiveQTE")]
    public class FAActiveQTE : FlowAction
    {
        [Name("用槽位模式输入")]
        public bool isSlotTypeInput;
        
        [ShowIf("isSlotTypeInput", 0)]
        [Name("技能ID")]
        public int skillID;
        
        [ShowIf("isSlotTypeInput", 1)]
        public BBParameter<SkillSlotType> skillSlotType = new BBParameter<SkillSlotType>();
        [ShowIf("isSlotTypeInput", 1)]
        public BBParameter<int> skillSlotIndex = new BBParameter<int>();
        
        private bool _isSuccess;
        protected override void _OnRegisterPorts()
        {
            var success = AddFlowOutput("Success");
            var fail = AddFlowOutput("Fail");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
                _Invoke();
                if (_isSuccess)
                {
                    success.Call(f);
                }
                else
                {
                    fail.Call(f);
                }
            });
        }
        
        protected override void _Invoke()
        {
            _isSuccess = false;
            var boy = _battle.actorMgr.boy;
            if (boy != null)
            {
                var qteController = boy.skillOwner.qteController;
                if (qteController != null)
                {
                    if (isSlotTypeInput)
                    {
                        var slot = boy.skillOwner.GetSkillSlot(skillSlotType.GetValue(), skillSlotIndex.GetValue());
                        if (slot != null)
                        {
                            _isSuccess = qteController.TryActiveQTE(slot.skill.config.ID);
                        }
                    }
                    else
                    {
                        _isSuccess = qteController.TryActiveQTE(skillID);
                    }
                }
            }
        }
    }
}
