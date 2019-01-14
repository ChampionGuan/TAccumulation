-----------------------------------------------------
-------------------定义View--------------------------
-----------------------------------------------------

local View = {}

-- 创建
View.Creat = function()
    local t = {}
    t.UI = nil
    t.PkgPath = nil
    t.PkgName = nil
    t.ComName = nil

    -- 未释放的FairyGUI.EventListerner的delegate，用法见UIUtils:AddUIEventCallback
    t.UnregisterDelegates = nil

    -- 存放Controller层的回调函数的表格
    t.CallbackList = nil

    -- 添加UI对象EventListener回调
    t.AddUIEventCallback = function(self, _eventListener, _callback)
        if _eventListener == nil or _callback == nil then
            return
        end

        _eventListener:Add(_callback)

        -- 初始化表格
        if self.UnregisterDelegates == nil then
            self.UnregisterDelegates = {}
        end

        -- 将移除回调的方法自动加入_view.UnregisterDelegates
        table.insert(self.UnregisterDelegates, 
            -- 移除回调
            function()
                _eventListener:Remove(_callback)
            end)
    end

    -- 添加UI对象EventListener回调
    t.SetUIEventCallback = function(self, _eventListener, _callback)
        if _eventListener == nil or _callback == nil then
            return
        end

        _eventListener:Set(_callback)

        -- 初始化表格
        if self.UnregisterDelegates == nil then
            self.UnregisterDelegates = {}
        end

        -- 将移除回调的方法自动加入_view.UnregisterDelegates
        table.insert(self.UnregisterDelegates, 
            -- 移除回调
            function()
                _eventListener:Remove(_callback)
            end)
    end

    -- 移除UI对象EventListener回调。view销毁时自动调用，不需要手动调用
    t.RemoveUIEventCallback = function(self)
        if nil ~= self.UnregisterDelegates then
            for k,v in pairs(self.UnregisterDelegates) do
                if v ~= nil then
                    v()
                end
            end

            self.UnregisterDelegates = nil
        end
    end

    -- 注册Controller层的回调方法
    t.InitCallback = function(self, _key, _callback)
        if type(_key) ~= "string" or type(_callback) ~= "function" then
            return
        end

        if self.CallbackList == nil then
            self.CallbackList = {}
        end

        self.CallbackList[_key] = _callback
    end

    -- 调用回调事件
    t.InvokeCallback = function(self, _key, ...)
        if type(_key) ~= "string" then
            return
        end

        if type(self.CallbackList) == "table" and type(self.CallbackList[_key]) == "function" then
            self.CallbackList[_key](...)
        end
    end

    t.LoadView = function(self)
    end

    t.interactive = function(self, isok)
        self.UI.touchable = isok
    end

    t.sortingOrder = function(self, order)
        self.UI.sortingOrder = order
    end

    t.show = function(self)
        self.UI.visible = true
    end

    t.hide = function(self)
        self.UI.visible = false
    end

    t.onDestroy = function(self)
    end

    t.destroy = function(self)
        -- 先调view自己的销毁
        self:onDestroy()

        self.CallbackList = nil

        -- 干掉所有未释放的delegate
        self:RemoveUIEventCallback()

        if nil ~= self.PkgPath and nil ~= self.PkgName then
            -- 释放view
            UIUtils.disposeView(self.PkgPath, self.PkgName, self.UI)
        end

        -- 对所有的字段置空
        for k, v in pairs(self) do
            local theType = type(v)
            if theType == "userdata" then
                if v.Dispose ~= nil then
                    self[k]:Dispose()
                end
                self[k] = nil
            elseif theType == "table" then
                self[k] = nil
            end
        end
    end

    -- 是否已析构
    t.isDispose = function(self)
        if nil == self.UI or nil == self.UI.displayObject or self.UI.displayObject.isDisposed then
            return true
        else
            return false
        end
    end

    return t
end

return View
