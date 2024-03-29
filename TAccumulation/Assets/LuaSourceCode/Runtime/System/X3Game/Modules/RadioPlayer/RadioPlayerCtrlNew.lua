﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/4/11 11:28
---

---@class RadioPlayerCtrlNew
local RadioPlayerCtrlNew = class("RadioPlayerCtrlNew")

local CS_PFWWISEUTILITY = CS.X3Game.Platform.PFWwiseUtility
local TAG = "LLM-Radio:"
function RadioPlayerCtrlNew:ctor(songList)
    ---是否执行了初始化
    self._isInited = false

    ---@type RadioSubConfig[]
    self._songList = songList or {} ---播放列表
    --Debug.LogError("RadioPlayerCtrlNew ctor ", songList)
    ---@type RadioSubConfig
    self._playSongConfig = nil

    ---ID对照-
    self._songDic = nil

    self._playState = GameConst.MusicPlayState.None
    self._playSongIndex = nil
    self._playPosition = nil

    ---语音
    self._voiceEventName = nil
    self._voicePlayingID = 0
    ---广播剧总时长
    self._radioTotalLength = 0

    ---初始化
    self:_Init()
end

---退出清理
function RadioPlayerCtrlNew:Exit()
    ---退出终止声音
    self:Stop()

    ---每一个句子的集合
    self._songList = nil
    self._songDic = nil
    self._playSongIndex = nil
    self._playPosition = nil
    self._playSongConfig = nil

    self._voicePlayingID = 0
    self._voiceEventName = nil
    self._radioTotalLength = 0

    --Debug.LogError("RadioPlayerCtrlNew Exit")

end

---设置播放数据源
---@param radioEventName string 广播剧Audio事件名称
---@param songList RadioSubConfig[] 广播剧播放List
---@param firstIndex int 首个ITEM的索引值
function RadioPlayerCtrlNew:SetSource(radioEventName, songList, songDic)
    if not (songList and songDic) then
        Debug.LogErrorWithTag(GameConst.LogTag.Radio, "SetSource Error! no data")
        return
    end

    self:Stop()
    self._playSongIndex = nil
    self._playPosition = nil
    self._playSongConfig = nil

    self._songList = songList
    self._songDic = songDic
    --self:ResortSongList(songList, firstIndex)

    --Debug.LogError("RadioPlayerCtrlNew SetSource ", radioEventName)
    self._voiceEventName = radioEventName
    self:_Init()
    ---共用一套排序好的数据。--看看是否有必要缓存下，避免每次排序
    return self._songList
end

---过滤，整理songList --配置中会有无效数据
---@param songList RadioSubConfig[]
---@param firstIndex int 首个ITEM的索引值
function RadioPlayerCtrlNew:ResortSongList(songList, firstIndex)
    if (not firstIndex) then
        Debug.LogErrorWithTag(GameConst.LogTag.Radio, "对应播放列表未传入对应初始ID")
        return
    end

    local sortList = {}
    local songDic = {}
    if (not (songList and firstIndex)) then
        return sortList, songDic
    end

    local firstItem = songList[firstIndex]

    if (firstItem) then
        if UNITY_EDITOR then
            if (firstItem.NextID == 0) then
                Debug.LogErrorWithTag(GameConst.LogTag.Radio, "对应曲目的FirstID配置指向了0，当前FirstID为：", firstIndex)
            end
        end
        table.insert(sortList, firstItem)
        songDic[firstItem.ID] = #sortList
        local dialogText = nil
        --for i = 1, #songList do
        ---临时处理下obt上换用后处理表格做法
        while(songList[firstItem.NextID]) do
            local nextItem = songList[firstItem.NextID]
            if(nextItem) then
                dialogText = UITextHelper.GetUIText(nextItem.DialogueText)
            end
            if (nextItem and (not string.isnilorempty(dialogText) or nextItem.RoleID < 0)) then
                table.insert(sortList, nextItem)
                songDic[nextItem.ID] = #sortList
                firstItem = nextItem
            elseif nextItem and string.isnilorempty(dialogText) then
                firstItem = nextItem
            else
                break ;
            end
        end
    else
        Debug.LogErrorWithTag(GameConst.LogTag.Radio, "播放列表中没有对应初始ID的数据: ", firstIndex)
    end
    return sortList, songDic

end

