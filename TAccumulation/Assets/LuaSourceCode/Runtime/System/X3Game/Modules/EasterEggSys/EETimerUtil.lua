
-- 这个Util类处理彩蛋系统的 "再次生效" 定时器逻辑 生命周期跟随EasterEggBLL
---@class EETimerUtil 
local EETimerUtil = {}

---@class EasterEggReEffectTimerInfo 彩蛋ReEffect定时器
---@filed timer number TimerId -- 定时器用于检查彩蛋的ReEffect行为
---@field timestamp number timestamp -- 彩蛋对应ReEffect时间戳 配套使用
---@field easterEggId number 彩蛋Id 便于索引

function EETimerUtil:OnInit()
    ---@type EasterEggReEffectTimerInfo 彩蛋ReEffect定时器信息
    self.reEffectTimerInfo = nil
end

function EETimerUtil:OnClear()
    TimerMgr.DiscardTimerByTarget(self)
    self.reEffectTimerInfo = nil
end

---@private Get 对符合条件(可再次生效且未到达再次生效时间点)的彩蛋返回其再次生效时间
---@return bool, number bool: 是否符合条件, number: 符合条件彩蛋的对应再次生效时间戳
local function __checkGetReEffectTime(self, easterEggId)
    -- 只处理客户端彩蛋
    if not BllMgr.GetEasterEggBLL():CheckIfClientType(easterEggId) then return end

    -- 获取配置&数据
    local eeCfg = LuaCfgMgr.Get("EasterEgg", easterEggId) if not eeCfg then Debug.LogError("EECfg not found, eeId : " .. tostring(easterEggId or "nil")) return end
    local eeData = BllMgr.GetEasterEggBLL():GetEasterEggData(easterEggId)

    -- 这个彩蛋之前是否生效过
    local effectedBefore = eeData and eeData.EffectTime > 0

    -- 当前是否在生效
    local isInEffect = BllMgr.GetEasterEggBLL():CheckIfInEffect(easterEggId)

    -- 3. 有历史生效记录的旧彩蛋 && 当前未生效 && CD类型(EffectCDType)不是 "不能再次生效" && CD类型不是 "无CD" && 没有到达再次生效时间;
    if effectedBefore and not isInEffect and eeCfg.EffectCDType ~= EasterEggEnum.EffectCDType.AlwaysCD and eeCfg.EffectCDType ~= EasterEggEnum.EffectCDType.NoCD then
        return eeData.ReEffectTime
    end
end

-- 处理timer
---@param self EETimerUtil
---@param reEffectTime number 彩蛋的再次刷新时间
---@param easterEggId number 彩蛋Id
local function __handleTimer(self, reEffectTime, easterEggId)
    if not self.reEffectTimerInfo or self.reEffectTimerInfo.timestamp > reEffectTime then
        -- clear timer
        if self.reEffectTimerInfo then
            TimerMgr.Discard(self.reEffectTimerInfo.timer)
            self.reEffectTimerInfo = nil
        end

        -- create timer
        local reEffectTimer
        local curTime = TimerMgr.GetCurTimeSeconds()
        reEffectTimer = TimerMgr.AddTimer(
                reEffectTime - curTime + math.random(1, 5),     -- 这里加个随机值
                function()
                    -- 检查所有彩蛋的再次生效 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
                    self:CheckAllEasterEggReEffect()

                    TimerMgr.Discard(reEffectTimer)
                    self.reEffectTimerInfo = nil
                end, self, 1
        )
        self.reEffectTimerInfo = {
            timer = reEffectTimer,
            timestamp = reEffectTime,
            easterEggId = easterEggId,
        }
    end
end

---@private 检查所有彩蛋的再次生效 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
local function __checkAllEasterEggReEffect(self)
    local allEasterEggMap = SelfProxyFactory.GetEasterEggProxy():GetAllData()
    if table.isnilorempty(allEasterEggMap) then return end
    
    local curTime = TimerMgr.GetCurTimeSeconds()
    local minReEffectTime, targetEasterEggId
    for easterEggId, easterEggData in pairs(allEasterEggMap) do
        local reEffectTime = __checkGetReEffectTime(self, easterEggId)
        if reEffectTime and reEffectTime > 0 then
            if reEffectTime <= curTime then
                BllMgr.GetEasterEggBLL():CheckEffectEasterEgg(easterEggId)
            else
                if not minReEffectTime or minReEffectTime > reEffectTime then
                    minReEffectTime = reEffectTime
                    targetEasterEggId = easterEggId
                end
            end
        end
    end
    
    if minReEffectTime then
        __handleTimer(self, minReEffectTime, targetEasterEggId)
    end
end

---@private 检查并更新再次生效逻辑的定时器
---@param self EasterEggBLL
local function __checkUpdateReEffectTimer(self, easterEggId)
    -- 不符合条件的彩蛋跳过
    local reEffectTime = __checkGetReEffectTime(self, easterEggId)
    if not reEffectTime or reEffectTime <= 0 then return end

    -- 当前时间 > 可再次生效时间的彩蛋跳过 在这里不处理ReEffect Request逻辑
    local curTime = TimerMgr.GetCurTimeSeconds()
    if reEffectTime < curTime then return end
    
    -- 处理timer
    __handleTimer(self, reEffectTime, easterEggId)
end

---@public 检查所有彩蛋的再次生效 (时间符合的彩蛋会立即Effect, 还没到时间的所有彩蛋会计算一个最近的时间点开启一个定时器进行下一步检查)
function EETimerUtil:CheckAllEasterEggReEffect()
    __checkAllEasterEggReEffect(self)
end

---@public 彩蛋数据更新时回调 检查timer
function EETimerUtil:OnSyncEasterEgg(easterEggId)
    -- 检查更新定时器 smf
    __checkUpdateReEffectTimer(self, easterEggId)
end

return EETimerUtil