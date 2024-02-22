--- X3@PapeGames
--- WwiseMgr
--- Created by Tungway
--- Created Date: 2020/7/13
---@class WwiseMgr
local WwiseMgr = {}
local MusicPauseCount = 0

---@class AKRESULT
AKRESULT = {
    AK_NotImplemented = 0,
    AK_Success = 1,
    AK_Fail = 2,
    AK_PartialSuccess = 3,
    AK_NotCompatible = 4,
    AK_AlreadyConnected = 5,
    AK_InvalidFile = 7,
    AK_AudioFileHeaderTooLarge = 8,
    AK_MaxReached = 9,
    AK_InvalidID = 14,
    AK_IDNotFound = 15,
    AK_InvalidInstanceID = 16,
    AK_NoMoreData = 17,
    AK_InvalidStateGroup = 20,
    AK_ChildAlreadyHasAParent = 21,
    AK_InvalidLanguage = 22,
    AK_CannotAddItseflAsAChild = 23,
    AK_InvalidParameter = 31,
    AK_ElementAlreadyInList = 35,
    AK_PathNotFound = 36,
    AK_PathNoVertices = 37,
    AK_PathNotRunning = 38,
    AK_PathNotPaused = 39,
    AK_PathNodeAlreadyInList = 40,
    AK_PathNodeNotInList = 41,
    AK_DataNeeded = 43,
    AK_NoDataNeeded = 44,
    AK_DataReady = 45,
    AK_NoDataReady = 46,
    AK_InsufficientMemory = 52,
    AK_Cancelled = 53,
    AK_UnknownBankID = 54,
    AK_BankReadError = 56,
    AK_InvalidSwitchType = 57,
    AK_FormatNotReady = 63,
    AK_WrongBankVersion = 64,
    AK_FileNotFound = 66,
    AK_DeviceNotReady = 67,
    AK_BankAlreadyLoaded = 69,
    AK_RenderedFX = 71,
    AK_ProcessNeeded = 72,
    AK_ProcessDone = 73,
    AK_MemManagerNotInitialized = 74,
    AK_StreamMgrNotInitialized = 75,
    AK_SSEInstructionsNotSupported = 76,
    AK_Busy = 77,
    AK_UnsupportedChannelConfig = 78,
    AK_PluginMediaNotAvailable = 79,
    AK_MustBeVirtualized = 80,
    AK_CommandTooLarge = 81,
    AK_RejectedByFilter = 82,
    AK_InvalidCustomPlatformName = 83,
    AK_DLLCannotLoad = 84,
    AK_DLLPathNotFound = 85,
    AK_NoJavaVM = 86,
    AK_OpenSLError = 87,
    AK_PluginNotRegistered = 88,
    AK_DataAlignmentError = 89,
    AK_DeviceNotCompatible = 90,
    AK_DuplicateUniqueID = 91,
    AK_InitBankNotLoaded = 92,
    AK_DeviceNotFound = 93,
    AK_PlayingIDNotFound = 94,
    AK_InvalidFloatValue = 95,
    AK_FileFormatMismatch = 96,
    AK_NoDistinctListener = 97,
    AK_ACP_Error = 98,
    AK_ResourceInUse = 99
}

---@private
local CLS = CS.PapeGames.X3.WwiseManager
---Wwise平台帮主类
local CS_PFWWISEUTILITY = CS.X3Game.Platform.PFWwiseUtility
---是否是首次初始化
local isFirsInit = true
---@private
---@type PapeGames.X3.WwiseManager
local _ins = nil

---@private
---@type table<fun(data:AkMarkerCallbackInfo)>
local markerCallMap = {}

---@private
---Get WwiseMgr.Instance
local function getIns()
    if not _ins then
        _ins = CLS.Instance
    end
    return _ins
end

local function toLuaAkResult(csAkResult)
    if not csAkResult then
        return AKRESULT.AK_NotImplemented
    end
    local ret = csAkResult:GetHashCode()
    return ret
end

