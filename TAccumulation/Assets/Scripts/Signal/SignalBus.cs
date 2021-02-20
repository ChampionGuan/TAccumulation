using System.Collections;
using System.Collections.Generic;
using System;

namespace PapeGames.X3
{
    public class SignalBus : Singleton<SignalBus>
    {
        private Dictionary<int, BaseSignal> m_SignalDict = null;

        protected override void Init()
        {
            base.Init();
            m_SignalDict = new Dictionary<int, BaseSignal>();
        }

        protected override void UnInit()
        {
            base.UnInit();
            m_SignalDict.Clear();
        }

        public void Dispatch(int key)
        {
            GetSignal(key).Dispatch();
        }

        public void Dispatch<T>(int key, T param1)
        {
            GetSignal<T>(key).Dispatch(param1);
        }

        public void Dispatch<T1, T2>(int key, T1 param1, T2 param2)
        {
            GetSignal<T1, T2>(key).Dispatch(param1, param2);
        }

        public void Dispatch<T1, T2, T3>(int key, T1 param1, T2 param2, T3 param3)
        {
            GetSignal<T1, T2, T3>(key).Dispatch(param1, param2, param3);
        }

        public void Dispatch<T1, T2, T3, T4>(int key, T1 param1, T2 param2, T3 param3, T4 param4)
        {
            GetSignal<T1, T2, T3, T4>(key).Dispatch(param1, param2, param3, param4);
        }

        public void Dispatch<T1, T2, T3, T4, T5>(int key, T1 param1, T2 param2, T3 param3, T4 param4, T5 param5)
        {
            GetSignal<T1, T2, T3, T4, T5>(key).Dispatch(param1, param2, param3, param4, param5);
        }

        public void AddListener(int key, Action callfunc)
        {
            GetSignal(key).AddListener(callfunc);
        }

        public void AddListener<T>(int key, Action<T> callfunc)
        {
            GetSignal<T>(key).AddListener(callfunc);
        }

        public void AddListener<T1, T2>(int key, Action<T1, T2> callfunc)
        {
            GetSignal<T1, T2>(key).AddListener(callfunc);
        }

        public void AddListener<T1, T2, T3>(int key, Action<T1, T2, T3> callfunc)
        {
            GetSignal<T1, T2, T3>(key).AddListener(callfunc);
        }

        public void AddListener<T1, T2, T3, T4>(int key, Action<T1, T2, T3, T4> callfunc)
        {
            GetSignal<T1, T2, T3, T4>(key).AddListener(callfunc);
        }

        public void AddListener<T1, T2, T3, T4, T5>(int key, Action<T1, T2, T3, T4, T5> callfunc)
        {
            GetSignal<T1, T2, T3, T4, T5>(key).AddListener(callfunc);
        }

        public void AddOnce(int key, Action callfunc)
        {
            GetSignal(key).AddOnce(callfunc);
        }

        public void AddOnce<T>(int key, Action<T> callfunc)
        {
            GetSignal<T>(key).AddListener(callfunc);
        }

        public void AddOnce<T1, T2>(int key, Action<T1, T2> callfunc)
        {
            GetSignal<T1, T2>(key).AddOnce(callfunc);
        }

        public void AddOnce<T1, T2, T3>(int key, Action<T1, T2, T3> callfunc)
        {
            GetSignal<T1, T2, T3>(key).AddOnce(callfunc);
        }

        public void AddOnce<T1, T2, T3, T4>(int key, Action<T1, T2, T3, T4> callfunc)
        {
            GetSignal<T1, T2, T3, T4>(key).AddListener(callfunc);
        }

        public void AddOnce<T1, T2, T3, T4, T5>(int key, Action<T1, T2, T3, T4, T5> callfunc)
        {
            GetSignal<T1, T2, T3, T4, T5>(key).AddOnce(callfunc);
        }

        public void RemoveListener(int key, Action callfunc)
        {
            GetSignal(key).RemoveListener(callfunc);
        }

        public void RemoveListener<T>(int key, Action<T> callfunc)
        {
            GetSignal<T>(key).RemoveListener(callfunc);
        }

        public void RemoveListener<T1, T2>(int key, Action<T1, T2> callfunc)
        {
            GetSignal<T1, T2>(key).RemoveListener(callfunc);
        }

        public void RemoveListener<T1, T2, T3>(int key, Action<T1, T2, T3> callfunc)
        {
            GetSignal<T1, T2, T3>(key).RemoveListener(callfunc);
        }

        public void RemoveListener<T1, T2, T3, T4>(int key, Action<T1, T2, T3, T4> callfunc)
        {
            GetSignal<T1, T2, T3, T4>(key).RemoveListener(callfunc);
        }

        public void RemoveListener<T1, T2, T3, T4, T5>(int key, Action<T1, T2, T3, T4, T5> callfunc)
        {
            GetSignal<T1, T2, T3, T4, T5>(key).RemoveListener(callfunc);
        }

        public Signal GetSignal(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal();
                m_SignalDict.Add(key, singal);
            }
            return (Signal)singal;
        }

        public Signal<T> GetSignal<T>(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal<T>();
                m_SignalDict.Add(key, singal);
            }
            return (Signal<T>)singal;
        }

        public Signal<T1, T2> GetSignal<T1, T2>(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal<T1, T2>();
                m_SignalDict.Add(key, singal);
            }
            return (Signal<T1, T2>)singal;
        }

        public Signal<T1, T2, T3> GetSignal<T1, T2, T3>(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal<T1, T2, T3>();
                m_SignalDict.Add(key, singal);
            }
            return (Signal<T1, T2, T3>)singal;
        }

        public Signal<T1, T2, T3, T4> GetSignal<T1, T2, T3, T4>(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal<T1, T2, T3, T4>();
                m_SignalDict.Add(key, singal);
            }
            return (Signal<T1, T2, T3, T4>)singal;
        }

        public Signal<T1, T2, T3, T4, T5> GetSignal<T1, T2, T3, T4, T5>(int key)
        {
            BaseSignal singal;
            if (!m_SignalDict.TryGetValue(key, out singal))
            {
                singal = new Signal<T1, T2, T3, T4, T5>();
                m_SignalDict.Add(key, singal);
            }
            return (Signal<T1, T2, T3, T4, T5>)singal;
        }
    }
}

