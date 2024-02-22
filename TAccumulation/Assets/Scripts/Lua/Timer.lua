﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/1/14 17:15
--- lua 计时器
---

local cs_timer = CS.UnityEngine.Time
local Timer = class("Timer")

---update_type
local UpdateType =
{
    UPDATE = 1,
    LATE_UPDATE = 2,
    FIXED_UPDATE = 3,
    FINAL_UPDATE = 4,
}

Timer.UpdateType = UpdateType

---添加延时回调（忽略scale）
---@param delay number 单位是秒
---@param func function
---@param target table 如果有，调用func的时候就是冒号调用（可以访问方法中的self），如果没有就是点调用
---@param count boolean | number  如果是number的话，执行次数，-1或者true:无限次，>=1 执行count次数
---@param update_type number TimerMgr.UpdateType  1:update 2:lateupdate,3:fixupdate 默认1
---@return number 用于取消注册的唯一id
function Timer:AddTimer(delay,func,target,count,update_type)
    return self:GenTimer(delay,func,target,count,false,update_type)
end

---添加延时回调,考虑scale
---@param delay number 单位是秒
---@param func function
---@param target table 如果有，调用func的时候就是冒号调用（可以访问方法中的self），如果没有就是点调用
---@param count boolean | number  如果是number的话，执行次数，-1或者true:无限次，>=1 执行count次数，是否是循环调用
---@param update_type number TimerMgr.UpdateType  1:update 2:lateupdate,3:fixupdate 默认1
---@return number 用于取消注册的唯一id
function Timer:AddScaledTimer(delay,func,target,count,update_type)
    return self:GenTimer(delay,func,target,count,true,update_type)
end

---取消延时回调
---@param timer_id number
---@param force_remove boolean default false 是否强制删除，（外部调用请忽略）
function Timer:Discard(timer_id,force_remove)
    if not timer_id  then return end
    local data = self.map[timer_id]
    if data then
        if force_remove then
            self.map[timer_id] = nil
            local update_map = self:GetUpdateMap(data.update_type)
            if update_map then
                update_map[timer_id] = nil
            end
            table.insert(self.cache,data)
        else
            data.is_deleted = true
        end
    end
end

function Timer:RealtimeSinceStartup()
    return cs_timer.realtimeSinceStartup
end

---根据绑定的target取消所有延时回调
---@param target table
function Timer:DiscardTimerByTarget(target)
    local timers = Timer.GetTimersByTarget(target)
    if not timers then return end
    for k,v in pairs(timers) do
        self:Discard(v)
    end
    target.__timer_pool = nil
end

---update
function Timer:Update(delta)
    self:Execute(UpdateType.UPDATE,delta)
end

---lateupdate
function Timer:LateUpdate(delta)
    self:Execute(UpdateType.LATE_UPDATE,delta)
end

---fixedupdate
function Timer:FixedUpdate(delta)
    self:Execute(UpdateType.FIXED_UPDATE,delta)
end

---final_updated
function Timer:FinalUpdate(delta)
    self:Execute(UpdateType.FINAL_UPDATE,delta)
end

---添加late update 回调
---@param func function
---@param target table
---@return number
function Timer:AddLateUpdate(func,target)
    local timer_id = self:GenTimer(0,func,target,true)
    if target then
        local func_list = target.__late_update
        if not func_list then
            func_list = {}
            target.__late_update = func_list
        end
        table.insert(func_list,timer_id)
    end
    return timer_id
end

---
---清理计时器
---@param timer_id number
function Timer:RemoveLateUpdate(timer_id)
    if  not timer_id then return end
    self:Discard(timer_id)
end

function Timer:RemoveLateUpdateByTarget(target)
    if not target then return end
    local func_list = target.__late_update
    if func_list and #func_list>0 then
        for k,v in pairs(func_list) do
            self:RemoveLateUpdate(v)
        end
        target.__late_update = nil
    end
end

---添加late update 回调
---@param func function
---@param target table
---@return number
function Timer:AddFixedLateUpdate(func,target)
    local timer_id = self:GenTimer(0,func,target,true)
    if target then
        local func_list = target.__fixed_update
        if not func_list then
            func_list = {}
            target.__fixed_update = func_list
        end
        table.insert(func_list,timer_id)
    end
    return timer_id
end

---
---清理计时器
---@param timer_id number
function Timer:RemoveFixedUpdate(timer_id)
    if  not timer_id then return end
    self:Discard(timer_id)
end

