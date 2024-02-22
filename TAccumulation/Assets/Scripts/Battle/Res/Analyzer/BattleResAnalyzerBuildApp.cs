using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public enum BuildResIDType
    {
        level,
        girlSuit,
        boySuit,
        weaponSkin,
        skill,
        buff,
    }

    public class BattleResAnalyzerBuildApp : ResAnalyzer
    {
        private BuildAppAnalyzePars _pars;
        private Dictionary<BuildResIDType, Dictionary<int, Dictionary<BattleResType, List<string>>>> _idResult;

        public BuildAppAnalyzePars pars => _pars;

        public Dictionary<BuildResIDType, Dictionary<int, Dictionary<BattleResType, List<string>>>> idResult =>
            _idResult;

        public override int ResID => 0;


        public BattleResAnalyzerBuildApp(BuildAppAnalyzePars pars) : base(null)
        {
            this._pars = pars;
        }

        protected override void DirectAnalyze()
        {
            ClearCache();
            if (pars == null)
            {
                LogProxy.LogErrorFormat("{0}，启动失败，参数为空", this.GetType());
                return;
            }

            BuildAppResAnalyzeLogger logCtrl = new BuildAppResAnalyzeLogger();
            logCtrl.Register();
            try
            {
                pars.NotNull();
                foreach (var id in pars.levelIDs)
                {
                    var analyzer = new BattleLevelResAnalyzer(id, resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.level, id, analyzer);
                }

                // 分析女主套装
                foreach (var suitID in pars.girlSuitIDs)
                {
                    var analyzer = new SuitResAnalyzer(suitID, parent: resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.girlSuit, suitID, analyzer);
                }

                // 分析女主cfg
                foreach (var cfgID in pars.girlCfgIDs)
                {
                    var analyzer = new HeroResAnalyzer(cfgID, resModule);
                    analyzer.Analyze();

                    // 出包时，系统侧只关注 suidID。 所以需要把cfg对应的资源统计到对应的suitID中
                    var suitIDs = new List<int>();
                    TbUtil.GetActorSuitIDsByCfgID(cfgID, suitIDs);
                    foreach (var suitID in suitIDs)
                    {
                        if (!pars.girlSuitIDs.Contains(suitID))
                            continue;
                        AddIDResult(BuildResIDType.girlSuit, suitID, analyzer);
                    }
                }

                // 分析男主套装
                foreach (var suitID in pars.boySuitIDs)
                {
                    var analyzer = new SuitResAnalyzer(suitID, parent: resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.boySuit, suitID, analyzer);
                }

                // 分析男主cfg
                foreach (var cfgID in pars.boyCfgIDs)
                {
                    var analyzer = new HeroResAnalyzer(cfgID, resModule);
                    analyzer.Analyze();

                    // 出包时，系统侧只关注 suidID。 所以需要把cfg对应的资源统计到对应的suitID中
                    var suitIDs = new List<int>();
                    TbUtil.GetActorSuitIDsByCfgID(cfgID, suitIDs);
                    foreach (var suitID in suitIDs)
                    {
                        if (!pars.boySuitIDs.Contains(suitID))
                            continue;
                        AddIDResult(BuildResIDType.boySuit, suitID, analyzer);
                    }
                }

                foreach (var id in pars.weaponSkinIDs)
                {
                    var analyzer = new WeaponResAnalyzer(id, resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.weaponSkin, id, analyzer);
                }

                foreach (var id in pars.sKillIDs)
                {
                    var analyzer = new SkillResAnalyzer(id, 1, resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.skill, id, analyzer);
                }

                foreach (var id in pars.buffIDs)
                {
                    var analyzer = new BuffResAnalyzer(id, 1, resModule);
                    analyzer.Analyze();
                    AddIDResult(BuildResIDType.buff, id, analyzer);
                }

                foreach (var id in pars.battleTags)
                {
                    // TODO 把tag分析转条件分析
                }
            }
            catch (Exception e)
            {
                LogProxy.LogError(e);
            }
            logCtrl.UnRegister();
        }

        protected override void OnEndAnalyze()
        {
            // 生成特效声音的离线数据
            FxCfg?.Serialize();
            ClearCache();
        }

        private void AddIDResult(BuildResIDType type, int id, ResAnalyzer analyzer)
        {
            if (_idResult == null)
            {
                _idResult = new Dictionary<BuildResIDType, Dictionary<int, Dictionary<BattleResType, List<string>>>>();
            }

            if (!_idResult.TryGetValue(type, out var idResult))
            {
                idResult = new Dictionary<int, Dictionary<BattleResType, List<string>>>();
                _idResult[type] = idResult;
            }

            var newTypeResult = analyzer.GetResultInfos();
            if (!idResult.TryGetValue(id, out var typeResult))
            {
                idResult[id] = newTypeResult;
            }
            else
            {
                foreach (var resultInfo in newTypeResult)
                {
                    var resType = resultInfo.Key;
                    if (!typeResult.ContainsKey(resType))
                    {
                        typeResult[resType] = resultInfo.Value;
                    }
                    else
                    {
                        // 这里没有去重
                        typeResult[resType].AddRange(resultInfo.Value);
                    }
                }
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BattleResAnalyzerBuildApp)
            {
                return true;
            }

            return false;
        }
    }
}