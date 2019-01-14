-----------------------------------------------------
-------------------定义SubController-----------------
-----------------------------------------------------
local facade = LuaHandle.load(UIConfig.Facade)

-- 实例化
local function SubController(ctrlName, viewName)
    local t = (LuaHandle.load(UIConfig.UICtrl))(ctrlName, viewName)
    -- 界面引用
    t.SubView = nil
    -- 父ctrl
    t.ParentCtrl = nil
    -- 创建界面--
    t.creat = function(self, parentCtrl)
        self.ParentCtrl = parentCtrl
        self.View = parentCtrl.View
        if nil ~= self.SubView and not Utils.uITargetIsNil(self.SubView.UI) then
            return
        end
        if self.ViewName ~= nil then
            self.SubView = LuaHandle.load(self.ViewName)
            self.SubView:LoadView()
        else
            if nil ~= parentCtrl.SubView then
                self.SubView = parentCtrl.SubView
            else
                self.SubView = parentCtrl.View
            end
        end
        self.Params = {}
        self:onCreat()
        -- 子ctrl创建
        for k, v in pairs(self.SubCtrl) do
            v:creat(self)
        end
    end
    -- 重建界面--
    t.reCreat = function(self)
        if self.ViewName ~= nil and (nil == self.SubView or Utils.uITargetIsNil(self.SubView.UI)) then
            self:creat(self.ParentCtrl)
            self:open(self.ParentCtrl, self.Data)
        end
    end
    -- 打开界面--
    t.open = function(self, parentCtrl, data)
        self.Data = data
        self.ParentCtrl = parentCtrl
        self:reCreat()

        -- 子ctrl打开
        for k, v in pairs(self.SubCtrl) do
            v:open(self, data)
        end
        self.IsOpen = true
    end
    -- 关闭界面--
    t.close = function(self, parentCtrl)
        if parentCtrl ~= self.ParentCtrl then
            return
        end
        self.ParentCtrl = parentCtrl
        self.IsOpen = false

        -- 子ctrl关闭
        for k, v in pairs(self.SubCtrl) do
            v:close(self)
        end
    end
    -- 显示界面--
    t.show = function(self, parentCtrl)
        -- 如果被销毁则重新创建
        self.ParentCtrl = parentCtrl
        self:reCreat()

        -- 子ctrl显示
        for k, v in pairs(self.SubCtrl) do
            v:show(self)
            v:setParent(self.SubView.UI)
        end

        if not self:uiIsDestroyed() then
            self.SubView:show()
        end

        self.IsOpen = true
        self.IsShow = true
    end
    -- 隐藏界面--
    t.hide = function(self, parentCtrl)
        if parentCtrl ~= self.ParentCtrl then
            return
        end
        self.ParentCtrl = parentCtrl
        self.IsShow = false

        -- 子ctrl隐藏
        for k, v in pairs(self.SubCtrl) do
            v:hide(self)
        end
        if not self:uiIsDestroyed() then
            self.SubView:hide()
        end
    end
    -- 通知界面是否可交互--
    t.interactive = function(self, parentCtrl, isok)
        self.ParentCtrl = parentCtrl

        -- 子ctrl交互
        for k, v in pairs(self.SubCtrl) do
            v:interactive(self, isok)
        end
        if not self:uiIsDestroyed() then
            self.SubView:interactive(isok)
        end
        self:onInteractive(isok)
    end
    -- 销毁界面--
    t.destroy = function(self, parentCtrl, force)
        -- 父对象为空时
        if nil == self.ParentCtrl then
            return
        end

        -- 非强制销毁，且父对象不一致
        if not force and parentCtrl ~= self.ParentCtrl then
            return
        end

        -- 非强制销毁，且不允许销毁 （比如一些共用的ctrl(聊天缩略框等)）
        if not force and self.IsCannotDestroy then
            if not self.IsShow then
                self:setParent(CSharp.GRoot.inst)
                self:hide(parentCtrl)
            end
            return
        end

        -- 子ctrl销毁
        for k, v in pairs(self.SubCtrl) do
            v:destroy(self, force)
        end

        if nil ~= self.SubView and not Utils.uITargetIsNil(self.SubView.UI) then
            self:onDestroy()
        end
        if not self:uiIsDestroyed() then
            self.SubView:destroy()
        end

        self.SubView = nil
        self.ParentCtrl = nil
        self.Params = nil
        self.IsOpen = false
        self.IsShow = false
        -- 移除ctrl
        facade:removeSubController(self)
    end
    -- 是否已销毁--
    t.uiIsDestroyed = function(self)
        if nil == self.ViewName or nil == self.SubView or Utils.uITargetIsNil(self.SubView.UI) then
            return true
        else
            return false
        end
    end
    -- 设置父对象
    t.setParent = function(self, parent, index)
        if nil == parent or self:uiIsDestroyed() then
            return
        end

        local sOrder = parent.sortingOrder
        parent.sortingOrder = 0
        if nil ~= index then
            parent:AddChildAt(self.SubView.UI, index)
        else
            parent:AddChild(self.SubView.UI)
        end
        parent.sortingOrder = sOrder

        self.SubView.UI.visible = true
        self.SubView.UI.position = CSharp.Vector3.zero
    end

    facade:registerSubController(t)
    return t
end

return SubController
