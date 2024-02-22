Profiler.SetEnable( UNITY_EDITOR or Debug.IsDebugBuild()  or CS.UnityEngine.Profiling.Profiler.enabled)
Profiler.SetEngineProfiler(CS.UnityEngine.Profiling.Profiler)
if Profiler.IsEnabled() then
    Profiler.SetLuaProfiler(require("Runtime.Common.BuildIn.perf.profiler"), string.concat(CS.UnityEngine.Application.persistentDataPath, "/luaProfilerReport.txt"))
end
CS.UnityEngine.Profiling.Profiler = Profiler