local EVENT_STOP_MUSIC = "stop_music";
local EVENT_STOP_SOUND = "stop_sound";
local EVENT_STOP_VOICE = "stop_voice";
local EVENT_STOP_DRAMA = "stop_audiodrama";
local EVENT_PAUSE_MUSIC = "pause_music";
local EVENT_RESUME_MUSIC = "resume_music";
local EVENT_PAUSE_VOSFX = "pause_vo_sfx";
local EVENT_RESUME_VOSFX = "resume_vo_sfx";
local EVENT_PAUSE_DRAMA = "pause_audiodrama";
local EVENT_RESUME_DRAMA = "resume_audiodrama";
local EVENT_PAUSE_PLOT = "pause_plot_sound";
local EVENT_RESUME_PLOT = "resume_plot_sound";
local EVENT_CLOSE_PLAYER_VOICE = "close_PlayerVoice";
local EVENT_OPEN_PLAYER_VOICE = "reset_PlayerVoice";
local EVENT_PAUSE_PLOT_VO = "pause_plot_vo"
local EVENT_RESUME_PLOT_VO = "resume_plot_vo"
local EVENT_STOP_LOOP = "stop_loop"
local EVENT_RESUME_LOOP = "resume_loop"
local EVENT_PAUSE_LOOP = "pause_loop"
local EVENT_STOP_AUDIO = "stop_audio"
---设置语言
---@param language string
---@return int
function WwiseMgr.SetLanguage(language)
    return getIns():SetLanguage(language)
end

--region Runtime.Common Play / Stop
---播放2D音效
---@param eventNameOrID string|uint
---@param onComplete fun(eventName:string, playingID:int):void
---@param onProgress fun(eventName:string, p:float):void
---@return uint playingID
function WwiseMgr.PlaySound2D(eventNameOrID, onComplete, onProgress)
    return getIns():PlaySound(eventNameOrID, nil, onComplete, onProgress)
end

---播放背景音乐
---@param eventName string
---@param onComplete fun(eventName:string, playingID:int):void
---@param onProgress fun(eventName:string, p:float):void
---@return uint playingID
function WwiseMgr.PlayMusic(eventName, onComplete, onProgress)
    return getIns():PlayMusic(eventName, onComplete, onProgress)
end

---获取当前正在播放的背景音乐
---@return string 当前正在播放的背景音
function WwiseMgr.GetPlayingMusic()
    return getIns().PlayingMusic
end

---播放3D音效
---@param eventNameOrID string|uint
---@param gameObj GameObject
---@param onComplete fun(eventName:string, playingID:int):void
---@param onProgress fun(eventName:string, p:float):void
---@return uint
function WwiseMgr.PlaySound3D(eventNameOrID, gameObj, onComplete, onProgress)
    return getIns():PlaySound(eventNameOrID, gameObj, onComplete, onProgress)
end

---停止2D音效
---@param eventNameOrID string|uint
---@param transitionDuration int
---@return AKRESULT
function WwiseMgr.StopSound2D(eventNameOrID, transitionDuration)
    if transitionDuration == nil then
        transitionDuration = 0
    end
    local ret = getIns():StopSound(eventNameOrID, nil, transitionDuration)
    ret = toLuaAkResult(ret)
    return ret
end

---通过playingId停止2D音效
---@param playingId uint
---@param transitionDurat int
---@return AKRESULT
function WwiseMgr.StopSoundByPlayingId(playingId, transitionDuration)
    if transitionDuration == nil then
        transitionDuration = 0
    end
    local ret = getIns():StopSoundByPlayingId(playingId, transitionDuration)
    ret = toLuaAkResult(ret)
    return ret
end

---停止3D音效
---@param eventNameOrID string|uint
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.StopSound3D(eventNameOrID, gameObj)
    local ret = getIns():StopSound(eventNameOrID, gameObj)
    ret = toLuaAkResult(ret)
    return ret
end

---暂停2D音效
---@param eventNameOrID string|uint
---@return AKRESULT
function WwiseMgr.PauseSound2D(eventNameOrID)
    local ret = getIns():PauseSound(eventNameOrID)
    ret = toLuaAkResult(ret)
    return ret
end

---通过playingId暂停2D音效
---@param playingId uint
---@return AKRESULT
function WwiseMgr.PauseSoundByPlayingId(playingId)
    local ret = getIns():PauseSoundByPlayingId(playingId)
    ret = toLuaAkResult(ret)
    return ret
end

---暂停3D音效
---@param eventNameOrID string|uint
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.PauseSound3D(eventNameOrID, gameObj)
    local ret = getIns():PauseSound(eventNameOrID, gameObj)
    ret = toLuaAkResult(ret)
    return ret
end

