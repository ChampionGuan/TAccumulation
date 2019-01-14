-- 检测unity对象是否被销毁(Object类型)
local function unityTargetIsNil(unityTarget)
    if nil == unityTarget or (CSharp.LogicUtils.IsNil(unityTarget)) then
        return true
    else
        return false
    end
end

-- 音源数据
local AudioSourceInfo = function()
    local t = {
        -- 实例化id
        insId = 0,
        -- 配置id
        configId = 0,
        -- 是否为3d音源
        is3d = false,
        -- 淡入淡出
        isFadeIn = false,
        -- 自身
        theSelf = nil,
        -- 跟随对象（3d音源,才会有跟随对象）
        theFollow = nil,
        -- 音源组件
        audioSource = nil,
        -- 默认音量
        defaultVolume = 1,
        -- 资源路径
        audioPath = "",
        -- 所在组
        groupName = "",
        -- 下一个音源
        nextAuidoGroupId = nil,
        -- 是否在空闲状态
        IsIdle = function(self)
            if self.audioSource.isPlaying then
                return false
            end
            self.onUpdate = nil
            return true
        end,
        -- 播放
        Play = function(self)
            if self.audioSource.isPlaying then
                return
            end

            self.onUpdate = nil
            -- 淡入
            if self.isFadeIn then
                local frame = 0
                local curValue = 0
                local interval = self.audioSource.volume / 30
                self.audioSource.volume = 0
                -- 30帧结束
                self.onUpdate = function(t)
                    if frame > 30 then
                        t.onUpdate = nil
                    end
                    frame = frame + 1
                    curValue = curValue + interval
                    t.audioSource.volume = curValue
                end
            end
            self.audioSource:Play()
        end,
        -- 停止
        Stop = function(self)
            self.onUpdate = nil
            -- 淡出
            if self.isFadeIn then
                local frame = 0
                local curValue = self.audioSource.volume
                local interval = curValue / 30
                -- 30帧结束
                self.onUpdate = function(t)
                    if frame > 30 then
                        t.onUpdate = nil
                        t.theFollow = nil
                        t.audioSource:Stop()
                        -- 卸载掉资源
                        CSharp.ResourceMgr.UnloadAb(t.audioPath)
                    end
                    frame = frame + 1
                    curValue = curValue - interval
                    t.audioSource.volume = curValue
                end
            else
                self.theFollow = nil
                self.audioSource:Stop()
                -- 卸载掉资源
                CSharp.ResourceMgr.UnloadAb(self.audioPath)
            end
            self.nextAuidoGroupId = nil
        end,
        -- 暂停
        Pause = function(self)
            self.onUpdate = nil
            self.audioSource:Pause()
        end,
        -- 恢复
        UnPause = function(self)
            self.onUpdate = nil
            self.audioSource:UnPause()
        end,
        -- 方法
        Update = function(self)
            -- 淡入淡出
            if nil ~= self.onUpdate then
                self:onUpdate()
            end

            -- 连续播放的处理
            if nil ~= self.nextAuidoGroupId and not self.audioSource.isPlaying then
                AudioManager.PlaySound(self.nextAuidoGroupId, nil, AudioStat.Play, self.theFollow)
                self.nextAuidoGroupId = nil
            end

            -- 3d音源的跟随处理
            if not self.is3d or unityTargetIsNil(self.theFollow) then
                return
            end
            if not self.theFollow.gameObject.activeSelf then
                self.theFollow = nil
            end
            if unityTargetIsNil(self.theFollow) then
                return
            end
            if self.audioSource.isPlaying then
                self.theSelf.transform.position = self.theFollow.position
            end
        end
    }
    return t
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- 分割线 -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 音源状态
AudioStat = {
    Play = 1,
    Pause = 2,
    UnPause = 3,
    Stop = 4
}

-- 音源管理
AudioManager = {}

-- 配置
local audioConfig = LuaHandle.load("Config.AudioConfig")
local audioGroupConfig = LuaHandle.load("Config.AudioGroupConfig")

