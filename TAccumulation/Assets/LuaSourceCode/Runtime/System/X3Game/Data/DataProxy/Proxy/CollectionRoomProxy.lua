﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/4/21 17:09

---@class CollectionRoomProxy
local CollectionRoomProxy = class("CollectionRoomProxy", BaseProxy)
---@type CollectionRoomData
local CollectionRoomData = require("Runtime.System.X3Game.Data.DataProxy.Data.CollectionRoomData")
---@type CollectionItemData
local CollectionItemData = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.CollectionItemData"
---@type StyleItemData
local StyleItemData = require("Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.StyleItemData")

function CollectionRoomProxy:OnInit()
    self:GetCollectionData()
end

--old interface
function CollectionRoomProxy:InitData(roleMap)
    --self.collectionData:SetRoleDataMap(roleMap)
end

---@param collection  pbcmessage.CollectionData
---@param decoration  pbcmessage.DecorationData
function CollectionRoomProxy:InitCollectData(collection, decoration)
    self.collectionData:SetRoleDataMap(collection.RoleCollectionMap)
    self.collectionData:SetNormalCollectionData(collection.NormalCollectionData)
    self.collectionData:SetDecorationData(decoration)
end

---@return CollectionRoomData
function CollectionRoomProxy:GetCollectionData()
    if not self.collectionData then
        self.collectionData = CollectionRoomData.new()
    end
    return self.collectionData
end

---@return CollectionItem
function CollectionRoomProxy:GetCollectionItemData(role_id, id)
    return self.collectionData:GetCollectionItemData(role_id, id)
end

---@return CollectionItemData
function CollectionRoomProxy:GetCollectItemInfo(role_id, id)
    local itemData = self:GetCollectionItemData(role_id, id)
    local item = CollectionItemData.new()
    item:SetRole(role_id)
    local is_ok = item:Refresh(itemData)
    if is_ok then
        return item
    end
end

---@param id int
---@return StyleItemData
function CollectionRoomProxy:GetDecorationItemInfo(id)
    local decoration = self.collectionData:GetDecorationItem(id)
    local styleItem = StyleItemData.new()
    styleItem:RefreshData(id, decoration)
    return styleItem
end

return CollectionRoomProxy
