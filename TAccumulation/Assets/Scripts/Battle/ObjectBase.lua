local objectIndex = 0
local function ObjectBase()
    objectIndex = objectIndex + 1

    local t = {}
    -- 实例化id
    t.InstanceId = objectIndex

    -- 配置（prefab, script字段必须有！！）
    t.TheConfig = nil
    -- gameobject
    t.TheGameobject = nil
    -- transofrm
    t.TheTransform = nil
    -- 初始化完成
    t.Initialized = false

    -- 层级
    t.TheLayer = nil

    -- 生成的特效
    t.Particles = {}
    -- 子脚本
    t.SubScripts = {}

    -- 初始化
    function t:Initialize(layer)
        self:OnInitialize(layer)
    end

    -- 销毁
    function t:Destroy()
        self:OnDestroy()
    end

    -- 引擎update
    function t:Update()
    end

    -- 引擎fixedUpdate
    function t:FixedUpdate()
    end

    -- 自定义update
    function t:CustomUpdate()
    end

    -- 自定义fixedUpdate
    function t:CustomFixedUpdate()
    end

    -- 添加组件
    function t:AddComponent(type)
        if Utils.unityTargetIsNil(self.TheGameobject) then
            return nil
        end

        local component = self:GetComponent(type)
        if nil == component then
            component = self.TheGameobject:AddComponent(type)
        end
        if Utils.unityTargetIsNil(component) then
            component = nil
        end
        return component
    end

    -- 添加组件
    function t:GetComponent(type)
        if Utils.unityTargetIsNil(self.TheGameobject) then
            return nil
        end

        local component = self.TheGameobject:GetComponentInChildren(type)
        if Utils.unityTargetIsNil(component) then
            component = nil
        end

        return component
    end

    -- 获取子对象
    function t:GetChilds(parent)
        if Utils.unityTargetIsNil(parent) then
            return nil
        end

        local childs = {}
        for i = 0, parent.childCount - 1 do
            table.insert(childs, parent:GetChild(i))
        end
        return childs
    end

    -- 播放音效
    function t:PlaySound(id, is3d)
        is3d = (nil == is3d or is3d)
        if is3d then --and not Utils.unityTargetIsNil(self.TheTransform) then
            AudioManager.PlaySound(id, nil, AudioStat.Play, self.TheTransform)
        else
            AudioManager.PlaySound(id, nil, AudioStat.Play)
        end
    end

    -- 生成特效
    function t:SpawnParticle(id, aliveTime, active)
        if nil == id then
            return
        end
        local particle = self.TheEngine:SpawnObjectFromPool(id, self.TheTransform)
        if nil == particle then
            return
        end
        particle:Initialize(self, aliveTime, active, self.TheLayer)

        -- 保存
        self.Particles[particle.InstanceId] = particle
        return particle
    end

    -- 销毁特效
    function t:DestroyParticle(particle)
        if nil == particle then
            return
        end
        -- 移除
        self.Particles[particle.InstanceId] = nil
        particle:OnDestroy()
    end

    -- 设置欧拉角
    function t:SetEulerAngles(eulerAngle)
        -- if Utils.unityTargetIsNil(self.TheTransform) then
        --     return
        -- end
        if nil ~= eulerAngle then
            self.TheTransform.eulerAngles = eulerAngle
        end
    end

    -- 设置位置和旋转
    function t:SetPos2Rot(position, rotation)
        -- if Utils.unityTargetIsNil(self.TheTransform) then
        --     return
        -- end
        if nil ~= position then
            self.TheTransform.position = position
        end
        if nil ~= rotation then
            self.TheTransform.rotation = rotation
        end
    end

    -- 设置旋转
    function t:SetRotByDir(direction)
        -- 角度
        local angle = CSharp.Vector3.Angle(direction, self.TheTransform.forward)
        -- 判断正负
        local signValue =
            CSharp.Vector3.Dot(self.TheTransform.up, CSharp.Vector3.Cross(self.TheTransform.forward, direction))

        if signValue < 0 then
            signValue = -1
        else
            signValue = 1
        end

        angle = angle * signValue
        if angle ~= 0 then
            self.TheTransform:Rotate(self.TheTransform.up, angle)
        end
    end

    -- 获取实时位置
    function t:GetRealPos()
        -- if Utils.unityTargetIsNil(self.TheTransform) then
        --     return
        -- end
        return self.TheTransform.position
    end

    -- 获取实时旋转
    function t:GetRealRot()
        -- if Utils.unityTargetIsNil(self.TheTransform) then
        --     return
        -- end
        return self.TheTransform.rotation.eulerAngles
    end

    -- 设置层级
    function t:SetLayer(layer)
        -- if Utils.unityTargetIsNil(self.TheTransform) then
        --     return
        -- end
        self.TheLayer = layer
        CSharp.LogicUtils.SetLayer(self.TheTransform, layer)
    end

    -- 设置可见
    function t:SetActive(active)
        -- if Utils.unityTargetIsNil(self.TheGameobject) then
        --     return
        -- end
        self.TheGameobject:SetActive(active)
    end

    -- 是否可见
    function t:IsActive()
        -- if Utils.unityTargetIsNil(self.TheGameobject) then
        --     return false
        -- end
        return self.TheGameobject.activeSelf
    end

    -- 实例化
    function t:OnInstance()
    end

    -- 初始化
    function t:OnInitialize(layer)
        self:SetLayer(layer)
        self.Initialized = true
    end

    -- 销毁
    function t:OnDestroy()
        if not self.Initialized then
            return
        end

        for k, v in pairs(self.Particles) do
            v:Destroy()
        end
        for k, v in pairs(self.SubScripts) do
            v:Destroy()
            self.TheEngine:ReturnScriptToPool(k, v)
        end
        self.TheEngine:ReturnObjectToPool(self)
        self.TheGameobject = nil
        self.TheTransform = nil
        self.Particles = {}
        self.SubScripts = {}
        self.Initialized = false
    end

    -- 实例化
    function t:Instance(engine, model, config)
        self.TheEngine = engine
        self.TheConfig = config
        self.TheGameobject = model
        self.TheTransform = model.transform
        self.Initialized = false
        self:OnInstance()
    end

    return t
end

return ObjectBase
