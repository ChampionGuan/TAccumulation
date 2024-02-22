﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/7/11 19:31
---
local PhotoEditPhotoCtrl = require "Runtime.System.X3Game.Modules.PhotoEditNew.PhotoEditPhotoCtrl"
local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"

---@class PhotoEditTouchNew
local PhotoEditTouchNew = class("PhotoEditTouchNew")

function PhotoEditTouchNew:ctor()
    ---@type PhotoEditPhotoCtrl[]
    self.ctrlList = {}
    self.focusId = nil
    self.exchangeId = nil  ---长按中的逻辑Id
    self.noTouchAreaList = nil
    self.forbiddenTouch = false

    ---拖动中标记位
    self.dragging = false
    ---禁止缩放移动标记位
    ---
    ---Debug使用
    --滚轮缩放
    self.scrollWheel = 0;
    self.zoomWeight = 2;
    self.oldScrollWheel = 0;
end

---注册手势函数
---@param go GameObject 关联的GO
function PhotoEditTouchNew:RegisterCtrl(go)
    EventMgr.AddListener(PurikuraConstNew.Event.OnPhotoItemMementoChange, self.OnMementoChange, self)
    self.ctrlGo = go
    ----这里确认下，看长按是否需要。---放到button那里实现感觉也行，通知触发长按状态
    self.touch = GameObjClickUtil.Get(go)
    self.touch:SetDelegate(self)
    self.touch:SetCtrlType(GameObjClickUtil.CtrlType.CLICK | GameObjClickUtil.CtrlType.DRAG | GameObjClickUtil.CtrlType.MULTI_TOUCH | GameObjClickUtil.CtrlType.MOUSE_SCROLL)
    self.touch:SetClickType(GameObjClickUtil.ClickType.POS | GameObjClickUtil.ClickType.TARGET | GameObjClickUtil.ClickType.LONG_PRESS)
    self.touch:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_DOWN, false)
    self.touch:SetMoveThresholdDis(10)
    --self.touch:SetScaleThreshold(10)

end

---移除手势函数注册
function PhotoEditTouchNew:RemoveCtrl()
    if (self.ctrlGo) then
        GameObjClickUtil.Remove(self.ctrlGo)
        self.ctrlGo = nil
    end
end

---注册照片逻辑控制
---@param id int 逻辑类id
---@param childDataList table 若干照片的数据列表
---@param limitData table 基于整体的限制数据
function PhotoEditTouchNew:RegisterPhotoItem(id, childDataList, limitData)
    if (not self.ctrlList[id]) then
        local item = PhotoEditPhotoCtrl:new();
        item:Init(id, childDataList, limitData)
        self.ctrlList[id] = item
    else
        ---这里先预防拍完编辑中，跳转到相册编辑的情况。
        Debug.LogError("RegisterPhotoItem ID ERROR ", id)
    end
end

---更新照片限位区域（不同情况下，照片的可移动范围不同）
---@param id int 逻辑类id
---@param childId int 子照片ID
---@param data table 包含限位的rect信息
function PhotoEditTouchNew:UpdatePhotoLimitScreenRect(id, childId, data)
    if (self.ctrlList[id]) then
        return self.ctrlList[id]:UpdatePhotoLimitScreenRect(childId, data);
    else
        Debug.LogError("UpdatePhotoLimitScreenRect no id ", id)
    end
end

---更新不触发拖拽的区域（用作点在按钮，或列表上不触发拖拽的功能）
---@param rectList table<Rect> rect列表，以屏幕坐标为准
function PhotoEditTouchNew:UpdateNoTouchArea(rectList)
    self.noTouchAreaList = rectList
end

---UI端控制
---@param forbidden bool 是否禁止移动及缩放
function PhotoEditTouchNew:UpdateNoTouchState(forbidden)
    self.forbiddenTouch = forbidden
end

---强制检测照片位置，并触发更新(针对当前选中目标)
function PhotoEditTouchNew:ForceCheckPhotoLimit()
    if (self.ctrlList[self.focusId]) then
        self.ctrlList[self.focusId]:ForceCheckPhotoLimit()
    else
        Debug.LogError("OnDoubleTouchScale no id ", self.focusId)
    end
