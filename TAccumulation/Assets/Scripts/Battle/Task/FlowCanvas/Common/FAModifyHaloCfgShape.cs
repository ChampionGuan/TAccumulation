using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改光环的模板属性—光环形状\nFAModifyHaloCfgShape")]
    public class FAModifyHaloCfgShape : FlowAction
    {
        [Name("光环ID")]
        public int haloID;
        
        [LabelText("光环形状")]
        public ShapeInfo shapeInfo = new ShapeInfo();

        protected override void _Invoke()
        {
            var targetID = haloID;
            if (targetID > 0)
            {
                var haloCfg = TbUtil.LoadModifyCfg<HaloCfg>(targetID);
                if (haloCfg != null)
                {
                    haloCfg.ShapeBoxInfo.ShapeInfo = shapeInfo.Clone();
                }
            }
        }
    }
}