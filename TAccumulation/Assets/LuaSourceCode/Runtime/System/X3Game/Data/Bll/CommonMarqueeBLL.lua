﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiangyu.
--- DateTime: 2023/2/10 16:21
---

---@class CommonMarqueeBLL
local CommonMarqueeBLL = class("CommonMarqueeBLL", BaseBll)

---初始化
function CommonMarqueeBLL:OnInit()
    ---@type MarqueeData 记录当前显示的跑马灯
    self.currentData = nil
    ---@type int 记录当前开始显示的跑马灯时间
    self.recordStartTime = 0
    
    EventMgr.AddListener("Game_Focus", self.OnGameFocus, self)
end

---请求服务器跑马灯数据
function CommonMarqueeBLL:SendRequest()
    GrpcMgr.SendRequestAsync(RpcDefines.AnnounceCMSConfigGetRequest,{})
end

---切换后台逻辑
function CommonMarqueeBLL:OnGameFocus(focus)
    if UNITY_EDITOR then
        return
    end
    EventMgr.Dispatch("OnCommonMarqueeWndFocus", focus)
end

---得到当前需要显示的有效跑马灯数据
---@return MarqueeData
function CommonMarqueeBLL:GetCurrentInfo()
    self.currentData = MarqueeMgr.GetMarqueeData()
    if self.currentData ~= nil then
        if self.currentData.playTime <= self.currentData.playedTime then
            self:Remove()
            return nil
        end
        self.recordStartTime = TimerMgr.GetCurTimeSeconds()
    end
    return self.currentData
end

---移除已经展示掉的跑马灯信息
function CommonMarqueeBLL:Remove()
    local id = self.currentData.id
    self.recordStartTime = 0
    self.currentData = nil
    MarqueeMgr.Remove(id)
end

---得到需要显示的时间
function CommonMarqueeBLL:GetPlayTime()
    if self.currentData == nil then
        return 0
    end
    local playTime = self.currentData.playTime - self.currentData.playedTime
    playTime = math.min(playTime, self.currentData.disableTime - TimerMgr.GetCurTimeSeconds())
    return playTime
end

---记录显示结束的跑马灯时间：用于界面屏蔽时
function CommonMarqueeBLL:RecordShowEndTime()
    if self.currentData ~= nil then
        self.currentData.playedTime = self.currentData.playedTime + TimerMgr.GetCurTimeSeconds() - self.recordStartTime
    end
    self.recordStartTime = 0
end

return CommonMarqueeBLL