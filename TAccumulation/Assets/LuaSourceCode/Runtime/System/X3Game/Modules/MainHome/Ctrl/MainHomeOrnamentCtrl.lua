---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeOrnamentCtrl.lua
---Created By 教主
--- Created Time 11:43 2021/7/2

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHomeOrnamentCtrl:MainHomeBaseCtrl
local MainHomeOrnamentCtrl = class("MainHomeOrnamentCtrl", BaseCtrl)

function MainHomeOrnamentCtrl:ctor()
    BaseCtrl.ctor(self)
    ---@type GameObject
    self.gameObject = nil
    ---@type GameObject
    self.ornamentRoot = nil
    self.bgObj = nil
    self.checkObjList = PoolUtil.GetTable()
    self.ornamentData = PoolUtil.GetTable()
    for k, v in pairs(LuaCfgMgr.GetAll("MainUIOrnaments")) do
        if not self.ornamentData[v.ManLimit] then
            self.ornamentData[v.ManLimit] = PoolUtil.GetTable()
        end
        if not self.ornamentData[v.ManLimit][v.StateLimit] then
            self.ornamentData[v.ManLimit][v.StateLimit] = PoolUtil.GetTable()
        end
        table.insert(self.ornamentData[v.ManLimit][v.StateLimit], v)
    end
    LuaCfgMgr.UnLoad("MainUIOrnaments")
end

function MainHomeOrnamentCtrl:Enter()
    BaseCtrl.Enter(self)
    local obj = UIMgr.LoadDynamicUIPrefab(MainHomeConst.MAIN_HOME_OBJ)
    GameObjectUtil.SetActive(obj, true)
    self.gameObject = obj
    self.ornamentRoot = GameObjectUtil.GetComponent(obj, "OCY_Ornaments")
    self.bgObj = GameObjectUtil.GetComponent(obj, "BGPos")
    local t = PoolUtil.GetTable()
    table.insert(t, self.bgObj)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ADD_CHECK_OBJS, t)
    PoolUtil.ReleaseTable(t)
    self:SetOrnamentsActive(false, true)
    SceneMgr.AddSceneObj(obj)
    self:RefreshOrnaments()
    self:RegisterEvent()
end

function MainHomeOrnamentCtrl:Exit()
    PoolUtil.ReleaseTable(self.checkObjList)
    GameObjectUtil.Destroy(self.gameObject)
    self.checkObjList = nil
    self.bgObj = nil
    self:UnRegisterEvent()
    BaseCtrl.Exit(self)
end

function MainHomeOrnamentCtrl:GetShowList()
    local main_state_data = self.bll:GetData()
    local man_limit = main_state_data:GetRoleId()
    local state_limit = main_state_data:GetStateId()
    local show_list = PoolUtil.GetTable()
    for man_type, v in pairs(self.ornamentData) do
        if man_type == -1 or man_type == man_limit then
            --不限男主
            for state_type, v2 in pairs(v) do
                if state_type == -1 or state_type == state_limit then
                    table.insertto(show_list, v2)
                end
            end
        end
    end
    return show_list
end

function MainHomeOrnamentCtrl:CheckOrnament(ornament)

    local res = false
    local state_data = self.bll:GetData()
    if ornament.Type == MainHomeConst.OrnamentType.GIFT then
        -- 礼盒
        res = state_data:GetAfkBoxNum() >= ornament.Para[1]
    elseif ornament.Type == MainHomeConst.OrnamentType.LOVETOKEN then
        -- 信物
        local tokens = state_data:GetAfkTokenIds()
        if tokens then
            for _, v in ipairs(tokens) do
                if v == ornament.Para[1] then
                    res = true
                    break
                end
            end
        end
    elseif ornament.Type == MainHomeConst.OrnamentType.COMMON_CONDITION then
        -- commonCondition
        res = ConditionCheckUtil.CheckConditionByCommonConditionGroupId(ornament.Para[1], nil)
    end
    if not res then
        return false
    end

    local obj = GameObjectUtil.GetComponent(self.ornamentRoot, ornament.Name)
    if not obj then
        return
    end
    GameObjectUtil.SetPosition(obj, ornament.Pos)
    GameObjectUtil.SetEulerAngles(obj, ornament.Rot)
    GameObjectUtil.SetActive(obj, true)
    return res, obj
end

function MainHomeOrnamentCtrl:RefreshOrnaments()
    local main_state_data = self.bll:GetData()
    if 0 == main_state_data:GetActorId() then
        self:SetOrnamentsActive(false)
        return
    end
    local show_list = self:GetShowList()
    PoolUtil.ReleaseTable(self.checkObjList)
    self.checkObjList = PoolUtil.GetTable()
    if #show_list > 0 then
        self:SetOrnamentsActive(false, true)
        for _, v in pairs(show_list) do
            local res, obj = self:CheckOrnament(v)
            if res then
                obj = GameObjectUtil.GetComponent(obj, "Pos") or obj
                self.checkObjList[obj] = v
            end
        end
        self:SetOrnamentsActive(true)
    else
        self:SetOrnamentsActive(false)
    end
    PoolUtil.ReleaseTable(show_list)
    self:CheckObjs()
end

function MainHomeOrnamentCtrl:CheckObjs()
    if not table.isnilorempty(self.checkObjList) then
        local objs = PoolUtil.GetTable()
        for k, v in pairs(self.checkObjList) do
            table.insert(objs, k)
        end
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_ADD_CHECK_OBJS, objs)
        PoolUtil.ReleaseTable(objs)
    end
end

function MainHomeOrnamentCtrl:OnClickObj(obj)
    if not self.checkObjList then
        return
    end
    local conf = self.checkObjList[obj]
    if conf then
        if conf.Type == MainHomeConst.OrnamentType.GIFT then
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST, MainHomeConst.NetworkType.GET_BOX_REWARD)
        elseif conf.Type == MainHomeConst.OrnamentType.LOVETOKEN then
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_SEND_REQUEST, MainHomeConst.NetworkType.GET_BOX_LOVE_TOKEN, conf.Para[1])
        end
    end
end

function MainHomeOrnamentCtrl:OnLongPressObj(obj)

end

function MainHomeOrnamentCtrl:SetOrnamentsActive(is_active, is_all)
    GameObjectUtil.SetActive(self.ornamentRoot, is_active, is_all)
end

function MainHomeOrnamentCtrl:OnSceneChanged()
    GameObjectUtil.SetActive(self.gameObject, true)
    SceneMgr.AddSceneObj(self.gameObject)
end

function MainHomeOrnamentCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_REFRESH_ORNAMENTS, self.RefreshOrnaments, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_CLICK_OBJ, self.OnClickObj, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ON_LONG_PRESS_OBJ, self.OnLongPressObj, self)
    EventMgr.AddListener(Const.Event.SCENE_LOADED, self.OnSceneChanged, self)
end

return MainHomeOrnamentCtrl