---------------------------------------------------------------------
---Client (C) Companykey_or_path, All Rights Reserved
---Created by: jiaozhu
---Date: 2020-05-27 14:10:32
---------------------------------------------------------------------

---To edit this template in: Data/Config/Template.lua
---To disable this template, check off menuitem: Options-Enable Template File


---所有脚本绑定逻辑
--[[
	self.gameObject  脚本挂载的gameobject
	self.transform   
	self.owner		 脚本的从属
	self:Init()		 初始化
	self:OnDestroy() 销毁

]]
---常量Transform类型
local TRANSFORM_TYPE = "Transform"
---常量GameObject类型
local GAMEOBJECT_TYPE = "GameObject"
---组件查找的名称
local LINKER = "ObjLinker"
---@class GameObjectCtrl
GameObjectCtrl = class("GameObjectCtrl", nil, true)

---初始化S
function GameObjectCtrl:ctor()
    ---@private
    ---@type PapeGames.X3UI.ObjLinker
    self.obj_linker = nil
    ---@type GameObjectCtrl
    self.owner = nil
    ---@type GameObject
    self.gameObject = nil
    ---@type Transform
    self.transform = nil
    ---@type Transform
    self.parent = nil
    ---@type string
    self.obj_name = ""
end

--初始化执行一次
function GameObjectCtrl:Init()
end

--每次添加组件都会执行一次
function GameObjectCtrl:Reset()
end

---设置owner 用于gameObject绑定lua脚本逻辑
---@param go UnityEngine.GameObject
---@param owner table
function GameObjectCtrl:SetOwner(go, owner)
    self.gameObject = go
    if go then
        self.transform = self:GetComponent(nil, TRANSFORM_TYPE)
    end
    self.owner = owner
    self:SetObjLinker(self.gameObject and self:GetComponent("", LINKER, false, true) or nil)
    self:Init()
end

---@return UICtrl
function GameObjectCtrl:GetOwner()
    return self.owner
end

---获取父子关系
---@return UICtrl
function GameObjectCtrl:GetParentCtrl()
    return self.owner
end

---@param key_or_path string 组件名称
---@param lua_path string 脚本路径
---@param is_cache boolean 是否启用缓存池
---@return UICtrl
function GameObjectCtrl:GetOrAddChildCtrl(key_or_path, lua_path, is_cache)
    return GameObjectCtrl.GetOrAddCtrl(self:GetGameObject(key_or_path), lua_path, self, is_cache)
end

---@param key_or_path string 组件名称
---@param lua_path string 脚本路径
---@return UICtrl
function GameObjectCtrl:GetChildCtrl(key_or_path, lua_path)
    return UICtrl.GetCtrl(self:GetGameObject(key_or_path), lua_path, self)
end

---获取父节点
---@return Transform
function GameObjectCtrl:GetParent()
    if not self.parent then
        self.parent = self.transform.parent
    end
    return self.parent
end

---设置linker(统一获取组件)
---@param obj_linker PapeGames.X3UI.ObjLinker
function GameObjectCtrl:SetObjLinker(obj_linker)
    self.obj_linker = obj_linker
end

---@return PapeGames.X3UI.ObjLinker
function GameObjectCtrl:GetLinker()
    return self.obj_linker
end

---@private
---@param key_or_path string | UnityEngine.Object
---@param type_str string
---@param func_str string
---@vararg any
function GameObjectCtrl:_InvokeFunc(key_or_path, type_str, func_str, ...)
    key_or_path = key_or_path == nil and "" or key_or_path
    local is_cs = type(key_or_path) == "string"
    if is_cs then
        if not self.obj_linker then
            is_cs = false
            if self.gameObject then
                local pre = key_or_path
                key_or_path = self:GetComponent(key_or_path, type_str)
                if key_or_path == nil then
                    Debug.LogErrorFormat("[NoObjLinker]GameObjectCtrl:%s--failed obj(%s) is nil,rootObj:%s", func_str, pre, self:GetName())
                    return
                end
            else
                key_or_path = nil
            end
        end
    end
    if is_cs and string.isnilorempty(key_or_path) then
        key_or_path = self.gameObject
        is_cs = false
    end
    if is_cs then
        if not string.find(key_or_path, "/", 1, true) and (self.obj_linker or GameObjectCtrl.IsOCX(key_or_path)) then
            key_or_path = string.hash(key_or_path)
        end
        return self:_InternalInvokeFunc(func_str, true, self.obj_linker, key_or_path, ...)
    else
        return self:_InternalInvokeFunc(func_str, false, key_or_path, ...)
    end
end

---不依赖于自身gameobject被销毁的接口
---@param func_str string 方法名称
---@param is_cs boolean
---@vararg any
function GameObjectCtrl:_InternalInvokeFunc(func_str, is_cs, ...)
    local handler_f = GameObjectCtrl.GetHandler(func_str, is_cs)
    if handler_f then
        if is_cs then
            return GameObjectCtrl.OptimizeCall(handler_f,...)
        end
        return handler_f(...)
    else
        Debug.LogErrorFormat("[GameObjectCtrl:_InternalInvokeFunc]--failed handler is nil,:func_str=%s,is_cs=%s", func_str, is_cs)
    end
end

---脚本被销毁
function GameObjectCtrl:Destroy()
    self:OnDestroy()
    self:InternalDestroy()
end

---销毁之后回调
---清理相关缓存
function GameObjectCtrl:OnDestroy()

end

---@private 内部调用
function GameObjectCtrl:InternalDestroy()
    ---清理缓存的gameObject
    self:ClearComponents()
    ---清理相关事件
    GameObjectCtrl.ClearTarget(self)
end

return GameObjectCtrl