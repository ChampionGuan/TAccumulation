// Name：InputEffectMgr_Handler
// Created by jiaozhu
// Created Time：2022-07-10 12:27

using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class InputEffectMgr
    {
        static List<EffectItem> s_FilterList = new List<EffectItem>();
        static List<EffectItem> s_RunningList = new List<EffectItem>();
        static List<EffectItem> s_AdditiveList = new List<EffectItem>();

        public static void Add(EffectItem filter)
        {
            if (s_FilterList.Contains(filter)) return;
            s_FilterList.Add(filter);
            if (filter.EffectTarget != null)
            {
                SetTemplate(filter.EffectName,filter.EffectTarget);
            }
        }

        public static void Remove(EffectItem filter)
        {
            if (!s_FilterList.Contains(filter)) return;
            s_FilterList.Remove(filter);
            if (filter.EffectTarget != null)
            {
                RemoveTemplate(filter.EffectName);
            }
        }


        void LateUpdate()
        {
            if (!IsEnable) return;
            if (s_CurEffect == null)
            {
                s_CurEffect = GetCurEffect();
            }
            CheckAdditiveEffect();
            if (s_CurEffect != null)
            {
                CheckCurEffect(s_CurEffect.AdditivityEffect);
                if (CheckCurEffect(s_CurEffect))
                {
                    s_CurEffect = null;
                }
            }
            CheckRunningList();
        }

        static void AddEffectToRunningList(EffectItem item)
        {
            if (!s_RunningList.Contains(item)) s_RunningList.Add(item);
        }

        static void RemoveEffectFromRunningList(EffectItem item)
        {
            if (s_RunningList.Contains(item)) s_RunningList.Remove(item);
            RemoveEffect(item);
        }


        void CheckRunningList()
        {
            if (s_CurEffect != null)
            {
                if (s_CurEffect.IsCanRecycle())
                {
                    s_CurEffect.Recycle();
                    s_CurEffect = null;
                }
            }

            if (s_RunningList.Count == 0) return;
            List<EffectItem> temp = null;
            foreach (var it in s_RunningList)
            {
                if (it.IsCanRecycle())
                {
                    if (temp == null) temp = ListPool<EffectItem>.Get();
                    temp.Add(it);
                }
            }

            if (temp != null)
            {
                foreach (var it in temp)
                {
                    it.Recycle();
                }

                ListPool<EffectItem>.Release(temp);
            }
        }

        bool CheckCurEffect(EffectItem item)
        {
            bool isRemove = false;
            if (item != null)
            {
                switch (item.EffectType)
                {
                    case EffectType.Click:
                        var pos = s_TouchDownPos;
                        UIUtility.SetScreenPositionXY(item.EffectTarget, pos.x, pos.y);
                        AddEffectToRunningList(item);
                        isRemove = true;
                        break;
                    case EffectType.Drag:
                        UIUtility.SetScreenPositionXY(item.EffectTarget, s_OnDragPos.x, s_OnDragPos.y);
                        break;
                    case EffectType.LongPress:
                        UIUtility.SetScreenPositionXY(item.EffectTarget, s_OnLongPressPos.x, s_OnLongPressPos.y);
                        break;
                }
            }

            return isRemove;
        }

        static void PlayEffect(GameObject obj)
        {
            var p = obj.GetComponentInChildren<ParticleSystem>();
            if (p != null)
            {
                p.Play();
            }
        }

        void ClearEffect()
        {
            if (s_CurEffect != null)
            {
                s_CurEffect.Recycle();
                s_CurEffect = null;
            }

            while (s_RunningList.Count > 0)
            {
                RemoveEffectFromRunningList(s_RunningList[0]);
            }
        }
    }
}