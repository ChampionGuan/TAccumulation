---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-09-08 15:53:31
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@private
local CLS = CS.X3Game.MusicPlayerMgr
---@class GameSoundMgr
local GameSoundMgr = {}
local AutoMode = true ---场景背景音乐模式（true:跟着场景ui打开自动播放，false:需要手动播放）
---默认背景音乐ViewTag（第一次打开的）
local _defaultBgSoundTag = nil
---前一个背景音乐ViewTag
local _prevBgSoundTag = nil
---当前背景音乐ViewTag
local _curBgSoundTag = ''
---特殊界面 真实的viewTag发生改变但没有切换UI发的事件
GameSoundMgr.CONST_VIEW_TAG_CHANGE = "ViewTagChange"
GameSoundMgr.EVENT_MUSIC_COMPLETE = "EVENT_MUSIC_COMPLETE"
---设置video是否静音
GameSoundMgr.EVENT_VIDEO_MUTE_CHANGE = "GameSoundMgr.EVENT_VIDEO_MUTE_CHANGE"
local bgmExitEventNameList = { "BGM_Playlist" }
---动态bgm播放的历史DynamicTag
local historyViewTagByDynamicTag = {}
---@type MusicContext
local musicHandler = {}
---@private
---@type X3Game.MusicPlayerMgr
local _ins = nil
---@private
---Get MusicPlayerMgr.Instance
local function getIns()
    if not _ins then
        _ins = CLS.Instance
    end
    return _ins
end
---@class MusicContext
---@field eventName string eventName
---@field stateName string  stateName
---@field stateGroupName string stateGroupName

---@return MusicContext
---@param stateName string  State名
local function GetSoundInfoWithStateName(stateName)
    if stateName == nil or stateName == '' then
        return nil
    end
    local cfgList = LuaCfgMgr.GetAll('MusicFunctionBGMStateConnect')
    local cfg = nil
    for k, v in pairs(cfgList) do
        if v['StateName'] == stateName then
            cfg = v
            break
        end
    end
    if cfg == nil then
        Debug.LogError("MusicFunctionBGMStateConnect is nil stateName: ", stateName)
        return nil
    end
    musicHandler.stateName = cfg['StateName']
    musicHandler.eventName = cfg['EventName']
    musicHandler.stateGroupName = cfg['StateGroupName']
    return musicHandler
end

---@return MusicContext
---@param uIControlCfg cfg.MusicFunctionUiView 配置表数据
local function GetSoundInfoWithUIControlCfg(uIControlCfg)
    local musicFunctionBGMControlCfg = LuaCfgMgr.Get("MusicFunctionBGMControl", uIControlCfg.FunctionID)
    if musicFunctionBGMControlCfg == nil then
        return nil
    end
    return GetSoundInfoWithStateName(musicFunctionBGMControlCfg['BGMEventName'])
end

---@return MusicContext
---@param viewTag string  ui的viewTag名字
local function GetSoundInfoWithViewTag(viewTag)
    viewTag = viewTag or ''
    local cfg = LuaCfgMgr.Get('MusicFunctionUiView', viewTag)
    if cfg == nil then
        cfg = LuaCfgMgr.Get('MusicFunctionDynamicTag', viewTag)
    end
    local realCfg = cfg
    if realCfg == nil then
        return nil
    end
    if realCfg.SystemCheckType and realCfg.SystemCheckType ~= 0 then
        return nil
    end
    if realCfg.MainUIBGM == 1 then
        local curBGMStateName = BllMgr.GetBGMBLL():GetCurBGMStateName()
        if curBGMStateName ~= nil then
            return GetSoundInfoWithStateName(curBGMStateName), viewTag
        else
            return GetSoundInfoWithUIControlCfg(realCfg), viewTag
        end
    else
        return GetSoundInfoWithUIControlCfg(realCfg), viewTag
    end
end

