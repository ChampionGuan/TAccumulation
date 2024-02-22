﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/3/21 11:04
---@class DotGridViewCtrl

local DotGridViewCtrl = class("DotGridViewCtrl", UICtrl)

function DotGridViewCtrl:ctor()

end

function DotGridViewCtrl:Init()
    self.selectIndex = 1
    self.gridView = self:GetComponent("", "GridView")
    self:AddGridViewListener("", handler(self, self.OnCellLoad))
end

function DotGridViewCtrl:SetCount(count)
    self.gridView:Load(count)
    self:SetActive(self.gridView, count > 1)
end

function DotGridViewCtrl:OnCellLoad(gv, cellItem, index)
    local item = GameObjectUtil.GetComponent(cellItem, "OCX_Dot", "GameObject")
    self:SetImage(item, self.selectIndex == index + 1 and "x3_com_page_slc" or "x3_com_page_bg")
    return Vector2.zero_readonly
end

---@param index:int 下标从1开始
function DotGridViewCtrl:SetIndex(index)
    self.selectIndex = index
    self.gridView:SelectCell(self.selectIndex - 1)
end

return DotGridViewCtrl