﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/11/19 17:01
---

local HttpErrorCode = class("HttpErrorCode")

HttpErrorCode.RequestType {
    ---区服列表
    ServerList = 10000,
    ---公告
    Announcement = 10100,
    ---资源更新
    ResUpdate = 10200,
    ---KeyValue
    Kv = 10300,
    ---举报
    UploadReport = 10400,
    ---活动
    Active = 10500,
    ---查询账号安全信息
    GetSafeStatus = 10600,
    ---查询角色未完成订单状态#
    UnFinishedOrder = 10700,
    ---查询实名信息
    CheckRealInfo = 10800,
    ---读取角色信息
    GetRoleInfo = 10900,
    ---IP
    GetIpLocate = 11000,
}

HttpErrorCode.CmsError = {
    ---非法字符
    RetErrChar = 1001,
    ---参数错误
    RetErrArgs = 1002,
    ---手机未验证
    RetErrPhoneVerify = 1005,
}

return HttpErrorCode