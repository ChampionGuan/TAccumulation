-- ai状态控制器
local function AIStateMachine()
    local t = {}
    t.CurrStat = nil

    function t:Initialize()
        self.CurrStat = nil
    end

    function t:FixedUpdate()
        if nil ~= self.CurrStat then
            self.CurrStat:FixedUpdate()
        end
    end

    function t:Update()
        if nil ~= self.CurrStat then
            self.CurrStat:Update()
        end
    end

    function t:ChangeStat(stat)
        -- 已经在当前状态了，不需要再进入一次
        if self.CurrStat == stat then
            return
        end

        if nil ~= self.CurrStat then
            self.CurrStat:Exit()
        end
        self.CurrStat = stat
        if nil ~= self.CurrStat then
            self.CurrStat:Enter()
        end
    end

    return t
end

-- ai状态
local function AIState(actor, enterInvoke, exitInvoke, updateInvoke, fixedUpdateInvoke)
    local t = {}

    t.Actor = actor
    t.EnterInvoke = enterInvoke
    t.ExitInvoke = exitInvoke
    t.UpdateInvoke = updateInvoke
    t.FixedUpdateInvoke = fixedUpdateInvoke

    function t:FixedUpdate()
        if nil ~= self.FixedUpdateInvoke then
            self.FixedUpdateInvoke(self.Actor)
        end
    end

    function t:Update()
        if nil ~= self.UpdateInvoke then
            self.UpdateInvoke(self.Actor)
        end
    end

    function t:Enter()
        if nil ~= self.EnterInvoke then
            self.EnterInvoke(self.Actor)
        end
    end

    function t:Exit()
        if nil ~= self.ExitInvoke then
            self.ExitInvoke(self.Actor)
        end
    end

    return t
end

return {
    AIStateMachine = AIStateMachine,
    AIState = AIState
}
