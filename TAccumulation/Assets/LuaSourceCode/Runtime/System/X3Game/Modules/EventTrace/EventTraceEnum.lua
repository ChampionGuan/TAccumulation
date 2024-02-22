
-- 数据埋点功能相关定义及配置

---@class EventTraceEnum
local EventTraceEnum = {}

---@class EventTraceEnum.EventType 所有打点事件枚举类型定义
EventTraceEnum.EventType = {

    --region [稳定性及性能分析 游戏进程生命周期相关] 事件枚举类型定义 ------------------------------------------------------
    GetSDKInit = 1,                                            -- 游戏请求SDK初始化事件
    ConnectCMS = 2,                                            -- 连接CMS事件
    CheckForceUpdate = 3,                                      -- 检查强更版本事件
    StartForceUpdate = 4,                                      -- 开始强制更事件
    CheckOptionalUpdate = 5,                                   -- 检查非强更版本事件
    StartOptionalUpdate = 6,                                   -- 开始非强更版本事件
    FinishOptionalUpdate = 7,                                  -- 结束非强更版本事件
    StartResourceCheck = 8,                                    -- 资源校验开始事件
    ResourceCheckResult = 9,                                   -- 资源校验结果事件
    ResourcePackageUnzip = 10,                                 -- 资源包解压开始事件
    ResourcePackageUnzipResult = 11,                           -- 资源包解压结果事件
    SwitchBackground = 12,                                     -- 前台切换后台事件
    SwitchFrontdesk = 13,                                      -- 后台切换前台事件
    EnterAccountLoginPage = 14,                                -- 进入账号登录页事件
    EnterAccountRegisterPage = 15,                             -- 进入账号注册页事件
    PlatAccountLogin = 16,                                     -- 游戏客户端发起平台登录请求事件
    PlatAccountRegister = 17,                                  -- 游戏客户端发起平台注册请求事件
    ShowAuthorizePopUp = 18,                                   -- 用户授权弹窗弹出事件
    AuthorizeResult = 19,                                      -- 用户授权结果事件
    ServerAuthentication = 20,                                 -- 鉴权事件
    EnterGamezoneSelectPage = 21,                              -- 进入区服选择页面事件
    GamezoneSelceted = 22,                                     -- 选择区服事件
    EnterGame = 23,                                            -- 进入游戏按钮点击事件
    Enterlobby = 24,                                           -- 登录后进入游戏大厅事件
    StartShaderWarmup = 25,                                    -- Shader预热开始
    EndShaderWarmup = 26,                                      -- Shader预热结束
    CallPlatLoginPage = 27,                                    -- 客户端请求sdk唤起平台登录页面时候上报告
    -- ...
    --endregion --------------------------------------------------------------------------------------------------------
    
    -- 其他页签类型 (比如业务事件) 这里要有个分类, 其他类型就不重新创建一个Table了 但Id要有所区分
    PlayMiaoCard = 1001,                                       -- 类似这样 从1001开始, 留有个ID段的概念
    
}

---@class EventTraceEnum.EventStatus 事件状态
EventTraceEnum.EventStatus = {
    Success = 0,                -- 成功 默认值
    Fail = 1,                   -- 失败
}