end
--region 操作记录
----------操作记录------------

---获取当前操作记录id(用作比对是否发生新的操作)
---@param id int 逻辑类id
---@return int 操作记录索引
function PhotoEditTouchNew:GetMementoIndex(id)
    if (self.ctrlList[id]) then
        return self.ctrlList[id]:GetMementoIndex();
    else
        Debug.LogError("GetMementoIndex no id ", id)
    end
end

---通过大页签记录恢复数据（暂时无用）
function PhotoEditTouchNew:RecoverByTabMemento(id)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:RecoverByTabMemento();
    else
        Debug.LogError("RecoverByTabMemento no id ", id)
    end
end

---增加一次操作记录快照
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
function PhotoEditTouchNew:AddMemento(id, type)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:AddMemento(type);
    else
        Debug.LogError("AddMemento no id ", id)
    end
end

---跳转到对应类型的初始状态
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
---@param isCancel bool 是否为关闭小页签
function PhotoEditTouchNew:JumpFirstMemento(id, type, isCancel)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:JumpFirstMemento(type, isCancel);
    else
        Debug.LogError("JumpFirstMemento no id ", id)
    end
end

---清除对应类型的操作记录快照
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
function PhotoEditTouchNew:ClearMemento(id, type)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:ClearMemento(type);
    end
end

---使用上一步的操作记录快照重置数据
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
function PhotoEditTouchNew:UnDo(id, type)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:UnDo(type);
    end
end

---使用下一步的操作记录快照重置数据
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
function PhotoEditTouchNew:ReDo(id, type)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:ReDo(type);
    end
end

---预留接口 --暂时不用
--function PhotoEditTouchNew:ReSet(id, type)
--    if (self.ctrlList[id]) then
--        self.ctrlList[id]:ReSet(type);
--    end
--end

---检测是否可以进行上一步或下一步
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
---@param isReDo bool 是否为前进
function PhotoEditTouchNew:CheckCanDo(id, type, isReDo)
    if (self.ctrlList[id]) then
        return self.ctrlList[id]:CheckCanDo(type, isReDo);
    end
end
----------------
--endregion

---切换贴纸翻转状态
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditTouchNew:SwitchFlipState(photoId, stickerIndex)
    if (self.ctrlList[photoId]) then
        self.ctrlList[photoId]:SwitchFlipState(stickerIndex);
    else
        Debug.LogError("SwitchFlipState no id ", photoId)
    end
end

---贴纸按住旋转，缩放
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
---@param state bool 开启状态
function PhotoEditTouchNew:SwitchRotateState(photoId, stickerIndex, state)
    if (self.ctrlList[photoId]) then
        self.ctrlList[photoId]:SwitchRotateState(stickerIndex, state);
    else
        Debug.LogError("SwitchRotateState no id ", photoId)
    end
end

---删除一个贴纸逻辑
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditTouchNew:DeleteSticker(photoId, stickerIndex)
    if (self.ctrlList[photoId]) then
        self.ctrlList[photoId]:DeleteSticker(stickerIndex);
    else
        Debug.LogError("DeleteSticker no id ", photoId)
    end
end

---旋转当前选中的item
---@param value Quaternion 旋转值
function PhotoEditTouchNew:RotateItem(value)
    if (self.focusId) then
        if (self.ctrlList[self.focusId]) then
            self.ctrlList[self.focusId]:Rotate(value);
        else
            Debug.LogError("RotateItem no id ", self.focusId)
        end
    end
end

---获取选中item的旋转值
---@return Quaternion 旋转值
function PhotoEditTouchNew:GetItemRotation()
    if (self.ctrlList[self.focusId]) then
        return self.ctrlList[self.focusId]:GetItemRotation();
    else
        Debug.LogError("GetItemRotation no id ", self.focusId)
    end
end

