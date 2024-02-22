using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 娃娃机BLLWrapper，由于娃娃机还有部分代码在C#，需要访问数据层
    /// </summary>
    public class UFOCatcherBLLWrapper
    {
        public static XLua.LuaTable UFOCatcherBLL
        {
            get
            {
                XLua.LuaFunction a = X3Lua.GetLuaFunction("BllMgr.Get");
                XLua.LuaTable b = a.Func<string, XLua.LuaTable>("UFOCatcherBLL");
                return b;
            }
        }

        /// <summary>
        /// 获取属性
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="name"></param>
        /// <returns></returns>
        public static T GetField<T>(string name)
        {
            return X3Lua.GetField<T>(UFOCatcherBLL, name);
        }

        /// <summary>
        /// 设置属性
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="name"></param>
        /// <param name="value"></param>
        public static void SetField<T>(string name, T value)
        {
            X3Lua.SetField<T>(UFOCatcherBLL, name, value);
        }

        /// <summary>
        /// 执行函数,带返回
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="funcName">函数名</param>
        /// <param name="args"></param>
        /// <returns></returns>
        public static T CallLuaFunction<T>(string funcName, params object[] args)
        {
            return X3Lua.CallLuaFunction<T>(UFOCatcherBLL, funcName, args);
        }

        /// <summary>
        /// 执行函数，不带返回
        /// </summary>
        /// <param name="funcName">函数名</param>
        /// <param name="args"></param>
        public static void CallLuaFunction(string funcName, params object[] args)
        {
            X3Lua.CallLuaFunction(UFOCatcherBLL, funcName, args);
        }
    }
}