using System;
using X3.CustomEvent;

namespace X3Battle
{
    public class ECEventMgr : EventMgr<EventType>
    {
    }

    public class ECEventDataBase : IEventData
    {
        public virtual ECEventDataBase Clone()
        {
            return null;
        }

        public virtual void OnRecycle()
        {
        }
    }

    public interface ECEventExpendParam
    {
        /// <summary>
        /// 优化，将lua端主动获取的额外参数，改到事件中带入
        /// </summary>
        void ExpendParamForLua();
    }

    public class ECMultiLayerEvent
    {
        private CustomEvent[] _arrayEvents;

        public ECMultiLayerEvent(int count = 1)
        {
            count = count < 1 ? 1 : count;
            _arrayEvents = new CustomEvent[count];
            for (var i = 0; i < count; i++)
            {
                _arrayEvents[i] = new CustomEvent();
            }
        }

        public void Add(Action action, int index = 0)
        {
            if (_VerifyIndex(index))
            {
                _arrayEvents[index].AddListener(action);
            }
        }

        public void Remove(Action action, int index = 0)
        {
            if (_VerifyIndex(index))
            {
                _arrayEvents[index].RemoveListener(action);
            }
        }

        public void Invoke()
        {
            for (var i = 0; i < _arrayEvents.Length; i++)
            {
                _arrayEvents[i].Dispatch();
            }
        }

        public void Clear()
        {
            for (var i = 0; i < _arrayEvents.Length; i++)
            {
                _arrayEvents[i].Clear();
            }
        }

        private bool _VerifyIndex(int index)
        {
            return index >= 0 && index < _arrayEvents.Length;
        }
    }
}