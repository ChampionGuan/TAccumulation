---Runtime.System.X3Game.Modules.CatCard.Controller/CatCardRunningCtrl.lua
---Created By 教主
--- Created Time 11:08 2021/8/18

local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local CatCardBaseCtrl = require(CatCardConst.BASE_CTRL_PATH)
---@class CatCardRunningCtrl:BaseCatCardCtrl
local CatCardRunningCtrl = class("CatCardRunningCtrl",CatCardBaseCtrl)
function CatCardRunningCtrl:ctor()
    CatCardBaseCtrl.ctor(self)
end
function CatCardRunningCtrl:Enter()
    self.super.Enter(self)
    self.breakMap = PoolUtil.GetTable()
    self:RegisterEvent()
end

function CatCardRunningCtrl:Exit()
    for k,v in pairs(self.breakMap) do
        PoolUtil.ReleaseTable(v)
    end
    PoolUtil.ReleaseTable(self.breakMap)
    self.super.Exit(self)
end

function CatCardRunningCtrl:ExecuteCall(handle)
    if handle and handle.call then
        handle.call(handle.target,table.unpack(handle.param))
    end
end

function CatCardRunningCtrl:OnEventBreak(breakType,breakCall,breakTarget,...)
    if not breakType then
        return
    end
    if not self.breakMap[breakType] then
        self.breakMap[breakType] = PoolUtil.GetTable()
    end
    local temp = self.breakMap[breakType]
    temp.call = breakCall
    temp.target = breakTarget
    if select("#",...)>0 then
        temp.param = {...}
    end
    self.bll:SetIsBreak(true)
end

function CatCardRunningCtrl:OnEventContinue(breakType)
    if not breakType then
        for k,v in pairs(self.breakMap) do
            self:ExecuteCall(v)
            PoolUtil.ReleaseTable(v)
        end
        table.clear(self.breakMap)
    else
        local t = self.breakMap[breakType]
        if t then
            self:ExecuteCall(t)
            PoolUtil.ReleaseTable(t)
            self.breakMap[breakType] = nil
        end

    end
    self.bll:SetIsBreak(not table.isnilorempty(self.breakMap))
end

function CatCardRunningCtrl:RegisterEvent()
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_BREAK,self.OnEventBreak,self)
    EventMgr.AddListener(CatCardConst.Event.CAT_CARD_CONTINUE,self.OnEventContinue,self)
end


return CatCardRunningCtrl