---获取真实需要播放的viewTag 从最上层往下找
---@return  string viewTag
local function GetCurSoundViewTag()
    local viewTagList = UIMgr.GetViewTagList(true)
    local retViewTag = nil
    for i = 0, viewTagList.Count - 1 do
        local viewTag = viewTagList[i]
        local uiControlCfg = LuaCfgMgr.Get('MusicFunctionUiView', viewTag)
        if uiControlCfg then
            if uiControlCfg.SPFunction == 1 then
                return nil
            end
            if uiControlCfg.MainUIBGM == 1 then
                retViewTag = viewTag
                break
            end
            if uiControlCfg.FunctionID ~= 0 then
                local musicFunctionBGMControlCfg = LuaCfgMgr.Get("MusicFunctionBGMControl", uiControlCfg.FunctionID)
                if musicFunctionBGMControlCfg ~= nil then
                    retViewTag = viewTag
                    break
                end
            end
        end
    end
    if historyViewTagByDynamicTag[retViewTag] ~= nil then
        retViewTag = historyViewTagByDynamicTag[retViewTag]
    end
    return retViewTag
end

---根据stateName播放音乐
---@param eventName string
---@param stateName string
---@param stateGroup string
---@param isReset boolean
local function ExePlaySoundWithStateName(eventName, stateName, stateGroup, isReset)
    if isReset == nil then
        isReset = false
    end
    getIns():Play(eventName, stateName, stateGroup, isReset)
end

---TopUI发生改变
local function OnTopUIChange(viewTag)
    if not AutoMode then
        return
    end
    if string.isnilorempty(viewTag) then
        viewTag = GetCurSoundViewTag()
    end
    local musicHandler, tempViewTag = GetSoundInfoWithViewTag(viewTag)
    viewTag = tempViewTag
    if musicHandler then
        if _defaultBgSoundTag == nil then
            _defaultBgSoundTag = viewTag
        end
        if _curBgSoundTag ~= viewTag then
            _prevBgSoundTag = _curBgSoundTag
            _curBgSoundTag = viewTag
        end
        ExePlaySoundWithStateName(musicHandler.eventName, musicHandler.stateName, musicHandler.stateGroupName)
    end
end

local function OnUIViewClose(data)
    if historyViewTagByDynamicTag[data.ViewTag] then
        historyViewTagByDynamicTag[data.ViewTag] = nil
    end
end

--系统 页签发生改变
local function OnViewTagChange()
    OnTopUIChange()
end

---设置需要检查的EventName
---@param eventName string eventNameM
local function AddExitEventNameList(eventName)
    getIns():AddExitEventNameList(eventName)
end

---Clear需要檢查的EventName
local function ClearExitEventNameList()
    getIns():ClearExitEventNameList()
end

---Clear播放列表
local function ClearMusicList()
    getIns():ClearMusicList()
end

---设置播放列表中的数据
---@param eventName string eventName
---@param stateName string stateName
local function AddPlayMusicData(eventName, stateName, stateGroupName)
    getIns():AddPlayMusicData(eventName, stateName, stateGroupName)
end

---初始化
GameSoundMgr.Init = function()
    GameSoundMgr.InitExitEventNameList()
    BllMgr.GetBGMBLL()
    EventMgr.AddListener(Const.Event.GLOBAL_UIVIEW_ON_UIHierarchy_Changed, OnTopUIChange)
    EventMgr.AddListener(GameSoundMgr.CONST_VIEW_TAG_CHANGE, OnViewTagChange)
    EventMgr.AddListener(Const.Event.GLOBAL_UIVIEW_ON_CLOSE, OnUIViewClose)
end

---销毁
GameSoundMgr.Clear = function()
    EventMgr.RemoveListener(Const.Event.GLOBAL_UIVIEW_ON_UIHierarchy_Changed, OnTopUIChange)
    EventMgr.RemoveListener(GameSoundMgr.CONST_VIEW_TAG_CHANGE, OnViewTagChange)
    EventMgr.RemoveListener(Const.Event.GLOBAL_UIVIEW_ON_CLOSE, OnUIViewClose)