---恢复2D音效
---@param eventNameOrID string|uint
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.ResumeSound2D(eventNameOrID)
    local ret = getIns():ResumeSound(eventNameOrID)
    ret = toLuaAkResult(ret)
    return ret
end

---通过playingId恢复2D音效
---@param playingId uint
---@return AKRESULT
function WwiseMgr.ResumeSoundByPlayingId(playingId)
    local ret = getIns():ResumeSoundByPlayingId(playingId)
    ret = toLuaAkResult(ret)
    return ret
end

---恢复3D音效
---@param eventNameOrID string|uint
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.ResumeSound3D(eventNameOrID, gameObj)
    local ret = getIns():ResumeSound(eventNameOrID, gameObj)
    ret = toLuaAkResult(ret)
    return ret
end
--endregion

--region Special Stop / Pause / Resume
---停止背景音乐
function WwiseMgr.StopMusic()
    getIns():StopMusic()
end

---暂停背景音乐
function WwiseMgr.PauseMusic()
    if (MusicPauseCount >= 1) then
        return ;
    end
    MusicPauseCount = MusicPauseCount + 1
    getIns():PostSystemEvent(EVENT_PAUSE_MUSIC)
end

---恢复暂停的背景音乐
function WwiseMgr.ResumeMusic()
    if (MusicPauseCount >= 1) then
        MusicPauseCount = MusicPauseCount - 1
    end

    getIns():PostSystemEvent(EVENT_RESUME_MUSIC)
end

---停止通用音效
function WwiseMgr.StopSound()
    getIns():PostSystemEvent(EVENT_STOP_SOUND)
end

---停止语音
function WwiseMgr.StopVoice()
    getIns():PostSystemEvent(EVENT_STOP_VOICE)
end

---暂停通用音效+语音
function WwiseMgr.PauseSoundVoice()
    getIns():PostSystemEvent(EVENT_PAUSE_VOSFX)
end

---恢复暂停的通用音效+语音
function WwiseMgr.ResumeSoundVoice()
    getIns():PostSystemEvent(EVENT_RESUME_VOSFX)
end

---暂停广播剧
function WwiseMgr.PauseRadio()
    getIns():PostSystemEvent(EVENT_PAUSE_DRAMA)
end

---停止广播剧
function WwiseMgr.StopRadio()
    getIns():PostSystemEvent(EVENT_STOP_DRAMA)
end

---恢复广播剧
function WwiseMgr.ResumeRadio()
    getIns():PostSystemEvent(EVENT_RESUME_DRAMA)
end

---暂停剧情音效
function WwiseMgr.PausePlot()
    getIns():PostSystemEvent(EVENT_PAUSE_PLOT)
end

---恢复剧情音效
function WwiseMgr.ResumePlot()
    getIns():PostSystemEvent(EVENT_RESUME_PLOT)
end

---暂停剧情分段语音
function WwiseMgr.PausePlotVo()
    getIns():PostSystemEvent(EVENT_PAUSE_PLOT_VO)
end

---恢复剧情分段语音
function WwiseMgr.ResumePlotVo()
    getIns():PostSystemEvent(EVENT_RESUME_PLOT_VO)
end

---停止循环音效
function WwiseMgr.StopLoop()
    getIns():PostSystemEvent(EVENT_STOP_LOOP)
end

---暂停循环音效
function WwiseMgr.PauseLoop()
    getIns():PostSystemEvent(EVENT_PAUSE_LOOP)
end

---恢复循环音效
function WwiseMgr.ResumeLoop()
    getIns():PostSystemEvent(EVENT_RESUME_LOOP)
end

---停止抽卡音效
function WwiseMgr.StopAudio()
    getIns():PostSystemEvent(EVENT_STOP_AUDIO)
end
--endregion

---播放到指定的位置（绝对位置，毫秒）
---@param eventNameOrID string|int eventName/eventID
---@param position int 定位绝对位置【单位：毫秒】 int
---@param gameObj GameObject
---@param playingID int 正在播放的playingID， 1、uint 2、> 0
---@return AKRESULT 是否定位成功
function WwiseMgr.SeekOnEventAbsolutely(eventNameOrID, position, gameObj, playingID)
    playingID = playingID or 0
    local ret = getIns():SeekOnEventAbsolutely(eventNameOrID, position, gameObj, playingID)
    ret = toLuaAkResult(ret)
    return ret
