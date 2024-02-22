// Name：IX3LuaDelegate
// Created by jiaozhu
// Created Time：2022-08-31 14:01

using UnityEngine;

namespace X3Game
{
    [XLua.CSharpCallLua]
    public interface IX3LuaGameDelegate
    {
        void OnEvent(string eventName, object eventValue);
        string HashToString(uint hash);
        void OnOpenUrl(string url, bool fullScreen = false);
        void OnLuaDestroy();

        void CheckUITextReplace();
        string GetUITextReplace(uint tag,string param,string externArgs=null);
    }
}