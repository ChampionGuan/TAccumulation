﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/7/11 19:24
---

---@class PhotoEditMgr
local PhotoEditMgr = class("PhotoEditMgr")

local PhotoEditDataNew = require "Runtime.System.X3Game.Modules.PhotoEditNew.PhotoEditDataNew"
local PhotoEditTouchNew = require "Runtime.System.X3Game.Modules.PhotoEditNew.PhotoEditTouchNew"
local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"

local self = PhotoEditMgr

-----每个照片应该有自己单独的数据存储--先处理切换照片的--点击时触发touchCtrl
----每个照片为主体，拼图的图片作为特殊的item ---需要有模式区分

function PhotoEditMgr:Init()
    self.editData = PhotoEditDataNew:new()
    self.touchCtrl = PhotoEditTouchNew:new()
end

--region UI记录的数据及状态数据
function PhotoEditMgr.SetGroupMode(mode)
    self.editData:SetGroupMode(mode)
end

function PhotoEditMgr.SetEditType(type)
    self.editData:SetEditType(type)
end

function PhotoEditMgr.GetGroupMode()
    return self.editData:GetGroupMode()
end

function PhotoEditMgr.GetEditType()
    return self.editData:GetEditType()
end

---记录开启编辑的入口
---@param mode Define.PhotoEntryMode 入口模式
function PhotoEditMgr.FillEditTagStack(mode)
    self.editData:EditStackPush(mode)
end
--endregion

---注册touch监听
---@param go GameObject 关联的GO
function PhotoEditMgr.RegisterCtrl(go)
    self.touchCtrl:RegisterCtrl(go)
end

---注册照片逻辑类
---@param id int 逻辑类id
---@param childDataList table 若干照片的数据列表
---@param limitData table 基于整体的限制数据
function PhotoEditMgr.RegisterPhotoItem(id, childDataList, limitData)
    self.touchCtrl:RegisterPhotoItem(id, childDataList, limitData)
end


---更新不触发拖拽的区域（用作点在按钮，或列表上不触发拖拽的功能）
---@param rectList table<Rect> rect列表，以屏幕坐标为准
function PhotoEditMgr.UpdateNoTouchArea(rectList)
    self.touchCtrl:UpdateNoTouchArea(rectList)
end

---UI端控制
---@param forbidden bool 是否禁止移动及缩放
function PhotoEditMgr.UpdateNoTouchState(forbidden)
    self.touchCtrl:UpdateNoTouchState(forbidden)
end


---强制检测照片位置，并触发更新(针对当前选中目标)
function PhotoEditMgr.ForceCheckPhotoLimit()
    self.touchCtrl:ForceCheckPhotoLimit()
end

---更新照片限位区域（不同情况下，照片的可移动范围不同）
---@param id int 逻辑类id
---@param childId int 子照片ID
---@param data table 包含限位的rect信息
function PhotoEditMgr.UpdatePhotoLimitScreenRect(id, childId, data)
    self.touchCtrl:UpdatePhotoLimitScreenRect(id, childId, data)
end

---添加一张贴纸
---@param id int 需要操作的逻辑类ID
---@param stickerId int 贴纸id
function PhotoEditMgr.AddSticker(id, stickerId)
    self.touchCtrl:AddSticker(id, stickerId)
end

---设置贴纸初始数据(与UI强相关的，例如对角线的长度)
---@param id int 需要操作的逻辑类ID
---@param stickerIndex int 需要操作的贴纸逻辑ID
---@param data table 若干基础数据
function PhotoEditMgr.SetStickerData(id, stickerIndex, data)
    self.touchCtrl:SetStickerData(id, stickerIndex, data)
end

---将某个子逻辑置为选中态
---@param id int 需要操作的逻辑类ID
---@param childId int 需要操作的子逻辑ID（可能为照片或贴纸）
---@param needRecord bool 需要记录操作步骤
function PhotoEditMgr.SelectItem(id, childId, needRecord)
    self.touchCtrl:SelectItem(id, childId, needRecord)
