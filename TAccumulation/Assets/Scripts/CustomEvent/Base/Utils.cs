using System;
using Unity.Profiling;
using Debug = UnityEngine.Debug;

namespace X3.CustomEvent
{
    public static class Utils
    {
        public const int MAX_STACK_DEPTH = 100;
        public static Action<object> logFatalFunc { set; private get; }
        public static Func<Delegate, ProfilerMarker?> getProfilerMarkerFunc { set; internal get; }
        public static ProfilerMarker GetPMarker = new ProfilerMarker("Event.CallList.Get()");
        public static ProfilerMarker CallInvokePMarker = new ProfilerMarker("Event.Invoke()");
        public static ProfilerMarker CallListInvokePMarker = new ProfilerMarker("Event.CallList.Invoke()");
        public static ProfilerMarker EventMgrDispatchPMarker = new ProfilerMarker("EventMgr.Dispatch()");

        public static void LogFatal(string log)
        {
            if (logFatalFunc != null)
            {
                logFatalFunc(log);
            }
            else
            {
                Debug.LogError(log);
            }
        }
    }
}