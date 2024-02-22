using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("获取CommonConditionGroupID值\nCommonConditionGroupID")]
    public class FCCommonConditionGroupID : FlowCondition
    {
        private ValueInput<int> _viGroupID;
        protected override void _OnAddPorts()
        {
            _viGroupID = AddValueInput<int>("GroupID");
        }

        protected override bool _IsMeetCondition()
        { 
            var viGroupID = _viGroupID.GetValue();
            return BattleEnv.LuaBridge.ConditionGroupId(viGroupID);
        }
    }
}
