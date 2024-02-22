using System;
using ParadoxNotion.Design;
using Unity.Profiling;
using UnityEngine.Profiling;

namespace X3Battle
{
    [Color("bf7fff")]
    public abstract class FlowCondition : BattleFlowNode
    {
#if ENABLE_PROFILER
        private string _profileStr;
        protected FlowCondition()
        {
            _profileStr = ParadoxNotion.StringUtils.Intern(this.GetType().FullName + "._IsMeetCondition");
        }
#endif

        protected sealed override void _OnRegisterPorts()
        {
            AddValueOutput<bool>("Result", () =>
            {
#if ENABLE_PROFILER
                using (new ProfilerMarker(_profileStr).Auto())
                {
                    bool result = _IsMeetCondition();
                    return result;
                }

#else
                bool result = _IsMeetCondition();
                                return result;
#endif

            });
            _OnAddPorts();
        }

        protected virtual void _OnAddPorts()
        {
        }

        protected abstract bool _IsMeetCondition();
    }
}