-- 音源路径前缀
local audioPathPrefix = "Audio/"
-- 场景的组名称(有几个特殊的组，需要注意，比如Scene,BgUI等)
local sceneGroupName = "Scene"
-- 系统背景音组名称
local bgUIGroupName = "BgUI"

-- 根对象
local audioRoot = nil
-- 音源实例化Id
local audioInsId = 0

-- 空闲音源
local idleAudio = nil
-- 各种音源
local musicAudio = nil
local effectAudio = nil
local groupAuido = nil

-- 音源音量值
local musicVolume = nil
local effectVolume = nil

-- 音量混合器
local audioMixer = nil
-- 音源监听对象
local curAudioListerner = nil
local defaultAudioListener = nil

-- 获取空闲音源
local function getIdleAudioSource(followTarget)
    local asData = nil
    local is3d = not unityTargetIsNil(followTarget) or false

    -- 从空闲音源里获取
    if nil ~= idleAudio then
        for k, v in pairs(idleAudio) do
            if v.is3d == is3d and v:IsIdle() then
                asData = v
                idleAudio[k] = nil
                break
            end
        end
    end

    -- 重新生成
    if nil == asData then
        asData = AudioSourceInfo()
        if is3d then
            asData.theSelf = CSharp.GameObject("3dSound")
            asData.audioSource = asData.theSelf:AddComponent(typeof(CSharp.AudioSource))
            asData.audioSource.spatialBlend = 1
            asData.audioSource.rolloffMode = CSharp.AudioRolloffMode.Linear
            asData.theSelf.transform.parent = audioRoot.transform
        else
            asData.theSelf = audioRoot
            asData.audioSource = asData.theSelf:AddComponent(typeof(CSharp.AudioSource))
            asData.audioSource.spatialBlend = 0
        end
        asData.is3d = is3d
    end

    audioInsId = audioInsId + 1
    asData.insId = audioInsId
    asData.isFadeIn = false
    asData.theFollow = followTarget
    asData.audioSource.playOnAwake = false

    return asData
end

-- 置音源状态
local function doAuidoState(asData, state)
    if nil == asData then
        return
    end

    if state == AudioStat.Play then
        asData:Play()
    elseif state == AudioStat.Stop then
        asData:Stop()
    elseif state == AudioStat.Pause then
        asData:Pause()
    elseif state == AudioStat.UnPause then
        asData:UnPause()
    end
end

-- 置音源设置
local function doAudioGroup(asData, clip, state, groupMutex)
    if nil == clip then
        return
    end
    if nil == asData.groupName or "" == asData.groupName or unityTargetIsNil(audioMixer) then
        return
    end
    asData.audioSource.clip = clip

    -- 组音频保存
    if nil == groupAuido[asData.groupName] then
        groupAuido[asData.groupName] = {}
    end

    -- 是否同组互斥
    if groupMutex and nil ~= groupAuido[asData.groupName] then
        for k, v in pairs(groupAuido[asData.groupName]) do
            v:Stop()
        end
    end
    groupAuido[asData.groupName][asData.insId] = asData

    -- 设置组
    local groups = audioMixer:FindMatchingGroups(asData.groupName)
    if groups.Length > 0 then
        asData.audioSource.outputAudioMixerGroup = groups[0]
    end

    -- 置音源状态
    doAuidoState(asData, state)
end

-- 设置监听者
local function setAudioListener(listener)
    if not unityTargetIsNil(curAudioListerner) then
        curAudioListerner.enabled = false
    end

    local curListener = nil
    if unityTargetIsNil(listener) then
        curListener = defaultAudioListener
    else
        curListener = listener
    end

    curAudioListerner = curListener
    if curAudioListerner ~= nil then
        curAudioListerner.enabled = true
    end
end