---@private
---初始化广播剧播放器
function RadioPlayerCtrlNew:_Init()
    self._playState = GameConst.MusicPlayState.None
    self._voicePlayingID = 0
    self._playPosition = 0

    if string.isnilorempty(self._voiceEventName) then
        self._radioTotalLength = 0
    else
        self._radioTotalLength = WwiseMgr.GetMaxLength(self._voiceEventName)
    end
end

function RadioPlayerCtrlNew:Reset()
    self._playPosition = 0
end

---后台播放使用 ---这个函数挪出去，和业务有点强关联了（或者分类型处理也行）
function RadioPlayerCtrlNew:SetSourceInBackground(config)
    --local radioList = LuaCfgMgr.GetAll(config.RadioName)
    --self:SetSource(config.RadioVoice, BackgroundRadioConfigDB:GetConfig(config.RadioName))
    --self:_SetPlaySongIndex(1)
    --

    --Debug.LogError("SetTest ", self._voiceEventName, " -- config ", config.RadioVoice)
end

---触发后台重新播放时
function RadioPlayerCtrlNew:PlayInBackground(radioName)
    --WwiseMgr.PauseMusic()
    self:_SetPlaySongIndex(1)

    self._playState = GameConst.MusicPlayState.Play
    WwiseMgr.TryResume()
    CS_PFWWISEUTILITY.IsBgMusicPlaying = true
    WwiseMgr.PlaySoundInBackground(radioName)
end

--region 获取参数接口
---@public 获取当前Radio配置
function RadioPlayerCtrlNew:GetRadio()
    return self._playSongConfig
end

---@public 获取当前Radio配置
function RadioPlayerCtrlNew:GetSubIndex()
    --return self._playSongConfig and self._playSongConfig.ID
    return self._playSongConfig and self._playSongIndex

end

---获取总时长
function RadioPlayerCtrlNew:GetLength()
    return self._radioTotalLength
end

---获取总时长
function RadioPlayerCtrlNew:GetPosition()
    return self._playPosition or 0
end

---是否已经结束
function RadioPlayerCtrlNew:IsEnd()
    local totalLength = self:GetLength()
    if totalLength then
        ---判定结束点
        return self:GetPosition() >= totalLength * 0.99
    end
    return true
end

---获取当前播放状态
function RadioPlayerCtrlNew:GetState()
    return self._playState
end

--function RadioPlayerCtrlNew:IsPlaying()
--    return self._playState == CompanyConst.MusicPlayMode.Play
--end

function RadioPlayerCtrlNew:GetSubCount()
    return self._songList and #self._songList or 0
end
--endregion