---获取指定item的frameId
---@return int 边框id
function PhotoEditTouchNew:GetItemFrame(photoId)
    if (self.ctrlList[photoId]) then
        return self.ctrlList[photoId]:GetFrame()
        --self.ctrlList[photoId]:Select(childId);
    else
        Debug.LogError("GetItemFrame no id ", photoId)
    end
end

---获取逻辑类的边框及滤镜等信息
---@param id int 逻辑类id
---@return table 包含边框，滤镜等信息
function PhotoEditTouchNew:GetItemData(photoId)
    if (self.ctrlList[photoId]) then
        return self.ctrlList[photoId]:GetData()
    else
        Debug.LogError("GetItemData no id ", photoId)
    end
end

---获取逻辑类的贴纸信息
function PhotoEditTouchNew:GetItemStickerIdList(photoId)
    if (self.ctrlList[photoId]) then
        return self.ctrlList[photoId]:GetStickerIdList()
    else
        Debug.LogError("GetItemStickerIdList no id ", photoId)
    end
end

---将某个子逻辑置为选中态
---@param id int 需要操作的逻辑类ID
---@param childId int 需要操作的子逻辑ID（可能为照片或贴纸）
---@param needRecord bool 需要记录操作步骤
function PhotoEditTouchNew:SelectItem(photoId, childId, needRecord)
    if (self.ctrlList[photoId]) then
        self.focusId = photoId
        self.ctrlList[photoId]:Select(childId, needRecord);
    else
        Debug.LogError("SelectItem no id ", photoId)
    end
end

---取消所有逻辑的选中
function PhotoEditTouchNew:UnSelectItem()
    if (self.focusId) then
        if (self.ctrlList[self.focusId]) then
            self.ctrlList[self.focusId]:UnSelect();
        else
            Debug.LogError("UnSelectItem no id ", self.focusId)
        end
        self.focusId = nil
    end
end

---添加一张贴纸
---@param id int 需要操作的逻辑类ID
---@param stickerId int 贴纸id
function PhotoEditTouchNew:AddSticker(id, stickerId)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:AddSticker(stickerId);
    else
        Debug.LogError("AddSticker no id ", id)
    end
end

---复制一个贴纸
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditTouchNew:CopySticker(id, stickerId)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:CopySticker(stickerId);
    else
        Debug.LogError("CopySticker no id ", id)
    end
end

---设置贴纸初始数据(与UI强相关的，例如对角线的长度)
---@param id int 需要操作的逻辑类ID
---@param stickerIndex int 需要操作的贴纸逻辑ID
---@param data table 若干基础数据
function PhotoEditTouchNew:SetStickerData(id, stickerIndex, data)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetStickerData(stickerIndex, data);
        self.focusId = id
    else
        Debug.LogError("AddSticker no id ", id)
    end
end

---设置边框
---@param id int 需要操作的逻辑类ID
---@param frameId int 边框ID
function PhotoEditTouchNew:SetFrame(id, frameId)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetFrame(frameId);
    else
        Debug.LogError("SetFrame no id ", id)
    end
end

---设置滤镜
---@param id int 需要操作的逻辑类ID
---@param frameId int 滤镜
function PhotoEditTouchNew:SetFilter(id, filterID)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetFilter(filterID);
    else
        Debug.LogError("SetFilter no id ", id)
    end
end

---设置套装
---@param id int 需要操作的逻辑类ID
---@param suitId int 套装Id
function PhotoEditTouchNew:SetSuit(id, suitId)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetSuit(suitId);
    else
        Debug.LogError("SetSuit no id ", id)
    end
end

----用于边框等，配置在表中的数据覆写(位置，选中，缩放)
---@param id int 逻辑类id
---@param childId int 子照片逻辑ID
---@param data table 包含位置，选中，缩放等
function PhotoEditTouchNew:SetPhotoItemData(id, childId, data)
    --Debug.LogError("SetPhotoItemData ", id, " childId ", childId)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetPhotoItemData(childId, data);
    else
        Debug.LogError("SetPhotoItemData no id ", id)
    end
