using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{

    /// <summary>
    /// 屏幕按压检测
    /// </summary>
    public class ScreenPressChecker : MonoBehaviour
    {
        /// <summary>
        /// 检测间隔
        /// </summary>
        public float Interval = 1f;

        /// <summary>
        /// 按压距离
        /// </summary>
        public float Distance = 300;

        /// <summary>
        /// 最少触摸数
        /// </summary>
        public int TouchCount = 2;

        /// <summary>
        /// 按压成功后的回调，参数为按压中心点的屏幕坐标
        /// </summary>
        public Action<Vector2> OnPress;
        
        /// <summary>
        /// 上次按压成功时间
        /// </summary>
        private float m_LastPressTime;

        private List<Vector2> m_CachedList;

        private void Awake()
        {
            m_CachedList = new List<Vector2>(TouchCount);
        }

        private void Update()
        {
            if (OnPress == null)
            {
                //没回调 不处理
                return;
            }
            
            if (Time.realtimeSinceStartup - m_LastPressTime < Interval)
            {
                //间隔时间中 不处理
                return;;
            }

            if (Input.touchCount < TouchCount)
            {
                //触摸数不够 不处理
                return;;
            }

            //计算中心点
            m_CachedList.Clear();
            Vector2 center = Vector2.zero;
            foreach (Touch touch in Input.touches)
            {
                m_CachedList.Add(touch.position);
            }
            center = GetCenter(m_CachedList);
            
            foreach (Touch touch in Input.touches)
            {
                float distance = Vector2.Distance(center, touch.position);
                if (distance < Distance)
                {
                    //有一个触摸点离中心点的距离在检测距离内 就算按压成功
                    
                    //记录按压时间 调用回调
                    m_LastPressTime = Time.realtimeSinceStartup;
                    OnPress(center);
                    return;;
                }
            }
        }
        

        /// <summary>
        /// 计算最小覆盖圆的中心点
        /// </summary>
        private Vector2 GetCenter(List<Vector2> posList)
        {
            //计算距离最远的一对点
            Vector2 result1 = default;
            Vector2 result2 = default;
            float maxDistance = float.MinValue;

            for (int i = 0; i < posList.Count; i++)
            {
                for (int j = i + 1; j < posList.Count; j++)
                {
                    Vector2 vi = posList[i];
                    Vector2 vj = posList[j];

                    float sqrDistance = Vector3.SqrMagnitude(vi - vj);

                    if (sqrDistance > maxDistance)
                    {
                        maxDistance = sqrDistance;
                        result1 = vi;
                        result2 = vj;
                    }
                }
            }


            //返回它俩的中心点
            return (result1 + result2) / 2;
        }
        
        private void LogMinDistance(Vector2 center)
        {
            float minDistance = float.MaxValue;
            foreach (Touch touch in Input.touches)
            {
                float distance = Vector2.Distance(center, touch.position);
                minDistance = Mathf.Min(minDistance, distance);
            }
            PapeGames.X3.X3Debug.Log("中心点离触摸点的最小距离：" + minDistance);
        }
    }

}
