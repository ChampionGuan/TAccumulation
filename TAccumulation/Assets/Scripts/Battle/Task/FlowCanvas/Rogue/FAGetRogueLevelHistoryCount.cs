using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue/Function")]
    [Name("获取Rogue关卡中已经通过得战斗事件节点总数量\nGetRogueLevelHistoryCount")]
    public class FAGetRogueLevelHistoryCount : FlowAction
    {
        public BBParameter<RogueStageFlag> flag = new BBParameter<RogueStageFlag>(RogueStageFlag.NormalFight);
        
        protected override void _OnRegisterPorts()
        {
            AddValueOutput("Count", () =>
            {
                int count = 0;
                if (_battle.rogue?.arg?.LayerDatas != null)
                {
                    foreach (var layerData in _battle.rogue.arg.LayerDatas)
                    {
                        if (layerData.LayerID == _battle.rogue.arg.CurrentLayerData.LayerID)
                        {
                            continue;
                        }
                        
                        var battleRogueLevelConfig = TbUtil.GetCfg<BattleRogueLevelConfig>(layerData.LevelID);
                        if (battleRogueLevelConfig != null)
                        {
                            if (!BattleUtil.ContainRogueStageType(flag.value, (RogueStageType)battleRogueLevelConfig.Type))
                            {
                                continue;
                            }

                            LogProxy.LogFormat("【战斗】【Rogue】已经通过符合条件且被统计到的关卡ID: {0}", layerData.LevelID);
                            ++count;
                        }
                    }
                }
                return count;
            });
        }
    }
}