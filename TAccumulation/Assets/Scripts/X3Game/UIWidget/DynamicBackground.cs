using System;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using Random = System.Random;


namespace X3Game
{
    /// <summary>
    /// 由于在轮播时会清理Lua虚拟机，所以需要一个Mono脚本来保证轮播的顺序以及时间的正确性
    /// </summary>
    [XLua.LuaCallCSharp]
    public class DynamicBackground : MonoBehaviour
    {
        private float m_TickTime = 5f;
        private int m_StartIndex = 0;

        private bool m_IsBegin = false;

        private float m_curTickTime = 0;

        private GameObject[] m_ObjArry;

        /// <summary>
        /// 显示特效
        /// </summary>
        private bool m_ShowEffect;
        
        private void OnEnable()
        {
            if (m_ObjArry != null) return;
            m_ObjArry = new GameObject[transform.childCount];
            for (var i = 0; i < transform.childCount; i++)
            {
                var child = transform.GetChild(i);
                GameObject o;
                (o = child.gameObject).SetActive(m_StartIndex == i);
                m_ObjArry[i] = o;
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (!m_IsBegin) return;
            m_curTickTime += Time.deltaTime;
            if (!(m_curTickTime > m_TickTime)) return;
            PlayAnimation();
            m_curTickTime = 0;
        }

        /// <summary>
        /// 
        /// </summary>
        public void ShowFirstBg()
        {
            var random = new Random(DateTime.Now.Second);
            m_StartIndex = random.Next(transform.childCount);
            for (var i = 0; i < m_ObjArry.Length; i++)
            {
                var child = m_ObjArry[i];
                var isShow = m_StartIndex == i;
                child.SetActive(isShow);
                if (isShow)
                {
                    child.transform.SetAsFirstSibling();
                }
            }
        }

        /// <summary>
        /// 设置轮播时间
        /// </summary>
        /// <param name="tickTime"></param>
        public void SetTickTime(float tickTime)
        {
            m_TickTime = tickTime;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="isShow"></param>
        public void SetShowEffect(bool isShow)
        {
            m_ShowEffect = isShow;
            m_StartIndex = Mathf.Min(m_ObjArry.Length - 1, m_StartIndex);
            var curObj = m_ObjArry[m_StartIndex];
            if (curObj)
            {
                var objLinker = curObj.GetComponent<ObjLinker>();
                if (objLinker)
                {
                    UIUtility.SetActiveOCX(objLinker, "Effect", isShow);
                }
            }
        }

        public void StartTick()
        {
            m_IsBegin = true;
        }

        // ReSharper disable Unity.PerformanceAnalysis
        private void PlayAnimation()
        {
            m_StartIndex++;
            if (m_StartIndex >= m_ObjArry.Length)
            {
                m_StartIndex = 0;
            }

            int lastIdx = m_StartIndex == 0 ? m_ObjArry.Length - 1 : m_StartIndex - 1;
            var lastObj = m_ObjArry[lastIdx];
            var curObj = m_ObjArry[m_StartIndex];

            curObj.transform.SetAsFirstSibling();
            curObj.SetActive(true);
            var objLinker = curObj.GetComponent<ObjLinker>();
            if (objLinker)
            {
                UIUtility.SetActiveOCX(objLinker, "Effect", m_ShowEffect);
            }
            EventMgr.Dispatch("DynamicBGFadeStart", null);
            
            if (lastIdx == m_StartIndex) { return; }    // 防止只有单张背景时仍在不断轮播
            
            lastObj.GetComponent<MotionHandler>()
                ?.InternalPlay("Fadeout", () =>
                {
                    lastObj.SetActive(false); 
                    EventMgr.Dispatch("DynamicBGFadeoutCpl", null);
                });
            curObj.GetComponent<MotionHandler>()
                ?.InternalPlay("Fadein", () =>
                {
                    EventMgr.Dispatch("DynamicBGFadeinCpl", null);
                });
        }
        
        public void SetBackgroundCount(int count)
        {
            if (count <= 0)
            {
                Debug.LogError("Invalid background count. Must be a non-negative(count > 0) integer.");
                return;
            }

            if (count > m_ObjArry.Length)
            {
                // Create additional background objects
                for (int i = m_ObjArry.Length; i < count; i++)
                {
                    GameObject newBackground = GameObject.Instantiate(transform.GetChild(0).gameObject, transform);
                    newBackground.SetActive(false);

                    Array.Resize(ref m_ObjArry, m_ObjArry.Length + 1);
                    m_ObjArry[m_ObjArry.Length - 1] = newBackground;
                }
            }
            else if (count < m_ObjArry.Length)
            {
                // Remove extra background objects
                for (int i = m_ObjArry.Length - 1; i >= count; i--)
                {
                    GameObject.DestroyImmediate(m_ObjArry[i]);
                    Array.Resize(ref m_ObjArry, m_ObjArry.Length - 1);
                }
            }
        }
    }
}