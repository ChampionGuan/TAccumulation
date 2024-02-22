using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("从群体策略中去掉或恢复某个单位\nFAEnableActorStrategy")]
    [Description("从群体策略中去掉或恢复某个单位")]
    public class FAEnableActorStrategy : FlowAction
    {
        [Name("开启群体策略AI")] public bool enable;
        [Name("SpawnID")]
        public BBParameter<int> UID = new BBParameter<int>();
        public BBParameter<int> groupID = new BBParameter<int>();
        [Name("MonsterTemplateID")]
        public BBParameter<int> templateID = new BBParameter<int>();

        private List<Actor> _monsterList = new List<Actor>(5);

        protected override void _Invoke()
        {
            _monsterList.Clear();
            _battle.actorMgr.GetMonstersByCondition(LevelMonsterMode.Alive, groupID.value, templateID.value, -1, _monsterList);
            foreach (var monster in _monsterList)
            {
                if (UID.value >= 0 && monster.spawnID == UID.value)
                {
                    monster.aiOwner?.SetIsStrategy(enable);
                }
            }
            _monsterList.Clear();
        }
    }
}
