using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class ObjectPool<T> : ObjectPoolBase<T> where T : class, new()
    {
        public ObjectPool(int preloadCount = 0, Func<T> newFunc = null) : base(preloadCount, newFunc)
        {
        }

        protected override T NewIns()
        {
            var ins = _newFunc?.Invoke();
            return ins ?? new T();
        }
    }

    public class ObjectPoolBase<T>
    {
        protected HashSet<T> _searchDatas = new HashSet<T>();
        protected Stack<T> _datas = new Stack<T>();
        protected Func<T> _newFunc;

        public ObjectPoolBase(int preloadCount = 0, Func<T> newFunc = null)
        {
            _newFunc = newFunc;
            Preload(preloadCount);
        }

        /// <summary>
        /// 预加载对象
        /// </summary>
        /// <param name="count">预加载数量</param>
        public void Preload(int count)
        {
            for (int i = 0; i < count; i++)
            {
                var item = NewIns();
                _datas.Push(item);
                _searchDatas.Add(item);
            }
        }

        /// <summary>
        /// 从池中获取一个对象
        /// </summary>
        /// <returns></returns>
        public T Get()
        {
            T item;
            if (_datas.Count > 0)
            {
                item = _datas.Pop();
                _searchDatas.Remove(item);
            }
            else
            {
                item = NewIns();
            }

            return item;
        }

        /// <summary>
        /// 将一个空闲对象回池
        /// </summary>
        /// <param name="item">对象</param>
        public void Release(T item)
        {
            if (null == item)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("回池复用对象不允许未空，请注意检查！！");
                return;
            }

            if (_searchDatas.Add(item))
            {
                _datas.Push(item);
                if (item is IReset iReset)
                {
                    iReset.Reset();
                }
            }
            else
            {
                var name = item.GetType().Name;
                PapeGames.X3.LogProxy.LogErrorFormat("对象池{0}出现了重复回池的元素，相关同学代码出现了异常逻辑！", name);
            }
        }

        public void Destroy()
        {
            _newFunc = null;
            _searchDatas.Clear();
            _datas.Clear();
        }

        protected virtual T NewIns()
        {
            var ins = null == _newFunc ? default : _newFunc.Invoke();
            return ins;
        }
    }

    public interface IReset
    {
        void Reset();
    }
}