end

----用于边框等，配置在表中的数据覆写(位置，选中，缩放)
------@param id int 逻辑类id
-----@param childId int 贴纸逻辑ID
-----@param data table 包含位置，选中，缩放等
function PhotoEditTouchNew:SetStickerItemData(id, childId, data)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetStickerItemData(childId, data);
    else
        Debug.LogError("SetStickerItemData no id ", id)
    end
end

function PhotoEditTouchNew:SetPhotoExchangeData(id, changeA, changeB)
    if (self.ctrlList[id]) then
        self.ctrlList[id]:SetPhotoExchangeData(changeA, changeB);
    else
        Debug.LogError("SetPhotoExchangeData no id ", id)
    end
end

----手势代理触发（目前用于检测判断是否可执行拖拽）
function PhotoEditTouchNew:OnTouchDown(pos)
    --Debug.LogError(" OnTouchDown ", pos)
    if (self.noTouchAreaList) then
        local v2 = Vector2.new(pos.x, pos.y)
        for i = 1, #self.noTouchAreaList do
            local rect = self.noTouchAreaList[i]
            --Debug.LogError("rect x ", rect.x, " -y ", rect.y, " = width ", rect.width, " =height ", rect.height)
            if (rect:Contains(v2)) then
                --Debug.LogError("contains")
                self.forbiddenTouch = true
                break
            end
        end
    end
end

----手势代理触发（触发交换检测）
function PhotoEditTouchNew:OnTouchUp(pos)
    if (self.exchangeId) then
        --self:OnExchangeEnd(self.exchangeId)
        if (self.ctrlList[self.exchangeId]) then
            self.ctrlList[self.exchangeId]:OnExchangeEnd()
        else
            Debug.LogError("OnExchangeEnd no id ", self.exchangeId)
        end
        self.exchangeId = nil
        --EventMgr.Dispatch(PurikuraConstNew.Event.OnPhotoExchangeStateChange)
    end
    ----注意多指问题，包括forbiddenTouch参数
    --XTBUG-23047 抬起时为1
    --if(GameObjClickUtil.TouchCount() == 0) then
        EventMgr.Dispatch(PurikuraConstNew.Event.OnPhotoNotHolding)
        self.forbiddenTouch = false
    --end

end

----手势代理触发（目前用于检测判断是否可执行拖拽）
function PhotoEditTouchNew:OnBeginDrag(pos)
    if (self.noTouchAreaList) then
        local v2 = Vector2.new(pos.x, pos.y)
        for i = 1, #self.noTouchAreaList do
            local rect = self.noTouchAreaList[i]
            if (rect:Contains(v2)) then
                self.forbiddenTouch = true
                break
            end
        end
    end
end

----手势代理触发（目前用于交换移动及移动）
function PhotoEditTouchNew:OnDrag(pos, deltaPos, gesture)
    if (self.forbiddenTouch) then
        return
    end
    local item = self.focusId and self.ctrlList[self.focusId]
    if (item) then
        if (self.exchangeId) then
            item:OnExchangeDrag(deltaPos, pos)
        else
            item:OnDrag(deltaPos, pos)
            --else
            --Debug.LogError("OnDrag ERROR ", self.focusId)
        end
        EventMgr.Dispatch(PurikuraConstNew.Event.OnPhotoHolding)
    end

end

----手势代理触发（目前用于添加快照）
function PhotoEditTouchNew:OnEndDrag(pos)
    --Debug.LogError("OnEndDrag -------------------------------", pos)
    ---交换过程中不记录位置
    if( self.focusId and (not self.forbiddenTouch) and (not self.exchangeId)) then
        if (self.ctrlList[self.focusId]) then
            self.ctrlList[self.focusId]:OnEndDrag();
        else
            Debug.LogError("OnEndDrag no id ", self.focusId)
        end
    end
    self.forbiddenTouch = false
end

