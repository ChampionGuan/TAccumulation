using System;
using System.Linq;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改Buff的模板属性—DamageBoxID\nFAModifyBuffDamageBoxID")]
    public class FAModifyBuffDamageBoxID : FlowAction
    {
        [Name("BuffID")] public int buffID;

        [Name("DamageBoxID")] public int damageBoxID;
        [Name("层数")] public int layer  = 0;

        protected override void _Invoke()
        {
            if (buffID > 0)
            {
                var buffCfg = TbUtil.LoadModifyCfg<BuffCfg>(buffID);
                if (buffCfg == null)
                {
                    LogProxy.LogError($"{buffID} buff 配置获取错误");
                    return;
                }

                LayersData layerData = null;
                if (layer <= 0)
                {
                    layer = 1;
                }
                
                //如果是中途添加的层数数据
                if (layer > buffCfg.LayersDatas.Count)
                {
                    buffCfg.LayersDatas.AddRange(Enumerable.Repeat<LayersData>(null,layer-buffCfg.LayersDatas.Count));
                }

                if (buffCfg.LayersDatas[layer - 1] == null)
                {
                    buffCfg.LayersDatas[layer - 1] = buffCfg.GetLayerData(layer).Clone();
                }
                buffCfg.LayersDatas[layer - 1].DamageBoxID = damageBoxID;

            }
        }
    }
}