-- 设置音源音量
local function setAudioVolume(volume, isEffect)
    if isEffect then
        CSharp.Stage.inst.soundVolume = volume

        for k, v in pairs(effectAudio) do
            v.audioSource.volume = v.defaultVolume * volume
        end
    else
        for k, v in pairs(musicAudio) do
            v.audioSource.volume = v.defaultVolume * volume
        end
    end
end

-- 当场景退出
local function onSceneExit()
    AudioManager.PlayGroupSound(bgUIGroupName, AudioStat.Stop)
    AudioManager.PlayGroupSound(sceneGroupName, AudioStat.Stop)
    setAudioListener(nil)
end

-- 当场景进入
local function onSceneEnter()
    local target = CSharp.Camera.main
    if nil ~= target then
        target = target.gameObject
    end

    -- 新的音源监听对象
    if unityTargetIsNil(target) then
        setAudioListener(nil)
        return
    end
    local listener = target:GetComponent(typeof(CSharp.AudioListener))
    if unityTargetIsNil(listener) then
        listener = target:AddComponent(typeof(CSharp.AudioListener))
    end
    setAudioListener(listener)
end

-- 获取声效开关
function AudioManager.GetSwitchAudioEffect()
    return LocalData.getAudioEffectSwitch()
end

-- 获取音乐开关
function AudioManager.GetSwitchAudioMusic()
    return LocalData.getAudioMusicSwitch()
end

-- 全局声效
function AudioManager.GetAudioEffectVolume()
    return LocalData.getAudioEffectVolume()
end

-- 全局音乐
function AudioManager.GetAudioMusicVolume()
    return LocalData.getAudioMusicVolume()
end

-- 全局声效开关
function AudioManager.SwitchAudioEffect(on)
    audioEffectSwitch = on
    LocalData.saveAudioEffectSwitch(on)
    setAudioVolume(audioEffectSwitch * effectVolume, true)
end

-- 全局音乐开关
function AudioManager.SwitchAudioMusic(on)
    audioMusicSwitch = on
    LocalData.saveAudioMusicSwitch(on)
    setAudioVolume(audioMusicSwitch * musicVolume, false)
end

-- 全局声效
function AudioManager.SetAudioEffectVolume(volume, save)
    if nil == save or save then
        LocalData.saveAudioEffectVolume(volume)
    end

    effectVolume = volume
    setAudioVolume(audioEffectSwitch * effectVolume, true)
end

-- 全局音乐
function AudioManager.SetAudioMusicVolume(volume, save)
    if nil == save or save then
        LocalData.saveAudioMusicVolume(volume)
    end

    musicVolume = volume
    setAudioVolume(audioMusicSwitch * musicVolume, false)
end

-- 播放组audio
function AudioManager.PlayGroupSound(groupName, state)
    if nil == groupAuido then
        return
    end
    if nil == groupName then
        return
    end
    if nil == groupAuido[groupName] then
        return
    end

    for k, v in pairs(groupAuido[groupName]) do
        doAuidoState(v, state)
    end
end

