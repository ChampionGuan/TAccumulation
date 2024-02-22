namespace X3Battle
{
    public static class ResAnalyzeEnv
    {
        public static void TryInitResAnalyzeEnv(AnalyzeRunEnv env = AnalyzeRunEnv.BuildApp)
        {
            BattleEnv.StartupArg = null;
            if (env == AnalyzeRunEnv.BranchMerge)
            {
                // 分支合并时 需要分析出动态依赖的，由编辑器生成的配置，例如，技能，buff等
                // 这里卸载掉所有的配置，分析时load的配置，即代表分析的配置
                TbUtil.UnInit();
            }
            BattleResMgr.Instance.TryInit();
            ResAnalyzer.ClearCache();
            ResAnalyzer.AnalyzeRunEnv = env;
        }

        public static void TryUnInitResAnalyzeEnv()
        {
            BattleResMgr.Instance.TryUninit();
            BattleEnv.LuaBridge?.DestroyBattle();
            ResAnalyzer.ClearCache();
        }
    }
}