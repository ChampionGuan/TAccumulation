using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PapeGames.X3;
using UnityEngine;
using X3Game.X3LuaBuilder;
using XLua;

namespace X3Game
{
    [LuaCallCSharp]
    public partial class UITextLanguage
    {
        static List<Func<int, string>> s_GetTextList;
        static List<Func<int, bool>> s_IsTextExists;
        static Dictionary<string, string> s_ReplaceMap;
        static Dictionary<string, bool> s_TempReplaceMap;
        static Dictionary<string, bool> s_ReplaceArgMap;
        static Dictionary<int, float> s_AccessMap;
        static Dictionary<int, string> s_Map;
        static List<int> s_ReplaceSuccessList;
        private static string s_TagBegin = "<param>";
        private static string s_TagEnd = "</param>";
        private static List<XFileUIText> s_UITextFiles;
        static float s_Dt = 60f;
        static float s_LastTick;
        private static int s_LastFrameCount = -1;
        private static int s_CurFrameCount = 0;
        private static bool s_LazyInit = false;
        private static object s_LockObj = new object();
        static bool s_IsLanguageDebug;
        public static bool IsLanguageDebug
        {
            get { return s_IsLanguageDebug; }
            set
            {
                if (s_IsLanguageDebug != value)
                {
                    s_IsLanguageDebug = value;
#if DEBUG_GM || UNITY_EDITOR
                    ClearCache(true);
#endif
                }
            }
        }
#if UNITY_EDITOR
        public static Action EditorInitCall = null;
#endif

        public static string GetUIText(int id)
        {
            return InternalGetUIText(id);
        }


        public static string GetUIText(int id, params object[] args)
        {
            string res = InternalGetUIText(id, args);
            if (!string.IsNullOrEmpty(res))
            {
                if (args.Length > 0)
                {
                    res = string.Format(res, args);
                }

                return res;
            }

            return res;
        }

        public static bool IsExist(int id)
        {
            if (s_IsTextExists == null || s_IsTextExists.Count == 0) return true;
            bool res = false;
            try
            {
                foreach (var it in s_IsTextExists)
                {
                    if (it.Invoke(id))
                    {
                        res = true;
                        break;
                    }
                }
            }
            catch (Exception e)
            {
            }

            return res;
        }

        public static void Tick()
        {
            if (!IsInit)
            {
                s_LastTick = Time.realtimeSinceStartup;
                return;
            }

            s_CurFrameCount = Time.frameCount;

            var cur = Time.realtimeSinceStartup;
            if (cur - s_LastTick < s_Dt) return;
            s_LastTick = cur;
            ClearCache();
        }

        static void ClearCache(bool forceClear = false)
        {
            var temp = ListPool<int>.Get();
            var cur = Time.realtimeSinceStartup;
            foreach (var it in s_AccessMap)
            {
                if (forceClear || cur - it.Value >= s_Dt)
                {
                    temp.Add(it.Key);
                }
            }

            if (temp.Count > 0)
            {
                foreach (var it in temp)
                {
                    RemoveCacheId(it);
                }
            }

            ListPool<int>.Release(temp);
        }

        /// <summary>
        /// 添加标签
        /// </summary>
        /// <param name="tag"></param>
        /// <param name="rep"></param>
        /// <param name="isCache"></param>
        /// <param name="needArg"></param>
        public static void AddReplaceTag(string tag, string rep, bool isCache = true,bool needArg=false)
        {
            if(string.IsNullOrEmpty(tag)) return;
            if (isCache)
            {
                if (s_ReplaceMap.ContainsKey(tag))
                {
                    CheckCache();
                }

                s_ReplaceMap[tag] = rep;
            }
            else
            {
                s_TempReplaceMap[tag] = true;
                if (needArg)
                {
                    s_ReplaceArgMap[tag] = true;
                }
            }
        }


        /// <summary>
        /// 删除标签
        /// </summary>
        /// <param name="tag"></param>
        public static void RemoveReplaceTag(string tag)
        {
            if (s_ReplaceMap.ContainsKey(tag))
            {
                s_ReplaceMap.Remove(tag);
            }
            else if (s_TempReplaceMap.ContainsKey(tag))
            {
                s_TempReplaceMap.Remove(tag);
            }

            if (s_ReplaceArgMap.ContainsKey(tag)) s_ReplaceArgMap.Remove(tag);
        }

        /// <summary>
        /// 添加委托
        /// </summary>
        /// <param name="del"></param>
        public static void AddDelegate(Func<int, string> del)
        {
            if (!s_GetTextList.Contains(del))
            {
                s_GetTextList.Add(del);
            }
        }

        /// <summary>
        /// 添加委托
        /// </summary>
        /// <param name="del"></param>
        public static void AddDelegate(Func<int, bool> del)
        {
            if (!s_IsTextExists.Contains(del))
            {
                s_IsTextExists.Add(del);
            }
        }

