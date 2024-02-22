using System;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace X3Game
{
    [RequireComponent(typeof(Slider))]
    [HelpURL("https://papergames.feishu.cn/docx/PYLzdz6xuoHJmDxF3occeDaNnMh")]
    public class MilestoneSlider : MonoBehaviour, IUIComponent
    {
        [SerializeField] protected GameObject m_MilestonePrefab = null;
        [SerializeField] protected RectTransform m_MilestonesParent = null;
        [SerializeField] private bool m_NeedHidenMilestoneBeginning = true; // 是否在进度条的一开始创建一个隐藏的 Milestone，用于偏移计算
        public UnityAction<MilestoneSlider, GameObject, int> onCellLoad;
        public UnityAction<MilestoneSlider, GameObject, int> onMilestoneEnter;

        #region Private
        private List<GameObject> m_MilestoneList = new List<GameObject>();
        private List<RectTransform> m_MilestoneRTList = new List<RectTransform>();
        private Tweener m_Tweener;
        private Slider m_Slider;
        protected Slider slider
        {
            get
            {
                if (!m_Slider)
                    m_Slider = GetComponent<Slider>();
                return m_Slider;
            }
        }
        private RectTransform m_SliderRT;
        protected RectTransform sliderRT
        {
            get
            {
                if (!m_SliderRT)
                {
                    m_SliderRT = GetComponent<RectTransform>();
                }
                return m_SliderRT;
            }
        }
        private static Vector3[] corners = new Vector3[4];
        private void GetRectTwoPoles(out float begin, out float end, RectTransform rt)
        {
            rt.GetWorldCorners(corners);
            if (slider.direction == Slider.Direction.BottomToTop)
            {
                begin = corners[0].y;
                end = corners[1].y;
            }
            else if (slider.direction == Slider.Direction.TopToBottom)
            {
                begin = corners[1].y;
                end = corners[0].y;
            }
            else if (slider.direction == Slider.Direction.LeftToRight)
            {
                begin = corners[0].x;
                end = corners[3].x;
            }
            else // slider.direction == Slider.Direction.RightToLeft
            {
                begin = corners[3].x;
                end = corners[0].x;
            }
        }
        private float NormalizeProgress(float value)
        {
            return (value - slider.minValue) / (slider.maxValue - slider.minValue);
        }
        private void OnDisable()
        {
            if (m_Tweener != null)
            {
                m_Tweener.Kill(true);
            }
        }

        private void OnDestroy()
        {
            X3Game.X3GameUIWidgetEntry.EventDelegate?.OnDestroy(this, this.GetInstanceID());
        }

        /// <summary>
        /// 根据 Milestones 计算进度设置的偏移值
        /// </summary>
        private float GetNormalizedValueOffset(float normalizedValue, List<RectTransform> mileStoneObjs)
        {
            if (Mathf.Approximately(normalizedValue, 0) || normalizedValue < 0)
                return 0;
            if (Mathf.Approximately(normalizedValue, 1.0f) || normalizedValue > 1.0f )
                return 1;
            
            if (mileStoneObjs != null && mileStoneObjs.Count > 0)
            {
                float sliderBegin, sliderEnd;
                GetRectTwoPoles(out sliderBegin, out sliderEnd, sliderRT);
                
                // milestone 的左右边界将进度划分成多个不相交的区间
                // 实际显示的进度也应该在这些区间中：0——1——2——3——4
                // 找到 normalizedValue 所在的相邻两个 milestone
                float lowerProgress = 0, upperProgress = 1; // 设置进度的前后两个 Milestone 的进度
                float lowerMilestoneEndProgress = 0, upperMilestoneBeginProgress = 1;  // 前一个 Milestone 的结束边界进度，后一个 Milestone 的开始边界进度
                
                for (int i = 0; i < mileStoneObjs.Count; i++)
                {
                    var milestoneObj = mileStoneObjs[i];
                    float milestoneBegin, milestoneEnd; 
                    GetRectTwoPoles(out milestoneBegin, out milestoneEnd, milestoneObj);
                    
                    float milestoneEndNormProgress = (milestoneEnd - sliderBegin) / (sliderEnd - sliderBegin);       // Milestone 结束边界进度
                    float milestoneBeginNormProgress = (milestoneBegin - sliderBegin) / (sliderEnd - sliderBegin);   // Milestone 开始边界进度

                    float milestonePosition = (milestoneEnd + milestoneBegin) / 2.0f;
                    float milestoneProgress = Mathf.Clamp((milestonePosition - sliderBegin) / (sliderEnd - sliderBegin), 0, 1);

                    if (milestoneProgress > normalizedValue && milestoneProgress - upperProgress < 0.00001)
                    {
                        upperProgress = milestoneProgress;
                        upperMilestoneBeginProgress = milestoneBeginNormProgress;
                    }

                    if (milestoneProgress < normalizedValue && milestoneProgress - lowerProgress > -0.00001)
                    {
                        lowerProgress = milestoneProgress;
                        lowerMilestoneEndProgress = milestoneEndNormProgress;
                    }
                }
                float normlizedValueOffset = (normalizedValue - lowerProgress) / (upperProgress - lowerProgress);
                normlizedValueOffset =
                    (upperMilestoneBeginProgress - lowerMilestoneEndProgress) * normlizedValueOffset +
                    lowerMilestoneEndProgress;
                
                return normlizedValueOffset;
            }

            return normalizedValue;
        }
        
        private void EnterMileStone(float normalizedValue, List<RectTransform> mileStoneObjs)
        {
            float sliderBegin, sliderEnd;
            GetRectTwoPoles(out sliderBegin, out sliderEnd, sliderRT);
            for (int i = 0; i < mileStoneObjs.Count; i++)
            {
                var milestoneObj = mileStoneObjs[i];
                float milestoneBegin, milestoneEnd; 
                GetRectTwoPoles(out milestoneBegin, out milestoneEnd, milestoneObj);
                    
                //float milestoneEndNormProgress = (milestoneEnd - sliderBegin) / (sliderEnd - sliderBegin);       // Milestone 结束边界进度
                float milestoneBeginNormProgress = (milestoneBegin - sliderBegin) / (sliderEnd - sliderBegin) - 0.001f;   // Milestone 开始边界进度

                if (normalizedValue > milestoneBeginNormProgress)
                {
                    var childGO = mileStoneObjs[i].gameObject;
                    onMilestoneEnter?.Invoke(this, childGO, i);
                    X3GameUIWidgetEntry.EventDelegate?.MilestoneSlider_OnMilestoneEnter(this, this.GetInstanceID(), childGO, i);
                    // return true;
                }
            }
            // return false;
        }
        
        private void SetNormalizedValueWithOffset(float normalizedValue, List<RectTransform> mileStoneObjs, bool notify)
        {
            if (Mathf.Approximately(normalizedValue, 0) || normalizedValue < 0)
            {
                slider.normalizedValue = 0;
                return;
            }
            if (Mathf.Approximately(normalizedValue, 1.0f) || normalizedValue > 1.0f )
            {
                slider.normalizedValue = 1;
                return;
            }

            float v = GetNormalizedValueOffset(normalizedValue, mileStoneObjs);
            if(notify) EnterMileStone(v, mileStoneObjs);
            slider.normalizedValue = v;
        }
        
        private void SetNormalizedValueWithAnimAndOffset(float normalizedValue, float duration, bool notify,
            List<RectTransform> mileStoneObjs, System.Action<Slider> onComplete = null,
            EasingFunction.Ease ease = EasingFunction.Ease.Linear)
        {
            if (Mathf.Approximately(normalizedValue, slider.normalizedValue))
                return;
            if (duration < 0)
            {
                SetNormalizedValueWithOffset(normalizedValue, mileStoneObjs, notify);
                onComplete?.Invoke(slider);
                return;
            }
            
            float normalizedOffsetValue = GetNormalizedValueOffset(normalizedValue, mileStoneObjs);
            
            if(m_Tweener != null)
                m_Tweener.Kill();
            
            float source = slider.normalizedValue;
            m_Tweener = Tweener.Create(duration, 0);
            m_Tweener.OnUpdate((float t) =>
            {
                float v = Mathf.Lerp(source, normalizedOffsetValue, t);
                EnterMileStone(v, mileStoneObjs);
                slider.normalizedValue = v;
            });
            m_Tweener.OnComplete(() =>
            {
                slider.normalizedValue = normalizedOffsetValue;
                m_Tweener = null;
                onComplete?.Invoke(slider);
            });
            m_Tweener.SetEase(ease);
            if(gameObject.activeInHierarchy)
                m_Tweener.Play();
        }
        #endregion

        #region Load
        /// <summary>
        /// 根据模板加载 Milestones
        /// </summary>
        /// <param name="dataCount"></param>
        public void Load(int dataCount)
        {
            // if (m_MilestoneList != null)
            // {
            //     foreach (var item in m_MilestoneList)
            //     {
            //         if (item.gameObject.activeSelf)
            //             item.gameObject.SetActive(false);
            //     }
            // }
            
            if (dataCount >= 0)
            {
                m_MilestoneRTList.Clear();
                m_MilestoneList.Clear();
                for (int i = 0; i < m_MilestonesParent.childCount; i++)
                {
                    var child = m_MilestonesParent.GetChild(i).gameObject;
                    var item = child.GetComponent<RectTransform>();
                    if (item != null)
                    {
                        if (item.gameObject.activeSelf)
                            item.gameObject.SetActive(false);
                        m_MilestoneList.Add(child);
                    }
                }
                
                for (int idx = 0; idx < dataCount; idx++)
                {
                    GameObject child = null;
                    if (idx < m_MilestoneList.Count)
                    {
                        child = m_MilestoneList[idx];
                    }
                    else
                    {
                        child = Instantiate<GameObject>(m_MilestonePrefab, m_MilestonesParent, false);
                        m_MilestoneList.Add(child);
                    }

                    child.SetActive(true);
                    onCellLoad?.Invoke(this, child, idx);
                    X3GameUIWidgetEntry.EventDelegate?.MilestoneSlider_OnCellLoad(this, this.GetInstanceID(), child, idx);
                    child.transform.SetSiblingIndex(idx);
                    m_MilestoneRTList.Add(child.GetComponent<RectTransform>());
                }
                
                // 在进度条的初始位置，创建一个虚拟的 Milestone，使得相邻两个进度之间视觉上等距
                if (m_NeedHidenMilestoneBeginning)
                {
                    GameObject child = null;
                    if (dataCount < m_MilestoneList.Count)
                    {
                        child = m_MilestoneList[dataCount].gameObject;
                    }
                    else
                    {
                        child = Instantiate<GameObject>(m_MilestoneList[0], m_MilestonesParent, false);
                        m_MilestoneList.Add(child);
                    }
                    child.SetActive(false);
                    RectTransform rt = child.GetComponent<RectTransform>();
                    Vector3 pos = rt.position;
                    float sliderBegin, sliderEnd;
                    GetRectTwoPoles(out sliderBegin, out sliderEnd, sliderRT);
                    if (slider.direction == Slider.Direction.BottomToTop || slider.direction == Slider.Direction.TopToBottom)
                    {
                        pos.y = sliderBegin;
                    }
                    else // slider.direction == Slider.Direction.RightToLeft || slider.direction == Slider.Direction.LeftToRight
                    {
                        pos.x = sliderBegin;
                    }
                    rt.position = pos;
                    m_MilestoneRTList.Add(rt);
                }
            }
        }
        #endregion

        #region Set Value
        /// <summary>
        /// 在设置进度的时候，根据 mileStones，减去偏移值。使用该方法会使 Slider 上的 value 与期望的 value 有所偏差，而且在调用该函数的时候，
        /// 要求 Milestone 的坐标已经设置完成， Milestone 和 Slider 之间也不应该有相对位移
        /// </summary>
        public void SetValue(float value)
        {
            SetNormalizedValueWithOffset(NormalizeProgress(value), m_MilestoneRTList, true);
        }

        /// <summary>
        /// 设置进度不通知
        /// </summary>
        public void SetValueWithoutNotify(float value)
        {
            SetNormalizedValueWithOffset(NormalizeProgress(value), m_MilestoneRTList, false);
        }

        /// <summary>
        /// 在设置进度的时候，根据 mileStones，减去偏移值，同时有进度条动画。使用该方法会使 Slider 上的 value 与期望的 value 有所偏差，而且在调用该函数的时候，
        /// 要求 Milestone 的坐标已经设置完成， Milestone 和 Slider 之间也不应该有相对位移
        /// </summary>
        /// <param name="value">Slier 进度 ，取值范围 [MinValue,MaxValue]</param>
        /// <param name="duration">过渡动画的时长</param>
        /// // <param name="notify">是否触发 onEnter 回调</param>
        /// <param name="onComplete">动画完成回调</param>
        /// <param name="ease">平滑函数</param>
        public void SetValueAnim(float value, float duration, bool notify = true, System.Action<Slider> onComplete = null, EasingFunction.Ease ease = EasingFunction.Ease.Linear)
        {
            SetNormalizedValueWithAnimAndOffset(NormalizeProgress(value), duration,notify, m_MilestoneRTList, onComplete, ease);
        }
        #endregion

        public void ResetStatus()
        {
            onCellLoad = null;
            onMilestoneEnter = null;
        }
    }
}