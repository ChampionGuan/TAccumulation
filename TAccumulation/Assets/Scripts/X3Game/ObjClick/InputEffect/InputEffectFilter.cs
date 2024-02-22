// Name：InputEffectFilter
// Created by jiaozhu
// Created Time：2022-07-10 13:44

using System;
using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;

namespace X3Game
{
    public class InputEffectFilter : MonoBehaviour
    {
        [SerializeField] List<InputEffectMgr.EffectItem> m_List = new List<InputEffectMgr.EffectItem>();

        void Check(bool isAdd)
        {
            foreach (var item in m_List)
            {
                if (item.Target == null)
                {
                    item.Target = gameObject;
                }

                if (isAdd)
                {
                    InputEffectMgr.Add(item);
                }
                else
                {
                    InputEffectMgr.Remove(item);
                }
            }
        }

        private void OnEnable()
        {
            Check(true);
        }

        private void OnDisable()
        {
            Check(false);
        }
    }
}