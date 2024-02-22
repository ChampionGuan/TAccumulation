using System;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改Buff的模板属性—存续逻辑\nFAModifyBuffMaintainLogic")]
    public class FAModifyBuffMaintainLogic : FlowAction
    {
        [Name("BuffID")] public int buffID;
        
        [Name("层数降低刷新清除条件")] public bool StackClear;
        [Name("时长")] public BBParameter<float> time = new BBParameter<float>();
        [Name("时长修改类型")] public ModifyCfgType modifyType;

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

                buffCfg.StackClear = StackClear;
                //遗留的潜规则，目前时间配置全部取一级一层的
                BuffLevelConfig buffLevelConfig = TbUtil.LoadModifyCfg<BuffLevelConfig>(buffID, 101);
                if (buffLevelConfig != null)
                {
                    switch (modifyType)
                    {
                        case ModifyCfgType.Set:
                        {
                            buffLevelConfig.Time = time.value;
                        }
                            break;
                        case ModifyCfgType.Add:
                        {
                            buffLevelConfig.Time += time.value;
                        }
                            break;
                        case ModifyCfgType.Sub:
                        {
                            buffLevelConfig.Time -= time.value;
                        }
                            break;
                        default:
                            throw new ArgumentOutOfRangeException();
                    }
                }
                else
                {
                    switch (modifyType)
                    {
                        case ModifyCfgType.Set:
                        {
                            buffCfg.Time = time.value;
                        }
                            break;
                        case ModifyCfgType.Add:
                        {
                            buffCfg.Time += time.value;
                        }
                            break;
                        case ModifyCfgType.Sub:
                        {
                            buffCfg.Time -= time.value;
                        }
                            break;
                        default:
                            throw new ArgumentOutOfRangeException();
                    }
                }
            }
        }
    }
}