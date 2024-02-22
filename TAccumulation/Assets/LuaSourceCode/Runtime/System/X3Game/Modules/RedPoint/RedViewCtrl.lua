﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/1/23 18:22
---
---红点gameObject绑定和解绑逻辑，以及红点显示逻辑

local RedConst = require("Runtime.System.X3Game.Modules.RedPoint.RedConst")
---@class RedViewCtrl
local RedViewCtrl = class("RedViewCtrl")
local RedView = require(RedConst.RED_VIEW_PATH)

---检测红点gameobject上红点显示
---@param obj UnityEngine.GameObject
---@param identify_id number|string 主要用于列表区分id 和 UpdateCount 中对应参数对应
function RedViewCtrl:CheckRedObj(obj,identify_id,...)
    if GameObjectUtil.IsNull(obj) then return end
    if UNITY_EDITOR then
        if obj:GetType() ~= typeof(CS.UnityEngine.GameObject) then
            Debug.LogError("[RedViewCtrl.CheckRedObj] --failed go is not gameObject ", obj)
            return
        end
    end
    local id = obj:GetInstanceID()
    self.obj_identify_map[id] = identify_id
    local view = self:GetView(obj)
    if view then
        return self:RefreshView(obj)
    else
        view = self:GetView(obj,true)
        return RedPointMgr.IsAlive(obj,identify_id)
    end
end

---GameObject绑定红点，每个gameObject只能绑定一个id
---@param obj UnityEngine.GameObject 红点载体
---@param red_id number 红点id
function RedViewCtrl:Bind(obj,red_id)
    if not red_id then
        Debug.LogError("【RedViewCtrl】 Bind --failed",obj,red_id)
        return
    end
    local view = self:GetView(obj,true)
    view:Bind(obj)
    view:SetId(red_id)
    local list = self:GetObjList(red_id,true)
    if not list[obj] then
        list[obj] = view
    end
    self:RefreshView(obj)
end

---解除绑定
---@param obj UnityEngine.GameObject 红点载体
function RedViewCtrl:UnBind(obj)
    local view = self:GetView(obj)
    if view then
        local list = self:GetObjList(view:GetId())
        if list then
            list[obj] = nil
            if table.isnilorempty(list) then
                PoolUtil.ReleaseTable(list)
                self.obj_map[view:GetId()] = nil
            end
        end
        self.view_map[obj] = nil
        self.view_pool:Release(view)
    end
end

---检测红点是否有效
---@param red_id number 红点id
---@param identify_id any 任意类型，和设置红点数量的时候保持一致
function RedViewCtrl:IsAlive(red_id,identify_id)
    return RedPointMgr.GetViewCount(red_id,identify_id) > 0
end

---刷新红点显示
---@param obj UnityEngine.GameObject
function RedViewCtrl:RefreshView(obj)
    local view = self:GetView(obj)
    if view then
        view:SetIdentifyId(self:GetIdentify(obj))
        return view:Refresh()
    end
    return false
end

---获取唯一标识符
---@param obj GameObject
---@return any
function RedViewCtrl:GetIdentify(obj)
    local id = (not GameObjectUtil.IsNull(obj)) and obj:GetInstanceID() or nil
    return id and self.obj_identify_map[id] or nil
end

---@param obj GameObject
---@return int
function RedViewCtrl:GetShowType(obj)
    local view = self:GetView(obj)
    return view and view:GetShowType() or -1
end

---数量变动回调
---@param red_id int
function RedViewCtrl:OnCountChange(red_id)
    local check_list  = self:GetObjList(red_id)
    if check_list then
        for obj,view in pairs(check_list) do
            self:RefreshView(obj)
        end
    end
end

---红点销毁
---@param red_cs PapeGames.X3.RedPoint
function RedViewCtrl:OnRedPointDestroy(red_cs)
    if not red_cs then
        return
    end
    local obj = red_cs.gameObject
    if not obj then
        return
    end
    self.obj_identify_map[obj:GetInstanceID()] = nil
    for k, v in pairs(self.obj_parent_map) do
        if v == obj then
            table.removebyvalue(self.obj_pool,k)
            self.obj_parent_map[k] = nil
            self:AddRedObjToCache(k)
        end
    end
end

---加载预设
---@param on_load_complete fun(type:UnityEngine.GameObject):void
function RedViewCtrl:LoadRedObj(on_load_complete)
    local obj = table.remove(self.obj_pool)
    obj = GameObjectUtil.IsNull(obj) and  X3AssetInsProvider.GetInsWithAssetPath(RedConst.TEMPLATE_ASSET_PATH) or obj
    if obj then
        self.obj_parent_map[obj] = nil
        obj.name = RedConst.NODE_NAME
        if on_load_complete then
            on_load_complete(obj)
        end
    end
end

---@param obj GameObject
function RedViewCtrl:AddRedObjToCache(obj)
    X3AssetInsProvider.ReleaseIns(obj)
end

---卸载预设
---@param obj UnityEngine.GameObject
---@param parentObj UnityEngine.GameObject
function RedViewCtrl:ReleaseRedObj(obj,parentObj)
    if obj then
        GameObjectUtil.SetActive(obj,false)
        self.obj_parent_map[obj] = parentObj
        table.insert(self.obj_pool,obj)
        --X3AssetInsProvider.ReleaseIns(obj)
    end
end

---@param red_id int
---@param is_create boolean
---@return GameObject[]
function RedViewCtrl:GetObjList(red_id,is_create)
    local list = self.obj_map[red_id]
    if not list  and is_create then
        list = PoolUtil.GetTable()
        self.obj_map[red_id] = list
    end
    return list
end

---@param obj GameObject
---@param is_create boolean
---@return RedView
function RedViewCtrl:GetView(obj,is_create)
    if obj == nil then return end
    local view = self.view_map[obj]
    if not view and is_create then
        view = self.view_pool:Get()
        self.view_map[obj] = view
    end
    return view
end

function RedViewCtrl:Init()
    self.view_map = {}
    self.obj_map = {}
    self.obj_pool ={}
    self.obj_parent_map = {}
    self.obj_identify_map = {}
    self.view_pool = PoolUtil.Get(function ()
        local view = RedView.new()
        view:SetOwner(nil,self)
        return view
    end,function (view)
        view:Clear()
    end)
end

function RedViewCtrl:Clear()
    table.clear(self.view_map)
    table.clear(self.obj_map)
    table.clear(self.obj_pool)
    table.clear(self.obj_parent_map)
    table.clear(self.obj_identify_map)
end

return RedViewCtrl