end

---播放到指定的位置（百分比）
---@param eventNameOrID string|int eventName/eventID
---@param percentage number 0~1
---@param gameObj GameObject
---@param playingID int 正在播放的playingID， 1、uint 2、> 0
---@return AKRESULT 是否定位成功
function WwiseMgr.SeekOnEvent(eventNameOrID, percentage, gameObj, playingID)
    playingID = playingID or 0
    local ret = getIns():SeekOnEvent(eventNameOrID, percentage, gameObj, playingID)
    ret = toLuaAkResult(ret)
    return ret
end

---@param eventName string
---@return float
function WwiseMgr.GetLength(eventName)
    return getIns():GetLength(eventName)
end

---@param eventName string
---@return float
function WwiseMgr.GetMaxLength(eventName)
    return getIns():GetLength(eventName)
end

---@param playingID number 正在播放的playingID， 1、uint 2、> 0
---@return AkSegmentInfo
function WwiseMgr.GetPlayingSegmentInfo(playingID)
    assert(playingID)
    return getIns():GetPlayingSegmentInfo(playingID)
end

---@param name string
---@param value float
---@return AKRESULT
function WwiseMgr.SetRTPC(name, value)
    local ret = getIns():SetRTPC(name, value)
    ret = toLuaAkResult(ret)
    return ret
end

---@param switchGroup string
---@param switchState string
---@return AKRESULT
function WwiseMgr.SetSwitch2D(switchGroup, switchState)
    local ret = getIns():SetSwitch2D(switchGroup, switchState)
    ret = toLuaAkResult(ret)
    return ret
end

---@param switchGroup string
---@param switchState string
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.SetSwitch3D(switchGroup, switchState, gameObj)
    local ret = getIns():SetSwitch3D(switchGroup, switchState, gameObj)
    ret = toLuaAkResult(ret)
    return ret
end

---@param switchGroup uint
---@param switchState uint
---@param gameObj GameObject
---@return AKRESULT
function WwiseMgr.SetSwitch(switchGroup, switchState, gameObj)
    local ret = getIns():SetSwitch(switchGroup, switchState, gameObj)
    ret = toLuaAkResult(ret)
    return ret
end

---@param stateGroup uint
---@param state uint
---@return AKRESULT
function WwiseMgr.SetState(stateGroup, state)
    local ret = getIns():SetState(stateGroup, state)
    ret = toLuaAkResult(ret)
    return ret
end

--region SoundBank Manipulation
---根据Event Name获取Bank Name
---@param eventName string
---@return string
function WwiseMgr.GetBankNameWithEventName(eventName)
    return getIns():GetBankNameWithEventName(eventName)
end

---根据Event ID获取Bank Name
---@param eventId uint
---@return string
function WwiseMgr.GetBankNameWithEventId(eventId)
    return getIns():GetBankNameWithEventId(eventId)
end

---加载Sound Bank
---@param bankName string
---@param autoRelease bool 是否自动卸载Bank
---@param refObj UObject 引用对象
---@return boolean
function WwiseMgr.LoadBank(bankName, autoRelease, refObj)
    if autoRelease == nil then
        autoRelease = true
    end
    return getIns():LoadBank(bankName, autoRelease, refObj)
end

---卸载Sound Bank
---@param bankName string
---@param force bool 是否强制卸载（默认强制）
function WwiseMgr.UnloadBank(bankName, force)
    if force == nil then
        force = true
    end
    getIns():UnloadBank(bankName, force)
end

---异步加载Sound Bnak
---@param bankName string
---@param onComplete fun(bankName:string, success:boolean)
---@param autoRelease bool 是否自动卸载Bank
---@param refObj UObject 引用对象
function WwiseMgr.LoadBankAsync(bankName, onComplete, autoRelease, refObj)
    if autoRelease == nil then
        autoRelease = true
    end
    getIns():LoadBankAsync(bankName, onComplete, autoRelease, refObj)
end

---给Bank增加引用对象
---@param bankNameOrId string|uint BankName or BankId
---@param refObj UObject
---@return bool
function WwiseMgr.AddRefObj(bankNameOrId, refObj)
    local ret = getIns():AddRefObj(bankNameOrId, refObj)
    return ret
end

