--- X3@PapeGames
--- GameStart 本文件属于Lua游戏启动的入口文件
--- Created by Tungway
--- Created Date: 2020/8/27
---GAME_FIRST_START's value set by GameMgr.cs
START_STATE = START_STATE or "FirstStart"
---重新执行全局变量的Init
if not GAME_FIRST_START and not GAME_FORCE_REBOOT then
    GameMgr.ReInitGlobal()
    GAME_FORCE_REBOOT = nil
end
GameStateMgr.Switch(GameState[START_STATE], GAME_FIRST_START)