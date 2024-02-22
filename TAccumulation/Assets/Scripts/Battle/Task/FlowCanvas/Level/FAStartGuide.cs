using System;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("引导开始\nGuideBegin")]
    public class FAStartGuide : FlowAction
    {
        private Action<string> _actionOnGuideEvent;

        public FAStartGuide()
        {
            _actionOnGuideEvent = OnGuideEvent;
        }
        
        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.TryRegisterGuideEvent(_actionOnGuideEvent);
            LogProxy.LogFormat("【新手引导】【引导开始】开始监听引导事件. Graph:{0}", this._graphOwner.name);
        }

        private void OnGuideEvent(string guideEventName)
        {
            var eventData = Battle.Instance.eventMgr.GetEvent<EventGuide>();
            eventData.Init(guideEventName);
            Battle.Instance.eventMgr.Dispatch(EventType.GuideCallBack, eventData);
        }
    }
}
