// Name：IGameMgrDelegate
// Created by jiaozhu
// Created Time：2022-08-31 12:56

namespace PapeGames.X3
{
    [XLua.CSharpCallLua]
    public interface IGameMgrDelegate
    {
        void OnPreUpdate(float dt, float realtimeSinceStartup);
        void OnUpdate(float dt, float realtimeSinceStartup);
        void OnFixedUpdate(float dt, float realtimeSinceStartup);
        void OnPreLateUpdate(float dt, float realtimeSinceStartup);
        void OnLateUpdate(float dt, float realtimeSinceStartup);
        void OnPreFinalUpdate(float dt, float realtimeSinceStartup);
        void OnFinalUpdate(float dt, float realtimeSinceStartup);
        void OnApplicationQuit();
        void OnApplicationFocus(bool focus);
        void OnApplicationPause(bool pauseStatus);
        void OnLowMemory();
        void OnStartRun();
        void OnStopRun();
        void OnLogout();
    }
}