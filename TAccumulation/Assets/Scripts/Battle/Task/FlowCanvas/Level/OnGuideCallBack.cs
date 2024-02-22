
using System;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("新手引导事件监听器\nListener:StartGuideEvent")]
    public class OnGuideCallBack : FlowListener
    {
        public BBParameter<string> eventName = new BBParameter<string>();

        private Action<EventGuide> _actionGuideCallBack;

        public OnGuideCallBack()
        {
            _actionGuideCallBack = _OnGuide;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventGuide>(EventType.GuideCallBack, _actionGuideCallBack, "OnGuideCallBack._OnGuide");
            LogProxy.LogFormat("【新手引导】【新手引导事件监听器】Graph:{0}, 监听新手引导事件={1}", this._graphOwner.name, eventName.value);
        }

        private void _OnGuide(EventGuide arg)
        {
            if (IsReachMaxCount())
                return;
            if (eventName.value == arg.eventName)
            {
                LogProxy.LogFormat("【新手引导】【新手引导事件监听器】Graph:{0}, 触发引导事件={1}", this._graphOwner.name, eventName.value, eventName.value);
                _Trigger();
            }
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventGuide>(EventType.GuideCallBack, _actionGuideCallBack);
            LogProxy.LogFormat("【新手引导】【新手引导事件监听器】Graph:{0}, 移除新手引导事件={1}", this._graphOwner.name, eventName.value);
        }
    }
}
