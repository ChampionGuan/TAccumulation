using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using PapeGames.X3UI;
using X3Game;
using PapeGames.X3;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public static class GameObjReleaseDelegate
    {
        public static void Release(GameObject obj)
        {
            if (obj == null) 
                return;
            UnityEngine.Profiling.Profiler.BeginSample("UIView.ResetStatus");
            List<IUIComponent> list = ListPool<IUIComponent>.Get();
            obj.GetComponentsInChildren<IUIComponent>(true, list);
            for (int i = 0; i < list.Count; i++)
            {
                var comp = list[i];
                comp.ResetStatus();
            }
            ListPool<IUIComponent>.Release(list);
            
            ReleaseButton(obj);
            ReleaseSlider(obj);
            GyroscopeUtility.ReleaseGyro(obj);
            ReleaseDropdown(obj);
            ReleaseTMP_Dropdown(obj);
            ReleaseTMP_InputField(obj);
            ReleaseInputField(obj);
            ReleaseX3AnimatorListener(obj);
            UnityEngine.Profiling.Profiler.EndSample();
        }
        

        #region 清理TMP_Dropdown委托

        static void ReleaseTMP_Dropdown(GameObject obj)
        {
            foreach (var comp in TMP_Dropdown.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onValueChanged.RemoveAllListeners();
                comp.onValueChanged.Invoke(0);
            }
        }

        #endregion

        #region 清理Dropdown委托

        static void ReleaseDropdown(GameObject obj)
        {
            foreach (var comp in Dropdown.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onValueChanged.RemoveAllListeners();
                comp.onValueChanged.Invoke(0);
            }
        }

        #endregion
        

        #region 清理Button委托

        static void ReleaseButton(GameObject obj)
        {
            foreach (var comp in Button.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onClick.RemoveAllListeners();
                comp.onClick.Invoke();
            }
        }

        #endregion
        

        #region 清理InputField委托

        static void ReleaseInputField(GameObject obj)
        {
            foreach (var comp in InputField.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onValueChanged.RemoveAllListeners();
                comp.onEndEdit.RemoveAllListeners();
                comp.onValueChanged.Invoke(string.Empty);
                comp.onEndEdit.Invoke(string.Empty);
            }
        }

        #endregion
        

        #region 清理TMP_InputField委托

        static void ReleaseTMP_InputField(GameObject obj)
        {
            foreach (var comp in TMP_InputField.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onValueChanged.RemoveAllListeners();
                comp.onEndEdit.RemoveAllListeners();
                comp.onValueChanged.Invoke(string.Empty);
                comp.onEndEdit.Invoke(string.Empty);
            }
        }

        #endregion

        #region 清理Slider委托

        static void ReleaseSlider(GameObject obj)
        {
            foreach (var comp in Slider.Entities)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.onValueChanged.RemoveAllListeners();
                comp.onValueChanged.Invoke(0);
            }
        }

        #endregion

        #region 清理X3Animator回调

        static void ReleaseX3AnimatorListener(GameObject obj)
        {
            foreach (var comp in X3Animator.RunningList)
            {
                //todo: to be optimized
                if (comp == null)
                    continue;
                if (!comp.transform.IsChildOf(obj.transform))
                    continue;
                comp.RemoveAllListener();;
            }
        }

        #endregion
    }
}