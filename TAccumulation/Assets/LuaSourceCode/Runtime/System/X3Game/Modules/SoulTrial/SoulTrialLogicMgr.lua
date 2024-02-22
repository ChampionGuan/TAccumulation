---
--- SoulTrialLogicMgr
--- Created by zhanbo.
--- DateTime: 2021/6/1 15:19
---
---@class SoulTrialLogicMgr
local SoulTrialLogicMgr = {}
local ANIM_MOVE_DOWN = "Move"
function SoulTrialLogicMgr:ctor()
    self.worldItems = {}
    for i = 1, 6 do
        self.worldItems[i] = {}
    end
    ---@type Vector3[]
    self.WORLD_POSITIONS = {}
end

---@param parentTransform Transform
function SoulTrialLogicMgr:Init(parentTransform)
    ---加载后面的场景Prefab
    if not self.soulTrialLayerGameObject then
        ---@type cfg.SundryConfig
        local cfg_SundryConfig = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.SOULTRIALSCENEPREFAB)
        local layerGameObject = UIMgr.LoadDynamicUIPrefab(cfg_SundryConfig)
        GameObjectUtil.SetParent(layerGameObject.transform, parentTransform, true)
        GameObjectTransformUtility.SetLocalPositionXYZ(layerGameObject, 0, 0, 0)
        ---初始化数据
        self.soulTrialLayerGameObject = layerGameObject
        ---创建模板
        for slot = 1, 6 do
            ---@type Transform
            local transform = GameObjectUtil.GetComponent(layerGameObject, "OCX_Point_0" .. slot, "Transform")
            local gameObject = transform.gameObject
            self.WORLD_POSITIONS[slot] = transform.position
            self.worldItems[slot].transform = transform
            self.worldItems[slot].gameObject = transform.gameObject
            self.worldItems[slot].x3Animator = gameObject:GetComponent("X3Animator")
        end
        self.selectObject = GameObjectUtil.GetComponent(layerGameObject, "OCX_select_soultrial_001")
        GameObjectUtil.SetActive(self.selectObject, false)
        self:_MoveDown(0)
        ---动画重置结束,记录初始的世界坐标
        for slot = 1, 6 do
            self.worldItems[slot].originPosition = GameObjectUtil.GetPosition(self.worldItems[slot].transform)
        end
    end
    self.soulTrialLayerGameObject:SetActive(true)
    --GameObjectUtil.SetActive(self.selectObject, true)
    self:PlayMotion_SelectIn()
end

function SoulTrialLogicMgr:Clear()
    if self.animator and self.moveDownCompleteHandler then
        self.animator:RemoveStateCompleteListener(self.moveDownCompleteHandler)
    end
    if self.soulTrialLayerGameObject then
        GameObjectUtil.Destroy(self.soulTrialLayerGameObject)
    end
    GameUtil.ClearTarget(self)
end

---@param slot int
---@param cfg_SoulTrial cfg.SoulTrial
function SoulTrialLogicMgr:SetWorldItemByIndex(slot, cfg_SoulTrial)
    local worldItem = self.worldItems[slot]
    local transform = worldItem.transform
    ---如果没有旧隐藏当前节点
    worldItem.gameObject:SetActive(cfg_SoulTrial ~= nil)
    ---创建某个类型的Prefab
    if cfg_SoulTrial then
        ---如果有旧数据就销毁
        if worldItem.prefab then
            GameObjectUtil.Destroy(worldItem.prefab)
        end
        ---因为每次数据不一样,所以prefab也不一样
        local Prefab = Res.LoadGameObject(cfg_SoulTrial.StageType, ResType.T_SystemItem)
        GameObjectUtil.SetParent(Prefab.transform, transform, false)
        worldItem.prefab = Prefab
        worldItem.prefab:SetActive(true)
        local topTransform = GameObjectUtil.GetComponent(worldItem.prefab, "OCX_Top", "Transform")
        self.worldItems[slot].topTransform = topTransform
        self.worldItems[slot].prefab = worldItem.prefab
    end
