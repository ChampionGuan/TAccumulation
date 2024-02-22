local PerformanceLog = {}

--region 性能打点功能
---开始性能打点
---@param tag string 业务类型
function PerformanceLog.Begin(tag, ...)
    if UNITY_EDITOR then
        Debug.LogFormat("PerformanceLog.Begin:" .. string.format(tag, ...))
    end
    if not PERFORMANCE_PROFILER_ENABLE then return end
    CS.X3Game.GameMgr.BeginPerformanceLog(string.format(tag, ...))
end

---结束性能打点
---@param tag string 业务类型
function PerformanceLog.End(tag, ...)
    if UNITY_EDITOR then
        Debug.LogFormat("PerformanceLog.End:" .. string.format(tag, ...))
    end
    if not PERFORMANCE_PROFILER_ENABLE then return end
    CS.X3Game.GameMgr.EndPerformanceLog(string.format(tag, ...))
end

---汇报美术场景名
function PerformanceLog.ReportScene(prevSceneName, sceneName)
    if UNITY_EDITOR then
        Debug.LogFormat("PerformanceLog.ReportScene: %s, prevScene=%s", sceneName, prevSceneName)
    end
    if not PERFORMANCE_PROFILER_ENABLE then return end
    CS.X3Game.GameMgr.ReportPerformanceScene(prevSceneName, sceneName)
end
--endregion

PerformanceLog.Tag = {
    ---手机
    Mobile = "业务.手机",
    ---抽卡
    Gacha = "业务.抽卡.%s",
    ---拍照
    Photo = "业务.拍照.%s",
    ---特殊约会
    SpecialDate = "业务.特约.%s",
    ---娃娃机
    UFOCatcher = "业务.娃娃机.%s",
    ---喵喵牌
    MiaoMiaoCard = "业务.喵喵牌.%s",
    ---叠叠乐
    BlockTower = "业务.叠叠乐.%s",
    ---热更--登录
    Login = "业务.登录",
    ---战斗
    Battle = "战斗.%s",
    ---战斗启动
    BattleStartup = "战斗Startup.%s",
    ---主线
    MainLine = "业务.主线.%s",
    ---动卡
    DynamicCard = "业务.动卡.%s",
    ---高光时刻
    CardHighlight = "业务.高光时刻.%s",
}

return PerformanceLog