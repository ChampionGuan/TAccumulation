﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/8/26 12:04
---

---@class NormalItemData
---@field owner Item.ItemData 公共数据所在的地方
---@field isDirty boolean
---@field normal_Num string 显示的数量
---@field normal_CdData table CD时间
---显示数据
---@field curTimeBgIndex number 当前timeBg的index 这里初始值不能是0 会影响回收后的显示
---@field curTimeValue number 当前剩余的时间
---@field limitTimerId number 限时道具计时器id
---@field itemShowConfig cfg.Item 对于虚拟道具就是Config是从BLL层拿出来的
local NormalItemData = class("NormalItemData")

--- 修改NormalItemData属性的方法集合
--- 数据修改后需要根据情况决定UI是否需要更新
--- @alias SetDataFunc fun(itemData:NormalItemData, value:any):void
--- @type table<ItemConst.DataEnum, SetDataFunc>
NormalItemData.SetDataFuncDic = {
    ---@param data NormalItemData
    ---@param value string
    [ItemConst.DataEnum.NUM] = function(data, value)
        if data.normal_Num ~= value then
            data.normal_Num = value
            data.isDirty = true
        end
    end,

    ---@param data NormalItemData
    ---@param value table
    [ItemConst.DataEnum.CD_DATA] = function(data, value)
        if data.normal_CdData ~= value then
            data.normal_CdData = value
            data.isDirty = true
        end
    end,
}

function NormalItemData:InitData()
    ---@type Item.ItemData
    local itemData = self.owner
    if itemData.itemTypeConfig.Virtual == 1 then
        self.itemShowConfig = BllMgr.GetItemBLL():GetItemShowCfg(itemData.configId, itemData.itemTypeConfig.Id)
    else
        self.itemShowConfig = itemData.itemConfig
    end
end

function NormalItemData:ctor()
    self.owner = nil
    self.isDirty = true
    self.normal_Num = nil
    self.normal_CdData = nil
    self.curTimeBgIndex = -1
    self.curTimeValue = 0
    self.limitTimerId = 0
    self.itemShowConfig = nil
end

function NormalItemData:Clear()
    self.owner = nil
    self.isDirty = true
    self.normal_Num = nil
    self.normal_CdData = nil
    self.curTimeBgIndex = -1
    self.curTimeValue = 0
    --在这里触发是因为数据被Clear的时候Ctrl可能还没触发OnClose
    TimerMgr.Discard(self.limitTimerId)
    self.limitTimerId = 0
    self.itemShowConfig = nil
end

return NormalItemData