---移除引用对象
---@param bankNameOrId string|uint BankName or BankId
---@param refObj UObject
---@return bool
function WwiseMgr.RemoveRefObj(bankNameOrId, refObj)
    local ret = getIns():RemoveRefObj(bankNameOrId, refObj)
    return ret
end

---根据EventId或EventName查找对应的Bank并移除引用对象
---@param eventIdOrName uint|string EventId or EventName
---@param refObj UObject
function WwiseMgr.RemoveRefObjByEvent(eventIdOrName, refObj)
    local ret = getIns():RemoveRefObjByEvent(eventIdOrName, refObj)
    return ret
end

---查询Sound Bank是否已加载
---@param bankName string
---@return boolean
function WwiseMgr.IsBankLoaded(bankName)
    return getIns():IsBankLoaded(bankName)
end

---加载所有Sound Bank
function WwiseMgr.LoadAllBanks()
    getIns():LoadAllBanks()
end

---卸载所有Sound Bnak
function WwiseMgr.UnloadAllBanks()
    getIns():UnloadAllBanks()
end

---根据EventID加载Sound Bank
---@param eventID uint
---@param autoRelease bool 是否自动卸载Bank
function WwiseMgr.LoadBankWithEventId(eventID, autoRelease)
    if autoRelease == nil then
        autoRelease = true
    end
    getIns():LoadBankWithEventId(eventID, autoRelease)
end

---根据Event Name加载Sound Bank
---@param eventName string
---@param autoRelease bool 是否自动卸载Bank
function WwiseMgr.LoadBankWithEventName(eventName, autoRelease)
    if autoRelease == nil then
        autoRelease = true
    end
    getIns():LoadBankWithEventName(eventName, autoRelease)
end

---根据Event Name卸载Sound Bank
---@param eventName string
---@param force bool 是否强制卸载（默认强制）
function WwiseMgr.UnloadBankWithEventName(eventName, force)
    if force == nil then
        force = true
    end
    getIns():UnloadBankWithEventName(eventName, force)
end

---根据Event Name卸载SoundBank
---@param eventID int
---@param force bool 是否强制卸载（默认强制）
function WwiseMgr.UnloadBankWithEventId(eventID, force)
    if force == nil then
        force = true
    end
    getIns():UnloadBankWithEventId(eventID, force)
end
--endregion

---Event ID转Event Name
---@param eventID uint
---@return string eventName
function WwiseMgr.GetEventName(eventID)
    return getIns():GetEventName(eventID)
end

---Event Name转Event ID
---@param eventName string
---@return uint eventID
function WwiseMgr.GetEventId(eventName)
    return getIns():GetEventId(eventName)
end

---Event 获取event是否存在
---@param eventName string
---@return uint eventID
function WwiseMgr.CheckEventExist(eventName)
    return getIns():CheckEventExist(eventName)
end

---获取播放进度（0~1）
---@param playingId uint
---@return float
function WwiseMgr.GetPlayingProgress(playingId)
    return getIns():GetPlayingProgress(playingId)
end

---@param playingId uint
---@return float
function WwiseMgr.GetPlayPosition(playingId)
    return getIns():GetPlayPosition(playingId)
end

function WwiseMgr.Init()
    local assetPath = string.format("Assets/Build/Res/GameObjectRes/BasicWidget/SoundBanksInfo_%s.asset", Locale.GetSoundLangName())
    local asset = Res.LoadWithAssetPath(assetPath, AutoReleaseMode.EndOfFrame)
    if asset ~= nil then
        CLS.LoadManifestFromAsset(asset)
    end
    local curSoundLang = Locale.GetSoundLang()
    WwiseMgr.SetLanguage(curSoundLang)
    getIns():Initialize()
    if isFirsInit then
        CS.AkBankManager.ReloadAllBanks()
    end
    WwiseMgr.SetVolume(100)
    if isFirsInit then
        isFirsInit = false
    end
end

--region 音量操作
---设置整体音量
---@param volume number 0~100
function WwiseMgr.SetVolume(volume)
    getIns().Volume = volume
end

---获取整体音量
---@return number 0~100
function WwiseMgr.GetVolume()
    return getIns().Volume
end

---设置背景音量
---@param volume number 0~100
function WwiseMgr.SetMusicVolume(volume)
    getIns().MusicVolume = volume
end

---获取背景音量
---@return number 0~100
function WwiseMgr.GetMusicVolume()
    return getIns().MusicVolume
end

