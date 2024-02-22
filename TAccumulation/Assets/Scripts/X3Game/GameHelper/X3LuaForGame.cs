using UnityEngine;
using XLua;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PapeGames.X3
{
    public static partial class X3Lua
    {
        private static X3Game.IX3LuaGameDelegate s_X3LuaGameDelegate;
        public static void SetDelegate(X3Game.IX3LuaGameDelegate iX3LuaGameDelegate)
        {
            s_X3LuaGameDelegate = iX3LuaGameDelegate;
        }

        public static X3Game.IX3LuaGameDelegate X3LuaGameDelegate
        {
            get { return s_X3LuaGameDelegate; }
        }
        static bool s_GameInited = false;
        public static bool IsGameInited { get { return s_GameInited; } }
        public static void InitForGame(bool editorGameInit = true)
        {
            if (s_GameInited) return;
            try
            {
#if UNITY_EDITOR
                if (!Application.isPlaying)
                {
                    RequireLuaScript("Editor.Misc.EditorNoPlayingInit", "X3Lua",  true);
                }
                else
                {
                    InitRuntime(editorGameInit);
                }
#else
                InitRuntime(editorGameInit);
#endif

                s_GameInited = true;
            }
            catch (System.Exception e)
            {
                X3Debug.LogErrorFormat("X3Lua.InitForGame: {0}", e.Message);
            }
        }

        static void InitRuntime(bool editorGameInit = true)
        {
#if _PAPER_SDK_ && !UNITY_EDITOR
            SetField("PAPER_SDK", true);
#endif
            //战斗自动化测试宏定义
#if AIRTEST
            SetField("AIRTEST", true);
#endif
            
            RequireLuaScript("GameInit", "X3Lua",  true);
#if UNITY_EDITOR
            if (editorGameInit)
            {
                RequireLuaScript("Editor.Misc.EditorGameInit", "X3Lua",  true);
            }
#endif
        }


#if UNITY_EDITOR
        [MenuItem("XLua/ReloadLua", false, 1)]
        static void ReloadLua()
        {
            EventMgr.Dispatch("RELOAD_LUA", null);
        }

        [MenuItem("XLua/Print Registry", false, 1)]
        static void PrintRegistry()
        {
            if (X3Lua.IsInited)
            {
                System.GC.Collect();
                X3Lua.FullGc();
                X3Lua.DoString("require('Runtime.Common.BuildIn.xlua.util').print_func_ref_by_csharp()");
            }
        }
#endif
    }
}