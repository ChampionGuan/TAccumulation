using UnityEngine;

namespace X3Battle
{
    public class TriggerLevelContext : TriggerContext
    {
        public override float deltaTime => battle.deltaTime;
        public override Transform parent => battle.root;
        
        public override object creater => battle.levelFlow;

        public TriggerLevelContext(Battle battle) : base(battle)
        {
            
        }
    }
}