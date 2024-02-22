using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("发起关卡缓动时间\nSetLevelSlowTime")]
    public class FALevelBulletTime : FlowAction
    {
        private FlowOutput _triggered;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _triggered = AddFlowOutput("Triggered");
        }

        protected override void _Invoke()
        {
            // DONE: 设置时缓.
            Battle.Instance.SetTimeScale(TbUtil.battleConsts.BattleEndScaler, TbUtil.battleConsts.BattleEndDuration, (int)LevelTimeScaleType.Bullet);
            Battle.Instance.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _OnScalerChange, "FALevelBulletTime._OnScalerChange");
        }
        
        private void _OnScalerChange(EventScalerChange eventScalerChange)
        {
            if (!(eventScalerChange.timeScalerOwner is Battle))
            {
                return;
            }

            var key = (int)LevelTimeScaleType.Bullet;
            if (!eventScalerChange.changeDatas.ContainsKey(key))
            {
                return;
            }

            if (eventScalerChange.changeDatas[key] != 1f)
            {
                return;
            }
            
            Battle.Instance.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _OnScalerChange);
            _triggered?.Call(new Flow());
        }
    }
}
