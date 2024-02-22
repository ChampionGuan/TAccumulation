using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取关卡实例ID组件所在的Position\nGetLevelInsIDPos")]
    public class FAGetLevelInsIDPos : FlowAction
    {
        public BBGetLevelInsIDPos getLevelInsIdPos = new BBGetLevelInsIDPos();
        protected override void _Invoke()
        {
            getLevelInsIdPos?.UpdatePos();
        }
    }
}
