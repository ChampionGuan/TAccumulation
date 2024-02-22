﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/6/8 21:48
---
---@class Framework.BaseParser:Framework.BaseCtrl
local BaseParser = class("BaseParser", Framework.BaseCtrl)

---@class Framework.BaseType

---@param target table
---@param viewType Framework.BaseType
---@return Framework.BaseView,boolean
function BaseParser:Bind(target, viewType)
    if not target or not viewType then
        self.logger:LogFatalFormat("[BaseParser:Bind] failed,target = [%s],viewType=[%s]", target, viewType)
        return
    end
    local view = self:Get(target, viewType)
    local isNew = false
    if not view then
        view = self:Create(viewType)
        if view then
            isNew = true
            self:Add(target, viewType, view)
        else
            self.logger:LogFatalFormat("[BaseParser:Bind] failed,class = [%s],viewType=[%s]", target.__cname, viewType)
        end
    end
    return view, isNew
end

---@param target table
---@param viewType Framework.BaseType
function BaseParser:UnBind(target, viewType)
    if not target then
        self.logger:LogWarningFormat("[%s:UnBind] failed target is nil", self.__cname)
        return
    end
    local view = self:Get(target, viewType)
    if view then
        if not viewType then
            local res = self.targetMap[target]
            self.targetMap[target] = nil
            for _, v in pairs(res) do
                if v.Destroy~=nil then
                    v:Destroy()
                end
            end
            self:ReleaseTable(res)
        else
            self.targetMap[target][viewType] = nil
            view:Destroy()
        end

    end
end

---@param baseType Framework.BaseType
---@return Framework.BaseView
function BaseParser:Create(baseType)
    local temp = self:GetTemplate(baseType)
    if temp then
        return temp.new()
    end
end


--region 底层调用

---@param rootDir string
---@param typeEnum Framework.BaseType
function BaseParser:Parse(rootDir, typeEnum)
    self.rootDir = rootDir
    self.typeEnum = typeEnum
    self:ParseEnum()
end

---@protected
function BaseParser:OnInit()
    ---@private
    ---@type string
    self.rootDir = ""
    ---@private
    ---@type table<Framework.BaseType,string>
    self.enumToKey = {}
    ---@private
    ---@type table<int,Framework.BaseView>
    self.template = {}
    ---@private
    ---@type table<table,Framework.BaseView>
    self.targetMap = {}
    ---@private
    ---@type table<string,int>
    self.typeEnum = nil
    ---@private
    ---@type table<string,int>
    self.viewTagToViewType = {}

end

---@private
---@param target table
---@return Framework.BaseView
function BaseParser:Get(target, viewType)
    if not target then
        return nil
    end
    local res = self.targetMap[target]
    if not res or not viewType then
        return res
    end
    return res[viewType]
end

---@param target table
---@param viewType Framework.BaseType
---@param comp Framework.GameObjectCtrl
function BaseParser:Add(target, viewType, comp)
    if not self.targetMap[target] then
        self.targetMap[target] = PoolUtil.GetTable()
    end
    self.targetMap[target][viewType] = comp
end

---@param target table
---@return Framework.BaseView[]
function BaseParser:GetAllByTarget(target)
    local temp = self:Get(target)
    if temp then
        local res = self:GetTable()
        for _, v in pairs(temp) do
            table.insert(res, v)
        end
        return res
    end
end

---@private
---@param viewType Framework.BaseType
function BaseParser:GetPath(viewType)
    return string.concat(self.rootDir, self.enumToKey[viewType])
end

---@private
---@param viewType Framework.BaseType
---@return Framework.BaseView
function BaseParser:GetTemplate(viewType)
    if not viewType then
        self.logger:LogErrorFormat("[%s:GetTemplate] failed type is nil", self.__cname)
        return
    end
    local template = self.template[viewType]
    local isNew = false
    if not template then
        local path = self:GetPath(viewType)
        template = require(path)
        if template then
            if not UNITY_EDITOR then
                self.enumToKey[viewType] = nil
            end
            LuaUtil.UnLoadLua(path)
            self.template[viewType] = template
            isNew = true
        else
            self.logger:LogErrorFormat("[%s:GetTemplate] failed type=[%s]", self.__cname, viewType)
        end
    end
    return template, isNew
end

---解析数据
---@private
function BaseParser:ParseEnum()
    for k, v in pairs(self.typeEnum) do
        self.enumToKey[v] = k
    end
end

---清理缓存
function BaseParser:Clear()
    table.clear(self.template)
    table.clear(self.enumToKey)
end

---@private
---@return table
function BaseParser:GetTable()
    return PoolUtil.GetTable()
end

---@private
---@param t table
function BaseParser:ReleaseTable(t)
    PoolUtil.ReleaseTable(t)
end

---@protected
function BaseParser:OnDestroy()
    for k, _ in pairs(self.targetMap) do
        self:UnBind(k)
    end
    table.clear(self.targetMap)
    self:Clear()
end

return BaseParser