--region 播放列表数据相关接口
---@private 设置当前播放器曲库索引
---@param songIndex number 曲库索引
function RadioPlayerCtrlNew:_SetPlaySongIndex(songIndex)
    --Debug.LogError("_SetPlaySongIndex ", songIndex, " total ", #self._songList)
    if (not songIndex) then
        Debug.LogErrorWithTag(GameConst.LogTag.Radio, "_SetPlaySongIndex no songIndex ")
    end
    self._playSongIndex = songIndex
    self._playSongConfig = self._songList[songIndex]
end

--- 获取原始SongConfig
---@param songIndex number SongList-ID
function RadioPlayerCtrlNew:GetSongConfig(songIndex, songID)
    local data = self._songList[songIndex]
    if (not data) then
        Debug.LogErrorWithTag(GameConst.LogTag.Radio, "_GetSongConfig no data ", songIndex, " id ", songID)
    end
    return data ---ID就是索引
end

---根据ID获取配置
function RadioPlayerCtrlNew:_GetSongConfigByID(id)
    local index = self._songDic[id]
    return self:GetSongConfig(index, id), index
end

---根据ID获取索引值（额外加了是否可用的判断）
function RadioPlayerCtrlNew:GetSongIndexByID(id)
    local item, index = self:_GetSongConfigByID(id)
    return item and index or 1
end

---@public 获取广播剧指定索引的播放时间点
---@param songID number 曲库索引[1,)
function RadioPlayerCtrlNew:GetSubRadioTime(songID)
    if (not songID) then
        --Debug.LogErrorWithTag(GameConst.LogTag.Radio, "想要0不要调这里，先标记下")
        return 0
    end
    local item = self:_GetSongConfigByID(songID)
    --return item and item.DialogueTime * 0.001 or self:_GetSongConfig(self._playSongIndex).DialogueTime * 0.001
    ---10.20 by dl 当原数据不可用时，与策划沟通，从头播放
    return item and item.DialogueTime * 0.001 or 0

    --if songIndex > self:GetSubCount() then
    --    songIndex = self:GetSubCount()
    --end
    --return self:_GetSongConfig(songIndex).DialogueTime * 0.001
end

----用于按进度定位配置
function RadioPlayerCtrlNew:GetPlayingSubIndexRecursive(radioCurPosition, fromIndex, toIndex)
    if toIndex <= fromIndex then
        return
    end

    local fromSongConfig = self._songList[fromIndex]
    local fromSubPlayTime = fromSongConfig.DialogueTime * 0.001
    local toSongConfig = self._songList[toIndex]
    local toSubPlayTime = toSongConfig.DialogueTime * 0.001
    if radioCurPosition >= fromSubPlayTime and radioCurPosition < toSubPlayTime then
        if toIndex - fromIndex == 1 then
            ----相邻索引
            return fromIndex
        end
    else
        return
    end

    local midSubIdx = (toIndex + fromIndex) // 2
    local midSongConfig = self._songList[midSubIdx]
    local midSubPlayTime = midSongConfig.DialogueTime * 0.001

    if radioCurPosition >= midSubPlayTime then
        return self:GetPlayingSubIndexRecursive(radioCurPosition, midSubIdx, toIndex)
    else
        return self:GetPlayingSubIndexRecursive(radioCurPosition, fromIndex, midSubIdx)
    end
end

---@private 获取当前广播剧播放索引
---@param radioCurPosition number 当前播放位置
---@return number 播放索引
function RadioPlayerCtrlNew:GetPlayingSubIndex(radioCurPosition)
    local totalCount = self:GetSubCount()
    local startSongConfig = self._songList[1]
    ---小于第一段的就是开头
    if radioCurPosition <= startSongConfig.DialogueTime * 0.001 then
        return 1
    end

    ---大于最后一段的就是结尾
    local endSongConfig = self._songList[totalCount]
    if radioCurPosition >= endSongConfig.DialogueTime * 0.001 then
        return totalCount
    end
    ---其他二分递归吧
    return self:GetPlayingSubIndexRecursive(radioCurPosition, 1, totalCount)
end

---@private 更新播放进度
---@param radioCurPosition number 当前播放位置
function RadioPlayerCtrlNew:_UpdatePlayingInfo(radioCurPosition)
    local radioPlayingIndex = self:GetPlayingSubIndex(radioCurPosition)
    --Debug.LogError("RadioPlayerCtrlNew radioCurPosition ", radioCurPosition, " radioPlayingIndex ", radioPlayingIndex)
    if radioPlayingIndex > 0 then
        self:_SetPlaySongIndex(radioPlayingIndex)
        self._playPosition = radioCurPosition
    end
end

---@public 外部更新播放进度
---@param radioCurPosition number 当前播放位置
function RadioPlayerCtrlNew:OnPlayUpdate(radioCurPosition)
    self:_UpdatePlayingInfo(radioCurPosition)
end

--endregion

--region 播放器行为接口
---@public 播放音乐
---@param songIndex number 曲库索引
---@param isForcePlay boolean 是否考虑正在播放的subRadioID==当前的参数subRadioID
---@param isResetPlay boolean 针对第一个subRadio,是否从0开始播放
function RadioPlayerCtrlNew:Play(songIndex, isForcePlay, isResetPlay)
    songIndex = songIndex or self._playSongIndex or 1
    if isForcePlay or self._playSongIndex ~= songIndex then
        self:_SetPlaySongIndex(songIndex)
        if songIndex <= 1 and isResetPlay then
            self._playPosition = 0
        else
            local songConfig = self:GetSongConfig(songIndex)
            self._playPosition = self:GetSubRadioTime(songConfig.ID)
            --Debug.LogError("RadioPlayerCtrlNew Play ", songIndex, " isResetPlay ", isResetPlay, self._playPosition)

        end
        --Debug.LogError("RadioPlayerCtrlNew:Play self._playPosition", self._playPosition)
        self:RePlay()
        return true
    else
        --print(TAG, "you see, playing:", self._playSongIndex)
    end
end

---@public 强制重新播放
function RadioPlayerCtrlNew:RePlay()
    ---print("DEMO:Replay", self._playSongIndex, self._playSongConfig)
    if self._playSongConfig then
        ---这是背景音乐播放
        self:Stop()
        self._playState = GameConst.MusicPlayState.Play

        WwiseMgr.LoadBankWithEventName(self._voiceEventName)
        self._voicePlayingID = WwiseMgr.PlaySound2D(self._voiceEventName)
        if self._playPosition > 0 then
            self:Seek2Position()
        end
        CS_PFWWISEUTILITY.IsBgMusicPlaying = true
    else
        print(TAG, "you see, nothing is Playing , successly...")
    end
end

---@public 继续播放
function RadioPlayerCtrlNew:Resume()
    ---print("DEMO:Resume", self._playState, "==", CompanyConst.MusicPlayState.Pause)
    if self._playState == GameConst.MusicPlayState.Pause then
        self._playState = GameConst.MusicPlayState.Play
        WwiseMgr.ResumeRadio()
        if self._voiceEventName then
            WwiseMgr.ResumeSound2D(self._voiceEventName)
        end
        if self._playPosition > 0 then
            self:Seek2Position()
        end
        CS_PFWWISEUTILITY.IsBgMusicPlaying = true
        return true
    end
    return false
end

---@public 暂停
function RadioPlayerCtrlNew:Pause()
    ---print("DEMO:Pause", self._playState, "==", CompanyConst.MusicPlayState.Play)
    if self._playState == GameConst.MusicPlayState.Play then
        self._playState = GameConst.MusicPlayState.Pause
        WwiseMgr.PauseRadio()
        if self._voiceEventName then
            WwiseMgr.PauseSound2D(self._voiceEventName)
        end
        CS_PFWWISEUTILITY.IsBgMusicPlaying = false
        return true
    end
    return false
end

---@public 终止
function RadioPlayerCtrlNew:Stop()
    if self._playState ~= GameConst.MusicPlayState.Stop then
        self._playState = GameConst.MusicPlayState.Stop
        WwiseMgr.StopRadio()
        --WwiseMgr.ResumeMusic()
        if self._voiceEventName then
            WwiseMgr.StopSound2D(self._voiceEventName)
        end
        CS_PFWWISEUTILITY.IsBgMusicPlaying = false
        return true
    end
    return false
end

---@public 定位
---@param percent number 定位的单位占比
---@return number 返回定位索引
function RadioPlayerCtrlNew:Seek(percent, force)
    ---当一首结束时，再去seek前面的进度，当前会出现seek返回成功，但无声的情况 ---临时处理下，等木琛修改seek接口后，按照返回的结果再决定是否重播
    if (self._playPosition >= self:GetLength()) then
        self._voicePlayingID = WwiseMgr.PlaySound2D(self._voiceEventName)
    end

    local positionValue = percent * self:GetLength()
    self:_UpdatePlayingInfo(positionValue)
    if self._playSongIndex > 1  or (force and self._playSongIndex > 0) then
        ----只有播放状态可以正常seek
        self:Seek2Position(positionValue)
    end
    return self._playSongIndex
end

---@public 定位到指定位置
---@param playPosition number 当前声音需要定位的绝对位置（毫秒）
---@return bool 返回是否成功
function RadioPlayerCtrlNew:Seek2Position(playPosition)
    playPosition = playPosition or self._playPosition

    local seekValue = math.floor(playPosition * 1000) ---向下取正毫秒
    local seekResult = WwiseMgr.SeekOnEventAbsolutely(self._voiceEventName, seekValue, nil, self._voicePlayingID)
    print(TAG, "+++Seek-seekResult++++:", seekResult, self._voiceEventName, seekValue,
            self._playState == GameConst.MusicPlayState.Play)
    return seekResult
end

---@public 播放下一个节点
function RadioPlayerCtrlNew:Next()
    --Debug.LogError("RadioPlayerCtrlNew Next ", self._playSongIndex, " == ", self:GetSubCount())
    if not self._playSongIndex then
        return
    end

    local totalCount = self:GetSubCount()
    if self._playSongIndex + 1 > totalCount then
        return false
    end
    self:Play(self._playSongIndex + 1)
    return true
end

---@public 播放上一个节点
function RadioPlayerCtrlNew:Prev()
    if not self._playSongIndex then
        return
    end

    if self._playSongIndex - 1 <= 0 then
        return false
    end
    self:Play(self._playSongIndex - 1)
    return true
end

---@public 自动下一个
function RadioPlayerCtrlNew:GoOn()
    return self:Next()
end

return RadioPlayerCtrlNew