---设置音效音量
---@param volume number 0~100
function WwiseMgr.SetSoundVolume(volume)
    getIns().SoundVolume = volume
end

---获取音效音量
---@return number 0~100
function WwiseMgr.GetSoundVolume()
    return getIns().SoundVolume
end

---设置配音音量
---@param volume number 0~100
function WwiseMgr.SetVoiceVolume(volume)
    getIns().VoiceVolume = volume
end

---获取配音音量
---@return number 0~100
function WwiseMgr.GetVoiceVolume()
    return getIns().VoiceVolume
end
--endregion

---设置音效速率
---@param eventName any
---@param speed float
function WwiseMgr.SetSpeed(eventName, speed)
    getIns():SetSpeed(eventName, speed)
end

---设置女主声音年龄
---@param val float
function WwiseMgr.SetAgeNumber(val)
    getIns():SetAgeNumber(val)
end

---设置女主声音力量感
---@param val float
function WwiseMgr.SetImpact(val)
    getIns():SetImpact(val)
end

---设置女主声音鼻音
---@param val float
function WwiseMgr.SetNasal(val)
    getIns():SetNasal(val)
end

---设置女主声音性感
---@param val float
function WwiseMgr.SetSexy(val)
    getIns():SetSexy(val)
end

---设置女主声音温暖
---@param val float
function WwiseMgr.SetWarm(val)
    getIns():SetWarm(val)
end

---卸载不再使用的Sound Banks
function WwiseMgr.UnloadUnusedBanks()
    getIns():UnloadUnusedBanks()
end

---Wwise GC
function WwiseMgr.CollectReservedMemory()
    --getIns():CollectReservedMemory()
end

---设置Soundbank白名单
---@param whiteList string[]
function WwiseMgr.SetBankWhiteList(whiteList)
    getIns():SetBankWhiteList(whiteList)
end

---设置自动卸载未使用Bank的Tick间隔时间（帧）
---@param value int 间隔帧数
function WwiseMgr.SetUnloadUnusedBanksTickInterval(value)
    CLS.UnloadUnusedBanksTickInterval = value
end

---设置自动卸载未使用Bank的冷却帧数（Bank被加载后至少需要等待多少帧才能被卸载）
---@param value int 冷却帧数
function WwiseMgr.SetUnloadUnusedBanksCoolingTime(value)
    CLS.UnloadUnusedBanksCoolingTime = value
end

---开启自动检测未使用的Bank并卸载
function WwiseMgr.EnableAutoUnloadUnusedBanks()
    CLS.AutoUnloadUnusedBanksEnabled = true
end

---关闭自动检测未使用的Bank并卸载
function WwiseMgr.DisableAutoUnloadUnusedBanks()
    CLS.AutoUnloadUnusedBanksEnabled = false
end

--region AkAudioListener
---删除默认的AkAudioListener
function WwiseMgr.DestroyDefaultListener()
    CS.WwiseEnvironment.DestroyDefaultListener()
end

---在主相机上创建AkAudioListener
---@param isDefault boolean 是否设置为默认的AkAudioListener
function WwiseMgr.GenerateListenerOnMainCamera(isDefault)
    isDefault = isDefault or false
    CS.WwiseEnvironment.GenerateListenerOnMainCamera(isDefault)
end

---销毁主相机上的AkAudioListener
function WwiseMgr.DestroyListenerOnMainCamera()
    CS.WwiseEnvironment.DestroyListenerOnMainCamera()
end

---删除指定的AkAudioListener
---@param obj UObject 任意可能关联AkAudioListener的对象
function WwiseMgr.DestroyListener(obj)
    CS.WwiseEnvironment.DestroyListener(obj)
end

---在指定的对象上生成AkAudioListener
---@param obj UObject 任意可能关联AkAudioListener的对象
---@param isDefault boolean 是否设置为默认的AkAudioListener
function WwiseMgr.GenerateListener(obj, isDefault)
    isDefault = isDefault or false
    CS.WwiseEnvironment.GenerateListener(obj, isDefault)
end
--endregion

---设置后台Tick的interval（毫秒）
function WwiseMgr.SetBgTickIntervalMS(millPeriod)
    CS_PFWWISEUTILITY.SetBgTickIntervalMS(millPeriod)
end

---wwise远程更新，安卓更新通知栏，ios更新center
function WwiseMgr.UpdateRemote()
    CS_PFWWISEUTILITY.UpdateRemote()
