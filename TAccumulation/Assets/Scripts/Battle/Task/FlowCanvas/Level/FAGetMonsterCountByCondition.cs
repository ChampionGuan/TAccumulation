using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("获取关卡局内指定条件的怪物数量\nGetCustomTypeMonsterNumInLevel")]
    public class FAGetMonsterCountByCondition : FlowAction
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        public BBParameter<int> monsterTemplateId = new BBParameter<int>();
        public BBParameter<LevelMonsterMode> mode = new BBParameter<LevelMonsterMode>();
        private int _count;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            AddValueOutput<int>("number", () => _count);
        }

        protected override void _Invoke()
        {
            _count = _battle.actorMgr.GetMonstersByCondition(mode.value, groupId.value, monsterTemplateId.value);
            LogProxy.LogFormat("【获取关卡局内指定条件的怪物数量】 _count: {0}", _count);
        }
    }
}
