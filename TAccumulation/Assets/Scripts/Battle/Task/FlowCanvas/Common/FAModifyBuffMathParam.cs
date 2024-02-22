
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改Buff的模板属性—属性模块\nFAModifyBuffRelation")]
    public class FAModifyBuffMathParam : FlowAction
    {
        [Name("BuffID")] public int buffID;
        [Name("层数")] public int layer  = 0;
        [Name("属性参数")] public List<AttrParam> attrParamsList;

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

                for (int i = 0; i < attrParamsList.Count; i++)
                {
                    var paramList = buffCfg.LayersDatas[layer - 1].AttrParamsList;
                    if (paramList.Count <= i)
                    {
                        paramList.Add(new AttrParam()
                            { AttrS = attrParamsList[i].AttrS, AttrF = (float[])attrParamsList[i].AttrF.Clone() });
                    }
                    else
                    {
                        paramList[i].AttrF = (float[])attrParamsList[i].AttrF.Clone();
                        paramList[i].AttrS = attrParamsList[i].AttrS;
                    }
                }
            }
        }
    }
}