        /// <summary>
        /// 清理委托
        /// </summary>
        /// <param name="del"></param>
        public static void RemoveDelegate(Func<int, string> del)
        {
            if (!IsInit) return;
            try
            {
                s_GetTextList.Remove(del);
            }
            catch (Exception e)
            {
            }
        }

        /// <summary>
        /// 清理委托
        /// </summary>
        /// <param name="del"></param>
        public static void RemoveDelegate(Func<int, bool> del)
        {
            if (!IsInit) return;
            try
            {
                s_IsTextExists.Remove(del);
            }
            catch (Exception e)
            {
            }
        }

        /// <summary>
        /// 清理所有委托
        /// </summary>
        public static void CleaAllDelegate()
        {
            if (s_GetTextList != null) s_GetTextList.Clear();
            if (s_IsTextExists != null) s_IsTextExists.Clear();
        }

        public static void SetCheckDt(float dt)
        {
            s_Dt = dt;
        }

        public static void Init()
        {
            if (s_LazyInit) return;
            try
            {
                var uiTextPaths = XFileMgr.UITextPaths;
                if (uiTextPaths != null)
                {
                    var lang = AppInfoMgr.Instance.Lang;
                    var langName = Locale.GetLangName(lang);
                    foreach (var it in uiTextPaths)
                    {
                        if (it.Contains(langName))
                        {
                            var f = XFileMgr.LoadPackage<XFileUIText>(it);
                            AddDelegate(f.Get);
                            AddDelegate(f.IsExist);
                            s_UITextFiles.Add(f);
                        }
                    }
                }
#if UNITY_EDITOR
                else
                {
                    if (EditorInitCall != null) EditorInitCall.Invoke();
                }
#endif
                s_LazyInit = true;
            }
            catch (Exception e)
            {
                X3Debug.LogError(e);
            }
        }

        public static void Clear()
        {
            s_LazyInit = false;
            s_CurFrameCount = 0;
            s_LastFrameCount = -1;
            s_LastTick = Time.realtimeSinceStartup;
            if (s_GetTextList != null) s_GetTextList.Clear();
            if (s_Map != null) s_Map.Clear();
            if (s_AccessMap != null) s_AccessMap.Clear();
            if (s_ReplaceMap != null) s_ReplaceMap.Clear();
            if (s_TempReplaceMap != null) s_TempReplaceMap.Clear();
            if (s_ReplaceArgMap != null) s_ReplaceArgMap.Clear();
            if (s_ReplaceSuccessList != null) s_ReplaceSuccessList.Clear();
            if (s_UITextFiles != null)
            {
                foreach (var it in s_UITextFiles)
                {
                    it.Clear();
                }

                s_UITextFiles.Clear();
            }

            CleaAllDelegate();
        }

        static void CheckCache()
        {
            if (s_ReplaceSuccessList == null || s_ReplaceSuccessList.Count == 0) return;
            foreach (var it in s_ReplaceSuccessList)
            {
                RemoveCacheId(it, true);
            }

            s_ReplaceSuccessList.Clear();
        }

        static void RemoveCacheId(int id, bool igNoreTag = false)
        {
            s_AccessMap.Remove(id);
            if (!igNoreTag)
            {
                s_ReplaceSuccessList.Remove(id);
            }

            RemoveFromMap(id);
        }

        static void LazyInit()
        {
            s_GetTextList = new List<Func<int, string>>();
            s_IsTextExists = new List<Func<int, bool>>();
            s_Map = new Dictionary<int, string>();
            s_AccessMap = new Dictionary<int, float>();
            s_ReplaceMap = new Dictionary<string, string>();
            s_TempReplaceMap = new Dictionary<string, bool>();
            s_ReplaceArgMap = new Dictionary<string, bool>();
            s_UITextFiles = new List<XFileUIText>();
            s_ReplaceSuccessList = new List<int>();
        }

        static bool CheckUITextReplace(string text, out string res)
        {
            res = text;
            if (s_ReplaceMap == null || s_ReplaceMap.Count == 0) return false;
            bool ok = false;
            foreach (var it in s_ReplaceMap)
            {
                ok = text.Contains(it.Key);
                if (ok) break;
            }

            if (ok)
            {
                CheckUITextReplaceForLua();
                var sb = StringUtility.GetStringBuilder();
                sb.Append(text);
                foreach (var it in s_ReplaceMap)
                {
                    sb.Replace(it.Key, it.Value);
                }

                res = sb.ToString();
                StringUtility.ReleaseStringBuilder(sb);
            }

            return ok;
        }