function Timer:RemoveFixedUpdateByTarget(target)
    if not target then return end
    local func_list = target.__fixed_update
    if func_list and #func_list>0 then
        for k,v in pairs(func_list) do
            self:RemoveLateUpdate(v)
        end
        target.__fixed_update = nil
    end
end

---添加计时器
---@see TimerMgr.AddLateUpdate
function Timer:AddFinalUpdate(func,target)
    local time_id = self:GenTimer(0,func,target,true)
    if target then
        local func_list = target.__final_update
        if not func_list then
            func_list = {}
            target.__final_update = func_list
        end
        table.insert(func_list,time_id)
    end
    return time_id
end

---清理计时器
function Timer:RemoveFinalUpdate(timer_id)
    if  not timer_id then return end
    self:Discard(timer_id)
end

---根据对象清理
function Timer:RemoveFinalUpdateByTarget(target)
    if not target then return end
    local func_list = target.__final_update
    if func_list and #func_list>0 then
        for k,v in pairs(func_list) do
            self:RemoveFinalUpdate(v)
        end
        target.__final_update = nil
    end
end

function Timer:Clear()
    for k,v in pairs(self.map) do
        self:Discard(k,true)
    end
end


---根据target获取所有计时器
function Timer.GetTimersByTarget(target)
    return target and target.__timer_pool or nil
end

---计算时间
local function check_time(_time,delta)
    local is_remove = false
    local is_finish = false
    local realtimeSinceStartup = cs_timer.realtimeSinceStartup
    --scaled
    if _time.is_scaled then
        _time.time = _time.time - delta
        if _time.time <=0 then
            is_finish = true
        end
    else
        if realtimeSinceStartup >= _time.time then
            is_finish = true
        end
    end
    if is_finish then
        if _time.count ~= -1 then
            if _time.count <=1 then
                _time.is_deleted = true
                is_remove = true
            else
                _time.count = _time.count-1
            end
        end
        if not is_remove then
            if _time.is_scaled then
                _time.time = _time.delay
            else
                _time.time = _time.delay + realtimeSinceStartup
            end
        end
        if _time.func then
            _time.func(_time.target)
        end
    end
    return is_remove
end


local _update_map
local _timer
local remove_list = {}
function Timer:Execute(update_type,delta)
    _update_map = self:GetUpdateMap(update_type)
    if _update_map then
        for k,v in pairs(_update_map) do
            _timer = self:GetTimer(v)
            if not _timer.is_deleted then
                if check_time(_timer,delta) then
                    table.insert(remove_list,k)
                end
            else
                table.insert(remove_list,k)
            end
        end
    end
    if #remove_list >0 then
        for k,v in pairs(remove_list) do
            self:Discard(v,true)
            remove_list[k] = nil
        end
    end
end

---生成时间数据
function Timer:GenTimer(delay,func,target,count,is_scaled,update_type)
    if count~=nil then
        if count == true then
            count = -1
        else
            if tonumber(count) then
                count = count
            else
                count = 1
            end
        end
    else
        count = 1
    end
    delay = delay or 0
    update_type = update_type or UpdateType.UPDATE
    target = target and target or self
    local __timer_pool = target.__timer_pool
    if not __timer_pool then
        __timer_pool = {}
        target.__timer_pool= __timer_pool
    end
    local cache = self:GetCache()
    local id = cache.id
    cache.time = is_scaled and delay or self:RealtimeSinceStartup() + delay
    cache.delay = delay
    cache.func = func
    cache.target = target~=self and target or nil
    cache.count = count
    cache.is_scaled = is_scaled
    cache.update_type = update_type
    cache.is_deleted = false
    self.map[id] = cache
    local update_map = self:GetUpdateMap(update_type)
    if update_map then
        update_map[id] = id
    end
    table.insert(__timer_pool,id)
    return id
end

function Timer:GetTimer(timer_id)
    return self.map[timer_id]
end

function Timer:GetUpdateMap(update_type)
    return update_type and self.update_map[update_type] or nil
end

function Timer:GetCache()
    if #self.cache>0 then
        local data = table.remove(self.cache)
        data.id = self:GetId()
        return data
    end
    return {id=self:GetId()}
end

function Timer:GetId()
    local id  = self.timer_id
    self.timer_id = id+1
    return id
end

function Timer:ctor()
    self.timer_id = 0
    self.map = {}
    self.update_map = {}
    for k,v in pairs(UpdateType) do
        self.update_map[v] = {}
    end
    self.cache = {}
end
return Timer