end

---销毁
GameSoundMgr.Destroy = function()
    EventMgr.RemoveListener(Const.Event.GLOBAL_UIVIEW_ON_UIHierarchy_Changed, OnTopUIChange)
    EventMgr.RemoveListener(GameSoundMgr.CONST_VIEW_TAG_CHANGE, OnViewTagChange)
    EventMgr.RemoveListener(Const.Event.GLOBAL_UIVIEW_ON_CLOSE, OnUIViewClose)
end

---设置背景音乐模式
---@param is_auto boolean (true:跟着场景ui打开自动播放,fale:需要手动播放)
GameSoundMgr.SetAutoMode = function(is_auto)
    AutoMode = is_auto
end

---设置声音句柄
GameSoundMgr.GetSoundInfoWithStateName = GetSoundInfoWithStateName

--region 外部调用播放停止音效相关接口
---播放音效
---@param eventName string
---@param onComplete fun(eventName:string):void
---@param onProgress fun(eventName:string, p:float):void
---@return uint playingID
GameSoundMgr.PlaySound = function(eventName, onComplete, onProgress)
    local bankName = WwiseMgr.GetBankNameWithEventName(eventName)
    if string.isnilorempty(bankName) then
        Debug.LogWarning("GameSoundMgr.PlaySound bnkName is nil eventName", eventName)
        return
    end
    WwiseMgr.LoadBank(bankName)
    return WwiseMgr.PlaySound2D(eventName, onComplete, onProgress)
end

---播放3d音效
---@param eventName string
---@param gameobject GameObject
---@param onComplete fun(eventName:string, playingID:int):void
---@return uint playingID
GameSoundMgr.PlaySound3DFx = function(eventName, gameobject, onComplete)
    local bankName = WwiseMgr.GetBankNameWithEventName(eventName)
    if string.isnilorempty(bankName) then
        Debug.LogWarning("GameSoundMgr.PlaySound3DFx bnkName is nil eventName", eventName)
        return
    end
    WwiseMgr.LoadBank(bankName)
    return WwiseMgr.PlaySound3D(eventName, gameobject, onComplete)
end

---播放背景音
---@param stateName string
---@return MusicContext 返回MusicContext
GameSoundMgr.PlayMusic = function(stateName, isLoop)
    if isLoop == nil then
        isLoop = true
    end
    if stateName == nil then
        ExePlaySoundWithStateName(nil,
                nil, nil, not isLoop)
        return
    end
    local MusicHandler = GetSoundInfoWithStateName(stateName)
    if MusicHandler then
        ExePlaySoundWithStateName(MusicHandler.eventName,
                MusicHandler.stateName, MusicHandler.stateGroupName, not isLoop)
    end
    return MusicHandler
end

---停止背景音
GameSoundMgr.StopMusic = function()
    getIns():Stop()
end

---立即终止音效，没有延迟
GameSoundMgr.StopSound = function(sound)
    if not sound then
        local curPlayEventName = GameSoundMgr.GetCurMusicEventName()
        if curPlayEventName then
            WwiseMgr.StopSound2D(curPlayEventName)
            GameSoundMgr.StopMusic()
        end
    else
        WwiseMgr.StopSound2D(sound)
    end
end

---立即终止音效，没有延迟
GameSoundMgr.StopSound3D = function(sound, gameObject)
    WwiseMgr.StopSound3D(sound, gameObject)
end

---外部调用播放BGM,定制化的UI需求
---@param viewTag string
GameSoundMgr.PlayUIBGM = function(viewTag, param)
    local realViewTag = GameSoundMgr.GetViewTagByParam(viewTag, param)
    historyViewTagByDynamicTag[viewTag] = realViewTag
    if realViewTag then
        OnTopUIChange(realViewTag, true)
    end
end

