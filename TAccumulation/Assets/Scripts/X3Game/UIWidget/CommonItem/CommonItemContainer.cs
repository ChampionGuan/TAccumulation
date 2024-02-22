using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [DisallowMultipleComponent]
    public class CommonItemContainer : MonoBehaviour
    {
        private bool m_IsInit;
        
        #region 需要被控制的值
        private float m_FxAlpha = 1;
        #endregion
        
        #region 需要关心的控件
        private CanvasGroup m_Group; //与FXAlpha关联
        #endregion
        
        /// <summary>
        /// 用于控制刷新控件
        /// </summary>
        private bool m_IsDirty;
        private int m_DirtyFlag;

        private const float TOLERANCE = 0.001f;
        private const int FX_ALPHA_FLAG = 1;
        private List<ICommonItemCtrl> m_CommonItems;
        
        public void Clear()
        {
            m_IsInit = false;
            m_FxAlpha = 1;
            m_IsDirty = false;
            m_DirtyFlag = 0;
            if (m_CommonItems != null)
            {
                m_CommonItems.Clear();
                ListPool<ICommonItemCtrl>.Release(m_CommonItems);
                m_CommonItems = null;
            }

            if (m_Group != null)
            {
                m_Group.needNotifyAlpha = false;
                m_Group.alphaEvent -= OnDidApplyAlphaChange;
                m_Group = null;
            }
        }

        /// <summary>
        /// 刷新子节点
        /// </summary>
        public void Refresh()
        {
            if (m_IsDirty)
                return;

            m_IsDirty = true;
            DecodeDirtyFlag();
        }

        private void LazyInit()
        {
            if (m_IsInit)
                return;
            
            m_IsInit = true;
            m_FxAlpha = 1;
            if (m_CommonItems == null)
                m_CommonItems = ListPool<ICommonItemCtrl>.Get();
            
            if (m_Group == null)
            {
                m_Group = GetComponent<CanvasGroup>();
                if (m_Group != null)
                {
                    m_Group.needNotifyAlpha = true;
                    m_Group.alphaEvent += OnDidApplyAlphaChange;
                }
                else
                {
                    var parentTrans = transform.parent;
                    while (parentTrans != null)
                    {
                        m_Group = parentTrans.GetComponent<CanvasGroup>();
                        if (m_Group != null)
                        {
                            m_Group.needNotifyAlpha = true;
                            m_Group.alphaEvent += OnDidApplyAlphaChange;
                            break;
                        }

                        //如果已经能找到Canvas，就不再继续往上找了
                        if (parentTrans.TryGetComponent<Canvas>(out var comp))
                            break;
                        
                        parentTrans = parentTrans.parent;
                    }
                }
            }
        }
        
        private void OnDidApplyAlphaChange(float value)
        {
            if (m_Group == null)
                return;
            
            if (Math.Abs(m_FxAlpha - m_Group.alpha) > TOLERANCE)
            {
                m_FxAlpha = m_Group.alpha;
                m_DirtyFlag |= FX_ALPHA_FLAG;
                DecodeDirtyFlag();
            }
        }
        
        /// <summary>
        /// 触发Dirty后需要进行的逻辑
        /// </summary>
        private void DecodeDirtyFlag()
        {
            if (m_IsDirty)
            {
                LazyInit();
                m_IsDirty = false;
                m_CommonItems.Clear();
                var result = ListPool<CommonItemCtrl>.Get();
                GetComponentsInChildren(result);
                m_CommonItems.AddRange(result);
                ListPool<CommonItemCtrl>.Release(result);
            }

            if (m_DirtyFlag > 0 && m_CommonItems != null)
            {
                if ((m_DirtyFlag & FX_ALPHA_FLAG) > 0)
                {
                    m_DirtyFlag ^= FX_ALPHA_FLAG;
                    foreach (var item in m_CommonItems)
                    {
                        if (item.Mark == CommonItemMark.FxAlpha)
                        {
                            item.Effect(m_FxAlpha);
                        }
                    }
                }
            }
        }
    }
}