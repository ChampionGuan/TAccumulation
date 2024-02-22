﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/4/1 14:07
---@class PlatformConst 
local PlatformConst = {}
---@class PlatformConst.PermissionType
PlatformConst.PermissionType = {
    READ_CALENDAR = 1, --- 读取日历
    WRITE_CALENDAR = 2, --- 写入日历
    READ_CALL_LOG = 3, --- 读取通话记录
    WRITE_CALL_LOG = 4, --- 写入通话记录
    PROCESS_OUTGOING_CALS = 5, --- 待补充
    CAMERA = 6, --- 相机
    READ_CONTACTS = 7, --- 读取通讯录
    WRITE_CONTACTS = 8, --- 写入通讯录
    GET_ACCOUNTS = 9, --- 手机账号
    ACCESS_FINE_LOCATION = 10, --- 精确定位
    ACCESS_COARSE_LOCATION = 11, --- 大致定位
    RECORD_AUDIO = 12, --- 录音
    READ_PHONE_STATE = 13, --- 读取手机状态
    READ_PHONE_NUMBERS = 14, --- 读取手机号码
    CALL_PHONE = 15, --- 拨打电话
    ANSWER_PHONE_CALLS = 16, --- 接听电话
    ADD_VOICEMAIL = 17, --- 添加声音库
    USE_SIP = 18, --- sip服务
    BODY_SENSORS = 19, --- 传感器
    SEND_SMS = 20, --- 发送短信
    RECEIVE_SMS = 21, --- 读取短信
    RECEIVE_WAP_PUSH = 22, --- 接收WAP PUSH
    RECEIVE_MMS = 23, --- 接收MMS
    READ_EXTERNAL_STORAGE = 24, --- 读取外部存储
    WRITE_EXTERNAL_STORAGE = 25, --- 写入外部存储
    Notification = 26, --- 通知
    IOS_IDFA = 27, --- iOS广告标识符
    IOS_NETWORK_STATE = 28, --- iOS网络状态
}
return PlatformConst