        static void CheckUITextReplaceForLua()
        {
            try
            {
                if (s_LastFrameCount == s_CurFrameCount)
                {
                    return;
                }

                s_LastFrameCount = s_CurFrameCount;

                X3Lua.X3LuaGameDelegate?.CheckUITextReplace();
            }
            catch (Exception e)
            {
            }
        }

        static string ParseArg(object[] args = null)
        {
            string res = null;
            if (args != null && args.Length > 0)
            {
                var sb2 = StringUtility.GetStringBuilder();
                int total = args.Length - 1;
                for (int i = 0; i < args.Length; i++)
                {
                    if (i == total)
                    {
                        sb2.Append($"{args[i]}");
                        
                    }
                    else
                    {
                        sb2.Append($"{args[i]},");
                    }
                }

                res = sb2.ToString();

                StringUtility.ReleaseStringBuilder(sb2);
            }

            return res;
        }

        static bool CheckTempReplace(string text, out string res, object[] args = null)
        {
            bool ok = false;
            res = text;
            var del = X3Lua.X3LuaGameDelegate;
            if (del == null || s_TempReplaceMap == null || s_TempReplaceMap.Count == 0) return ok;
            StringBuilder sb = null;

            string externArgs = null;

            foreach (var it in s_TempReplaceMap)
            {
                if (res.Contains(it.Key))
                {
                    ok = true;
                    if (sb == null)
                    {
                        sb = StringUtility.GetStringBuilder();
                        sb.Append(res);
                        if (s_ReplaceArgMap.ContainsKey(it.Key))
                        {
                            externArgs = ParseArg(args);
                        }
                    }

                    int index = 0;
                    int length = it.Key.Length;
                    int beginLength = s_TagBegin.Length;


                    while ((index = res.IndexOf(it.Key, index)) != -1)
                    {
                        index += length;
                        int start = index + beginLength;
                        int end = res.IndexOf(s_TagEnd, start);
                        var param = res.Substring(start, end - start);
                        var value = del.GetUITextReplace(CommonUtility.StringToHash(it.Key), param, externArgs);
                        sb.Replace($"{it.Key}{s_TagBegin}{param}{s_TagEnd}", value);
                    }
                }
            }

            if (sb != null)
            {
                res = sb.ToString();
                StringUtility.ReleaseStringBuilder(sb);
            }

            return ok;
        }

        public static string ReplaceTag(string text, out bool ok)
        {
            return InternalReplaceTag(text, out ok, out var cache);
        }

        public static bool IsInit
        {
            get { return s_GetTextList != null && s_GetTextList.Count > 0; }
        }

        static void AccessId(int id)
        {
            float cur = 0;
            try
            {
                cur = Time.realtimeSinceStartup;
            }
            catch (Exception e)
            {
            }

            s_AccessMap[id] = cur;
        }

        static void AddToMap(int id, string text)
        {
            s_Map.Add(id, text);
        }

        static void RemoveFromMap(int id)
        {
            if (!s_Map.ContainsKey(id)) return;
            s_Map.Remove(id);
        }

        static string InternalGetUIText(int id, object[] args = null)
        {
            lock (s_LockObj)
            {
                Init();
                if (!IsExist(id))
                {
                    return string.Empty;
                }

                AccessId(id);
                string res = string.Empty;
                try
                {
                    if (s_ReplaceSuccessList.Contains(id))
                    {
                        CheckUITextReplaceForLua();
                    }

                    if (!s_Map.TryGetValue(id, out res))
                    {
                        foreach (var del in s_GetTextList)
                        {
                            res = del.Invoke(id);
                            if (!string.IsNullOrEmpty(res))
                            {
                                bool ok = false;
                                bool cache = false;
                                res = InternalReplaceTag(res, out ok, out cache, args);
                                if (ok)
                                {
                                    if (!s_ReplaceSuccessList.Contains(id))
                                    {
                                        s_ReplaceSuccessList.Add(id);
                                    }
                                }
#if UNITY_EDITOR
                                if (!Application.isPlaying)
                                {
                                    res = res.Replace("\\\\", "\\");
                                    res = res.Replace("\\n", "\n");
                                }
#endif
#if DEBUG_GM || UNITY_EDITOR
                                if (IsLanguageDebug)
                                {
                                    res = $"[{id}]{res}";
                                }
#endif
                                if (cache)
                                {
                                    AddToMap(id, res);
                                }

                                break;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    X3Debug.LogError(e);
                }


                return res;
            }
        }

        static string InternalReplaceTag(string text, out bool ok, out bool cache, object[] args = null)
        {
            ok = false;
            cache = true;
            if (string.IsNullOrEmpty(text)) return text;
            if (CheckUITextReplace(text, out string res))
            {
                ok = true;
                return res;
            }
            else if (CheckTempReplace(text, out string res2, args))
            {
                cache = false;
                return res2;
            }

            return text;
        }

        static UITextLanguage()
        {
            LazyInit();
        }
    }
}