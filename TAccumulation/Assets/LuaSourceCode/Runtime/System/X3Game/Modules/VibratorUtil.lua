---
--- 设备震动功能
--- Created by zhanbo.
--- DateTime: 2021/12/9 14:43
---
---@class VibratorUtil
local VibratorUtil = {}
---@class EVibratorAmplitude
VibratorUtil.EAmplitude = {
    VIBRATOR_INTENSITY_LIGHT = 0,
    VIBRATOR_INTENSITY_MEDIUM = 1,
    VIBRATOR_INTENSITY_HEAVY = 2,
}
local CLS = CS.PapeGames.X3.VibratorUtility

---播放
---@param amplitude EVibratorAmplitude (震动强度: 目前提供3档强度：0—小 1— 中 2—强 同等强度在不同机型上可能震感不同)
---@param frequency float (单次震动频率: 单位为秒,单次震动频率*单次震动次数=单次震动总时长 单次震动频率一般为0.01即可)
---@param time number (单次震动次数: 单次震动频率*单次震动次数=单次震动总时长 填-1表示不指定震动次数，持续震动直到收到震动停止的信号)
---@param groupFrequency float (多次震动间隔: 需要进行多次震动时，每次震完后，间隔多少秒进行下一次震动)
---@param groupTime number (总震动次数: 一共要调用多少次单次震动 填写-1表示不限次数持续循环震动，直到收到停止信号)
function VibratorUtil.Play(amplitude, frequency, time, groupFrequency, groupTime)
    if not amplitude then
        Debug.LogError("震动强度 is nil.")
        return
    end
    if not frequency then
        Debug.LogError("单次震动频率 is nil.")
        return
    end
    if not time then
        Debug.LogError("单次震动次数 is nil.")
        return
    end
    if not groupFrequency then
        groupFrequency = 0
    end
    if not groupTime then
        groupTime = 0
    end
    CLS.Play(amplitude, frequency, time, groupFrequency, groupTime)
end

---播放(通过表格Id)
---@param Id number
function VibratorUtil.PlayId(Id)
    local cfg_Vibration = LuaCfgMgr.Get("Vibration", Id)
    if not cfg_Vibration then
        Debug.LogError("cfg_Vibration is nil " .. Id)
        return
    end
    CLS.Play(cfg_Vibration.Amplitude, cfg_Vibration.Frequency, cfg_Vibration.Time, cfg_Vibration.GroupFrequency, cfg_Vibration.GroupTime)
end

---停止
function VibratorUtil.Stop()
    CLS.Stop()
end

return VibratorUtil
