local Facade = {}
-- 当界面显示时
Facade.onCtrlShow = nil
-- 当界面隐藏时
Facade.onCtrlHide = nil
-- 当界面打开时
Facade.onCtrlOpen = nil
-- 当界面打开时
Facade.onCtrlClose = nil

-- 本地存储--
local ControllerCenter = {}
local ControllerStack = {}
local SubControllerCenter = {}

local function printCtrlName()
    for k, v in pairs(ControllerStack) do
        print(v.ControllerName, v.Type, "in stack !!!")
    end
end
-- 当界面显示时
local function onCtrlShow(ctrl)
    if nil ~= Facade.onCtrlShow then
        Facade.onCtrlShow(ctrl)
    end
end
-- 当界面隐藏时
local function onCtrlHide(ctrl)
    if nil ~= Facade.onCtrlHide then
        Facade.onCtrlHide(ctrl)
    end
end
-- 当界面打开时
local function onCtrlOpen(ctrl)
    if nil ~= Facade.onCtrlOpen then
        Facade.onCtrlOpen(ctrl)
    end
end
-- 当界面关闭时
local function onCtrlClose(ctrl)
    if nil ~= Facade.onCtrlClose then
        Facade.onCtrlClose(ctrl)
    end
end
-- 比较两ctrl的渲染顺序
local function compareBothCtrlSortingOrder(ctrlA, ctrlB)
    if
        (nil ~= ctrlA.SortingOrder and nil == ctrlB.SortingOrder) or
            (nil ~= ctrlA.SortingOrder and nil ~= ctrlB.SortingOrder and ctrlA.SortingOrder > ctrlB.SortingOrder)
     then
        return true
    end
    return false
end

-- 栈中ctrl排序
local function sortCtrlStack()
    -- 冒泡
    for m = 1, #ControllerStack do
        for n = m + 1, #ControllerStack do
            -- 两ctrl渲染顺序比较
            if compareBothCtrlSortingOrder(ControllerStack[m], ControllerStack[n]) then
                -- 交换位置
                local temp = ControllerStack[m]
                ControllerStack[m] = ControllerStack[n]
                ControllerStack[n] = temp
            end
        end
    end
end
-- 关闭栈中之前界面--
local function hidePreCtrl(id)
    if id <= 0 then
        return
    end
    local ctrl = ControllerStack[id]
    if nil == ctrl then
        return
    end
    ctrl:hide()
    onCtrlHide(ctrl)

    if ctrl.Type == UIDefine.CtrlType.PopupBox then
        id = id - 1
        hidePreCtrl(id)
    end
end
-- 打开栈中之前界面--
local function showPreCtrl(id)
    if id <= 0 then
        return
    end
    local ctrl = ControllerStack[id]
    if nil == ctrl then
        return
    end
    ctrl:show()
    ctrl:sortingOrder(id * 10)

    if ctrl.Type == UIDefine.CtrlType.PopupBox then
        id = id - 1
        showPreCtrl(id)
    end
end
-- 交互栈中之前界面--
local function interactivePreCtrl(id)
    if id <= 0 then
        return
    end
    local ctrl = ControllerStack[id]
    if nil == ctrl then
        return
    end
    ctrl:interactive(true)

    if ctrl.PreCtrlInteractive then
        id = id - 1
        interactivePreCtrl(id)
    end
end
-- 模糊制定界面--
local function BlurPreCtrl(id)
    local ctrl = ControllerStack[id]
    if nil == ctrl then
        return
    end
    if ctrl.IsShow then
        ctrl:blur(true)
    end
    BlurPreCtrl(id + 1)
