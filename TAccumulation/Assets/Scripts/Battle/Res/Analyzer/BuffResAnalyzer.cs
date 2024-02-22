using System.Collections.Generic;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;

namespace X3Battle
{
    public class BuffResAnalyzer : ResAnalyzer
    {
        private int _buffID;
        private HashSet<int> _sBuffFxDistinctCache = new HashSet<int>();
        public override int ResID => _buffID;

        public BuffResAnalyzer(int buffID, int buffLevel = 1, ResModule parent=null) : base(parent)
        {
            _buffID = buffID;
        }

        protected override void DirectAnalyze()
        {
            if (_buffID == 0)
            {
                return;
            }
            
            BuffCfg buffCfg = TbUtil.GetCfg<BuffCfg>(_buffID);
            if (buffCfg == null)
            {
                return;
            }

            _sBuffFxDistinctCache.Clear();
            foreach (var item in buffCfg.LayersDatas)
            {
                //TODO ,优化
                foreach (var fxID in item.FxIDList)
                {
                    if (fxID != 0)
                    {
                        _sBuffFxDistinctCache.Add(fxID);
                    }
                }

                if (item.DamageBoxID > 0)
                {
                    var damageBoxAnalyze = new DamageBoxAnalyzer(resModule, item.DamageBoxID);
                    damageBoxAnalyze.Analyze();
                }
            }

            foreach (var fxID in _sBuffFxDistinctCache)
            {
                resModule.AddResultByFxId(fxID);
            }
            
            ResAnalyzeUtil.AnalyzeIcon(resModule,buffCfg.BuffIcon);

            ResModule triggerResModule = resModule.AddChild("Trigger");
            if (buffCfg.Triggers != null)
            {
                foreach (var trigger in buffCfg.Triggers)
                {
                    var triggerAnalyzer = new TriggerAnalyzer(triggerResModule, trigger.ID);
                    triggerAnalyzer.Analyze();
                }
            }

            //buffAction依赖的资源
            foreach (var action in buffCfg.BuffActions)
            {
                if (action is BuffActionHalo actionHalo)
                {
                    var haloAnalyzer = new HaloAnalyzer(resModule, actionHalo.HaloID);
                    haloAnalyzer.Analyze();
                }

                if (action is BuffEndDamage actionHaloEndDamage)
                {
                    var damageBoxAnalyze = new DamageBoxAnalyzer(resModule, actionHaloEndDamage.damageBoxID);
                    damageBoxAnalyze.Analyze();
                }
                
                if (action is PlayMatAnim actionPlayMatAnim)
                {
                    resModule.AddResultByPath(actionPlayMatAnim.matAnimPath,BattleResType.MatCurveAsset);
                }

                if (action is BuffActionFrozen actionFrozen)
                {
                    //冰冻材质效果
                    resModule.AddResultByPath(TbUtil.battleConsts.FrozenMatEffectPath, BattleResType.MatCurveAsset);
                    resModule.AddResultByPath(TbUtil.battleConsts.RoleFrozenMatEffectPath, BattleResType.MatCurveAsset);
                    //冰冻PPV
                    if (!string.IsNullOrEmpty(TbUtil.battleConsts.Frozen_PPV))
                    {
                        var analyzer = new TimelineResAnalyzer(resModule, TbUtil.battleConsts.Frozen_PPV, BattleResType.Timeline, false, timelineTags: BattleResTag.PPVTimeline);
                        analyzer.Analyze();
                    }
                    //冰冻特效
                    resModule.AddResultByFxId(TbUtil.battleConsts.FrozenGroundFXID);
                    resModule.AddResultByFxId(TbUtil.battleConsts.IceBreakingEndFX);
                    resModule.AddResultByFxId(TbUtil.battleConsts.IceBreakingFX);
                }

                if (action is BuffActionPlayFx actionPlayFx)
                {
                    if (!_sBuffFxDistinctCache.Contains(actionPlayFx.fxID))
                    {
                        resModule.AddResultByFxId(actionPlayFx.fxID);
                        _sBuffFxDistinctCache.Add(actionPlayFx.fxID);
                    }
                }
                
                if (action is BuffActionPlayPPV actionPlayPPV)
                {
                    if (!string.IsNullOrEmpty(actionPlayPPV.path))
                    {
                        var analyzer = new TimelineResAnalyzer(resModule, actionPlayPPV.path, BattleResType.Timeline, false, timelineTags: BattleResTag.PPVTimeline);
                        analyzer.Analyze();
                    }
                }
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BuffResAnalyzer analyzer)
            {
                return analyzer._buffID == _buffID;
            }

            return false;
        }
    }
}