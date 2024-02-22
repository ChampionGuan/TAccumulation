using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    // 男主分析特殊之处：
    // 套装分析会分析男主的技能，武器
    // Actor分析器，不会分析男主的技能武器信息
    
    // 套装概念只有男女主才有
    public class LevelTagAnalyzer : ResAnalyzer
    {
        private List<int>  _levelTags;
        private List<int>  _scoreTags;
        private List<int> _realLevelTags;
        public LevelTagAnalyzer(List<int> levelTags, List<int> scoreTags, ResModule parent = null) : base(parent)
        {
            _levelTags = levelTags;
            _scoreTags = scoreTags;
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is LevelTagAnalyzer analyzer)
            {
                return true;
            }
            return false;
        }

        public override int ResID { get; }

        protected override void DirectAnalyze()
        {
            ResAnalyzeUtil.AnalyzeActionModule(resModule, BattleConst.LevelBeforeCameraActionModuleId);
            bool matchSuccess = true;
            _realLevelTags = new List<int>();
            foreach (var levelTag in _levelTags)
            {
                if (!TbUtil.TryGetCfg(levelTag, out BattleTag battleTag))
                {
                    continue;
                }
                _realLevelTags.Add(levelTag);
                if (!_scoreTags.Contains(levelTag))
                {
                    matchSuccess = false;
                    break;
                }
            }
            if (_realLevelTags.Count == 0)
            {
                return;
            }
        }
        
    }
}