end
-- 从栈中移除指定界面--
local function removeFromStack(ctrl)
    local removeSucceed = false
    for i = (#(ControllerStack)), 1, -1 do
        if ControllerStack[i] == nil or ControllerStack[i].ControllerName == ctrl.ControllerName then
            removeSucceed = true
            table.remove(ControllerStack, i)
            break
        end
    end

    return removeSucceed
end
-- 获取打开的ctrl
local function getOpenCtrl(id, add)
    local ctrl = ControllerStack[id]
    if nil == ctrl or ctrl.IsOpen then
        return ctrl, id
    else
        return getOpenCtrl(id + add, add)
    end
end
-- 将界面压栈--
function Facade:pushingStack(ctrl)
    -- 隐藏之前面板
    local ctrlNum = #ControllerStack
    if ctrl.Type ~= UIDefine.CtrlType.PopupBox then
        hidePreCtrl(ctrlNum)
    end

    -- 新面板加入栈中
    removeFromStack(ctrl)
    table.insert(ControllerStack, ctrl)
    sortCtrlStack()

    ctrlNum = #ControllerStack

    -- 重置交互性和渲染顺序
    for k, v in pairs(ControllerStack) do
        v:interactive(false)
        v:sortingOrder(k * 10)
    end
    -- 重新设置交互性
    interactivePreCtrl(ctrlNum)

    -- 界面打开
    local theLastCtrl = ControllerStack[ctrlNum]
    onCtrlShow(theLastCtrl)

    -- 处理最后一个面板
    if theLastCtrl.ControllerName == ctrl.ControllerName then
        ctrl:show()
    else
        showPreCtrl(ctrlNum)
    end
end
-- 将界面出栈--
function Facade:popingStack(ctrl)
    -- 关闭自身
    ctrl:hide()
    ctrl:interactive(false)
    onCtrlHide(ctrl)

    -- 判断已无面板
    local ctrlNum = (#ControllerStack)
    if ctrlNum <= 0 then
        return
    end

    -- 未移除成功
    if not removeFromStack(ctrl) then
        return
    end

    -- 栈顶面板
    local theLastCtrl = nil
    theLastCtrl, ctrlNum = Facade:getTopCtrl()
    if nil == theLastCtrl then
        return
    end

    -- 重置交互性（在打开面板之前）
    interactivePreCtrl(ctrlNum)
    -- 打开之前面板
    if ctrl.Type ~= UIDefine.CtrlType.PopupBox then
        showPreCtrl(ctrlNum)
    end
    -- 界面显示
    onCtrlShow(theLastCtrl)
    -- 界面关闭
    onCtrlClose(ctrl)
    -- 背景模糊
    BlurPreCtrl(1)
end
-- 打开指定界面--
function Facade:openController(name, data)
    local ctrl = self:getController(name)
    if ctrl == nil then
        LuaHandle.load(name)
        ctrl = self:getController(name)
    end
    -- 存在预处理逻辑，默认都是预处理成功
    if ctrl:preHandle(data) then
        ctrl:creat()
        ctrl:open(data)
        onCtrlOpen(ctrl)
    end
end
-- 向所有打开界面广播消息--
function Facade:sendNtfMessage(ntfType, ...)
    for k, v in pairs(ControllerStack) do
        if v ~= nil and v.IsOpen then
            v:ntfHandle(ntfType, ...)
        end
    end
end
-- 注册界面--
function Facade:registerController(ctrl)
    if nil == ctrl.ControllerName then
        error("ctrl cannot have no name !!!")
    end
    ControllerCenter[ctrl.ControllerName] = ctrl
end
-- 移除界面--
function Facade:removeController(ctrl)
    if nil == ctrl then
        return
    end
    -- ControllerCenter[ctrl.ControllerName] = nil
end
-- 注册sub界面--
function Facade:registerSubController(ctrl)
    if nil == ctrl.ControllerName then
        error("ctrl cannot have no name !!!")
    end
    SubControllerCenter[ctrl.ControllerName] = ctrl
end
-- 移除sub界面--
function Facade:removeSubController(ctrl)
    if nil == ctrl then
        return
    end
    -- SubControllerCenter[ctrl.ControllerName] = nil
end
-- 获取顶部界面--
function Facade:getTopCtrl()
    return getOpenCtrl(#ControllerStack, -1)
end
-- 获取底部界面--
function Facade:getBottomCtrl()
    return getOpenCtrl(1, 1)
end
-- 获取指定界面--
function Facade:getController(name)
    if name == nil then
        return nil
    end

    return ControllerCenter[name]
end
-- 获取指定界面--
function Facade:getSubController(name)
    if name == nil then
        return nil
    end

    return SubControllerCenter[name]
end
-- 获取顶部的非弹框界面--
function Facade:getTopCtrl2NotPopup()
    local ctrl = nil
    for i = #ControllerStack, 1, -1 do
        if ControllerStack[i].Type ~= UIDefine.CtrlType.PopupBox then
            ctrl = ControllerStack[i]
            break
        end
    end
    return ctrl
end
-- 获取顶部的全屏界面--
function Facade:getTopFullScreenCtrl()
    local ctrl = nil
    for i = #ControllerStack, 1, -1 do
        if ControllerStack[i].Type == UIDefine.CtrlType.FullScreen then
            ctrl = ControllerStack[i]
            break
        end
    end
    return ctrl
end
-- 关闭指定界面--
function Facade:destroyController(name)
    local ctrl = ControllerCenter[name]
    if nil ~= ctrl then
        ctrl:destroyBySelf()
    end
end
-- 关闭所有的界面--
function Facade:destroyAllController(force)
    if nil == force then
        force = false
    end
    if force then
        ControllerStack = {}
    end
    for k, v in pairs(ControllerCenter) do
        -- 不删除loading
        if v.ControllerName == UIConfig.ControllerName.Loading then
            -- do nothing
        else
            v:destroyByOther(force)
        end
    end

    Utils.LuaGC()
    Utils.SystemGC()
end
-- 更新所有打开的界面--
function Facade:updateAllController()
    for k, v in pairs(ControllerStack) do
        if v.IsShow and not v.IsDestroyed then
            v:update()
        end
    end
    -- subCtrl特殊处理
    for k, v in pairs(SubControllerCenter) do
        if v.IsShow then
            v:update()
        end
    end
end
-- 更新所有打开的界面--
function Facade:fixedUpdateAllController()
    for k, v in pairs(ControllerStack) do
        if v.IsShow and not v.IsDestroyed then
            v:fixedUpdate()
        end
    end
    -- subCtrl特殊处理
    for k, v in pairs(SubControllerCenter) do
        if v.IsShow then
            v:fixedUpdate()
        end
    end
end

-- 刷新所有打开的界面--
function Facade:refreshAllController()
    for i = #ControllerStack, 1, -1 do
        if ControllerStack[i].IsOpen and not ControllerStack[i].IsDestroyed then
            ControllerStack[i]:refresh()
        end
    end
end

return Facade
