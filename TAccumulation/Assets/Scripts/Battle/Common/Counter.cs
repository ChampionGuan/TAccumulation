
using System;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public enum CounterType
    {
        BattleLoad, // 资源分析阶段的资源load
        ABLoad, // XResources.LoadAsset
        Instantiate, // 资源load出之后的实例化
        SceneLoad, // 场景加载统计
        GraphCopy,
        FxCopy,
    }
    
    /// <summary>
    /// 可以对一种数据，持续统计
    /// 可以截取一个时间段内的统计
    /// </summary>
    public class Counter 
    {
        private float _startNum;
        private float _totalNum;

        public void Start()
        {
            _startNum = _totalNum;
        }

        public float End()
        {
            return _totalNum - _startNum;
        }

        public void Add(float t)
        {
            _totalNum += t;
        }

        public float Count()
        {
            return _totalNum;
        }

        public void Reset()
        {
            _totalNum = 0;
        }
    }
    
    public class BattleCounterMgr
    {
        private static BattleCounterMgr _instance;
        public static BattleCounterMgr Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new BattleCounterMgr();
                }
                return _instance;
            }
        }
        
        private Dictionary<CounterType, Counter> _counters;
        
        private IResDelegate _preDelegate;
        private IResExtensionDelegate _preResExtensionDelegate;

        public BattleCounterMgr()
        {
            _counters = new Dictionary<CounterType, Counter>();
        }

        public void Add(CounterType type, float num)
        {
            if (!_counters.TryGetValue(type, out var counter))
            {
                counter = new Counter();
                _counters[type] = counter;
            }
            counter.Add(num);
        }
        
        public void Start(CounterType type)
        {
            if (!_counters.TryGetValue(type, out var counter))
            {
                return;
            }
            counter.Start();
        }
        
        public float End(CounterType type)
        {
            if (!_counters.TryGetValue(type, out var counter))
            {
                return 0;
            }
            return counter.End();
        }
        
        public float Count(CounterType type)
        {
            if (!_counters.TryGetValue(type, out var counter))
            {
                return 0;
            }
            return counter.Count();
        }

        public void Reset(CounterType type)
        {
            if (!_counters.TryGetValue(type, out var counter))
            {
                return;
            }
            counter.Reset();
        }

        public void Clear()
        {
            _counters = new Dictionary<CounterType, Counter>();
        }
        
        public void StartResLoadCount()
        {
            _preDelegate = Res.Delegate;
            _preResExtensionDelegate = Res.ExtensionDelegate;
            Res.SetDelegate(new SceneLoadDelegate());
            Res.SetExtensionDelegate(new ResLoadDelegate());
        }
        
        public void EndResLoadCount()
        {
            Res.SetDelegate(_preDelegate);
            Res.SetExtensionDelegate(_preResExtensionDelegate);
        }
        
    }
}