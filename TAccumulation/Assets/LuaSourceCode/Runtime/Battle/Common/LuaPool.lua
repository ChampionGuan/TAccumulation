---
---Created by fuqiang
---Date: 2021/11/17
---

---@class ClassInfo
---@field name string
---@field funNew fun(...)
---@field cacheCount Int
---@field isPreload boolean
---@field usingCount Int
---@field maxUseCount Int

---lua逻辑对象池
---注意：这个类使用table实现，不通过class接口实现，因为class接口依赖该类
---@class LuaPool
local LuaPool = { __cname = "LuaPool" }

---@protected
function LuaPool:ctor()
    ---@type table<string, ClassInfo>
    self._classInfos = {}
    ---未使用的对象列表
    ---@type table<string, any[]>
    self._unusedObjLists = {}
    ---@type table<string, table<any, boolean>>
    ---正在被使用的对象列表
    self._usingObjList = {}

    ---临时对象列表
    ---@type table<string, any[]>
    self._tempObjLists = {}
end

---@param className string 类名
---@param funNew fun(...) 创建函数
---@param cacheCount Int 最大缓存数量
function LuaPool:Register(className, funNew, cacheCount)
    if self._classInfos[className] then
        Debug.LogErrorFormat("lua通用对象池：类(name=%s)已注册，可能重名，请在类名前+前缀", className)
        return
    end

    ---@type ClassInfo
    self._classInfos[className] =
    {
        name = className,
        funNew = funNew,
        cacheCount = cacheCount or 0,
        usingCount = 0,
        maxUseCount = 0
    }
end

function LuaPool:_ResetClassInfo()
    for k, classInfo in pairs(self._classInfos) do
        classInfo.usingCount = 0
        classInfo.maxUseCount = 0
        classInfo.isPreload = false
    end
end

function LuaPool:Init()
    for k, classInfo in pairs(self._classInfos) do
        self:TryPreload(classInfo.name)
    end
end

---@protected
---@param className string
function LuaPool:TryPreload(className)
    local classInfo = self._classInfos[className]
    if not classInfo or classInfo.isPreload then
        return
    end

    self._unusedObjLists[className] = self._unusedObjLists[className] or {}
    local unusedObjs = self._unusedObjLists[className]
    ---预缓存
    for i = 1, classInfo.cacheCount do
        table.insert(unusedObjs, self:_CreateObj(classInfo))
    end

    classInfo.isPreload = true
end

---@param class Class 类对象
---@param cacheCount Int 最大缓存数量
function LuaPool:RegisterByClass(class, cacheCount)
    self:Register(class.__cname, class.__new, cacheCount)
end

---@param classInfo ClassInfo
function LuaPool:_CreateObj(classInfo)
    local obj = classInfo.funNew()
    if obj.__cname == nil then
        obj.__cname = classInfo.name
    end
    return obj
end

function LuaPool:Get(className)
    local classInfo = self._classInfos[className]
    if not classInfo then
        Debug.LogErrorFormat("Lua通用对象池：类型(name=%s)为注册", className)
        return
    end

    local unusedObjs = self._unusedObjLists[className]
    if not unusedObjs then
        unusedObjs = {}
        self._unusedObjLists[className] = unusedObjs
    end

    local obj = nil
    if #unusedObjs > 0 then
        obj = table.remove(unusedObjs)
    else
        obj = self:_CreateObj(classInfo)
    end

    local usingObjs = self._usingObjList[className]
    if not usingObjs then
        usingObjs = {}
        self._usingObjList[className] = usingObjs
    end
    usingObjs[obj] = true
    classInfo.usingCount = classInfo.usingCount + 1
    classInfo.maxUseCount = math.max(classInfo.maxUseCount, classInfo.usingCount)
    return obj
end

---@param class Class
function LuaPool:GetByClass(class)
    return self:Get(class.__cname)
end

function LuaPool:Recycle(obj)
    if not obj.__cname then
        Debug.LogErrorFormat("lua通用对象池报错：回收对象类数据不存在")
        return
    end

    local usingObjs = self._usingObjList[obj.__cname]
    if not usingObjs or not usingObjs[obj] then
        Debug.LogErrorFormat("lua通用对象池报错：回收对象不属于该对象池")
        return
    end

    local unusedObjs = self._unusedObjLists[obj.__cname]
    ---理论上由对象池创建过对象后，对象列表一定存在
    ---如果为空，则表明对象不属于对象池
    if not unusedObjs then
        Debug.LogErrorFormat("lua通用对象池报错：对象列表不存在，回收的对象不属于对象池。path=%s", path)
        return
    end

    table.insert(unusedObjs, obj)
    usingObjs[obj] = nil

    local classInfo = self._classInfos[obj.__cname]
    classInfo.usingCount = classInfo.usingCount - 1
end

function LuaPool:GetTemp(className)
    local obj = self:Get(className)
    local tempObjs = self._tempObjLists[className]
    if not tempObjs then
        tempObjs = {}
        self._tempObjLists[className] = tempObjs
    end

    table.insert(tempObjs, obj)
    return obj
end

function LuaPool:RecycleTemps()
    for k, tempObjs in pairs(self._tempObjLists) do
        for i = #tempObjs, 1, -1 do
            self:Recycle(tempObjs[i])
            tempObjs[i] = nil
        end
    end
end

function LuaPool:Destroy()
    self:RecycleTemps()

    self._unusedObjLists = {}
    for k, usingObjs in pairs(self._usingObjList) do
        if #usingObjs > 0 then
            Debug.LogErrorFormat("lua通用对象池报错：对象(className=%s)残留数量count=%d",
                    usingObjs[1].__cname, #usingObjs)
        end
    end
    self._usingObjList = {}

    for k, tempObjs in pairs(self._tempObjLists) do
        if #tempObjs > 0 then
            Debug.LogErrorFormat("lua通用对象池报错：临时对象(className=%s)残留数量count=%d",
                    tempObjs[1].__cname, #tempObjs)
        end
    end
    self._tempObjLists = {}

    if UNITY_EDITOR then
        Debug.Log(self:GetDebugInfo())
    end

    self:_ResetClassInfo()
end

function LuaPool:GetDebugInfo()
    local strs = {}
    table.insert(strs, "lua通用对象池调试信息")
    table.insert(strs, "对象最大使用数量")
    for k, classInfo in pairs(self._classInfos) do
        local str = string.format("%s=%d", classInfo.name, classInfo.maxUseCount)
        table.insert(strs, str)
    end
    local result = table.concat(strs, "\n")
    return result
end

LuaPool:ctor()
g_LuaPool = LuaPool