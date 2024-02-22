
-- 数据格式处理 包括链接SDK和设备层业务层 收集相关信息


-- 获取公有属性
---@class EventTraceDataHandler
local EventTraceDataHandler = {}

-- 当前事件发生时候客户端时间   格式 YYYY-MM-DD HH:MM:SS:MS
local function __getClientdtEventTime()
    -- 获取当前的本地时间
    local now = CS.System.DateTime.Now

    local function __formatDateTime(year, month, day, hour, minute, second, millisecond)
        return string.format("%04d-%02d-%02d %02d:%02d:%02d:%03d",
                year, month, day, hour, minute, second, millisecond)
    end

    return __formatDateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second, now.Millisecond)
end

-- 当前事件客户端UTC毫秒粒度的时间戳
local function __getClientEventTimeStamp()
    -- 获取当前UTC时间戳
    local utc_time_stamp = os.time()

    -- 将UTC时间戳转换为毫秒
    local luaTimestamp = utc_time_stamp * 1000
    
    local utcNowMillisecond = CS.System.DateTime.UtcNow.Millisecond
    return luaTimestamp + utcNowMillisecond
end

-- 游戏客户端版本(APP内核版本，需要冷更方式更新)
local function __getClientVersion()
    local clientVersion, _ = AppInfoMgr.GetAppVersionAndBuildNum()
    return clientVersion
end

-- 平台openid，平台登录后才能获得该字段，后续所有事件一定要上报
local function __getVOpenID()
    return SDKMgr.GetNid() or 0
end

-- 游戏角色ID，角色登录之后获得该字段，之后事件都要报
local function __getVRoleID()
    if SelfProxyFactory and SelfProxyFactory.GetPlayerInfoProxy() and SelfProxyFactory.GetPlayerInfoProxy().uid then
        return SelfProxyFactory.GetPlayerInfoProxy().uid
    end
    return 0
end

-- 获取当前uiVIew栈 popup和window类型
---@return table<number, string>
local function __getCurViewTagList()
    local viewList = {}
    local viewTagList = UIMgr.GetViewTagList(true)
    local retViewTag = nil
    for i = 0, viewTagList.Count - 1 do
        local viewTag = viewTagList[i]
        local viewInfo = CS.X3Game.UIViewUtility.GetViewInfo(viewTag)
        local viewType = tostring(viewInfo.ViewType)
        if string.startswith(viewType, "UIPopup") or string.startswith(viewType, "UIWindow") then
            table.insert(viewList, viewTag)
        end
    end
    return viewList
end

-- 当前事件发生的所在页面id (目前不上报)
local function __getCurrentPageId()
    return ""
    --local curViewTagList = __getCurViewTagList() or {}
    --return curViewTagList[1] or ""
end

-- 当前页面从哪个页面进入的父页面ID (目前不上报)
local function __getReferPageId()
    return ""
    --local curViewTagList = __getCurViewTagList() or {}
    --return curViewTagList[2] or ""
end

-- 设备 IP：客户端公网的IP
local function __getClientIp()
    
end

-- 当前上报事件唯一标识，全局唯一。同一个事件因各种原因多次上报n次（比如网络问题导致重复上报），则n条记录的requestID完全不同
local function __generateUUID()
    local csGuid = CS.System.Guid
    local randomGuid = csGuid.NewGuid():ToString()
    return tostring(randomGuid)
end

