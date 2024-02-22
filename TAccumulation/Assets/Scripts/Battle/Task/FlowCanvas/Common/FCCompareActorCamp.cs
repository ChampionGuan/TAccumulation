using FlowCanvas;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断两个Actor之间的阵营关系\nCompareActorCamp")]
    public class FCCompareActorCamp : FlowCondition
    {
        public FactionRelationship factionRelationship = FactionRelationship.Enemy;
        private ValueInput<Actor> _viSourceActor;
        private ValueInput<Actor> _viTargetActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
            _viTargetActor = AddValueInput<Actor>("TargetActor");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError($"请联系策划【卡宝】, 蓝图{this._graphOwner.name}中节点【判断两个Actor之间的阵营关系 CompareActorCamp】参数配置错误, SourceActor==null, 条件永远返回false");
                return false;
            }

            var targetActor = _viTargetActor.GetValue();
            if (targetActor == null)
            {
                _LogError($"请联系策划【卡宝】, 蓝图{this._graphOwner.name}中节点【判断两个Actor之间的阵营关系 CompareActorCamp】参数配置错误, TargetActor==null, 条件永远返回false");
                return false;
            }

            var result = sourceActor.GetFactionRelationShip(targetActor);
            return result == factionRelationship;
        }
    }
}
