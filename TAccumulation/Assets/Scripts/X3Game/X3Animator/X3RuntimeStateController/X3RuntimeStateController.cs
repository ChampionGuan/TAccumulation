using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class X3RuntimeStateController : IClearable
    {
        private readonly List<Layer> m_LayerList = new List<Layer>();
        public Layer DefaultLayer
        {
            get
            {
                if (m_LayerList.Count == 0)
                    m_LayerList.Add(ClearableObjectPool<Layer>.Get());
                return m_LayerList[0];
            }
        }

        public void Stop()
        {
            foreach (var layer in m_LayerList)
            {
                layer.Stop();
            }
        }
        
        public void Pause()
        {
            foreach (var layer in m_LayerList)
            {
                layer.Pause();
            }
        }
            
        public void Resume()
        {
            foreach (var layer in m_LayerList)
            {
                layer.Resume();
            }
        }

        public void Update(float dt)
        {
            List<Layer> layerList = ListPool<Layer>.Get();
            layerList.AddRange(m_LayerList);
            layerList.Reverse();
            for (int i = layerList.Count - 1; i >= 0; i--)
            {
                var layer = layerList[i];
                if (layer == null)
                    continue;
                layer.OnUpdate(dt);
                layer.FireEvents();
            }

            ListPool<Layer>.Release(layerList);
        }
        
        public void LateUpdate()
        {
            foreach (var layer in m_LayerList)
            {
                layer.LateUpdate();
            }
        }
        
        private float m_DefaultTransitionDuration = 0.2f;
        public float DefaultTransitionDuration
        {
            set
            {
                m_DefaultTransitionDuration = Mathf.Max(0, value); 
                foreach (var layer in m_LayerList)
                {
                    layer.DefaultTransitionDuration = value;
                }
            }
            get { return m_DefaultTransitionDuration; }
        }

        public void Clear()
        {
            foreach (var layer in m_LayerList)
            {
                ClearableObjectPool<Layer>.Release(layer);
            }
            m_LayerList.Clear();
        }

        private static readonly Dictionary<int, string> s_HashToNameDict = new Dictionary<int, string>();
        public static int StateNameToHash(string stateName)
        {
            if (string.IsNullOrEmpty(stateName))
                return 0;
            int hash = stateName.GetHashCode();
            s_HashToNameDict[hash] = stateName;
            return hash;
        }
        public static string HashToStateName(int hash)
        {
            if (s_HashToNameDict.TryGetValue(hash, out string stateName))
                return stateName;
            return string.Empty;
        }
        public static bool LogEnabled { set; get; } = false;
        private const float VADLID_DURATION = 0.0001f;
    }
}
