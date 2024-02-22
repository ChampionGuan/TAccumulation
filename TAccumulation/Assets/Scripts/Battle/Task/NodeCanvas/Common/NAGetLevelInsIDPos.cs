using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Action")]
    [Name("获取关卡实例ID组件所在的Postion")]
    public class NAGetLevelInsIDPos : BattleAction
    {
        public BBGetLevelInsIDPos getLevelInsIdPos = new BBGetLevelInsIDPos();
        protected override void OnExecute()
        {
            if (getLevelInsIdPos == null)
            {
                EndAction(false);
                return;
            }
            getLevelInsIdPos.UpdatePos();
            EndAction(true);
        }
    }
}
