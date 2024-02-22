using System.Collections.Generic;

namespace X3Battle
{
    public class SharedFlagSet
    {
        private Dictionary<int, SharedFlag> _datas;

        public SharedFlagSet()
        {
            _datas = new Dictionary<int, SharedFlag>();
        }
        
        // 添加
        public void Acquire(object owner, int key)
        {
            _datas.TryGetValue(key, out var shareFlag);
            if (shareFlag == null)
            {
                shareFlag = new SharedFlag();
                _datas.Add(key, shareFlag);
            }
            shareFlag.Acquire(owner);
        }
        
        // 移除
        public void Remove(object owner, int key)
        {
            _datas.TryGetValue(key, out var owners);
            if (owners != null)
            {
                owners.Remove(owner);
            }
        }

        // 是否活跃
        public bool IsActive(int key)
        {
            _datas.TryGetValue(key, out var owners);
            if (owners != null)
            {
                var isActive = owners.IsActive();
                return isActive;
            }
            return false;
        }

        // 清理
        public void Clear()
        {
            foreach (var iter in _datas)
            {
                iter.Value.Clear();
            }
        }
    }
}