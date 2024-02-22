using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("检测ActorAI状态")]
    [Name("CheckActorAIStatus")]
    public class CheckActorAIStatus : BattleCondition
    {
        public BBParameter<ActorAIStatus[]> valueB = new BBParameter<ActorAIStatus[]>();

        private ActorAIContext _aiContext;

        protected override string info => "Actor AI 状态 == " + valueB;

        protected override void _OnGraphStart()
        {
            _aiContext = _context as ActorAIContext;
        }
        
        protected override bool OnCheck()
        {
            if (null == _aiContext) return false;
            return Array.IndexOf(valueB.value, _aiContext.status) >= 0;
        }
    }
}
