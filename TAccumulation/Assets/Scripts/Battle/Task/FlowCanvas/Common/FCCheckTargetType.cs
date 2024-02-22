using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断目标类型\nCheckTargetType")]
    public class FCCheckTargetType : FlowCondition
    {
        public enum CheckActorType
        {
            EnemyMonster,
            Boy,
            Girl,
            Creature,
            Item,
        }

        public BBParameter<CheckActorType> checkActorType = new BBParameter<CheckActorType>(CheckActorType.EnemyMonster);

        private ValueInput<Actor> _viActor;

        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override bool _IsMeetCondition()
        {
            var target = _viActor.GetValue();
            if (target == null)
            {
                _LogError("请联系策划【蜗牛君】, 节点【判断目标类型 FCCheckTargetType】引脚参数【Actor】没有正确赋值!");
                return false;
            }

            var checkType = checkActorType.GetValue();
            switch (checkType)
            {
                case CheckActorType.EnemyMonster:
                    return target.IsMonster() && target.factionType == FactionType.Monster;
                case CheckActorType.Boy:
                    return target.IsBoy();
                case CheckActorType.Girl:
                    return target.IsGirl();
                case CheckActorType.Creature:
                    return target.IsCreature();
                case CheckActorType.Item:
                    return target.IsItem();
            }
            
            return false;
        }
    }
}
