using System;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;
using PapeGames.X3;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;
using UnityEngine.Profiling;


namespace X3Battle{

    [Category("Battle")]
    [Description(@"自动事件检查器
事件触发时会强制检查过渡条件，如果条件满足则直接过度到目标状态")]
    public class AutoEventChecker : ConditionTask<GraphOwner>, IFSMCondition
    {
        [RequiredField]
        public BBParameter<string> eventName = new BBParameter<string>();

        protected override string info { get { return "<color=yellow>auto-[" + eventName.ToString() + "]</color>"; } }

        public FSMConnection connection { get; set; }

        private Action<string, IEventData>_delegate = null;

        public override void OnValidate(ITaskSystem ownerSystem)
        {
            if (_delegate == null)
            {
                _delegate = OnCustomEvent;
            }
            
            base.OnValidate(ownerSystem);
            
            LogProxy.LogErrorFormat("AutoEventChecker(eventName={0}, gameObject={1})已废弃，请使用FSMConnection.triggerEvents!", eventName, (ownerSystem.contextObject as FSM).name);
        }

        protected override void OnEnable()
        {
            using (ProfilerDefine.OnCustomEventOnEnablePMarker.Auto())
            {
                router.onCustomEvent += _delegate;
            }
        }
        protected override void OnDisable()
        {
            using (ProfilerDefine.OnCustomEventOnDisablePMarker.Auto())
            {
                router.onCustomEvent -= _delegate;
            }
        }

        protected override bool OnCheck() { return false; }

        void OnCustomEvent(string eventName, IEventData data)
        {
            using (ProfilerDefine.OnCustomEventPMarker.Auto())
            {
                bool b = false;
                using (ProfilerDefine.OnCustomEvent1PMarker.Auto())
                {
                    b = eventName.Equals(this.eventName.value, System.StringComparison.OrdinalIgnoreCase);
                }
                if (b)
                {
                    using (ProfilerDefine.OnCustomEvent2PMarker.Auto())
                    {
                        YieldReturn(true);
                    }
                    using (ProfilerDefine.OnCustomEvent3PMarker.Auto())
                    {
                        TryCheckFSMTransitions();
                    }
                }
            }
        }

        protected void TryCheckFSMTransitions()
        {
        }
    }

}
