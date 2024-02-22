using NodeCanvas.Framework;
using PapeGames.Rendering;
using ParadoxNotion.Design;

namespace X3Battle
{
    //因为任意选定的目标可以在运行时动态修改，修改后无法获取到任意两个单位之间距离的历史信息，所以这里判断目标写死是男女主
    [Category("X3Battle/AI")]
    [Description("是否一定时间男女主保持在指定距离内")]
    public class RemainIndistanceWithinTime:BattleCondition
    {
        public BBParameter<float> distance = new BBParameter<float>();
        public BBParameter<float> time = new BBParameter<float>();

        private float _remainTime = 0f;
        private int _timerID = 0;
        private const float STickInterval = 0.5f;

        protected override void _OnGraphStart()
        {
            _remainTime = 0f;
            _timerID = _battle.battleTimer.AddTimer(this, delay:0f, tickInterval:STickInterval, repeatCount:-1, funcTick:_TickTimer);
        }
        
        protected override void _OnGraphStop()
        {
            _battle.battleTimer.Discard(this, _timerID);
        }

        protected override bool OnCheck()
        {
            return _remainTime >= time.value;
        }
        
        private void _TickTimer(int timerID, int count)
        {
            if (BattleUtil.CompareActorDistance(distance.value, _battle.actorMgr.girl, _battle.actorMgr.boy, true, true, ECompareOperator.GreaterThan))
            {
                _remainTime = 0f;
            }
            else
            {
                // 这里精度不高 
                _remainTime += STickInterval;
            }
        }
        
    }
}