--endregion
---获取需要播放的UIBGM的ViewTag
function GameSoundMgr.GetViewTagByParam(viewTag, param)
    local realViewTag
    if viewTag == UIConf.MainLineChapterWnd then
        if param then
            local chapterInfoCfg = LuaCfgMgr.Get("ChapterInfo", param)
            local tag = chapterInfoCfg.BGMTag
            if tag then
                realViewTag = tag
            else
                Debug.LogError("获取主线BGM的tag失败, 请检查配置")
            end
        end
    elseif viewTag == UIConf.CollectionRoomWnd then
        local curRole = param
        local roleCfg = LuaCfgMgr.Get("RoleInfo", curRole)
        if roleCfg then
            realViewTag = roleCfg.CollectionRoomWndBGM
        end
    elseif viewTag == UIConf.RadioListWnd then
        if param ~= 0 then
            local roleInfo = LuaCfgMgr.Get("RoleInfo", param)
            local _radioBGMTag = roleInfo and roleInfo.RadioBGMTag or ""
            realViewTag = _radioBGMTag
        end
    elseif viewTag == UIConf.SpecialDateChooseDateWnd then
        local roleInfo = LuaCfgMgr.Get("RoleInfo", param)
        if roleInfo then
            realViewTag = roleInfo.SpecialDateWndBGM
        end
    elseif viewTag == UIConf.GachaMainWnd then
        if param then
            local GroupInfo = LuaCfgMgr.Get("GachaGroup", param)
            if GroupInfo ~= nil and not string.isnilorempty(GroupInfo.Music) then
                realViewTag = GroupInfo.Music
            end
        end
    elseif viewTag == UIConf.ASMRWnd then
        if param ~= 0 then
            local roleInfo = LuaCfgMgr.GetAll("RoleInfo")
            realViewTag = roleInfo[param].ASMRBGMTag
        end
    elseif viewTag == UIConf.StoryEntranceWnd then
        if param ~= 0 then
            local roleInfo = LuaCfgMgr.GetAll("RoleInfo")
            realViewTag = roleInfo[param].BesideYouBGMTag
        end
    elseif viewTag == UIConf.LovepointTaskWnd then
        if param ~= 0 then
            local roleInfo = LuaCfgMgr.GetAll("RoleInfo")
            realViewTag = roleInfo[param].LovepointTaskWndBGM
        end
    elseif viewTag == UIConf.ActivityMainWnd then
        realViewTag = param
    elseif viewTag == UIConf.AnecdoteWnd then
        if param ~= 0 then
            local roleInfo = LuaCfgMgr.Get("RoleInfo", param)
            realViewTag = roleInfo and roleInfo.AnecdoteWndBGM
        end
    elseif viewTag == UIConf.AnecdoteReaderWnd then
        realViewTag = param
    elseif viewTag == UIConf.ScoreStoryChapterWnd then
        realViewTag = param
    end
    return realViewTag
end

---获取当前背景音乐的EventName
function GameSoundMgr.GetCurMusicEventName()
    return getIns().CurPlayEventName
end
---获取当前背景音乐的EventName
function GameSoundMgr.GetCurPlayStateName()
    return getIns().CurPlayStateName
end

---初始化需要检查Exit事件的EventName
function GameSoundMgr.InitExitEventNameList()
    ClearExitEventNameList()
    for i = 1, #bgmExitEventNameList do
        local eventName = bgmExitEventNameList[i]
        AddExitEventNameList(eventName)
    end
end

---设置播放列表
---@param stateNameList table<string> stateNameList
function GameSoundMgr.AddMusicListData(stateNameList)
    ClearMusicList()
    for i = 1, #stateNameList do
        local stateName = stateNameList[i]
        local musicData = GetSoundInfoWithStateName(stateName)
        AddPlayMusicData(musicData.eventName, musicData.stateName, musicData.stateGroupName)
    end
end

---设置播放模式
---@param playMode
function GameSoundMgr.SetPlayMode(playMode)
    getIns():SetPlayMode(playMode)
end

return GameSoundMgr