end

---@param deltaTime number
function SoulTrialLogicMgr:_MoveDown(deltaTime)
    for Slot = 2, 6, 1 do
        ---@type X3Animator
        local Animator = self.worldItems[Slot].x3Animator
        Animator:FastForward(ANIM_MOVE_DOWN, deltaTime)
    end
end

function SoulTrialLogicMgr:PlayMoveDownAnim(callBack)
    self.animator = self.worldItems[3].x3Animator
    self.moveDownCompleteHandler = handler(self, self.OnMoveDownComplete)
    self.animator:AddStateCompleteListener(self.moveDownCompleteHandler)
    self.moveDownHandler = callBack
    for slot = 2, 6, 1 do
        local x3Animator = self.worldItems[slot].x3Animator
        x3Animator:Play(ANIM_MOVE_DOWN, 0, CS.UnityEngine.Playables.DirectorWrapMode.Hold)
    end
end

function SoulTrialLogicMgr:OnMoveDownComplete(stateName)
    if stateName == ANIM_MOVE_DOWN and self.moveDownHandler then
        self.animator:RemoveStateCompleteListener(self.moveDownCompleteHandler)
        self.moveDownHandler()
        self.moveDownHandler = nil
    end
end

function SoulTrialLogicMgr:GetWorldItemTransform(slot)
    return self.worldItems[slot].transform
end

function SoulTrialLogicMgr:GetWorldItemTopTransform(slot)
    return self.worldItems[slot].topTransform
end

function SoulTrialLogicMgr:GetOriginSlotPosition(slot)
    return self.worldItems[slot].originPosition
end

function SoulTrialLogicMgr:PlayMotion_SelectOut()
    GameObjectUtil.SetActive(self.selectObject, false)
    --UIUtil.PlayMotion(self.selectObject, "fx_ui_soultrail_select_out")
end

function SoulTrialLogicMgr:PlayMotion_SelectIn()
    GameObjectUtil.SetActive(self.selectObject, true)
    UIUtil.PlayMotion(self.selectObject, "fx_ui_soultrail_select_in")
end

function SoulTrialLogicMgr:GetBallModel(slot)
    return self.worldItems[slot] and self.worldItems[slot].prefab or nil
end

function SoulTrialLogicMgr:PlayMotion_Ball_Out()
    local ball = self.ballInModel
    if ball then
        GameObjectUtil.SetActive(GameObjectUtil.GetComponent(ball, "OCX_Fx_Ball"), false)
    end
end

function SoulTrialLogicMgr:PlayMotion_Ball_In(slot)
    local ball = self:GetBallModel(slot)
    if ball then
        self.ballInModel = ball
        GameObjectUtil.SetActive(GameObjectUtil.GetComponent(ball, "OCX_Fx_Ball"), true)
    end
end

function SoulTrialLogicMgr:PlayEffect(callback)
    ---选中动效消失,原球自身特效关闭
    UIUtil.PlayMotion(self.selectObject, "fx_ui_soultrail_select_out")
    ---原球自身特效关闭
    self:PlayMotion_Ball_Out()
    ---等待固定0.6秒: 播放选中特效显示,球运动动画,锁消失动画
    TimerMgr.AddScaledTimer(0.6, function()
        ---球运动动画
        self:PlayMoveDownAnim(function()
            -----播放选中特效显示
            --self:PlayMotion_SelectIn()
            
            EventMgr.Dispatch(SoulTrialConst.Event.CLIENT_ST_ON_DRAG_REFRESH, 1)
        end)
        ---锁消失动画
        if callback then callback() end
    end, self)
end

function SoulTrialLogicMgr:OnResetBallPosition()
    self:_MoveDown(0)
    self:PlayMotion_SelectIn()
end

SoulTrialLogicMgr:ctor()

return SoulTrialLogicMgr