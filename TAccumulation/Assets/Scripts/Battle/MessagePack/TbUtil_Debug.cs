using System.Collections.Generic;

namespace X3Battle
{
    public static partial class TbUtil
    {
        public static Dictionary<int, BattleEditorConfig> editorRoleCfgs => GetCfgs<BattleEditorConfigs>()?.battleEditorConfigs;
        public static Dictionary<int, BattleEditorScene> editorSceneCfgs => GetCfgs<BattleEditorScenes>()?.battleEditorScenes;
        public static Dictionary<int, BuffConflictTag> editorBuffConflictTagsCfgs => GetCfgs<BuffConflictTags>()?.buffConflictTags;
        public static Dictionary<int, BattleBuffMultipleTag> editorBuffMultipleTagsCfgs => GetCfgs<BattleBuffMultipleTags>()?.battleBuffMultipleTags;
        public static Dictionary<int, BattleSkillTag> editorSkillTags => GetCfgs<BattleSkillTags>()?.battleSkillTags;
        public static Dictionary<int, EntriesTag> editorEntriesTags => GetCfgs<EntriesTags>()?.entriesTags;
        public static Dictionary<int, string> debugTextCfgs => GetCfgs<DebugTextCfgs>()?.dbgText;
        public static Dictionary<int, BattleActorShowTag> editorActorShowTags => GetCfgs<BattleActorShowTags>()?.battleActorShowTags;
        public static Dictionary<int, BattleActionTag> editorBattleActionTags => GetCfgs<BattleActionTags>()?.battleActionTags;

        /// <summary>
        /// 获取调试文本
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string GetDebugText(int id)
        {
            if (null == debugTextCfgs)
            {
                return string.Empty;
            }
        
            return debugTextCfgs.TryGetValue(id, out var value) ? value : string.Empty;
        }
    }
}
