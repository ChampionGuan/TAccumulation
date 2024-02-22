using System.Collections;
using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;
using  System;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 吹气检测工具类（主要用来被Lua使用）
    /// </summary>
    [XLua.LuaCallCSharp]
    public static class BlowCheckUtil
    {
        
        public static void AddListener(GameObject blowObj, Action onBlowSuccess, Action onBlowStart, Action onBlowStop, Action<float> onBlowProgress)
        {
            if (blowObj != null)
            {
                ComponentUtility.GetComponent(blowObj, out BlowChecker bc);
                bc.OnBlowSuccess += onBlowSuccess;
                bc.OnBlowStart += onBlowStart;
                bc.OnBlowStop += onBlowStop;
                bc.OnBlowProgress += onBlowProgress;
            }
        }
    
        public static void RemoveListener(GameObject blowObj, Action onBlowSuccess, Action onBlowStart, Action onBlowStop, Action<float> onBlowProgress)
        {
            if (blowObj != null)
            {
                ComponentUtility.GetComponent(blowObj, out BlowChecker bc);
            

                if (onBlowSuccess != null)
                {
                    bc.OnBlowSuccess -= onBlowSuccess;
                }
                else
                {
                    bc.OnBlowSuccess = null;
                }
                
                if (onBlowStart != null)
                {
                    bc.OnBlowStart -= onBlowStart;
                }
                else
                {
                    bc.OnBlowStart = null;
                }
                
                if (onBlowStop != null)
                {
                    bc.OnBlowStop -= onBlowStop;
                }
                else
                {
                    bc.OnBlowStop = null;
                }
            
                if (onBlowProgress != null)
                {
                    bc.OnBlowProgress -= onBlowProgress;
                }
                else
                {
                    bc.OnBlowProgress = null;
                }
            }
        }
    
        public static void StartCheck(GameObject blowObj)
        {
            if (blowObj != null)
            {
                ComponentUtility.GetComponent(blowObj, out BlowChecker bc);
                bc.StartCheck();
            }
        }
    
        public static void EndCheck(GameObject blowObj)
        {
            if (blowObj != null)
            {
                ComponentUtility.GetComponent(blowObj, out BlowChecker bc);
                bc.EndCheck();
            }
        }
        
        public static void SetParam(GameObject blowObj, float volume,int frameCount)
        {
            if (blowObj != null)
            {
                ComponentUtility.GetComponent(blowObj, out BlowChecker bc);
                bc.Volume = volume;
                bc.FrameCount = frameCount;
            }
        }
        
    }
}

