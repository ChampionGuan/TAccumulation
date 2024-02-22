using System;
using System.Collections.Generic;

namespace UnityEngine.Timeline
{
    [CreateAssetMenu(fileName = "PhysicsWindConfigAsset", menuName = "PhysicsWindConfigAsset", order = 0)]
    public class PhysicsWindConfigAsset : ScriptableObject, ISerializationCallbackReceiver
    {
        [SerializeField] public PhysicsWindConfigDictionary configs = new PhysicsWindConfigDictionary();
        public void OnBeforeSerialize()
        {
            configs?.OnBeforeSerialize();
        }

        public void OnAfterDeserialize()
        {
            configs?.OnAfterDeserialize();
        }
    }

    [Serializable]
    public class PhysicsWindConfig
    {
        [Header("ID")] public int ID;
        [Header("描述")] public string Description;
        [Header("数据列表")] public List<PhysicWindConfigData> Datas = new List<PhysicWindConfigData>();
    }

    [Serializable]
    public class PhysicWindConfigData
    {
        [Header("描述")] public string Description;
        [Header("部件名字")] public string PartName;
        [Header("风场资源名字")] public string PhysicsWindName;
    }

    [Serializable]
    public class PhysicsWindConfigDictionary : ISerializationCallbackReceiver
    {
        [SerializeField] private List<int> _keys = new List<int>();

        [SerializeField] private List<PhysicsWindConfig> _values = new List<PhysicsWindConfig>();

        private Dictionary<int, PhysicsWindConfig> _dictionary = new Dictionary<int, PhysicsWindConfig>();

        public Dictionary<int, PhysicsWindConfig> Dictionary
        {
            get => _dictionary;
            set => _dictionary = value;
        }

        public void OnBeforeSerialize()
        {
            foreach (var kvp in _dictionary)
            {
                if (!_keys.Contains(kvp.Key))
                {
                    _keys.Add(kvp.Key);
                    _values.Add(kvp.Value);
                }
                else
                {
                    int idx = _keys.IndexOf(kvp.Key);
                    if (idx >= _values.Count)
                    {
                        _values.Add(kvp.Value);
                    }
                    else
                    {
                        _values[idx] = kvp.Value;
                    }
                }
            }
        }

        public void OnAfterDeserialize()
        {
            _dictionary.Clear();
            int count = Math.Min(_keys.Count, _values.Count);
            for (int i = 0; i < count; i++)
            {
                _dictionary[_keys[i]] = _values[i];
            }
        }
    }
}