end

---取消所有逻辑的选中
function PhotoEditMgr.UnSelectItem()
    self.touchCtrl:UnSelectItem()
end

---旋转当前选中的item
---@param value Quaternion 旋转值
function PhotoEditMgr.RotateItem(value)
    self.touchCtrl:RotateItem(value)
end

---获取选中item的旋转值
---@return Quaternion 旋转值
function PhotoEditMgr.GetSelectItemRotation()
    return self.touchCtrl:GetItemRotation()
end

---获取指定item的frameId
---@return int 边框id
function PhotoEditMgr.GetItemFrame(id)
    return self.touchCtrl:GetItemFrame(id)
end

---获取逻辑类的边框及滤镜等信息
---@param id int 逻辑类id
---@return table 包含边框，滤镜等信息
function PhotoEditMgr.GetItemData(id)
    return self.touchCtrl:GetItemData(id)
end

---获取逻辑类的贴纸列表
function PhotoEditMgr.GetItemStickerIdList(id)
    return self.touchCtrl:GetItemStickerIdList(id)
end

---删除一个贴纸逻辑
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditMgr.DeleteSticker(id, stickerIndex)
    self.touchCtrl:DeleteSticker(id, stickerIndex)
end

---变更当前选中照片为可交换状态--- 长按交换功能 --默认当前选中item
function PhotoEditMgr.SetExChangeState()
    self.touchCtrl:SetExChangeState()
end

---设置长按时浮起的起始位置
function PhotoEditMgr.SetExchangeRootPos(pos)
    self.touchCtrl:SetExchangeRootPos(pos)
end

---贴纸按住旋转，缩放
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
---@param state bool 开启状态
function PhotoEditMgr.SwitchRotateState(id, stickerIndex, state)
    self.touchCtrl:SwitchRotateState(id, stickerIndex, state)
end

---切换贴纸翻转状态
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditMgr.SwitchFlipState(id, stickerIndex)
    self.touchCtrl:SwitchFlipState(id, stickerIndex)
end

---复制一个贴纸
---@param id int 逻辑类id
---@param stickerIndex int 贴纸逻辑id
function PhotoEditMgr.CopySticker(id, stickerIndex)
    self.touchCtrl:CopySticker(id, stickerIndex)
end

---设置边框
---@param id int 逻辑类id
---@param frameId int 边框ID
function PhotoEditMgr.SetFrame(id, frameId)
    self.touchCtrl:SetFrame(id, frameId)
end

---设置滤镜
---@param id int 逻辑类id
---@param filterID int 滤镜ID
function PhotoEditMgr.SetFilter(id, filterID)
    self.touchCtrl:SetFilter(id, filterID)
end

function PhotoEditMgr.SetSuit(id, suitId)
    self.touchCtrl:SetSuit(id, suitId)
end

----用于边框等，配置在表中的数据覆写(位置，选中，缩放)
---@param id int 逻辑类id
---@param childId int 子照片逻辑ID
---@param data table 包含位置，选中，缩放等
function PhotoEditMgr.SetPhotoItemData(id, childId, data)
    self.touchCtrl:SetPhotoItemData(id, childId, data)
end

----用于边框等，配置在表中的数据覆写(位置，选中，缩放)
------@param id int 逻辑类id
-----@param childId int 贴纸逻辑ID
-----@param data table 包含位置，选中，缩放等
function PhotoEditMgr.SetStickerItemData(id, childId, data)
    self.touchCtrl:SetStickerItemData(id, childId, data)
end

function PhotoEditMgr.SetPhotoExchangeData(id, changeA, changeB)
    self.touchCtrl:SetPhotoExchangeData(id, changeA, changeB)
end

-------操作记录

---获取当前操作记录id(用作比对是否发生新的操作)--默认大页签
---@param id int 逻辑类id
---@return int 操作记录索引
function PhotoEditMgr.GetMementoIndex(id)
    return self.touchCtrl:GetMementoIndex(id)
