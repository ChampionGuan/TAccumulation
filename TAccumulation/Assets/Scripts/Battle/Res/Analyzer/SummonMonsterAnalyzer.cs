using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 召唤物解析
    /// </summary>
    public class SummonMonsterAnalyzer: ResAnalyzer
    {
        private int _summonCreatureID;
        public override int ResID => _summonCreatureID;

        public SummonMonsterAnalyzer(ResModule parent, int summonMonsterID) : base(parent)
        {
            _summonCreatureID = summonMonsterID;
        }

        protected override void DirectAnalyze()
        {
            var battleSummon = TbUtil.GetCfg<BattleSummon>(_summonCreatureID);
            if (battleSummon == null)
            {
                return;
            }
            var monsterCfg = TbUtil.GetCfg<MonsterCfg>(battleSummon.Template);
            if (monsterCfg == null)
            {
                return;
            }
            
            ActorCfg actorCfg = null;
            
            // DONE: 构建BornCfg, ActorCfg
            if (monsterCfg.CreatureType == CreatureType.Substitute)
            {
                BattleArg arg = BattleEnv.StartupArg;
                if (arg != null)
                {
                    if (monsterCfg.CopyTargetType == TargetType.Boy)
                    {
                        if (TbUtil.TryGetCfg(arg.boyID, out BoyCfg boyCfg))
                        {
                            actorCfg = boyCfg;
                        }
                    }
                    else if (monsterCfg.CopyTargetType == TargetType.Girl)
                    {
                        if (TbUtil.TryGetCfg(arg.girlID, out HeroCfg girlCfg))
                        {
                            actorCfg = girlCfg;
                        }
                    }
                }
                // TODO 如果是Monster类型
                
                resModule.AddResultByPath(monsterCfg.CreatureMaterial, BattleResType.Material);
                
                // DONE: 召唤物按全场最大数量进行分析.
                for (int i = 0; i < battleSummon.MaxNum; i++)
                {
                    var actorResAnalyzer = new ActorResAnalyzer(resModule, monsterCfg);
                    actorResAnalyzer.Analyze();
                }
            }
            else
            {
                actorCfg = monsterCfg;
            }

            if (actorCfg != null)
            {
                // DONE: 召唤物按全场最大数量进行分析.
                for (int i = 0; i < battleSummon.MaxNum; i++)
                {
                    // 这里需要的是分身的模型（男主或者女主，怪物等），不需要技能,武器信息
                    var actorResAnalyzer = new ActorResAnalyzer(resModule, actorCfg);
                    actorResAnalyzer.Analyze();
                }
            }
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is SummonMonsterAnalyzer analyzer)
            {
                return analyzer._summonCreatureID == _summonCreatureID;
            }

            return false;
        }
    }
}