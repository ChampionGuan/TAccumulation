-- 时间线事件
local function LineEvent(delay, args, invoke, host, index)
    local t = {}
    t.Index = index
    -- 延时
    t.Delay = delay
    -- 结束
    t.IsOver = false
    -- 目标
    t.Host = host
    -- 参数
    t.Args = args
    -- 回调
    t.Invoke = invoke

    -- 重置
    function t:Reset()
        self.IsOver = false
    end
    -- 计时
    function t:Ticker(p)
        if self.IsOver then
            return
        end
        if self.Delay > p then
            return
        end
        if nil ~= self.Invoke then
            self.Invoke(self.Host, self.Args, self.Index)
        end
        self.IsOver = true
    end

    return t
end

-- 时间线
local function TimeLine(index)
    local t = {}
    t.Index = index
    -- 开始
    t.IsStart = false
    -- 暂停
    t.IsPause = false
    -- 计时
    t.Ticker = 0
    -- 线上事件
    t.Events = {}

    -- 添加事件
    function t:AddEvent(delay, args, invoke, host)
        local event = LineEvent(delay, args, invoke, host, self.Index)
        table.insert(self.Events, event)
    end
    -- 更新
    function t:FixedUpdate()
        if not self.IsStart or self.IsPause then
            return
        end
        self.Ticker = self.Ticker + TimerManager.fixedDeltaTime
        for k, v in pairs(self.Events) do
            v:Ticker(self.Ticker)
        end
    end
    -- 清除
    function t:Clear()
        self.Events = {}
        self.Ticker = 0
    end
    -- 重置
    function t:Reset()
        self.IsStart = false
        self.IsPause = false
        self.Ticker = 0
        for k, v in pairs(self.Events) do
            v:Reset()
        end
    end
    -- 开始
    function t:Start()
        self:Reset()
        self.IsStart = true
        self:FixedUpdate()
    end
    -- 暂停
    function t:Pause()
        self.IsPause = true
    end
    -- 恢复
    function t:Resume()
        self.IsPause = false
    end

    return t
end

return {
    TimeLine = TimeLine,
    LineEvent = LineEvent
}
