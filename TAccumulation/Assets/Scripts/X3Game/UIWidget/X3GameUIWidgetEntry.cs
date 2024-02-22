using XLua;

namespace X3Game
{
    [LuaCallCSharp]
    public static class X3GameUIWidgetEntry
    {
        public static IX3GameUIWidgetEventDelegate EventDelegate { set; get; }
    }
}