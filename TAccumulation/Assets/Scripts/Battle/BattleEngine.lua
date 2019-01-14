local BattleEngine = {}
-- 速率
local speedRate = 1

-- 对象池
local luaPool = {}
local modelPool = {}
local scriptUsing = {}
local modelInstantiate = {}

local actorConfig = LuaHandle.load("Config.NewBattle.ActorConfig")
local gameObjectConfig = LuaHandle.load("Config.NewBattle.GameObjectConfig")

function BattleEngine:CustomFixedUpdate()
    for _, v in pairs(scriptUsing) do
        if v.Initialized then
            v:CustomFixedUpdate()
        end
    end
end

function BattleEngine:CustomUpdate()
    for _, v in pairs(scriptUsing) do
        if v.Initialized then
            v:CustomUpdate()
        end
    end
end

function BattleEngine:FixedUpdate()
    for _, v in pairs(scriptUsing) do
        if v.Initialized then
            v:FixedUpdate()
        end
    end
end

function BattleEngine:Update()
    for _, v in pairs(scriptUsing) do
        if v.Initialized then
            v:Update()
        end
    end
end

-- 空闲脚本
function BattleEngine:GetScript(path)
    if nil == path then
        return
    end

    local pool = luaPool[path]
    if nil == pool then
        pool = {}
        luaPool[path] = pool
    end
    local script = nil
    if #pool > 0 then
        script = table.remove(pool, 1)
    else
        script = LuaHandle.load(path)()
    end

    return script
end

-- 获取配置
function BattleEngine:GetActorConfig(id)
    return actorConfig[id]
end

-- 获取配置
function BattleEngine:GetObjectConfig(id)
    return gameObjectConfig[id]
end

-- 空闲模型
function BattleEngine:GetModel(path)
    if nil == path then
        return
    end

    local pool = modelPool[path]
    if nil == pool then
        pool = {}
        modelPool[path] = pool
    end
    if #pool > 0 then
        model = table.remove(pool, 1)
    else
        local instantiate = modelInstantiate[path]
        if nil == instantiate then
            instantiate = CSharp.LogicUtils.LoadResource(path)
            if not instantiate then
                return nil
            end
            modelInstantiate[path] = instantiate
        end

        model = CSharp.GameObject.Instantiate(instantiate)
    end

    if model.SetActive then
        model:SetActive(false)
    end

    return model
end

-- 生成角色（走ActorConfig配置）
function BattleEngine:SpawnActorFromPool(id, parent, pos, rot)
    if nil == id then
        return nil
    end
    local config = self:GetActorConfig(id)
    if config == nil then
        return nil
    end

    -- 池中获取脚本
    local lua = self:GetScript(config.Script)
    -- 池中获取模型
    local model = self:GetModel(config.Prefab, true)

    -- 位置信息
    model.transform.parent = parent
    model.transform.localScale = config.LocalScale
    if nil ~= pos then
        model.transform.position = pos
    end
    if nil ~= rot then
        model.transform.rotation = rot
    end

    -- 实例化
    lua:Instance(self, model, config)
    -- 加入使用队列
    scriptUsing[lua.InstanceId] = lua

    return lua
end

-- 生成角色（走GameObjectConfig配置）
function BattleEngine:SpawnObjectFromPool(id, parent, pos, rot)
    if nil == id then
        return nil
    end
    local config = self:GetObjectConfig(id)
    if nil == config then
        return nil
    end

    -- 机型
    if DeviceProfiler:GetGraphicsLevel() > config.DeviceLevel then
        return nil
    end

    -- 池中获取脚本
    local lua = self:GetScript(config.Script)
    -- 池中获取模型
    local model = self:GetModel(config.Prefab)

    -- 位置信息
    model.transform.parent = parent
    model.transform.localScale = config.LocalScale
    model.transform.localPosition = config.OffsetPos
    model.transform.localRotation = CSharp.Quaternion.Euler(config.OffsetRot)
    if nil ~= pos then
        model.transform.position = pos
    end
    if nil ~= rot then
        model.transform.rotation = rot
    end
    if not config.Follow then
        model.transform.parent = nil
        model.transform.localScale = config.LocalScale
    end

    -- 如果是挂在脚底的对象，则抬高0.05米
    if config.SlotType == Define.ActorSlotType.Base then
        model.transform.position = model.transform.position + CSharp.Vector3(0, 0.05, 0)
    end

    -- 实例化
    lua:Instance(self, model, config)
    -- 加入使用队列
    scriptUsing[lua.InstanceId] = lua

    return lua
end

-- 回池
function BattleEngine:ReturnObjectToPool(script)
    if nil == script or nil == script.TheConfig then
        return
    end
    scriptUsing[script.InstanceId] = nil

    self:ReturnScriptToPool(script.TheConfig.Script, script)
    self:ReturnModelToPool(script.TheConfig.Prefab, script.TheGameobject)
end

-- 脚本回池
function BattleEngine:ReturnScriptToPool(name, script)
    if nil == name or nil == script then
        return
    end

    if nil == luaPool[name] then
        luaPool[name] = {}
    end
    table.insert(luaPool[name], script)
end

-- 模型回池
function BattleEngine:ReturnModelToPool(name, model)
    if nil == name or Utils.unityTargetIsNil(model) then
        return
    end

    if nil == modelPool[name] then
        modelPool[name] = {}
    end
    if model.SetActive then
        model:SetActive(false)
        model.transform.parent = nil
    end
    table.insert(modelPool[name], model)
end

function BattleEngine:Destroy()
    for _, v in pairs(scriptUsing) do
        v:Destroy()
    end
    for _, v in pairs(modelPool) do
        CSharp.ResourceMgr.UnloadAb(_)
        for _1, v1 in pairs(v) do
            CSharp.GameObject.Destroy(v1)
        end
    end
    modelPool = {}
    modelInstantiate = {}
end

return BattleEngine
