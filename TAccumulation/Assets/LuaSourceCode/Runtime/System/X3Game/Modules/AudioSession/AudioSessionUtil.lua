---
--- AudioSessionUtil
--- Created by kaikai.
--- DateTime: 2023/08/14
---

---@class AudioSessionUtil
local AudioSessionUtil = {}
---@type AudioSessionConst
local AudioSessionConst = require("Runtime.System.X3Game.Modules.AudioSession.AudioSessionConst")
local CS_PFWWISEUTILITY = CS.X3Game.Platform.PFWwiseUtility

---设置AudioSessionCategory
---@param category AudioSessionConst.Category
function AudioSessionUtil.SetCategory(category)
    CS_PFWWISEUTILITY.SetAudioSessionCategory(category)
end

---设置AudioSessionCategory
---@param category AudioSessionConst.Category
---@param options AudioSessionConst.CategoryOptions
function AudioSessionUtil.SetCategoryWithOptions(category, options)
    CS_PFWWISEUTILITY.SetAudioSessionCategory(category, options)
end

---设置AudioSessionCategory
---@param category AudioSessionConst.Category
---@param options AudioSessionConst.CategoryOptions
---@param mode AudioSessionConst.Mode
function AudioSessionUtil.SetCategoryWithOptionsAndMode(category, options, mode)
    CS_PFWWISEUTILITY.SetAudioSessionCategory(category, options, mode)
end
---@public 进入录音模式 需要与ExitRecordMode成对使用
---@param options AudioSessionConst.CategoryOptions
---@param mode AudioSessionConst.Mode
---@param onMuteCheck function(bool) 检测设备是否静音回调
---@param onSetCategoryFinish function() 设置AudioSession完成回调
function AudioSessionUtil.EnterRecordMode(options, mode, onMuteCheck, onSetCategoryFinish, delay, maxWaitCount)
    if not delay then
        delay = 0.2
    end
    if not maxWaitCount then
        maxWaitCount = 5
    end
    CS_PFWWISEUTILITY.EnterRecordMode(options, mode, function(isMute, result)
        if result == AudioSessionConst.EnterRecordErrorCode.Success then
            if onMuteCheck then
                onMuteCheck(isMute)
            end
        else
            --onMuteCheck(false)
            Debug.LogError("EnterRecordMode onMuteCheck Fail !!! EnterRecordErrorCode is ", result);
        end
    end, function(result)
        if result == AudioSessionConst.EnterRecordErrorCode.Success then
            if onSetCategoryFinish then
                onSetCategoryFinish(result)
            end
        else
            if onSetCategoryFinish then
                onSetCategoryFinish(result)
            end
            Debug.LogError("EnterRecordMode onSetCategoryFinish Fail !!! EnterRecordErrorCode is ", result);
        end
    end, delay, maxWaitCount)
end

---@public 退出录音模式
function AudioSessionUtil.ExitRecordMode()
    CS_PFWWISEUTILITY.ExitRecordMode()
end


---设置AudioSessionMode
---@param mode AudioSessionConst.Mode
function AudioSessionUtil.SetMode(mode)
    CS_PFWWISEUTILITY.SetAudioSessionMode(mode)
end

---重置AudioSession（重置为Wwise的初始设置）
function AudioSessionUtil.ResetAudioSessionCategory()
    CS_PFWWISEUTILITY.ResetAudioSessionCategory()
end

---恢复AudioSession（恢复成上一次的设置）
function AudioSessionUtil.RestoreAudioSessionCategory()
    CS_PFWWISEUTILITY.ResetAudioSessionCategory()
end

return AudioSessionUtil