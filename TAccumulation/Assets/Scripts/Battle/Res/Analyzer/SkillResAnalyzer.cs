using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class SkillResAnalyzer : ResAnalyzer
    {
        private int _skillID;
        private int _skillLevel;
        public override int ResID => _skillID;
        public SkillResAnalyzer(int skillID, int skillLevel, ResModule parent=null) : base(parent)
        {
            _skillID = skillID;
            _skillLevel = skillLevel;
        }

        protected override void DirectAnalyze()
        {
            var skillCfg = TbUtil.GetCfg<SkillCfg>(_skillID);
            if (skillCfg == null)
            {
                LogProxy.LogErrorFormat("技能分析器分析失败，skillID：{0} 不存在", _skillID);
                return;
            }
            
            var skillLevelCfg = TbUtil.GetSkillLevelCfg(_skillID, _skillLevel);
            
            //技能图片分析
            if (skillLevelCfg != null)
            {
                ResAnalyzeUtil.AnalyzeIcon(resModule, skillLevelCfg.SkillIcon);
            }
            
            if (skillCfg.ReleaseType == SkillReleaseType.Passive)
            {
                // 被动技资源分析 
                _AnalyzePassive(skillCfg, skillLevelCfg);
            }
            else if (skillCfg.ReleaseType == SkillReleaseType.Active)
            {
                // 主动技资源分析
                _AnalyzeActive(skillCfg, skillLevelCfg);
            }
        }

        // 解析被动专属资源
        private void _AnalyzePassive(SkillCfg skillCfg, SkillLevelCfg skillLevelCfg)
        {
            // 被动技触发器资源分析
            int triggerID = 0;
            
            if (skillLevelCfg != null && skillLevelCfg.TriggerID > 0)
            {
                triggerID = skillLevelCfg.TriggerID;
            }
            else if (skillCfg.TriggerID > 0)
            {
                triggerID = skillCfg.TriggerID;
            }

            if (triggerID > 0)
            {
                var triggerAnalyzer = new TriggerAnalyzer(resModule, triggerID);
                triggerAnalyzer.Analyze();   
            }
                
            // 被动技buff资源分析
            // DONE: 先读取表里的BuffID, 再读取编辑器里配置的BuffID.
            List<int> buffIds = new List<int>();
            if (skillLevelCfg?.BuffIDs != null && skillLevelCfg.BuffIDs.Length > 0)
            {
                foreach (int buffID in skillLevelCfg.BuffIDs)
                {
                    buffIds.Add(buffID);
                }
            }
            else if (skillCfg.BuffIDs != null && skillCfg.BuffIDs.Count > 0)
            {
                foreach (int buffID in skillCfg.BuffIDs)
                {
                    buffIds.Add(buffID);
                }
            }

            // 被动技能的buff.
            foreach (var buffID in buffIds)
            {
                ResAnalyzeUtil.AnalyzeBuff(resModule, buffID);
            }
        }

        // 解析主动专属资源
        private void _AnalyzeActive(SkillCfg skillCfg, SkillLevelCfg skillLevelCfg)
        {
            // 动作模组
            if (skillCfg.ActionModuleIDs != null)
            {
                foreach (var actionModuleID in skillCfg.ActionModuleIDs)
                {
                    ResAnalyzeUtil.AnalyzeActionModule(resModule, actionModuleID, BattleResTag.BeforeBrokenShirt);
                }
            }
            
            // 爆衣动作模组
            if (skillCfg.BrokenShirtActionModuleIDs != null)
            {
                foreach (var actionModuleID in skillCfg.BrokenShirtActionModuleIDs)
                {
                    ResAnalyzeUtil.AnalyzeActionModule(resModule, actionModuleID, BattleResTag.AfterBrokenShirt);
                }
            }
            
            // 主动技上的位移特效
            if ((skillCfg.Type == SkillType.MaleActive || skillCfg.Type == SkillType.EXMaleActive) && skillCfg.ActiveSkillTransport)
            {
                resModule.AddResultByFxId(skillCfg.PreTransportFX);
                resModule.AddResultByFxId(skillCfg.PostTransportFX);
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is SkillResAnalyzer analyzer)
            {
                return analyzer._skillID == _skillID;
            }
            return false;
        }
    }
}