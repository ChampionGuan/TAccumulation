﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/12/30 14:50
--- 数据存储
---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Client.SaveData:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local SaveData = class('SaveData',ICommand)
function SaveData:ctor()
    ICommand.ctor(self)
end

---执行命令
---@param data table
---@param isClear boolean 是否清理所有数据
function SaveData:OnCommand(data,isClear)
    if isClear then
        self.entity:SendToClient(Command.Common.ClearData,true)
    end
    if  data == nil  then
        if isClear then
            return
        end
        LogicUtil.LogErrorFormat("[SaveData:OnCommand] failed data is [%s]",data)
        return
    end
    self.entity:SendToClient(Command.Common.DataStore,ServerConst.DataCommandType.Save,data)
    if self.entity:IsSyncData() then
        self.entity:SendToClient(Command.Common.DataSync,ServerConst.DataCommandType.Save,data)
    end
end

---初始化
function SaveData:OnInit()
end

---销毁
function SaveData:OnDispose()
end
return SaveData