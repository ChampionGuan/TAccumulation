﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by afan002.
--- DateTime: 2023/11/4 15:57
---

---@class DropMultipleUtil
---@type DropMultipleUtil
local DropMultipleUtil = {}


---初始化多倍掉落奖励UI显示所需参数
---@param go GameObject 挂有ObjectLinker的DropMultiple节点
---@param target UIViewCtrl、UICtrl 需要绑定生命周期的父脚本
---@param params table<string, any> 参数列表
---{
---showType = X3DataConst.DropMultipleShowType 显示类型，不包含物品下标和角标
---effectSystem = X3DataConst.DropMultipleShowType 显示类型，不包含物品下标和角标
---effectStageType = int 关卡类型
---subType = int 关卡子类，可为空
---effectStage = int 关卡ID，可为空
---}
---return DropMultipleCtrl
function DropMultipleUtil.InitDropMultiple(go, target, params)
    local dropMultipleCtrl = Framework.GetOrAddCtrl(go, X3Game.Ctrl.DropMultiple__DropMultipleCtrl, target)
    dropMultipleCtrl:InitData(params)

    return dropMultipleCtrl
end

return DropMultipleUtil