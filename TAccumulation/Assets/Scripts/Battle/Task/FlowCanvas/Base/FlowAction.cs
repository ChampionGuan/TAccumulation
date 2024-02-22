using ParadoxNotion.Design;
using Unity.Profiling;
using UnityEngine.Profiling;

namespace X3Battle
{
    [Color("bf7fff")]
    public abstract class FlowAction : BattleFlowNode
    {
#if ENABLE_PROFILER
        private string _profileStr;
        protected FlowAction()
        {
            _profileStr = ParadoxNotion.StringUtils.Intern(this.GetType().FullName + ".Invoke"); 
        }
#endif

        protected override void _OnRegisterPorts()
        {
            var o = AddFlowOutput("Out");
            AddFlowInput("In", (FlowCanvas.Flow f) =>
            {
#if ENABLE_PROFILER
                using (new ProfilerMarker(_profileStr).Auto())
                {
                    _Invoke();
                }
#else
                _Invoke();
#endif
                o.Call(f);
            });
        }

        protected virtual void _Invoke()
        {
        }
    }
}
