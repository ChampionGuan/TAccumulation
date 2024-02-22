---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by. AuthorName
-- Date. 2020-07-07 10.56.58
---------------------------------------------------------------------

-- To edit this template in. Data/Config/Template.lua
-- To disable this template, check off menuitem. Options-Enable Template File

---@class LuaCfgMgr
local LuaCfgMgr = {}
local CheckInTable, GetDataByCondition
--[[

cfg_name：配置表中sheet名称
key1,key2：获取配置表数据的key
name_index.作为和名字拼接时使用(针对包含文件夹路径)，比如对话表，（Dialogue_1001）根据剧情id和名字拼接表数据名称LuaCfgMgr.Get("Dialogue",1001)

LuaCfgMgr.Get(cfg_name,key1,key2)  支持双key，单key，获取单行数据

LuaCfgMgr.GetAll(cfg_name,name_index) 获取该配置所有数据

LuaCfgMgr.UnLoad(cfg_name,name_index)  卸载配置表（针对于比较大型的配置表，在优化的时候可以卸载，其他的暂不需要考虑）


--]]
local CfgHelper = require("Runtime.Common.CfgHelper")

---已经过去的时间
local TimePass = 0
---定时清理时间
local TimeCount = 120
---定时清理数据信息
local TimeClearCfgMap = {["PhoneMsgConversation"] = -1}

---@class cfg.UseArgString1

---lua统一获取配置表接口
---@param cfg_name string
---@param key1 number
---@param key2 number
---@return cfg.UseArgString1
function LuaCfgMgr.Get(cfg_name, key1, key2, ...)
    LuaCfgMgr.UpdateTimeClearInfo(cfg_name)
    return CfgHelper.Get(cfg_name, key1, key2, ...)
end

---获取该配置表的所有数据
---@param cfg_name string
---@param name_index number default nil
---@return cfg.UseArgString1[]
function LuaCfgMgr.GetAll(cfg_name, name_index)
    LuaCfgMgr.UpdateTimeClearInfo(cfg_name)
    return CfgHelper.GetAll(cfg_name, name_index)
end

---根据匹配条件查找
---返回第一个符合条件的数据行
---@param cfg_name string
---@param condition table<any,any>,(key,value)
---@return cfg.UseArgString1
function LuaCfgMgr.GetDataByCondition(cfg_name, condition)
    if not condition then
        return nil
    end
    return GetDataByCondition(cfg_name, condition, true)
end

---获取配置表副本
---@param cfg table
---@return table
function LuaCfgMgr.CloneCfg(cfg)
    return CfgHelper.CloneCfg(cfg)
end

---查看cfg内部字段
---@param cfg table
---@return table<any,any>
function LuaCfgMgr.ViewCfg(cfg)
    return LuaCfgMgr.CloneCfg(cfg)
end

---@param cfg_name string
---@return boolean
function LuaCfgMgr.IsMultiKey(cfg_name)
    return CfgHelper.IsMultiKey(cfg_name)
end

---根据匹配条件查找，
---返回所有符合的数据行
---@param cfg_name string
---@param condition table<any,any>,(key,value)
---@return cfg.UseArgString1[]
function LuaCfgMgr.GetListByCondition(cfg_name, condition)
    if not condition then
        return {}
    end
    return GetDataByCondition(cfg_name, condition)
end

---卸载配置表
---@param cfg_name string
---@param name_index number default nil
function LuaCfgMgr.UnLoad(cfg_name, name_index)
    CfgHelper.UnLoad(cfg_name, name_index)
end

---战斗专用
function LuaCfgMgr.GetLen(t)
    return CfgHelper.GetLen(t)
end

---战斗专用
function LuaCfgMgr.Pairs(t)
    return CfgHelper.CfgPairs(t)
end

---清理所有配置文件
function LuaCfgMgr.Clear()
    CfgHelper.Clear()
end

---@param log function
---@param log_warn function
---@param log_error function
function LuaCfgMgr.SetLog(log, log_warn, log_error)
    CfgHelper.SetLog(log, log_warn, log_error)
end

---@param is_enabled boolean
function LuaCfgMgr.SetLogEnable(is_enabled)
    CfgHelper.SetLogEnable(is_enabled)
end

---设置卸载函数
---@param un_load_func function
function LuaCfgMgr.SetUnLoadFunc(un_load_func)
    CfgHelper.SetUnLoadFunc(un_load_func)
end

---设置配置表目录
---@param cfg_dir string
function LuaCfgMgr.SetCfgDir(cfg_dir)
    CfgHelper.SetCfgDir(cfg_dir)
end

---设置是否是debug模式
---@param is_enable boolean
function LuaCfgMgr.SetDebugEnable(is_enable)
    CfgHelper.SetDebugEnable(is_enable)
end

---设置是否可写it
---@param is_enable boolean
function LuaCfgMgr.SetWriteEnable(is_enable)
    CfgHelper.SetWriteEnable(is_enable)
end

---设置是否可以跳过
---@param is_enable boolean
---@param skip_tag string
function LuaCfgMgr.SetSkipEnable(is_enable,skip_tag)
    CfgHelper.SetSkipEnable(is_enable,skip_tag)
end

---表合并：src中的数据merger到dst中
function LuaCfgMgr.ParseMerger()
    local cfg = require("LuaCfg.CfgAutoMergeConfig",true,true)
    if cfg then
        CfgHelper.ParseMerge(cfg)
        LuaUtil.UnLoadLua("LuaCfg.CfgAutoMergeConfig")
    end
end

---更新定时清理的table信息
function LuaCfgMgr.UpdateTimeClearInfo(cfg_name)
    if TimeClearCfgMap[cfg_name] ~= nil then
        TimeClearCfgMap[cfg_name] = os.time()
    end
end

---Tick,每过120s检查一次是否清理
function LuaCfgMgr.Tick(deltaTime)
    TimePass = TimePass + deltaTime
    if TimePass >= TimeCount then
        local curTime = os.time()
        for cfg_name, time in pairs(TimeClearCfgMap) do
            if time > -1 and curTime - time >= TimeCount then
                LuaCfgMgr.UnLoad(cfg_name)
                TimeClearCfgMap[cfg_name] = -1
            end
        end
        TimePass = 0
    end
end

---检测目标table中包含的key，value是否能在原始table中找到
---@param src_table table
---@param dst_table table
---@return boolean
CheckInTable = function(src_table, dst_table)
    if not src_table or not dst_table then
        return false
    end
    for k, v in pairs(dst_table) do
        if v ~= src_table[k] then
            return false
        end
    end
    return true
end

---@param cfg_name string
---@param condition table
---@param is_just_one boolean
---@return table
GetDataByCondition = function(cfg_name, condition, is_just_one)
    local res = not is_just_one and { } or nil
    local data_list = LuaCfgMgr.GetAll(cfg_name)
    if data_list then
        local is_multi_key = CfgHelper.IsMultiKey(cfg_name)
        local is_break = false
        for k, v in pairs(data_list) do
            if is_multi_key then
                for m, n in pairs(v) do
                    if CheckInTable(n, condition) then
                        if is_just_one then
                            res = n
                            is_break = true
                            break
                        else
                            table.insert(res, n)
                        end
                    end
                end
            else
                if CheckInTable(v, condition) then
                    if is_just_one then
                        is_break = true
                        res = v
                    else
                        table.insert(res, v)
                    end
                end
            end
            if is_break then
                break
            end
        end
    end
    return res
end

return LuaCfgMgr