---@class EventTraceEnum.EventCfg  属性配置
EventTraceEnum.EventCfg = {
    --region [稳定性及性能分析 游戏进程生命周期相关] ----------------------------------------------------------------------
    -- 游戏请求SDK初始化事件
    [EventTraceEnum.EventType.GetSDKInit] = {
        eventId = 1,                                                            -- 事件序号
        eventName = "GetSDKInit",                                               -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 连接CMS事件
    [EventTraceEnum.EventType.ConnectCMS] = {
        eventId = 2,                                                            -- 事件序号
        eventName = "ConnectCMS",                                               -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 获取服务器列表事件
    [EventTraceEnum.EventType.CheckForceUpdate] = {
        eventId = 3,                                                            -- 事件序号
        eventName = "CheckForceUpdate",                                         -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 选择服务器事件
    [EventTraceEnum.EventType.StartForceUpdate] = {
        eventId = 4,                                                            -- 事件序号
        eventName = "StartForceUpdate",                                         -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 登录游戏事件
    [EventTraceEnum.EventType.CheckOptionalUpdate] = {
        eventId = 5,                                                            -- 事件序号
        eventName = "CheckOptionalUpdate",                                      -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 开始非强更版本事件
    [EventTraceEnum.EventType.StartOptionalUpdate] = {
        eventId = 6,                                                            -- 事件序号
        eventName = "StartOptionalUpdate",                                      -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            -- 游戏资源版本
            [1] = {
                name = "ResourceVersion",                                               -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 本次非强更客户端版本
            [2] = {
                name = "NewClientVersion",                                              -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 本次非强更游戏资源版本
            [3] = {
                name = "NewResourceVersion",                                            -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 更新包大小，保留2位小数
            [4] = {
                name = "UpdateSize",                                                    -- 字段名
                type = "number",                                                         -- 数据类型
            },
            -- 单位：MB
            [5] = {
                name = "Unit",                                                          -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 0:分包资源    1: 热更（非强更）资源
            [6] = {
                name = "UpdateType",
                type = "number",
            }
        },
    },
    -- 结束非强更版本事件
    [EventTraceEnum.EventType.FinishOptionalUpdate] = {
        eventId = 7,                                                            -- 事件序号
        eventName = "FinishOptionalUpdate",                                     -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            -- 游戏资源版本
            [1] = {
                name = "ResourceVersion",                                               -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 本次非强更客户端版本
            [2] = {
                name = "NewClientVersion",                                              -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 本次非强更游戏资源版本
            [3] = {
                name = "NewResourceVersion",                                            -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 更新包大小，保留2位小数
            [4] = {
                name = "UpdateSize",                                                    -- 字段名
                type = "number",                                                         -- 数据类型
            },
            -- 单位：MB
            [5] = {
                name = "Unit",                                                          -- 字段名
                type = "string",                                                       -- 数据类型
            },
            -- 0:分包资源    1: 热更（非强更）资源
            [6] = {
                name = "UpdateType",
                type = "number",
            },
            -- 热更整体时长，单位（秒），保留2位小数
            [7] = {
                name = "UpdatetimeCost",
                type = "number",
            },
            -- Status不为0 （即非正常结束更新）时候上报，记录已更新的下载包大小，保留2为小数
            [8] = {
                name = "ComepleteSize",
                type = "number",
            }
        },
    },
    -- 资源校验开始事件
    [EventTraceEnum.EventType.StartResourceCheck] = {
        eventId = 8,                                                            -- 事件序号
        eventName = "StartResourceCheck",                                       -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 资源校验结果事件
    [EventTraceEnum.EventType.ResourceCheckResult] = {
        eventId = 9,                                                            -- 事件序号
        eventName = "ResourceCheckResult",                                      -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 资源包解压开始事件
    [EventTraceEnum.EventType.ResourcePackageUnzip] = {
        eventId = 10,                                                           -- 事件序号
        eventName = "ResourcePackageUnzip",                                     -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 资源包解压结果事件
    [EventTraceEnum.EventType.ResourcePackageUnzipResult] = {
        eventId = 11,                                                           -- 事件序号
        eventName = "ResourcePackageUnzipResult",                               -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 前台切换后台事件
    [EventTraceEnum.EventType.SwitchBackground] = {
        eventId = 12,                                                           -- 事件序号
        eventName = "SwitchBackground",                                         -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 后台切换前台事件
    [EventTraceEnum.EventType.SwitchFrontdesk] = {
        eventId = 13,                                                           -- 事件序号
        eventName = "SwitchFrontdesk",                                          -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 进入账号登录页事件
    [EventTraceEnum.EventType.EnterAccountLoginPage] = {
        eventId = 14,                                                           -- 事件序号
        eventName = "EnterAccountLoginPage",                                    -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 进入账号注册页事件
    [EventTraceEnum.EventType.EnterAccountRegisterPage] = {
        eventId = 15,                                                           -- 事件序号
        eventName = "EnterAccountRegisterPage",                                 -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 游戏客户端发起平台登录请求事件
    [EventTraceEnum.EventType.PlatAccountLogin] = {
        eventId = 16,                                                           -- 事件序号
        eventName = "PlatAccountLogin",                                         -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 游戏客户端发起平台注册请求事件
    [EventTraceEnum.EventType.PlatAccountRegister] = {
        eventId = 17,                                                           -- 事件序号
        eventName = "PlatAccountRegister",                                      -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 用户授权弹窗弹出事件
    [EventTraceEnum.EventType.ShowAuthorizePopUp] = {
        eventId = 18,                                                           -- 事件序号
        eventName = "ShowAuthorizePopUp",                                       -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 用户授权结果事件
    [EventTraceEnum.EventType.AuthorizeResult] = {
        eventId = 19,                                                           -- 事件序号
        eventName = "AuthorizeResult",                                          -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            [1] = {
                name = "AuthorizationResult",                                      -- 字段名
                type = "number",                                                        -- 数据类型
            },
        },
    },
    -- 鉴权事件
    [EventTraceEnum.EventType.ServerAuthentication] = {
        eventId = 20,                                                           -- 事件序号
        eventName = "ServerAuthentication",                                     -- 埋点事件名称
        privateParams = {},                                                     -- 事件上报私有字段
    },
    -- 进入区服选择页面事件
    [EventTraceEnum.EventType.EnterGamezoneSelectPage] = {
        eventId = 21,                                                           -- 事件序号
        eventName = "EnterGamezoneSelectPage",                                  -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            [1] = {
                name = "IZoneAreaID",                                              -- 字段名
                type = "number",                                                        -- 数据类型
            },
        },
    },
    -- 选择区服事件
    [EventTraceEnum.EventType.GamezoneSelceted] = {
        eventId = 22,                                                           -- 事件序号
        eventName = "GamezoneSelceted",                                         -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            [1] = {
                name = "IZoneAreaID",                                              -- 字段名
                type = "number",                                                        -- 数据类型
            },
        },
    },
    -- 进入游戏按钮点击事件
    [EventTraceEnum.EventType.EnterGame] = {
        eventId = 23,                                                           -- 事件序号
        eventName = "EnterGame",                                                -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            [1] = {
                name = "IZoneAreaID",                                              -- 字段名
                type = "number",                                                        -- 数据类型
            },
        },
    },
    -- 登录后进入游戏大厅事件
    [EventTraceEnum.EventType.Enterlobby] = {
        eventId = 24,                                                           -- 事件序号
        eventName = "Enterlobby",                                               -- 埋点事件名称
        privateParams = {                                                       -- 事件上报私有字段
            [1] = {
                name = "IZoneAreaID",                                              -- 字段名
                type = "number",                                                        -- 数据类型
            },
        },
    },
    -- Shader预热开始
    [EventTraceEnum.EventType.StartShaderWarmup] = {
        eventId = 25,                                                           -- 事件序号
        eventName = "StartShaderWarmup",                                        -- 埋点事件名称
        privateParams = {},
    },
    -- Shader预热结束
    [EventTraceEnum.EventType.EndShaderWarmup] = {
        eventId = 26,                                                           -- 事件序号
        eventName = "EndShaderWarmup",                                          -- 埋点事件名称
        privateParams = {},
    },
    -- 客户端请求sdk唤起平台登录页面时候上报告
    [EventTraceEnum.EventType.CallPlatLoginPage] = {
        eventId = 27,                                                           -- 事件序号
        eventName = "CallPlatLoginPage",                                        -- 埋点事件名称
        privateParams = {},
    },

    --endregion --------------------------------------------------------------------------------------------------------

    
}

---@class EventTraceEnum.PublicPropertiesCfg 公有属性配置
EventTraceEnum.PublicPropertiesCfg = {
    --  操作序列，用于标识同session内发生的顺序
    [1] = { name = "seqID", type = "number", isNecessary = true},
    -- 当前事件发生时候客户端时间 格式 YYYY-MM-DD HH:MM:SS:MS
    [2] = { name = "ClientdtEventTime", type = "string", isNecessary = true},
    -- 当前事件客户端UTC毫秒粒度的时间戳
    [3] = { name = "ClienteventTimeStamp", type = "number", isNecessary = true},
    -- 游戏 clientid
    [4] = { name = "vGameAppid", type = "string", isNecessary = true},
    -- 0：成功；1：失败
    [5] = { name = "Status", type = "number", isNecessary = true},
    -- status为1时候获取服务端返回的错误码
    [6] = { name = "ErrorCode", type = "number", isNecessary = false},
    -- status为1时候获取服务端返回的错误详情。配合Errorcode进行问题分析场景使用
    [7] = { name = "ErrorReason", type = "string", isNecessary = false},
    -- APP包名
    [8] = { name = "packageName", type = "string", isNecessary = true},
    -- 渠道ID
    [9] = { name = "platID", type = "number", isNecessary = true},
    -- 分包渠道ID
    [10] = { name = "subPlatID", type = "number", isNecessary = true},
    -- 广告渠道ID
    [11] = { name = "adPlatID", type = "string", isNecessary = true},
    -- 游戏客户端版本(APP内核版本，需要冷更方式更新)
    [12] = { name = "clientVersion", type = "string", isNecessary = true},
    -- 平台openid，平台登录后才能获得该字段，后续所有事件一定要上报
    [13] = { name = "vopenID", type = "string", isNecessary = true},
    -- 游戏角色ID，角色登录之后获得该字段，之后事件都要报
    [14] = { name = "vRoleID", type = "string", isNecessary = true},
    -- 平台SDK版本
    [15] = { name = "sdkVersion", type = "string", isNecessary = true},
    -- 手机电话卡（SIM）运营商
    [16] = { name = "telecomOper", type = "string", isNecessary = true},
    -- 像素密度（移动端独有）
    [17] = { name = "density", type = "number", isNecessary = true},
    -- 终端操作系统类型
    [18] = { name = "systemType", type = "string", isNecessary = true},
    -- 终端机型品牌型号
    [19] = { name = "systemDeviceType", type = "string", isNecessary = true},
    -- 安卓设备厂商系统的版本
    [20] = { name = "osVersion", type = "string", isNecessary = true},
    -- 设备MAC地址
    [21] = { name = "macAddress", type = "string", isNecessary = true},
    -- deviceId;获取规则：IOS上报IDFA,获取不到则上报IDFV（CUID）。安卓上报OAID,获取不到上报AndroidID,还获取不到上报paperdevice设备串
    [22] = { name = "deviceID", type = "string", isNecessary = true},
    -- appsflyerID
    [23] = { name = "afID", type = "string", isNecessary = true},
    -- firebaseID
    [24] = { name = "firebaseID", type = "string", isNecessary = true},
    -- iOS 上报IDFA（移动端独有）
    [25] = { name = "IDFA", type = "string", isNecessary = true},
    -- iOS 上报当前激活时的IDFV
    [26] = { name = "IDFV", type = "string", isNecessary = true},
    -- 安卓oaid（移动端独有）
    [27] = { name = "oaid", type = "string", isNecessary = true},
    -- AndroId Id（移动端独有）
    [28] = { name = "androidID", type = "string", isNecessary = true},
    -- 安卓gaid（移动端独有）
    [29] = { name = "gaid", type = "string", isNecessary = true},
    -- wifi信号强度
    [30] = { name = "wifiRssi", type = "number", isNecessary = true},
    -- 移动信号强度
    [31] = { name = "signalLevel", type = "number", isNecessary = true},
    -- 网络状态,0-弱网,1-正常
    [32] = { name = "networkStatus", type = "number", isNecessary = true},
    -- 是否使用代理IP,0-未使用,1-使用
    [33] = { name = "proxy", type = "number", isNecessary = true},
    -- 设备总存储
    [34] = { name = "allDisk", type = "number", isNecessary = true},
    -- 设备剩余存储
    [35] = { name = "residueDisk", type = "number", isNecessary = true},
    -- 客户端local dns
    [36] = { name = "ldns", type = "string", isNecessary = true},
    -- gpu信息
    [37] = { name = "gpuModel", type = "string", isNecessary = true},
    -- 显示屏宽度
    [38] = { name = "screenWidth", type = "number", isNecessary = true},
    -- 显示屏高度
    [39] = { name = "screenHeight", type = "number", isNecessary = true},
    -- cpu型号
    [40] = { name = "cpuModel", type = "string", isNecessary = true},
    -- cpu核数
    [41] = { name = "cpuCore", type = "number", isNecessary = true},
    -- cpu主频
    [42] = { name = "cpuFreq", type = "number", isNecessary = true},
    -- 当前App占用内存
    [43] = { name = "appMemory", type = "number", isNecessary = true},
    -- 手机总内存
    [44] = { name = "allMemory", type = "number", isNecessary = true},
    -- 网络制式
    [45] = { name = "xg", type = "string", isNecessary = true},
    -- 判断是否是模拟器，true表示是，Android特有，sdk版本1.9.2新增
    [46] = { name = "isEmulator", type = "string", isNecessary = true},
    -- 当前前台会话的唯一键，退出前台之后返回该值变化。（如果激活后一直没有退后台，可以用这个sessionID找到对应的一次前台会话的激活事件）
    [47] = { name = "activityID", type = "string", isNecessary = false},
    -- 当前进程的唯一键，退后台不变，只有杀掉退出重启才会变，可以用这个ID一直找到当前进程的激活事件
    [48] = { name = "sessionID", type = "string", isNecessary = true},
    -- 激活事件标识的唯一键
    [49] = { name = "RequestID", type = "string", isNecessary = true},
    -- 设备时区
    [50] = { name = "timeZone", type = "string", isNecessary = true},
    -- 设备 IP：客户端本地的IPv4
    [51] = { name = "ip", type = "string", isNecessary = true},
    -- 设备 IP：客户端本地的IPv6
    [52] = { name = "ipv6", type = "string", isNecessary = true},
    -- iOS上报设备短号；安卓上报序列号
    [53] = { name = "systemMachine", type = "string", isNecessary = true},
    -- 浏览器UA
    [54] = { name = "userAgent", type = "string", isNecessary = true},
    -- 设备默认语种
    [55] = { name = "systemLang", type = "string", isNecessary = true},
    -- caid(占坑)
    [56] = { name = "caid", type = "string", isNecessary = true},
    -- 安卓独有，SDK自己生成的设备ID
    [57] = { name = "paperDevice", type = "string", isNecessary = true},
    -- 当前事件发生的所在页面id
    [58] = { name = "CurrentPageId", type = "string", isNecessary = true},
    -- 当前页面从哪个页面进入的父页面ID
    [59] = { name = "ReferPageId", type = "string", isNecessary = true},
    -- 当前移动终端操作系统版本号，eg：10
    [60] = { name = "SystemSoftware", type = "string", isNecessary = true},
    -- WIFI/5G/4G/3G/2G；无网络时传空
    [61] = { name = "Network", type = "string", isNecessary = true},
    ---- 设备 IP：客户端公网的IP
    --[62] = { name = "ClientIP", type = "string", isNecessary = true},
    -- 事件标识, 同一个动作触发的多个事件使用相同 EventId 用于关联查询
    [63] = { name = "EventId", type = "number", isNecessary = true},
}
return EventTraceEnum
