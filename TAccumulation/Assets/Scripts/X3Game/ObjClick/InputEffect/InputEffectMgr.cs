// Name：InputEffectMgr
// Created by jiaozhu
// Created Time：2022-07-10 10:57

using UnityEngine;
using UnityEngine.SceneManagement;
using XLua;
using PapeGames.X3;

namespace X3Game
{
    [MonoSingletonAttr(true, "InputEffectMgr")]
    [LuaCallCSharp]
    public partial class InputEffectMgr : MonoSingleton<InputEffectMgr>, InputClickDelegate, InputDragDelegate
    {
        private static bool s_Enable;

        public static bool IsEnable
        {
            get { return s_Enable; }
            set
            {
                if (value != s_Enable)
                {
                    s_Enable = value;
                    if (s_InputComponent != null)
                    {
                        s_InputComponent.SetTouchEnable(s_Enable);
                    }
                }
            }
        }

        /// <summary>
        /// 显示特效
        /// </summary>
        /// <param name="effectType"></param>
        /// <param name="effectName"></param>
        public static void ShowEffect(EffectType effectType, string effectName = null, int order = 0,
            bool isAdditive = false)
        {
            if (!IsEnable) return;
            if (isAdditive)
            {
                if (s_CurEffect==null || s_CurEffect.AdditivityEffect==null)
                {
                    AddEffect(effectType, effectName, order, true);
                }
                return;
            }

            if (s_CurEffect != null)
            {
                if (s_CurEffect.EffectType == effectType)
                {
                    return;
                }
                else
                {
                    Instance.CheckRunningList();
                }
            }

            effectName = string.IsNullOrEmpty(effectName) ? GetEffectName(effectType) : effectName;
            AddEffect(effectType, effectName, order);
        }
    }
}