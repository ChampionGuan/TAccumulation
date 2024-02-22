using FlowCanvas;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断目标单位芯核数量\nCompareCoreNum(core)")]
    public class FCCompareCoreNum : FlowCondition
    {
        [GatherPortsCallback]
        public ECoreCompareOperator coreCompareOperator;
        private ValueInput<int> _viCoreNum;
        private ValueInput<Actor> _viTarget;

        protected override void _OnAddPorts()
        {            
            _viTarget = AddValueInput<Actor>("Target");
            if(coreCompareOperator != ECoreCompareOperator.MaxEqualTo)
                _viCoreNum = AddValueInput<int>("CoreNum");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viTarget.GetValue();
            if (actor == null || actor.attributeOwner == null)
                return false;

            if (actor.type != ActorType.Monster)
                return false;
            
            var weakNum = actor.attributeOwner.GetAttrValue(AttrType.WeakPoint);
            if (coreCompareOperator == ECoreCompareOperator.MaxEqualTo)
            {
                if ((int) weakNum == actor.monsterCfg.ShieldMax)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }

            LogProxy.LogFormat("【判断目标单位芯核数量】: weakNum:{0}, viCoreNum:{1}", weakNum, _viCoreNum.GetValue());
            if (!BattleUtil.IsCompareSize(weakNum, _viCoreNum.GetValue(), coreCompareOperator))
                return false;
            
            return true;
        }
    }
}
