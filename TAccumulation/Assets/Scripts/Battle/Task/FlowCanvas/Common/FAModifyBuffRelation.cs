using System;
using System.Linq;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改Buff的模板属性—冲突关系\nFAModifyBuffRelation")]
    public class FAModifyBuffRelation : FlowAction
    {
        [Name("BuffID")] public int buffID;
        
        [Name("冲突关系")] public MutexRelationType MutexRelation;
        [Name("清楚条件")] public TimeConditionType ClearCondition;  //清除条件 
        [Name("层数叠加")] public bool MultiplyStack;  // 层数是否叠加
        [Name("最大层数")] public int MaxStack;  // 最大层数

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
                
                //如果是中途添加的层数数据
                if (MaxStack > buffCfg.LayersDatas.Count)
                {
                    buffCfg.LayersDatas.AddRange(Enumerable.Repeat<LayersData>(null,MaxStack-buffCfg.LayersDatas.Count));
                }

                buffCfg.MutexRelation = MutexRelation;
                buffCfg.ClearCondition = ClearCondition;
                buffCfg.MultiplyStack = MultiplyStack;
                buffCfg.MaxStack = MaxStack;
                

            }
        }
    }
}