using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class BattleTimer : ECComponent
    {
        // 无效ID
        public const int INVALID_ID = 0;
        
        private int _uniqueID;
        private IDeltaTime _owner;
        private Dictionary<TimerTickMode, List<Timer>> _timersMap;
        private List<Timer> _cachedTimers;
        private List<Timer> _removedTimers;

        public BattleTimer(IDeltaTime owner, int type) : base(type)
        {
            _owner = owner;
            _uniqueID = 1000;
            _timersMap = new Dictionary<TimerTickMode, List<Timer>>();
            _timersMap.Add(TimerTickMode.Update, new List<Timer>(10));
            _timersMap.Add(TimerTickMode.LateUpdate, new List<Timer>(10));
            _cachedTimers = new List<Timer>(10);
            for (int i = 0; i < 10; i++)
            {
                _cachedTimers.Add(new Timer());
            }
            _removedTimers = new List<Timer>(10);
            requiredLateUpdate = true;
        }

        protected override void OnUpdate()
        {
            _TickTimers(_timersMap[TimerTickMode.Update]);
        }

        private void _TickTimers(List<Timer> timers)
        {
            int count = timers.Count;
            for (int i = 0; i < count; i++)
            {
                _Tick(timers[i], _owner.deltaTime);
            }

            for (int i = _removedTimers.Count - 1; i >= 0; i--)
            {
                Timer timer = _removedTimers[i];
                if (timers.Remove(timer))
                {
                    _cachedTimers.Add(timer);
                    _removedTimers.Remove(timer);
                }
                
            }
        }

        protected override void OnLateUpdate()
        {
            _TickTimers(_timersMap[TimerTickMode.LateUpdate]);
        }

        public bool IsTimerOver(int id)
        {
            var time = _GetTimer(id, out _);
            return null == time || _removedTimers.Contains(time);
        }

        /// <summary>
        /// 创建倒计时
        /// </summary>
        /// <param name="owner"></param> 宿主
        /// <param name="delay"></param> 延时 （单位：秒）
        /// <param name="tickInterval"></param> 更新间隔  （<=0:每帧更新; >0:按间隔更新，单位秒）
        /// <param name="repeatCount"></param> 重复次数（小于0：无限次，大于0：次数）
        /// <param name="description"></param> 描述
        /// <param name="funcStart"></param> 开始回调
        /// <param name="funcTick"></param> 更新回调
        /// <param name="funcComplete"></param> 结束回调
        /// <returns></returns>
        public int AddTimer(object owner, float delay = 0, float tickInterval = 1, int repeatCount = 1, string description = null, Action<int> funcStart = null, Action<int, int> funcTick = null, Action<int> funcComplete = null, TimerTickMode tickMode = TimerTickMode.Update)
        {
            int id = ++_uniqueID;
            return _AddTimer(owner, id, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete, tickMode);
        }

        /// <summary>
        /// 创建倒计时待Id
        /// </summary>
        /// <param name="owner"></param> 宿主
        /// <param name="id"></param> 计时器id
        /// <param name="delay"></param> 延时 （单位：秒）
        /// <param name="tickInterval"></param> 更新间隔  （<=0:每帧更新; >0:按间隔更新，单位秒）
        /// <param name="repeatCount"></param> 重复次数（小于0：无限次，大于0：次数）
        /// <param name="description"></param> 描述
        /// <param name="funcStart"></param> 开始回调
        /// <param name="funcTick"></param> 更新回调
        /// <param name="funcComplete"></param> 结束回调
        /// <returns></returns>
        public int AddTimer(object owner, int id, float delay = 0, float tickInterval = 1, int repeatCount = 1, string description = null, Action<int> funcStart = null, Action<int, int> funcTick = null, Action<int> funcComplete = null, TimerTickMode tickMode = TimerTickMode.Update)
        {
            Timer timer = _GetTimer(id, out TimerTickMode originalTickMode);
            if (timer == null)
            {
                return _AddTimer(owner, id, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete, tickMode);
            }
            if (originalTickMode != tickMode)
            {
                _timersMap[originalTickMode].Remove(timer);
                _timersMap[tickMode].Add(timer);
            }
            timer.Reset(owner, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete);
            return id;
        }

        /// <summary>
        /// 销毁
        /// </summary>
        /// <param name="owner"></param> 宿主
        /// <param name="id"></param>
        public void Discard(object owner, int id = INVALID_ID)
        {
            if (owner == null && id == INVALID_ID)
                return;
            foreach (var _timersItem in _timersMap)
            {
                foreach (Timer timer in _timersItem.Value)
                {
                    if (_TimerIsMatch(timer, owner, id))
                    {
                        _RemoveTimer(timer);
                    }
                }
            }
        }

        /// <summary>
        /// 暂停
        /// </summary>
        /// <param name="owner"></param> 宿主
        /// <param name="id"></param> timer id
        /// <param name="paused"></param>是否暂停
        public void Pause(object owner, int id, bool paused)
        {
            if (owner == null && id == INVALID_ID)
            {
                return;
            }
            
            foreach (var _timersItem in _timersMap)
            {
                foreach (Timer timer in _timersItem.Value)
                {
                    if (_TimerIsMatch(timer, owner, id))
                    {
                        timer.paused = paused;
                    }
                }
            }
        }

        private bool _TimerIsMatch(Timer timer, object owner, int id)
        {
            return owner != null && timer.owner == owner || timer.id == id;
        }

        private int _AddTimer(object owner, int id, float delay, float tickInterval, int repeatCount, string description, Action<int> funcStart, Action<int, int> funcTick, Action<int> funcComplete, TimerTickMode tickMode)
        {
            using (ProfilerDefine.BattleTimerAddTimer1Marker.Auto())
            {
                Timer timer;
                if (_cachedTimers.Count > 0)
                {
                    timer = _cachedTimers[0];
                    _cachedTimers.RemoveAt(0);
                    timer.id = id;
                    timer.Reset(owner, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete);
                }
                else
                {
                    timer = new Timer(id, owner, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete);
                }
                _timersMap[tickMode].Add(timer);
                return id;
            }
        }

        private void _Tick(Timer timer, float delta)
        {
            if (timer == null || timer.paused)
            {
                return;
            }

            timer.delay -= delta;
            if (!(timer.delay < 0)) return;

            if (!timer.start)
            {
                timer.funcStart?.Invoke(timer.id);
                timer.start = true;
            }

            timer.leftTickInterval -= delta;
            if (!(timer.leftTickInterval <= 0)) return;

            timer.hasRepeatCount += 1;
            timer.funcTick?.Invoke(timer.id, timer.hasRepeatCount);

            if (timer.repeatCount < 0 || timer.repeatCount - timer.hasRepeatCount > 0)
            {
                timer.leftTickInterval = timer.tickInterval;
            }
            else
            {
                timer.funcComplete?.Invoke(timer.id);
                Discard(timer.owner, timer.id);
            }
        }

        private void _RemoveTimer(Timer timer)
        {
            if (timer == null || _removedTimers.Contains(timer))
            {
                return;
            }

            timer.paused = true;
            _removedTimers.Add(timer);
        }

        private Timer _GetTimer(int id, out TimerTickMode tickMode)
        {
            foreach (var _timersItem in _timersMap)
            {
                foreach (Timer timer in _timersItem.Value)
                {
                    if (timer.id == id)
                    {
                        tickMode = _timersItem.Key;
                        return timer;
                    }
                }
            }
            tickMode = TimerTickMode.Update;
            return null;
        }

        protected override void OnDestroy()
        {
            _timersMap.Clear();
            _removedTimers.Clear();
        }

        public class Timer
        {
            public int id;
            public object owner;
            public bool paused;
            public string description;
            public bool start;
            public float delay;
            public float? tickInterval;
            public float? leftTickInterval;
            public int repeatCount;
            public int hasRepeatCount;
            public Action<int> funcStart;
            public Action<int, int> funcTick;
            public Action<int> funcComplete;
            
            public Timer(){}

            public Timer(int id, object owner, float delay, float tickInterval, int repeatCount, string description, Action<int> funcStart, Action<int, int> funcTick, Action<int> funcComplete)
            {
                this.id = id;
                Reset(owner, delay, tickInterval, repeatCount, description, funcStart, funcTick, funcComplete);
            }

            public void Reset(object owner, float delay, float tickInterval, int repeatCount, string description, Action<int> funcStart, Action<int, int> funcTick, Action<int> funcComplete)
            {
                this.owner = owner;
                this.start = false;
                this.paused = false;
                this.delay = delay;
                this.tickInterval = tickInterval;
                this.leftTickInterval = tickInterval;
                this.repeatCount = repeatCount;
                this.hasRepeatCount = 0;
                this.description = description;
                this.funcStart = funcStart;
                this.funcTick = funcTick;
                this.funcComplete = funcComplete;
            }
        }
    }
}