-- 获取公有事件属性列表
---@param self EventTraceDataHandler
---@param eventId number
local function __generatePublicProperties(self, eventId)
    --local deviceInfo = SDKMgr.GetDeviceInfo()
    local deviceInfo = SDKMgr.GetRawDeviceInfo()

    local params = {
        seqID = EventTraceMgr:GetSeqId(),
        
        -- 当前事件发生时客户端时间 格式 YYYY-MM-DD HH:MM:SS:MS
        ClientdtEventTime = __getClientdtEventTime(),

        -- 当前事件客户端UTC毫秒粒度的时间戳
        ClienteventTimeStamp = __getClientEventTimeStamp(),
        
        -- 当前上报事件唯一标识，全局唯一。同一个事件因各种原因多次上报n次（比如网络问题导致重复上报），则n条记录的requestID完全不同
        uuid = __generateUUID(),

        -- 游戏 clientid
        vGameAppid = deviceInfo.vGameAppId,

        -- APP包名
        packageName = deviceInfo.packageName,

        -- 渠道ID
        platID = deviceInfo.platId,

        -- 分包渠道ID
        subPlatID = deviceInfo.subPlatId,

        -- 广告渠道ID
        adPlatID = deviceInfo.adplatId,
        
        -- 游戏客户端版本(APP内核版本，需要冷更方式更新)
        clientVersion = __getClientVersion(),

        -- 平台openid，平台登录后才能获得该字段，后续所有事件一定要上报
        vopenID = __getVOpenID(),

        -- 游戏角色ID，角色登录之后获得该字段，之后事件都要报
        vRoleID = __getVRoleID(),
        
        -- 平台SDK版本
        sdkVersion = deviceInfo.sdkVersion,

        -- 手机电话卡（SIM）运营商
        telecomOper = deviceInfo.phoneCompanies,

        -- 像素密度（移动端独有）
        density = deviceInfo.density,

        -- 终端操作系统类型
        systemType = deviceInfo.systemType,

        -- 终端机型品牌型号
        systemDeviceType = deviceInfo.systemDeviceType,

        -- xx安卓设备制造商系统的版本
        osVersion = deviceInfo.osVersion,

        -- 设备MAC地址
        macAddress = deviceInfo.macAddress,

        -- deviceId;获取规则：IOS上报IDFA,获取不到则上报IDFV（CUID）。安卓上报OAID,获取不到上报AndroidID,还获取不到上报paperdevice设备串
        deviceID = deviceInfo.eventValue3,

        -- appsflyerID
        afID = deviceInfo.eventValue4,

        -- firebaseID
        firebaseID = deviceInfo.eventValue5,

        -- iOS 上报IDFA（移动端独有）
        IDFA = deviceInfo.idfa,

        -- iOS 上报当前激活时的IDFV
        IDFV = deviceInfo.idfv,

        -- 安卓oaid（移动端独有）
        oaid = deviceInfo.oaid,

        -- AndroId Id（移动端独有）
        androidID = deviceInfo.deviceId,

        -- 安卓gaid（移动端独有）
        gaid = deviceInfo.gaid,

        -- wifi信号强度
        wifiRssi = deviceInfo.wifiRssi,

        -- 移动信号强度
        signalLevel = deviceInfo.signalLevel,

        -- 网络状态,0-弱网,1-正常
        networkStatus = deviceInfo.networkStatus,

        -- 是否使用代理IP,0-未使用,1-使用
        proxy = deviceInfo.proxy,

        -- 设备总存储
        allDisk = deviceInfo.allDisk,

        -- 设备剩余存储
        residueDisk = deviceInfo.residueDisk,

        -- 客户端local dns
        ldns = deviceInfo.ldns,

        -- gpu信息
        gpuModel = deviceInfo.gpuModel,

        -- 显示屏宽度
        screenWidth = deviceInfo.screenWidth,

        -- 显示屏高度
        screenHeight = deviceInfo.screenHeight,

        -- cpu型号
        cpuModel = deviceInfo.cpuModel,

        -- cpu核数
        cpuCore = deviceInfo.cpuCore,

        -- cpu主频
        cpuFreq = deviceInfo.cpuFreq,

        -- 当前App占用内存
        appMemory = deviceInfo.appMemory,

        -- 手机总内存
        allMemory = deviceInfo.allMemory,

        -- 网络制式
        xg = deviceInfo.xg,

        -- 判断是否是模拟器，true表示是，Android特有，sdk版本1.9.2新增
        isEmulator = deviceInfo.isEmulator,
        
        -- 当前前台会话的唯一键，退出前台之后返回该值变化。（如果激活后一直没有退后台，可以用这个sessionID找到对应的一次前台会话的激活事件）
        activityID = deviceInfo.activityId,
        
        -- 当前进程的唯一键，退后台不变，只有杀掉退出重启才会变，可以用这个ID一直找到当前进程的激活事件
        sessionID = deviceInfo.sessionId,
        
        -- 激活事件标识的唯一键
        RequestID = deviceInfo.requestId,
        
        -- 设备时区
        timeZone = deviceInfo.timeZone,
        
        -- 设备 IP：客户端本地的IPv4
        ip = deviceInfo.ip,
        
        -- 设备 IP：客户端本地的IPv6
        ipv6 = deviceInfo.ipv6,
        
        -- iOS上报设备短号；安卓上报序列号
        systemMachine = deviceInfo.systemMachine,
        
        -- 浏览器UA
        userAgent = deviceInfo.userAgent,
        
        -- 设备默认语种
        systemLang = deviceInfo.systemLang,
        
        -- caid(占坑) 
        caid = "",
        
        -- 安卓独有，SDK自己生成的设备ID
        paperDevice = deviceInfo.paperDevice,
        
        -- 当前事件发生的所在页面id
        CurrentPageId = __getCurrentPageId(),
        
        -- 当前页面从哪个页面进入的父页面ID
        ReferPageId = __getReferPageId(),
        
        -- 当前移动终端操作系统版本号，eg：10
        SystemSoftware = deviceInfo.systemSoftware,
        
        -- WIFI/5G/4G/3G/2G；无网络时传空
        Network = deviceInfo.network,
        
        ---- 设备 IP：客户端公网的IP (这个不要了)
        --ClientIP = __getClientIp(),
    }
    
    -- 配置检查 默认值填充
    for idx, cfg in pairs(EventTraceEnum.PublicPropertiesCfg) do
        if (nil == params[cfg.name]) and (cfg.isNecessary) then
            if cfg.type == "number" then
                params[cfg.name] = 0
            elseif cfg.type == "string" then
                params[cfg.name] = ""
            end
        end
    end
    
    return params
end
EventTraceDataHandler.GeneratePublicProperties = __generatePublicProperties

-- 事件对应的私有属性参数
---@param self EventTraceDataHandler
---@param eventId number
---@param privateParams table 带进来的参数
local function __generatePrivateProperties(self, eventId, privateParams)
    local params = {}
    
    if not table.isnilorempty(privateParams) then
        for key, val in pairs(privateParams) do
            params[key] = val
        end
    end

    -- 配置检查 默认值填充
    local eventCfg = EventTraceEnum.EventCfg[eventId]
    local privateProperties = eventCfg.privateProperties or {}
    for idx, cfg in pairs(privateProperties) do
        if (nil == params[cfg.name]) and (cfg.isNecessary) then
            if cfg.type == "number" then
                params[cfg.name] = 0
            elseif cfg.type == "string" then
                params[cfg.name] = ""
            end
        end
    end
    
    return params
end
EventTraceDataHandler.GeneratePrivateProperties = __generatePrivateProperties

return EventTraceDataHandler


