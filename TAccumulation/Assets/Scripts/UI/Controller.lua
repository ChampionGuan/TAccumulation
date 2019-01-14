-----------------------------------------------------
-------------------定义controller--------------------
-----------------------------------------------------
-- 界面销毁配置
local uiDisposeConfig = LuaHandle.load("Config.UIDisposeConfig")
-- facade
local facade = LuaHandle.load(UIConfig.Facade)
-- blur
local blurEffect = LuaHandle.load(UIConfig.UIBlur)
-- layer
local cameraLayer = LuaHandle.load(UIConfig.UILayer)
-- datatrunk
local dataTrunk = LuaHandle.load("Data.DataTrunk")

-- 实例化
local function Controller(ctrlName, viewName, isRegister)
    local t = {}
    t.ConfigInfo = dataTrunk.ConfigInfo
    t.PlayerInfo = dataTrunk.PlayerInfo
    -- 外部传入数据
    t.Data = nil
    -- 参数
    t.Params = nil
    -- 类型
    t.Type = UIDefine.CtrlType.FullScreen
    -- 渲染顺序
    t.SortingOrder = nil
    -- 交互性
    t.Interactive = true
    -- 模糊(默认为关闭)
    t.PreCtrlBlur = false
    -- 上一个Ctrl的交互性(默认为关闭)
    t.PreCtrlInteractive = false
    -- 不允许被销毁
    t.IsCannotDestroy = false
    -- 是否预处理面板
    t.IsPreHandle = false
    -- 是否打开
    t.IsOpen = false
    -- 是否显示
    t.IsShow = false
    -- 是否交互
    t.IsInteractive = false
    -- 是否被销毁
    t.IsDestroyed = true
    -- ctrl名称
    t.ControllerName = ctrlName
    -- view名称
    t.ViewName = viewName
    -- view引用
    t.View = nil
    -- 计时器
    t.TimerCd = nil
    -- 子ctrl
    t.SubCtrl = {}

    -- 广播消息--
    t.sendNtfMsg = function(self, ntfType, ...)
        facade:sendNtfMessage(ntfType, ...)
    end
    -- 预处理界面--
    t.preHandle = function(self, data)
        self.IsPreHandle = true
        self.Data = data
        return self:onPreHandle()
    end
    -- 创建界面--
    t.creat = function(self)
        if not self.IsDestroyed then
            return
        end
        if nil ~= self.ViewName and nil == self.View then
            self.View = LuaHandle.load(self.ViewName)
        end
        self.View:LoadView()

        self.IsDestroyed = false
        self.Params = {}
        self:onCreat()

        -- 子ctrl创建
        for k, v in pairs(self.SubCtrl) do
            v:creat(self)
        end

        -- 初始交互性
        self:interactive(self.IsInteractive)
        -- 创建计时器
        local aliveTime = uiDisposeConfig[self.ControllerName] or 0
        if nil == self.TimerCd and aliveTime ~= -1 then
            self.TimerCd = TimerManager.newTimer(aliveTime, false, true, nil, nil, self.destroyBySelf, self)
        end
    end
    -- 打开界面--
    t.open = function(self, data, isPushStack)
        -- 如果被销毁
        if self.IsDestroyed then
            self:creat()
        end

        self.Data = data
        if nil ~= self.TimerCd then
            self.TimerCd:pause()
        end

        -- 子ctrl打开
        for k, v in pairs(self.SubCtrl) do
            v:open(self, data)
        end
        self.IsOpen = true
        self.IsPreHandle = false
        self:openOver()
        -- 判断是否要推入栈中
        if nil == isPushStack or isPushStack then
            facade:pushingStack(self)
        end

        -- 弹窗动画
        if t.Type == UIDefine.CtrlType.PopupBox and self.View.Window ~= nil then
            self.View.Window.pivot = CSharp.Vector2(0.5, 0.5)
            self.View.Window.scale = CSharp.Vector2(0.85, 0.85)
            self.View.Window:TweenScale(CSharp.Vector2(1, 1), 0.1)
        end
    end
    -- 关闭界面--
    t.close = function(self)
        if not self.IsOpen then
            return
        end
        -- 子ctrl关闭
        for k, v in pairs(self.SubCtrl) do
            v:close(self)
        end
        self.IsOpen = false
        self:closeOver()
        -- 移除模糊
        blurEffect.RemoveBlur(self.ControllerName)

        if nil ~= self.TimerCd then
            self.TimerCd:start()
        end
        facade:popingStack(self)
    end
    -- 显示界面--
    t.show = function(self)
        -- 如果被销毁
        if self.IsDestroyed then
            self:open(self.Data, false)
        end
        -- 未open状态，不处理
        if not self.IsOpen then
            return false
        end
        -- 相机渲染
        cameraLayer:Mask(self)
        -- 模糊
        self:blur(true)

        if self.IsShow then
            return false
        end

        -- 子ctrl显示
        for k, v in pairs(self.SubCtrl) do
            v:show(self)
            v:setParent(self.View.UI)
        end

        if not self.IsDestroyed then
            self.View:show()
        end

        self.IsShow = true
        self:showOver()
        return true
    end
    -- 隐藏界面--
    t.hide = function(self)
        -- 未show状态，不处理
        if not self.IsShow then
            return false
        end
        -- 模糊
        self:blur(false)

        -- 子ctrl隐藏
        for k, v in pairs(self.SubCtrl) do
            v:hide(self)
        end

        if not self.IsDestroyed then
            self.View:hide()
        end

        self.IsShow = false
        self.IsPreHandle = false
        self:hideOver()
        return true
    end
    -- 开始打开界面--
    t.openOver = function(self)
        self:onOpen(self.Data)
        -- 子ctrl打开
        for k, v in pairs(self.SubCtrl) do
            v:openOver()
        end
    end
    -- 结束关闭界面--
    t.closeOver = function(self)
        -- 子ctrl关闭
        for k, v in pairs(self.SubCtrl) do
            if not v.IsOpen then
                v:closeOver()
            end
        end
        self:onClose()
    end
    -- 结束显示界面--
    t.showOver = function(self)
        -- 子ctrl显示
        for k, v in pairs(self.SubCtrl) do
            v:showOver()
        end
        self:onShow()
    end
    -- 开始隐藏界面--
    t.hideOver = function(self)
        self:onHide()
        -- 子ctrl隐藏
        for k, v in pairs(self.SubCtrl) do
            if not v.IsShow then
                v:hideOver()
            end
        end
    end
    -- 通知界面是否可交互--
    t.interactive = function(self, isok)
        -- 没有交互性
        if not self.Interactive and isok then
            isok = self.Interactive
        end
        self.IsInteractive = isok
        -- 子ctrl交互
        for k, v in pairs(self.SubCtrl) do
            v:interactive(self, isok)
        end
        if not self.IsDestroyed then
            self.View:interactive(isok)
        end
        self:onInteractive(isok)
    end
    -- 通知界面是否可交互--
    t.interactiveBySelf = function(self, isok)
        self.Interactive = isok
        self:interactive(isok)
    end
    -- 是否模糊--
    t.blur = function(self, isBlur)
        if not self.PreCtrlBlur then
            return
        end
        if not self.IsDestroyed then
            blurEffect.Blur(isBlur, self, self.View.UI.sortingOrder - 1)
        end
    end
    -- 销毁界面--
    t.destroyBySelf = function(self, force)
        force = nil == force and false or force
        -- 未被销毁
        if not self.IsDestroyed then
            -- 置为销毁
            self.IsDestroyed = true
            -- 清除计时器
            self.TimerCd = TimerManager.disposeTimer(self.TimerCd)

            -- 在非强制条件下，才允许关闭自己（重要）
            -- 上层已将数据清空，不需再进行关闭
            if not force and self.IsOpen then
                self:close()
            end

            -- 子ctrl销毁
            for k, v in pairs(self.SubCtrl) do
                v:destroy(self, force)
            end
            -- 销毁
            if self.View ~= nil then
                self:onDestroy()
                self.View:destroy()
                self.View = nil
            end
        end

        self.IsPreHandle = false
        self.IsOpen = false
        self.IsShow = false
        self.Data = nil
        self.Params = nil

        -- 对所有的字段置空
        for k, v in pairs(self) do
            if type(v) == "userdata" then
                if v.Dispose ~= nil then
                    self[k]:Dispose()
                end

                self[k] = nil
            end
        end

        -- 移除模糊
        blurEffect.RemoveBlur(self.ControllerName)
        -- 移除ctrl
        facade:removeController(self)

        -- 弹框类型的不调用GC
        -- if t.Type ~= UIDefine.CtrlType.PopupBox and not force then
        --     Utils.LuaGC()
        --     Utils.SystemGC()
        -- end
    end
    -- 销毁界面--
    t.destroyByOther = function(self, force)
        -- 强制销毁
        if force then
            self:destroyBySelf(force)
            return
        end

        -- 判断已被销毁
        if self.IsDestroyed then
            return
        end
        -- 正在显示和不允许被销毁
        if self.IsCannotDestroy or self.IsShow then
            return
        end
        -- 置为销毁
        self.IsDestroyed = true
        -- 清除计时器
        self.TimerCd = TimerManager.disposeTimer(self.TimerCd)

        -- 子ctrl销毁
        for k, v in pairs(self.SubCtrl) do
            v:destroy(self, force)
        end
        -- 销毁
        if self.View ~= nil then
            self:onDestroy()
            self.View:destroy()
            self.View = nil
        end
    end
    -- 通知界面设置渲染顺序--
    t.sortingOrder = function(self, order)
        -- 如果拥有自己的渲染顺序,则使用自己的渲染值
        if nil ~= self.SortingOrder then
            order = self.SortingOrder
        end
        if not self.IsDestroyed then
            self.View:sortingOrder(order)
        end
        if self.IsShow then
            self:blur(true)
        end
    end
    -- 广播消息--
    t.ntfHandle = function(self, ntfType, ...)
        -- 子ctrl广播
        for k, v in pairs(self.SubCtrl) do
            v:ntfHandle(ntfType, ...)
        end
        self:onNtfHandle(ntfType, ...)
    end
    -- 更新--
    t.update = function(self)
        self:onUpdate()
    end
    -- 更新--
    t.fixedUpdate = function(self)
        self:onFixedUpdate()
    end
    -- 刷新--
    t.refresh = function(self)
        -- 子ctrl更新
        for k, v in pairs(self.SubCtrl) do
            v:refresh()
        end
        self:onRefresh()
    end
    -- 子ctrl--
    t.requireSubCtrl = function(self, name)
        if nil == name then
            return nil
        end

        local sub = nil
        for k, v in pairs(self.SubCtrl) do
            if v.ControllerName == name then
                sub = v
                break
            end
        end
        if nil == sub then
            sub = LuaHandle.load(name)
            table.insert(self.SubCtrl, sub)
        end
        return sub
    end
    --------当xx方法处理，子类重写----------
    t.onNtfHandle = function(self, ntfType, ...)
    end
    t.onPreHandle = function(self)
        return true
    end
    t.onCreat = function(self)
    end
    t.onOpen = function(self, data)
    end
    t.onClose = function(self)
    end
    t.onShow = function(self)
    end
    t.onInteractive = function(self, isOk)
    end
    t.onHide = function(self)
    end
    t.onUpdate = function(self)
    end
    t.onFixedUpdate = function(self)
    end
    t.onDestroy = function(self)
    end
    t.onRefresh = function(self)
    end

    if nil == isRegister or isRegister then
        facade:registerController(t)
    end
    return t
end

return Controller
