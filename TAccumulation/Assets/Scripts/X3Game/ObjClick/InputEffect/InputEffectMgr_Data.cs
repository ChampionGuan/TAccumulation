// Name：InputEffectMgr_Data
// Created by jiaozhu
// Created Time：2022-07-10 10:17

using System;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class InputEffectMgr
    {
        private static string CLICK_EFFECT;
        private static string DRAG_EFFECT;
        private static string LONG_PRESS_EFFECT;
        private static float RECYCLE_DT = 1f;
        private static List<EffectItem> s_ShowList = new List<EffectItem>();
        private static Dictionary<string, float> s_EffectDt = new Dictionary<string, float>();
        private static EffectItem s_CurEffect;

        /// <summary>
        /// 设置特效相关
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public static void SetEffect(string clickEffect = null, string dragEffect = null, string longPressEffect = null)
        {
            CLICK_EFFECT = clickEffect;
            DRAG_EFFECT = dragEffect;
            LONG_PRESS_EFFECT = longPressEffect;
        }

        /// <summary>
        /// 设置循环使用时间
        /// </summary>
        /// <param name="dt"></param>
        public static void SetRecycleDt(float dt)
        {
            RECYCLE_DT = dt;
        }

        /// <summary>
        /// 
        /// </summary>
        [Serializable]
        public class EffectItem : IClearable
        {
            public EffectType EffectType;
            public FilterType FilterType;
            public string EffectName;
            public GameObject Target;
            public GameObject EffectTarget;
            [NonSerialized] public int Order;
            private Rect screenRect;
            private float duration;
            private bool isSetRect;
            [NonSerialized] public EffectItem AdditivityEffect;

            public EffectItem Clone()
            {
                EffectItem item = ClearableObjectPool<EffectItem>.Get();
                item.EffectName = EffectName;
                item.EffectType = EffectType;
                return item;
            }

            public void Clear()
            {
                Order = 0;
                isSetRect = false;
                if (EffectTarget != null)
                {
                    Release(EffectName, EffectTarget);
                    EffectTarget = null;
                }

                if (AdditivityEffect != null)
                {
                    AdditivityEffect.Recycle();
                    AdditivityEffect = null;
                }
                EffectName = string.Empty;
            }

            public void LoadEffect()
            {
                if (EffectTarget == null)
                {
                    if (string.IsNullOrEmpty(EffectName))
                    {
                        return;
                    }

                    EffectTarget = Get(EffectName);
                }

                if (EffectTarget != null)
                {
                    if (EffectType == EffectType.Click)
                    {
                        duration = Time.realtimeSinceStartup + RECYCLE_DT;
                    }

                    PlayEffect(EffectTarget);
                }
            }

            public void Recycle()
            {
                RemoveEffectFromRunningList(this);
            }

            public bool IsCanRecycle()
            {
                bool res = false;
                switch (EffectType)
                {
                    case EffectType.Click:
                        res = duration <= Time.realtimeSinceStartup;
                        break;
                    case EffectType.Drag:
                        res = s_CurTouchType != InputType.Drag;
                        break;
                    case EffectType.LongPress:
                        res = s_CurTouchType != InputType.LongPress;
                        break;
                }

                return res;
            }

            public bool IsTouchedObject(Vector2 screenPos)
            {
                screenRect = RTUtility.GetScreenRect(Target.transform as RectTransform);
                return screenRect.Contains(screenPos);
            }
        }

        static EffectItem GenEffect(EffectType effectType, string effectName, int order)
        {
            var item = ClearableObjectPool<EffectItem>.Get();
            item.EffectType = effectType;
            item.EffectName = effectName;
            item.Order = order;
            return item;
        }
        
        static void AddEffect(EffectType effectType, string effectName, int order,bool isAdditive=false)
        {
            if (isAdditive)
            {
                s_AdditiveList.Add(GenEffect(effectType,effectName,order));
                return;
            }
            if (s_CurEffect != null) return;
            AddEffect(GenEffect(effectType,effectName,order));
        }

        static bool AddEffect(EffectItem effectItem)
        {
            if (s_ShowList.Contains(effectItem)) return false;
            s_ShowList.Add(effectItem);
            return true;
        }

        static bool RemoveEffect(EffectItem effectItem)
        {
            bool res = false;
            if (s_ShowList.Contains(effectItem))
            {
                res = s_ShowList.Remove(effectItem);
            }

            ClearableObjectPool<EffectItem>.Release(effectItem);
            return res;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="effectType"></param>
        /// <returns></returns>
        static EffectItem GetFilter(EffectType effectType)
        {
            EffectItem filter = null;
            foreach (var it in s_FilterList)
            {
                if (it.EffectType == effectType && it.IsTouchedObject(s_TouchDownPos))
                {
                    filter = it;
                    break;
                }
            }

            return filter;
        }

        static EffectItem GetCurEffect()
        {
            if (s_CurEffect != null) return s_CurEffect;
            if (s_ShowList.Count == 0) return null;
            if (s_ShowList.Count >= 2)
            {
                s_ShowList.Sort(OnSortEffect);
            }

            s_CurEffect = s_ShowList[s_ShowList.Count - 1];
            s_ShowList.Remove(s_CurEffect);
            while (s_ShowList.Count > 0)
            {
                RemoveEffect(s_ShowList[s_ShowList.Count - 1]);
            }

            if (s_CurEffect != null)
            {
                EffectItem filter = GetFilter(s_CurEffect.EffectType);
                if (filter != null)
                {
                    RemoveEffect(s_CurEffect);
                    s_CurEffect = null;
                    if (filter.FilterType == FilterType.Override)
                    {
                        s_CurEffect = filter.Clone();
                    }
                }
            }

            if (s_CurEffect != null)
            {
                s_CurEffect.LoadEffect();
            }

            return s_CurEffect;
        }

        static void CheckAdditiveEffect()
        {
            if (s_AdditiveList.Count == 0) return ;
            if (s_AdditiveList.Count >= 2)
            {
                s_AdditiveList.Sort(OnSortEffect);
            }

            if (s_CurEffect == null)
            {
                var effect = s_AdditiveList[s_AdditiveList.Count - 1];
                ShowEffect(effect.EffectType,effect.EffectName,effect.Order);
                foreach (var it in s_AdditiveList)
                {
                    RemoveEffect(it);
                }
                s_AdditiveList.Clear();
            }
            else
            {
                EffectItem target=null;
                foreach (var it in s_AdditiveList)
                {
                    if (it.EffectType == s_CurEffect.EffectType)
                    {
                        target = it;
                        break;
                    }
                }

                if (target != null)
                {
                    s_AdditiveList.Remove(target);
                    target.LoadEffect();
                    s_CurEffect.AdditivityEffect = target;
                }
                
                foreach (var it in s_AdditiveList)
                {
                    RemoveEffect(it);
                }
                s_AdditiveList.Clear();
            }
        }

        static int OnSortEffect(EffectItem a, EffectItem b)
        {
            if (a.Order != b.Order)
            {
                return a.Order - b.Order;
            }

            return 0;
        }

        /// <summary>
        /// 根据类型获取特效名称
        /// </summary>
        /// <param name="effectType"></param>
        /// <returns></returns>
        static string GetEffectName(EffectType effectType)
        {
            string res = string.Empty;
            switch (effectType)
            {
                case EffectType.Click:
                    res = CLICK_EFFECT;
                    break;
                case EffectType.Drag:
                    res = DRAG_EFFECT;
                    break;
                case EffectType.LongPress:
                    res = LONG_PRESS_EFFECT;
                    break;
            }

            return res;
        }

        /// <summary>
        /// 获取特效时长
        /// </summary>
        /// <param name="effectName"></param>
        /// <param name="effect"></param>
        /// <returns></returns>
        static float GetEffectDt(string effectName, GameObject effect)
        {
            float dt = 0;
            if (!s_EffectDt.TryGetValue(effectName, out dt))
            {
                List<ParticleSystem> tempList = ListPool<ParticleSystem>.Get();
                effect.GetComponentsInChildren<ParticleSystem>(tempList);
                foreach (var it in tempList)
                {
                    if (it.gameObject.activeSelf && it.emission.enabled)
                    {
                        float temp = 0;
                        if (it.emission.rateOverTimeMultiplier <= 0)
                        {
                            temp = it.main.startDelayMultiplier + it.main.startLifetimeMultiplier;
                        }
                        else
                        {
                            temp = it.main.startDelayMultiplier +
                                   Mathf.Max(it.main.duration, it.main.startLifetimeMultiplier);
                        }

                        dt = Mathf.Max(dt, temp);
                    }
                }

                s_EffectDt.Add(effectName, dt);
            }

            return dt;
        }
    }
}