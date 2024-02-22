using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活(关闭)空气墙\nActiveObstacle")]
    public class FAActiveObstacle : FlowAction
    {
        public BBParameter<int> id = new BBParameter<int>();
        public BBParameter<bool> active = new BBParameter<bool>();

        protected override void _Invoke()
        {
            Battle.Instance.actorMgr.ActiveObstacle(id.value, active.value);
            //发送空气墙状态改变事件
            var eventData = Battle.Instance.eventMgr.GetEvent<EventObstacleState>();
            eventData.Init(id.value, active.value);
            Battle.Instance.eventMgr.Dispatch(EventType.ObstacleStateChange, eventData);
        }
    }
}
