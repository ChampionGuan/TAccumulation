using System.Collections;
using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 屏幕按压检测工具类（主要用来被Lua使用）
    /// </summary>
    [XLua.LuaCallCSharp]
    public static class ScreenPressCheckUtil
    {
        public static void AddListener(ObjLinker context, string name, System.Action<Vector2> onPress)
        {
            GameObject go = UIUtility.GetOCX(context, name);
            if (go != null)
            {
                ComponentUtility.GetComponent(go, out ScreenPressChecker spc);
                spc.OnPress += onPress;
            }
        }
    
        public static void RemoveListener(ObjLinker context, string name, System.Action<Vector2> onPress)
        {
            GameObject go = UIUtility.GetOCX(context, name);
            if (go != null)
            {
                ComponentUtility.GetComponent(go, out ScreenPressChecker spc);

                if (onPress != null)
                {
                    spc.OnPress -= onPress;
                }
                else
                {
                    spc.OnPress = null;
                }
            
            }
        }

        public static void SetParam(ObjLinker context, string name,float interval, float distance, int touchCount )
        {
            GameObject go = UIUtility.GetOCX(context, name);
            if (go != null)
            {
                ComponentUtility.GetComponent(go, out ScreenPressChecker spc);
                spc.Interval = interval;
                spc.Distance = distance;
                spc.TouchCount = touchCount;
            }
        }
    }

}
