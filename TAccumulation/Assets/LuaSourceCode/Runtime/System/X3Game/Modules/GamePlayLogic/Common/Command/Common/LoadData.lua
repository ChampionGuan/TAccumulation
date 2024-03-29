﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/12/30 13:50
---
---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Client.LoadData:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local LoadData = class('LoadData', ICommand)
function LoadData:ctor()
    ICommand.ctor(self)
    ---@type fun(type:table)
    self.onLoadFinish = handler(self, self.OnLoadFinish)
    ---@type fun(type:table)
    self.onComplete = nil
end

---执行命令
---@param onComplete fun(type:PureLogic.LoadData)
function LoadData:OnCommand(onComplete)
    self.onComplete = onComplete
    self.entity:SendToClient(Command.Common.DataStore, ServerConst.DataCommandType.Get, nil, self.onLoadFinish)
end

---@param data PureLogic.LoadData
function LoadData:OnLoadFinish(data)
    local onComplete = self.onComplete
    self.onComplete = nil
    local version = 0
    local timeStamp = 0
    if data then
        version = data[ServerConst.DataVersionName] or version
        timeStamp = data[ServerConst.TimeStamp] or timeStamp
    end
    if onComplete then
        if self.entity:IsSyncData() then
            self.entity:SendToClient(Command.Common.DataSync, ServerConst.DataCommandType.Get, nil, function(serverData, isNew)
                local ret = data
                local serverTimeStamp = serverData[ServerConst.TimeStamp] or LogicUtil.GetTimeStamp()
                if isNew or timeStamp ~= serverTimeStamp then
                    self.entity:SendToServer(Command.Common.ClearData)
                    ret = serverData
                    ret[ServerConst.TimeStamp] = serverTimeStamp
                else
                    local serverVersion = serverData[ServerConst.DataVersionName]
                    if serverVersion and serverVersion > version then
                        self.entity:SetDataVersion(serverVersion)
                        ret = serverData
                    end
                end
                onComplete(ret)
                
            end)
        else
            onComplete(data)
        end

    end
end

---初始化
function LoadData:OnInit()

end

---销毁
function LoadData:OnDispose()
end
return LoadData