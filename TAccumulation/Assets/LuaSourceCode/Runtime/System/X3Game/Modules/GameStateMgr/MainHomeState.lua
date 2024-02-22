---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 15:29:44
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MainHomeState
local MainHomeState = class("MainHomeState", require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState"))
local MainHomeCtrl = require("Runtime.System.X3Game.Modules.MainHome.MainHomeCtrl")
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local batch_id
local isLoading = true
function MainHomeState:ctor()
    self.Name = "MainHomeState"
end

local function unload_res()
    if not batch_id then
        return
    end
    ResBatchLoader.UnloadAsync(batch_id)
end

local function get_loading_type()
    return BllMgr.GetMainHomeBLL():GetLoadingType()
end

---@return float,float 比重，起始比例
local function get_progress_weight()
    return BllMgr.GetMainHomeBLL():GetWeightAndProgress()
end

local function pre_load_res(finish_call)
    local res = MainHomeCtrl:GetPreLoadRes()
    for k, v in pairs(res) do
        ResBatchLoader.AddTask(v.res, v.res_type)
        PoolUtil.ReleaseTable(v)
    end
    PoolUtil.ReleaseTable(res)
    ResBatchLoader.AddSceneTask(MainHomeCtrl:GetSceneName())
    batch_id = ResBatchLoader.LoadAsync(isLoading and get_loading_type() or GameConst.LoadingType.None,
            false, finish_call, nil, get_progress_weight())
    BllMgr.GetMainHomeBLL():SetWeightAndProgress(1,0)
    BllMgr.GetMainHomeBLL():SetLoadingType(GameConst.LoadingType.MainHome)
end

local function toMainHome(prevStateName, isClearUI)
    pre_load_res(function()
        ---兜底：回主城时把Global LOD设为HD。
        if prevStateName == "Battle" then
            CharacterMgr.SetGlobalLOD(0)
        end
        Debug.Log("进入主界面loading结束回调")
        
        UIMgr.SetCanRestoreHistory(true)
        local isEnter = true
        if ((not UIMgr.IsInHistory(UIConf.MainHomeWnd)) and (not UIMgr.IsOpened(UIConf.MainHomeWnd))) then
            isEnter = false
            UIMgr.Open(UIConf.MainHomeWnd,function()
                MainHomeCtrl:Enter()
            end)

            local watermark = PlayerPrefs.GetInt("ServerWaterMark", 0)
            if watermark ~= 0 then
                UIMgr.Open("MarkWnd", false)
            end
        else
            UIMgr.RestoreHistory()
        end

        if isLoading then
            UIMgr.Hide(UIConf.MainHomeWnd)
        end
        
        if isClearUI then
            UIMgr.BackToHome()
        end
        if isEnter then
            MainHomeCtrl:Enter()
        end

        ---恢复历史UI历史堆栈
        UIMgr.RecoverViewSnapShot()
        
        --是否战斗失败 点击再试一次 重新开始战斗
        ChapterStageManager.IsOpenChapterWnd()
        SelfProxyFactory.GetLegendProxy():IsRecoverWnd()
        
        if CS.X3Game.GameMgr.LanguageChangeType ~= GameConst.LanguageChangeType.None then
            BllMgr.GetSystemSettingBLL():TurnToLanguageSettingPage(false, CS.X3Game.GameMgr.LanguageChangeType == GameConst.LanguageChangeType.Voice)---走到这里说明是切换语音/语言了，需要贴脸弹设置
            ---打开设置语音界面，
            if SubPackageDownloadMgr.IsValid() then
                DownloadMgr:ReadDownloadData(false)
            end
        end
    end)
end

function MainHomeState:OnEnter(prevStateName, is_clear_ui, is_Loading)
    if is_Loading == nil then
        is_Loading = true
    end
    if BllMgr.GetHeadIconBLL():IsShowLoading() then
        BllMgr.GetMainHomeBLL():SetLoadingType(GameConst.LoadingType.FaceEditHeadIcon)
        BllMgr.GetMainHomeBLL():SetWeightAndProgress(BllMgr.GetHeadIconBLL():GetLoadingWeightAndProgress())
        BllMgr.GetHeadIconBLL():EndLoading()
    end
    isLoading = is_Loading
    self.prevStateName = prevStateName
    self.is_clear_ui = is_clear_ui
    --进入MainHome清除黑白屏
    UICommonUtil.ScreenTransitionClear(true)
    UICommonUtil.SetCaptureEnable(false)
    --进入主界面时清理一次待机的预加载节点
    PreloadBatchMgr.UnloadHoldonNodes()
    if isLoading and not BllMgr.GetHeadIconBLL():IsShowLoading() then
        --暂时不接入战斗、拍照的loading渐入和渐出功能
        --if prevStateName == GameState.Photo then
        --    UICommonUtil.SetLoadingEnable(get_loading_type(), true);
        --    self:OnLoadingMoveInComplete(prevStateName, is_clear_ui)
        --else
        UICommonUtil.SetLoadingEnableWithOpenParam({
            MoveInCallBack = function()
                self:OnLoadingMoveInComplete(prevStateName, is_clear_ui)
            end,
            IsPlayMoveOut = true,
            MoveOutCallBack = function()
                EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_LOADING_MOVEOUT_FINISH)
            end
        }, get_loading_type(), true)
        --end
    else
        self:OnLoadingMoveInComplete(prevStateName, is_clear_ui)
    end
end

function MainHomeState:OnLoadingMoveInComplete(prevStateName, is_clear_ui)
    UIMgr.SetPortraitMode(function()
        ---需要刷新
        if BllMgr.GetMainHomeBLL():IsNeedReqMainUIDailyRefresh() then
            EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SERVER_MAIN_UI_UPDATE_REPLY, self.OnMainUIUpdateReply, self)
            BllMgr.GetMainHomeBLL():Req_MainUIDailyRefresh()
        else
            toMainHome(prevStateName, is_clear_ui)
        end
    end)
end

function MainHomeState:OnMainUIUpdateReply()
    EventMgr.RemoveListener(MainHomeConst.Event.MAIN_HOME_SERVER_MAIN_UI_UPDATE_REPLY, self.OnMainUIUpdateReply, self)
    toMainHome(self.prevStateName, self.is_clear_ui)
end

function MainHomeState:OnExit(nextStateName)
    MainHomeCtrl:Exit()
    unload_res()
    CharacterMgr.ReleaseAllIns()
    --if nextStateName == GameState.Battle or nextStateName == GameState.MainStory then
    --    UIMgr.Close(UIConf.MainHomeWnd, false)
    --end
end

return MainHomeState