----手势代理触发（滚轮缩放的DEBUG功能）
function PhotoEditTouchNew:OnScrollWheel(scrollWheel, delta)

    self.scrollWheel = self.scrollWheel - scrollWheel * self.zoomWeight
    local delta = self.oldScrollWheel - self.scrollWheel
    if math.abs(delta) <= 0.001 then
        return
    end
    --Debug.LogError("OnScrollWheel scrollWheel ", scrollWheel, " delta ", delta)
    self:OnDoubleTouchScale(delta, 1)
    self.oldScrollWheel = self.scrollWheel

end

function PhotoEditTouchNew:OnEndScrollWheel(scrollWheel, delta)
    self:OnEndDoubleTouchScale()
    self:OnTouchUp()
end

function PhotoEditTouchNew:OnLongPress()

end

---------双指
function PhotoEditTouchNew:OnDoubleTouchScale(delta, scale)
    if (self.focusId) then
        if(self.forbiddenTouch) then
            return
        end
        if (self.ctrlList[self.focusId]) then
            --Debug.LogError("delta ", delta, " SCALE ", scale, " res ", delta > 0 and 0.05 * scale or -(0.1 / scale))
            self.ctrlList[self.focusId]:OnScale(delta > 0 and 0.05 * scale or -(0.1 / scale));
            --self.ctrlList[self.focusId]:OnScale(delta);
            EventMgr.Dispatch(PurikuraConstNew.Event.OnPhotoHolding)
        else
            Debug.LogError("OnDoubleTouchScale no id ", self.focusId)
        end
    end
end

function PhotoEditTouchNew:OnEndDoubleTouchScale(delta, scale)
    if (self.focusId) then
        if (self.ctrlList[self.focusId]) then
            PhotoEditMgr.AddItemMemento(self.focusId)
            EventMgr.Dispatch(PurikuraConstNew.Event.OnLogicChangeMemento)
            -------------这里要想下是存正确的位置还是存当前的位置
            self:ForceCheckPhotoLimit()
        end
    end
end

function PhotoEditTouchNew:OnBeginDoubleTouchRotate(delta, angle)

end

function PhotoEditTouchNew:OnDoubleTouchRotate(delta, angle)

end

function PhotoEditTouchNew:OnEndDoubleTouchRotate(delta, angle)

end


----长按交换功能---变更当前选中照片为可交换状态--- 长按交换功能 --默认当前选中item
function PhotoEditTouchNew:SetExChangeState()
    if (self.focusId) then
        self.exchangeId = self.focusId
        self.ctrlList[self.focusId]:OnExchangeStart()
    end
end

function PhotoEditTouchNew:SetExchangeRootPos(pos)
    if(self.focusId) then
        self.ctrlList[self.focusId]:SetExchangeRootPos(pos)
    end
end

---按照快照刷新数据
---@param data <table> 快照数据
---@param isCancel bool 是否为关闭小页签
function PhotoEditTouchNew:OnMementoChange(data, isCancel)
    if (data and self.ctrlList[data.id]) then
        self.ctrlList[data.id]:OnMementoChange(data, isCancel)
    else
        Debug.LogError("OnMementoChange no data or id ", data)
    end
end

---单次编辑关闭时
function PhotoEditTouchNew:Depose(lastEditMode)
    --Debug.LogError(" PhotoEditTouchNew Depose")
    self.focusId = nil
    self.noTouchAreaList = nil
    self.forbiddenTouch = false
    self:RemoveCtrl() -- PhotoHeadshotShotNum
    local totalCount = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHOTOHEADSHOTSHOTNUM)
    if(lastEditMode and lastEditMode ~= Define.PhotoEntryMode.Sticker) then
        local startId = PurikuraConstNew.PhotoRegisterStartId[lastEditMode]
        for i = startId, startId + totalCount do
            if(self.ctrlList[i]) then
                self.ctrlList[i]:Depose()
                self.ctrlList[i] = nil
            end
        end
    else
        for index, ctrl in pairs(self.ctrlList) do
            ctrl:Depose()
        end
        self.ctrlList = {}
    end

    EventMgr.RemoveListenerByTarget(self)
end

return PhotoEditTouchNew