-- 播放audio
function AudioManager.PlaySound(id, insId, state, followTarget)
    local asData = nil

    -- 实例化Id不为空
    if nil ~= insId then
        if nil ~= musicAudio then
            asData = musicAudio[insId]
        end
        if nil == asData and nil ~= effectAudio then
            asData = effectAudio[insId]
        end
        if nil == id and nil ~= asData then
            doAuidoState(asData, state)
            return asData.insId
        end
        if nil ~= id and nil ~= asData then
            if id == asData.configId then
                doAuidoState(asData, state)
                return asData.insId
            else
                doAuidoState(asData, AudioStat.Stop)
            end
        end
    end

    -- 配置id为空
    if nil == id then
        return nil
    end

    local audioGroupConfig = audioGroupConfig[id]
    -- 音源组
    if nil == audioGroupConfig or #audioGroupConfig <= 0 then
        print("group key is nil " .. id)
        return nil
    end

    -- 随机种子
    if #audioGroupConfig > 1 then
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    end
    -- 随机音源
    local audioConfig = audioConfig[audioGroupConfig[math.random(1, #audioGroupConfig)]]
    -- 无效配置
    if nil == audioConfig then
        return nil
    end

    asData = getIdleAudioSource(followTarget)
    asData.configId = id
    asData.groupName = audioConfig.groupName
    asData.defaultVolume = audioConfig.defaultVolume
    asData.isFadeIn = audioConfig.isFadeIn
    asData.nextAuidoGroupId = audioConfig.nextAuidoGroupId
    asData.audioPath = audioPathPrefix .. audioConfig.name
    asData.audioSource.loop = audioConfig.isLoop
    asData.audioSource.minDistance = audioConfig.minDistance
    asData.audioSource.maxDistance = audioConfig.maxDistance

    if audioConfig.isBg then
        musicAudio[asData.insId] = asData
        asData.audioSource.volume = asData.defaultVolume * audioMusicSwitch * musicVolume
    else
        effectAudio[asData.insId] = asData
        asData.audioSource.volume = asData.defaultVolume * audioEffectSwitch * effectVolume
    end

    CSharp.ResourceMgr.AsyncLoad(
        asData.audioPath,
        audioConfig.name,
        typeof(CSharp.AudioClip),
        function(clip)
            doAudioGroup(asData, clip, state, audioConfig.groupMutex)
        end
    )

    return asData.insId
end

function AudioManager.initialize()
    if nil ~= audioRoot then
        return
    end

    audioRoot = CSharp.GameObject("AudioRoot")
    CSharp.UObject.DontDestroyOnLoad(audioRoot)

    -- 当前用的音源监听对象
    curAudioListerner = CSharp.GameObject.FindObjectOfType(typeof(CSharp.AudioListener))
    if nil == defaultAudioListener then
        defaultAudioListener = audioRoot:AddComponent(typeof(CSharp.AudioListener))
    end

    -- 事件监听
    if nil ~= Event then
        Event.addListener(Event.EXIT_SCENCE, onSceneExit)
        Event.addListener(Event.ENTER_SCENCE, onSceneEnter)
    end

    audioMixer = CSharp.ResourceMgr.Load("Audio/AudioMixer", "AudioMixer", typeof(CSharp.AudioMixer))
    setAudioListener(nil)

    audioInsId = 100
    groupAuido = {}
    idleAudio = {}
    musicAudio = {}
    effectAudio = {}
    audioMusicSwitch = AudioManager.GetSwitchAudioMusic()
    audioEffectSwitch = AudioManager.GetSwitchAudioEffect()

    -- 设置全局音量
    AudioManager.SetAudioEffectVolume(AudioManager.GetAudioEffectVolume())
    AudioManager.SetAudioMusicVolume(AudioManager.GetAudioMusicVolume())
end

function AudioManager.update()
    if nil ~= musicAudio then
        for k, v in pairs(musicAudio) do
            v:Update()

            -- 判断是否处于空闲状态
            if v:IsIdle() and nil ~= v.insId and nil ~= groupAuido[v.groupName] then
                musicAudio[v.insId] = nil
                groupAuido[v.groupName][v.insId] = nil
                table.insert(idleAudio, v)
            end
        end
    end
    if nil ~= effectAudio then
        for k, v in pairs(effectAudio) do
            v:Update()

            -- 判断是否处于空闲状态
            if v:IsIdle() and nil ~= v.insId and nil ~= groupAuido[v.groupName] then
                effectAudio[v.insId] = nil
                groupAuido[v.groupName][v.insId] = nil
                table.insert(idleAudio, v)
            end
        end
    end
end

function AudioManager.onDestory()
    CSharp.UObject.Destroy(audioRoot)
    audioRoot = nil
    audioInsId = 0
    idleAudio = nil
    musicAudio = nil
    effectAudio = nil
    groupAuido = nil
    musicVolume = nil
    effectVolume = nil
    audioMixer = nil
    curAudioListerner = nil
    defaultAudioListener = nil
end
