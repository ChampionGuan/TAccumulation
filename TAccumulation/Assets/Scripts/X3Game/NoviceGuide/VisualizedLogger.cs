using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using PapeGames.X3;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace PapeGames.NoviceGuide
{
    [Serializable]
    public class GuideLog
    {
        public long Time;
        public string TriggerType;
        public string TriggerParams;
        public List<CheckResult> CheckResults;
    }

    [Serializable]
    public class GuideLogs
    {
        public List<GuideLog> Items;
    }

    [Serializable]
    public class CheckResult
    {
        public int Order;
        public string GuideID;
        public string GuideName;
        public bool Result;
        public bool IsCompleted;
        public List<ConditionCheck> GuideChecks;
    }
    
    public enum ConditionCheckType
    {
        Level       = 1, // 等级条件
        Unlock      = 2, // 系统解锁条件
        UI          = 3, // UI开启条件
        UIControl   = 4, // UI控件存在且显示的条件
        PageUI      = 5, // 页签打开条件
        Stage       = 6, // 关卡完成
        Guide       = 7, // 前置引导
        Extra       = 8, // 额外条件
        Event       = 9, // 事件
    }

    [Serializable]
    public class ConditionCheck
    {
        public int ConditionType;
        public string ConditionTypeDesc;
        public string ConditionParams;
        public string TargetParams;
        public bool Result;
    }
    
    [Serializable]
    public class GuideControlPathCheck
    {
        public string Type;
        public string ID;
        public string OldPath;
        public string NewPath;
    }

    public class VisualLogger
    {
        private static bool Inited = false;
        
        public static string FileName = "";
        private static readonly bool enableWriteToFile = true;
        private static FileStream fs;
        private static StreamWriter sw;
        
        
        private const string endStr = "]}";

        public static int RunningGuideID;
        public static int RunningStepID;
        public static List<GuideLog> ItemSource = new List<GuideLog>();

        public static event Action OnItemSourceChange;
        public static event Action OnRuntimeInfoChange;
        public static event Action<int,bool> OnGuideGameDataChanged;
        public static event Action<string,string> OnRuntimeGuideControlChange; 
        public static event Action<string,string> OnRunTimeGuideCheckResultChange; 

        public static void Init()
        {
            if (Inited) return;
            if (Application.isBatchMode) return;
            if (enableWriteToFile)
            {
                if (FileName!="")
                {
                    CreateFile($"{Application.persistentDataPath}/guidelog{FileName}.txt");
                }
            }

            #if UNITY_EDITOR
            EditorApplication.playModeStateChanged += change =>
            {
                if(change == PlayModeStateChange.ExitingPlayMode)
                    Destroy();
            };
            #endif
            Inited = true;
        }

        public static void Destroy()
        {
            try
            {
                if (enableWriteToFile && fs != null)
                {
                    sw?.Flush();
                    sw?.Close();
                    fs.Close();
                }
            }
            catch (System.Exception exception)
            {
                Debug.LogException(exception);
            }
        }

        private static void CreateFile(string fullPath)
        {
            try
            {
                fs = new FileStream(fullPath, FileMode.Create, FileAccess.ReadWrite, FileShare.ReadWrite);
                sw = new StreamWriter(fs);
            }
            catch (System.Exception exception)
            {
                Debug.LogException(exception);
            }
        }


        public static void SetSource(string text)
        {
            ItemSource = JsonUtility.FromJson<GuideLogs>("{\"Items\": ["+string.Join(",",text.TrimEnd('\n').Split('\n'))+"]}").Items;
            OnItemSourceChange?.Invoke();
        }

        public static void SetFileName(string fileName)
        {
            FileName = fileName;
        }

        [Conditional("UNITY_EDITOR")]
        public static void Log(string message)
        {
            Init();
            LogProxy.Log(message);
            ItemSource.Add(JsonUtility.FromJson<GuideLog>(message));
            OnItemSourceChange?.Invoke();
            
            if (enableWriteToFile && sw != null)
            {
                sw.WriteLine(message);
                sw.Flush();
            }
        }
        [Conditional("UNITY_EDITOR")]
        public static void RefreshRunningGuideInfo(int guideID)
        {
            RunningGuideID = guideID;
            OnRuntimeInfoChange?.Invoke();
        }

        [Conditional("UNITY_EDITOR")]
        public static void RefreshRunningStepInfo(int stepID)
        {
            RunningStepID = stepID;
            OnRuntimeInfoChange?.Invoke();
        }

        [Conditional("UNITY_EDITOR")]
        public static void RefreshGuideState(int guideID,bool status)
        {
            OnGuideGameDataChanged?.Invoke(guideID, status);
        }
        
        [Conditional("UNITY_EDITOR")]
        public static void RefreshGuideEditor()
        {
            OnRuntimeInfoChange?.Invoke();
        }
        
        [Conditional("UNITY_EDITOR")]
        public static void LogPathChange(string message)
        {
            Init();
            LogProxy.Log(message);
            var guideControlCheck =  JsonUtility.FromJson<GuideControlPathCheck>(message);
            if (guideControlCheck.Type == "GuideContent")   // 查找控件
            {
                OnRuntimeGuideControlChange?.Invoke(guideControlCheck.ID, guideControlCheck.NewPath);
            } 
            else if (guideControlCheck.Type == "Guide") // 引导条件
            {
                OnRunTimeGuideCheckResultChange?.Invoke(guideControlCheck.ID,guideControlCheck.NewPath);
            }
            if (enableWriteToFile && sw != null)
            {
                sw.WriteLine($"PathChange:{message}");
                sw.Flush();
            }

        }
        
    }
}