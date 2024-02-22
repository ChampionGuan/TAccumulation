﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/12/30 14:50
--- 数据存储
---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Client.ClearData:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local ClearData = class('ClearData',ICommand)

---执行命令
---@param noSendClear boolean
function ClearData:OnCommand(noSendClear)
    self.entity:SendToClient(Command.Common.DataStore,ServerConst.DataCommandType.Clear)
    if self.entity:IsSyncData() then
        self.entity:SendToClient(Command.Common.DataSync,ServerConst.DataCommandType.Clear)
    end
    if not noSendClear then
        self.entity:SendToClient(Command.Common.SaveData,nil,nil,true)
    end
end

---初始化
function ClearData:OnInit()
end

---销毁
function ClearData:OnDispose()
end
return ClearData