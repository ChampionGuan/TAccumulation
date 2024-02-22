using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改道具的模板属性—生效筛选类型\nFAModifyItemCfgFilter")]
    public class FAModifyItemCfgFilter : FlowAction
    {
        [Name("道具ID")]
        public int itemID;

        [Name("修改类型")]
        public ModifyCfgType modifyType;
        
        [Name("筛选类型")]
        public ItemFilterType fliterFlag;

        protected override void _Invoke()
        {
            var targetID = itemID;
            if (targetID > 0)
            {
                var itemCfg = TbUtil.LoadModifyCfg<ItemCfg>(targetID);
                if (itemCfg != null)
                {
                    var modifyCfgType = modifyType;
                    var filterValue = fliterFlag;
                    if (modifyCfgType == ModifyCfgType.Set)
                    {
                        itemCfg.EffectFilterType = filterValue;
                    }
                    else if(modifyCfgType == ModifyCfgType.Add)
                    {
                        itemCfg.EffectFilterType |= filterValue;
                    }
                    else if (modifyCfgType == ModifyCfgType.Sub)
                    {
                        itemCfg.EffectFilterType &= ~filterValue;
                    }
                }
            }
        }
    }
}