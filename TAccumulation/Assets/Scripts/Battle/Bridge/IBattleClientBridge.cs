using UnityEngine;

namespace X3Battle
{
    public interface IBattleClientBridge
    {
        /// <summary>
        /// lua端桥
        /// </summary>
        /// <returns></returns>
        IBattleLuaBridge luaBridge { get; }

        /// <summary>
        /// 当游戏被重启
        /// </summary>
        void OnGameReboot();

        /// <summary>
        /// 当战斗结束
        /// </summary>
        void OnBattleDestroy();

        /// <summary>
        /// 重启lua虚拟机（仅在调试环境下起效）
        /// </summary>
        void RestartLuaEnv(bool force);

        /// <summary>
        /// 执行lua逻辑
        /// </summary>
        /// <param name="str"></param>
        object[] DoLuaString(string str);

        /// <summary>
        /// 获取lua值
        /// </summary>
        /// <param name="luaTable"></param>
        /// <param name="key"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        T GetLuaValue<T>(object luaTable, string key);

        /// <summary>
        /// 调用lua方法
        /// </summary>
        /// <param name="globalFuncName"></param>
        /// <param name="args"></param>
        /// <param name="result"></param>
        void CallLuaFunction(string globalFuncName, object[] args, out object[] result);

        /// <summary>
        /// 调用lua方法
        /// </summary>
        /// <param name="luaTable"></param>
        /// <param name="funcName"></param>
        /// <param name="args"></param>
        /// <param name="result"></param>
        void CallLuaFunction(object luaTable, string funcName, object[] args, out object[] result);

        /// <summary>
        /// 获取lua端调用堆栈
        /// </summary>
        /// <returns></returns>
        string GetCallstack();

        /// <summary>
        /// 上报异常
        /// </summary>
        /// <param name="e"></param>
        /// <param name="message"></param>
        void ReportException(System.Exception e, string message);

        /// <summary>
        /// 上报自定义数据
        /// 崩溃详情页->跟踪数据->valueMapOthers.txt 查看
        /// </summary>
        void ReportCustomInfo(string key, string value);

        /// <summary>
        /// 获得主相机
        /// </summary>
        /// <returns></returns>
        Camera GetMainCamera();

        /// <summary>
        /// 获得UI相机
        /// </summary>
        /// <returns></returns>
        Camera GetUICamera();

        /// <summary>
        /// 获得UI根节点
        /// </summary>
        /// <returns></returns>
        RectTransform GetUIRoot();

        /// <summary>
        /// 节点显隐时的动效播放
        /// </summary>
        /// <param name="node"></param>
        /// <param name="visible"></param>
        void NodePlayMotion(RectTransform node, bool visible);

        /// <summary>
        /// 播放背景音乐
        /// </summary>
        /// <param name="eventName"></param>
        /// <param name="stateName"></param>
        /// <param name="stateGroup"></param>
        void PlayMusic(string eventName, string stateName, string stateGroup, bool isLoop);

        /// <summary>
        /// 获取当前正在播放的背景音乐名字
        /// </summary>
        /// <returns></returns>
        string GetCurPlayStateName();

        /// <summary>
        /// 获取文本信息
        /// </summary>
        /// <param name="uiTextID"></param>
        /// <returns></returns>
        string GetUIText(int uiTextID);

        /// <summary>
        /// 设置UI交互性开关
        /// </summary>
        /// <param name="go"></param>
        /// <param name="enabled"></param>
        void SetUITouchEnable(GameObject go, bool enabled);
    }
}