end

---通过记录恢复界面状态 ---暂时没用到
function PhotoEditMgr.RecoverByTabMemento(id)
    self.touchCtrl:RecoverByTabMemento(id)
end

---增加一次操作记录快照（大页签）
---@param id int 逻辑类id
function PhotoEditMgr.AddTabMemento(id)
    self.touchCtrl:AddMemento(id, PurikuraConstNew.MementoMode.Tab)
end

---跳转到大页签的初始状态
---@param id int 逻辑类id
function PhotoEditMgr.JumpFirstTabMemento(id)
    self.touchCtrl:JumpFirstMemento(id, PurikuraConstNew.MementoMode.Tab)
end

---清除大页签的操作记录快照
---@param id int 逻辑类id
function PhotoEditMgr.ClearTabMemento(id)
    self.touchCtrl:ClearMemento(id, PurikuraConstNew.MementoMode.Tab)
end

---使用上一步的操作记录快照重置数据（大页签）
---@param id int 逻辑类id
function PhotoEditMgr.UnDoTab(id)
    self.touchCtrl:UnDo(id, PurikuraConstNew.MementoMode.Tab)
end


---使用下一步的操作记录快照重置数据（大页签）
---@param id int 逻辑类id
function PhotoEditMgr.ReDoTab(id)
    self.touchCtrl:ReDo(id, PurikuraConstNew.MementoMode.Tab)
end

function PhotoEditMgr.ReSetTab(id)
    --self.touchCtrl:ReSet(id, PurikuraConstNew.MementoMode.Tab)
end

---检测大页签是否可以进行上一步或下一步
---@param id int 逻辑类id
---@param type PurikuraConstNew.MementoMode 页签枚举
---@param isReDo bool 是否为前进
function PhotoEditMgr.CheckTabCanDo(id, isReDo)
    return self.touchCtrl:CheckCanDo(id, PurikuraConstNew.MementoMode.Tab, isReDo)
end

---增加一次操作记录快照（小页签）
---@param id int 逻辑类id
function PhotoEditMgr.AddItemMemento(id)
    self.touchCtrl:AddMemento(id, PurikuraConstNew.MementoMode.Item)
end

---跳转到小页签的初始状态
---@param id int 逻辑类id
---@param isCancel bool 是否为关闭小页签
function PhotoEditMgr.JumpFirstItemMemento(id, isCancel)
    self.touchCtrl:JumpFirstMemento(id, PurikuraConstNew.MementoMode.Item, isCancel)
end

---使用上一步的操作记录快照重置数据（小页签）
---@param id int 逻辑类id
function PhotoEditMgr.UnDoItem(id)
    self.touchCtrl:UnDo(id, PurikuraConstNew.MementoMode.Item)
end

---使用下一步的操作记录快照重置数据（小页签）
---@param id int 逻辑类id
function PhotoEditMgr.ReDoItem(id)
    self.touchCtrl:ReDo(id, PurikuraConstNew.MementoMode.Item)
end

function PhotoEditMgr.ReSetItem(id)
    --self.touchCtrl:ReSet(id, PurikuraConstNew.MementoMode.Item)
end

---清除小页签的操作记录快照
---@param id int 逻辑类id
function PhotoEditMgr.ClearItemMemento(id)
    self.touchCtrl:ClearMemento(id, PurikuraConstNew.MementoMode.Item)
end

---检测是否可以进行上一步或下一步（小页签）
---@param id int 逻辑类id
function PhotoEditMgr.CheckItemCanDo(id, isReDo)
    return self.touchCtrl:CheckCanDo(id, PurikuraConstNew.MementoMode.Item, isReDo)
end

function PhotoEditMgr.Clear()
    PhotoEditMgr.Depose()
end

---单次编辑退出时
---
function PhotoEditMgr.Depose()
    local lastEditMode = self.editData:EditStackPop()
    self.touchCtrl:Depose(lastEditMode)
    self.editData:Depose()
end

self:Init()

return PhotoEditMgr