end

---@class IWwiseRemoteControlDelegate
---@field OnInit fun()
---@field OnUpdate fun()
---@field OnPlay fun()
---@field OnPause fun()
---@field OnNext fun()
---@field OnPrev fun()
---@field OnStop fun()
---@field OnNextTrack fun()
---@field OnPrevTrack fun()
---@field GetDatas fun():string[]

---Wwise设置Wwise Remote播放器的控制代理
---@param delegate IWwiseRemoteControlDelegate
function WwiseMgr.SetRemoteControlDelegate(delegate)
    CS_PFWWISEUTILITY.SetRemoteControlDelegate(delegate)
end

---@return boolean 是否开启了Wwise后台播放
function WwiseMgr.IsBgModeActive()
    local ret = CS_PFWWISEUTILITY.IsBgModeActive()
    return ret
end

---开启或关闭Wwise后台播放
---@param active bool 是否开启后台播放
function WwiseMgr.SetBgModeActive(active)
    if (WwiseMgr.IsBgModeActive() == active) then
        Debug.LogWarning("WwiseMgr.SetBgModeActive already set bgMode: ", active)
        return
    end

    if active then
        local f = CS.System.IO.Path.Combine(CS.UnityEngine.Application.streamingAssetsPath, "Audio.wav")
        CS.X3Game.Platform.PFMediaPlayerUtility.SetFakeBgMusicFilePath(f)
    end
    CS_PFWWISEUTILITY.SetBgModeActive(active)
end

---仅为兼容安卓进入业务就需触发后台逻辑的情况
---@param active bool 是否开启后台播放
function WwiseMgr.EnterBGMode(active, isBgMusicPlaying)
    CS_PFWWISEUTILITY.EnterBGMode(active, isBgMusicPlaying)
end

---Wwise挂起
function WwiseMgr.TrySuspend()
    CS_PFWWISEUTILITY.Suspend()
end

---Wwise恢复
function WwiseMgr.TryResume()
    CS_PFWWISEUTILITY.WakeupFromSuspend()
end

---女主声音开关
---@param isOpen bool
function WwiseMgr.SetPlayerVoiceOpen(isOpen)
    if isOpen then
        getIns():PostSystemEvent(EVENT_OPEN_PLAYER_VOICE)
    else
        getIns():PostSystemEvent(EVENT_CLOSE_PLAYER_VOICE)
    end
end

---置于后台播放时使用
function WwiseMgr.PlaySoundInBackground(evtName, updateRemote)
    updateRemote = updateRemote or false
    local playID = CS_PFWWISEUTILITY.PlaySound(evtName, updateRemote)
end

---清理Wwise正在播放的信息
function WwiseMgr.ClearPlayingInfo()
    getIns():ClearPlayingInfo()
end

---清理wwise
function WwiseMgr.Clear()
    ---Do Nothing 保证音效一直存在
end

---Destroy
function WwiseMgr.Destroy()
    for k, v in pairs(markerCallMap) do
        CLS.UnregisterEventCallback(v)
    end
    table.clear(markerCallMap)
    GameSoundMgr.StopMusic()
    WwiseMgr.StopVoice()
    WwiseMgr.ClearPlayingInfo()
    WwiseMgr.SetRemoteControlDelegate(nil)
    WwiseMgr.SetBgModeActive(false)
    WwiseMgr.UnloadAllBanks()
    CLS.DestroyInstance()
    _ins = nil
end

---设置wwiseLog开关
function WwiseMgr.SetLogEnable(logEnable)
    CLS.LogEnable = logEnable
end

---获取WwiseLog开关是否开启
function WwiseMgr.GetLogEnable()
    return CLS.LogEnable
end

---注册AkMarker事件回调
---@param cb fun(data:AkMarkerCallbackInfo)
function WwiseMgr.RegisterMarkerEventCallback(cb)
    if cb ~= nil then
        table.insert(markerCallMap, cb)
        CLS.RegisterMarkerEventCallback(cb)
    end
end

---反注册AkMarker事件回调
---@param cb fun(data:AkMarkerCallbackInfo)
function WwiseMgr.UnregisterMarkerEventCallback(cb)
    if cb ~= nil then
        table.removebyvalue(markerCallMap, cb)
        CLS.UnregisterEventCallback(cb)
    end
end

return WwiseMgr