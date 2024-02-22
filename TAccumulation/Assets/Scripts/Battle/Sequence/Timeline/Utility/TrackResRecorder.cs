using System;
using System.Collections.Generic;
using PapeGames.X3;

#if UNITY_EDITOR

#endif

namespace UnityEngine.Timeline
{
    [Serializable]
    public class TrackResRecorder
    {
        public List<string> keys = new List<string>();
        public List<TrackResItem> trackRes = new List<TrackResItem>();

        // 设置资源
        public void SetRes(string key, TrackResItem resItem)
        {
            var idx = keys.IndexOf(key);
            if (idx >= 0)
            {
                keys[idx] = key;
                trackRes[idx] = resItem;
            }
            else
            {
                keys.Add(key);
                trackRes.Add(resItem);
            }
        }
        
        // 获取资源
        public TrackResItem GetRes(string key)
        {
            var idx = keys.IndexOf(key);
            if (idx >= 0)
            {
                return trackRes[idx];
            }
            return null;
        }
        
        // 获取资源上的GameObject
        public GameObject GetResObject(string key)
        {
            var res = GetRes(key);
            if (res != null)
            {
                if (res.resType == TrackResItem.TrackResType.Avatar)
                {
                    return res.avatarData.instance;
                } 
            }
            return null;
        }

        // 删除资源
        public void DeleteRes(string key)
        {
            var idx = keys.IndexOf(key);
            if (idx >= 0)
            {
                keys.RemoveAt(idx);
                trackRes.RemoveAt(idx);
            }
        }
        
        // 是否有Key
        public bool HasKey(string key)
        {
            return keys.IndexOf(key) >= 0;
        }
        
        // 是否有GameObject，有返回key
        public string TryGetResKey(GameObject obj)
        {
            for (int i = 0; i < keys.Count; i++)
            {
                var key = keys[i];
                var res = trackRes[i];
                if (res.resType == TrackResItem.TrackResType.Avatar)
                {
                    if (res.avatarData.instance == obj)
                    {
                        return key;
                    }
                } 
            }
            return null;
        }
        
        // 获取一个可用的key
        public string GetEmptyKeyByEditor(string preKey)
        {
            // 100够用了
            for (int i = 0; i < 100; i++)
            {
                string key = preKey + i;
                if (!HasKey(key))
                {
                    return key;
                }
            }
            PapeGames.X3.LogProxy.LogError("请检查一下逻辑，检索了100个槽位key还不够用！");
            return null;
        }
    }

    // 轨道资源路径
    [Serializable]
    public class TrackResItem
    {
        public TrackResType resType;
        public TrackAvatarData avatarData;

        // 清除和当前类型不同的其他类型的无用Data
        public void ClearOtherTypeData()
        {
            if (resType == TrackResType.Avatar)
            {
                 // 这里清除其余类型的数据
            }
        }
        
        // avatar类型的数据
        [Serializable]
        public class TrackAvatarData
        {
            public string suit;  // 绑定的suit
            public Material material;  // 绑定的material
            [NonSerialized]
            public GameObject instance; // 生成的实例
        }
        
        public enum TrackResType
        {
            Avatar,  
        }
    }
    
    // 编辑器代码，先写到这里
#if UNITY_EDITOR

#endif
}

