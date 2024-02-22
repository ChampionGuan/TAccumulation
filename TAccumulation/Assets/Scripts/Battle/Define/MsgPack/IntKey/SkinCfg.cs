using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class SkinCfg
    {
        /// <summary> 编号 </summary>
        [Key(0)] public int ID;

        /// <summary> 名字 </summary>
        [Key(1)] public string Name;

        /// <summary> Timeline的替换目录 </summary>
        [Key(2)] public List<ReplaceDirData> TimelineDirDatas;
        
        /// <summary> Audio的运行时使用的替换目录 </summary>
        [Key(3)] public DoubleStringTable AudioDict;
        
        /// <summary> 编辑器用的虚拟目录字段 </summary>
        [Key(4)] public string VirtualPath;

        /// <summary> 差异名字(目录匹配规则用) </summary>
        [Key(5)] public string DiffName;

        /// <summary> FX的特效ID替换表 </summary>
        [Key(6)] public Dictionary<int, int> FxIDTable;

        /// <summary> 原套装ID </summary>
        [Key(7)] public int OriginSuitID;

        /// <summary> 原逻辑ID </summary>
        [Key(8)] public int OriginLogicID;

        /// <summary> 是否是WeaponSuitID </summary>
        [Key(9)] public bool IsWeaponSuitID;
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class ReplaceDirData
    {
        [Key(0)] public string OriginDir;

        [Key(1)] public string TargetDir;
    }
    
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class DoubleStringTable
    {
        [Key(0)]
        public List<string> keys = new List<string>();
        [Key(1)]
        public List<string> values = new List<string>();

        [NonSerialized] 
        private Dictionary<string, string> _dictionary = null;

        public void Add(string key, string value)
        {
            if (keys.Contains(key))
                return;
            keys.Add(key);
            values.Add(value);
        }

        public bool RemoveAt(int index)
        {
            keys.RemoveAt(index);
            values.RemoveAt(index);
            return true;
        }

        public bool Remove(string key)
        {
            int index = keys.IndexOf(key);
            if (index < 0)
                return false;
            return RemoveAt(index);
        }

        public bool TryGetValue(string key, out string value)
        {
            if (_dictionary == null)
            {
                _OnAfterDeserialize();
            }
            return _dictionary.TryGetValue(key, out value);
        }
        
        private void _OnAfterDeserialize()
        {
            _dictionary = new Dictionary<string, string>();
            if (keys.Count != values.Count)
                throw new System.Exception("there are " + keys.Count + " keys and " + values.Count + " values after deserialization. Make sure that both key and value types are serializable.");

            for (int i = 0; i < keys.Count; i++)
                _dictionary.Add(keys[i], values[i]);
        }
    }
}