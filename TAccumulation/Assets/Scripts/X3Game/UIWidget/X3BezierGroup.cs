using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace X3Game
{
    public class X3BezierGroup : MonoBehaviour
    {
        [Serializable]
        public struct TargetInfo
        {
            public string Key;
            public GameObject Target;
        }

        [SerializeField] private bool m_FixZ = true;
        [SerializeField] private BezierSpline m_Spline = new BezierSpline(100f);
        [SerializeField] private List<TargetInfo> m_Targets = new List<TargetInfo>();

        public bool IsValid => m_Spline != null;
        public bool FixZ => m_FixZ;
        public BezierSpline Spline => m_Spline;

        private Dictionary<string, GameObject> m_TargetDict;

        private Dictionary<string, GameObject> TargetDict
        {
            get
            {
                if (m_TargetDict == null)
                {
                    m_TargetDict = new Dictionary<string, GameObject>();
                    foreach (var target in m_Targets)
                    {
                        if (!string.IsNullOrEmpty(target.Key) && !m_TargetDict.ContainsKey(target.Key))
                            m_TargetDict[target.Key] = target.Target;
                    }
                }

                return m_TargetDict;
            }
        }

        public void SetTargetPos(string key, float xProgress)
        {
            if (string.IsNullOrEmpty(key) || !IsValid)
                return;
            if (TargetDict.ContainsKey(key) && TargetDict[key] != null)
            {
                if (m_Spline.GetPointByXProgress(xProgress, out Vector3 pos))
                {
                    var rt = TargetDict[key].GetComponent<RectTransform>();

                    if (m_FixZ && rt != null)
                    {
                        rt.anchoredPosition = pos;
                    }
                    else
                    {
                        TargetDict[key].transform.localPosition = pos;
                    }
                }
            }
        }

#if UNITY_EDITOR
        public void SetUpdateSpline(BezierSpline newSpline, bool fixZ)
        {
            m_FixZ = fixZ;
            m_Spline = new BezierSpline(newSpline);
            m_Spline.SetLength(1);
        }

        public void SetTargetPosEditorOnly(string key, float xProgress)
        {
            m_TargetDict = null;
            SetTargetPos(key, xProgress);
        }
#endif
    }
}