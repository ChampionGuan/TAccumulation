using System;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Event")]
    public abstract class FlowEvent : BattleFlowNode
    {
        protected FlowOutput _triggeredOutput;
        protected bool _isRegisterEvent;
        protected bool _isTriggering { get; private set; }
        
        protected override void _OnRegisterPorts()
        {
            _triggeredOutput = AddFlowOutput("Triggered");
            _OnAddPorts();
        }

        protected sealed override void _OnPostGraphStarted()
        {
            base._OnPostGraphStarted();
            this._TryRegisterEvent();
        }

        protected sealed override void _OnPostGraphStoped()
        {
            base._OnPostGraphStoped();
            this._TryUnregisterEvent();
        }

        protected void _TryRegisterEvent()
        {
            if (_isRegisterEvent)
                return;
            _isRegisterEvent = true;
            _RegisterEvent();
        }

        protected void _TryUnregisterEvent()
        {
            _isTriggering = false;
            if (!_isRegisterEvent)
                return;
            _isRegisterEvent = false;
            _UnRegisterEvent();
        }

        protected virtual void _OnAddPorts()
        {
        }

        protected abstract void _RegisterEvent();
        protected abstract void _UnRegisterEvent();
        
        protected void _Trigger()
        {
            if (_isTriggering)
            {
                return;
            }
            
            _isTriggering = true;
            _triggeredOutput.Call(new FlowCanvas.Flow());
            _isTriggering = false;
        }
        
        protected bool _IsMainObject(EEventTarget eEventTarget, object testObj)
        {
            switch (eEventTarget)
            {
                case EEventTarget.All:
                    return true;
                case EEventTarget.Self:
                    if (testObj == this._actor)
                        return true;
                    break;
                case EEventTarget.Girl:
                    if (testObj == Battle.Instance.actorMgr.girl)
                        return true;
                    break;
                case EEventTarget.Boy:
                    if (testObj == Battle.Instance.actorMgr.boy)
                        return true;
                    break;
                case EEventTarget.Stage:
                    if (testObj == Battle.Instance.actorMgr.stage)
                        return true;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            return false;
        }
    }
}
