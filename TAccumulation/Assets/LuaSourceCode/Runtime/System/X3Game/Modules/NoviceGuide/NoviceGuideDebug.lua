---仅用于Editor下的调试
---@class NoviceGuideDebug
local NoviceGuideDebug = {}
local this = NoviceGuideDebug
---检查对象池，用于检查控件是否找到
---@class NoviceGuideCheckInfoPool
---@field key string
---@field value NoviceGuideCheckInfo
local NoviceGuideCheckInfoPool = nil
---当前新手引导绑定的UI界面
---@class NoviceGuideBindWnds
local NoviceGuideBindWnds = {}

local NoviceGuideUtility = CS.PapeGames.X3Editor.NoviceGuideUtility
local UnityTime = CS.UnityEngine.Time


if UNITY_EDITOR then
    -- 初始化编辑器，还没包含这个s
    if NoviceGuideDefine == nil then
        NoviceGuideDefine = require "Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideDefine"
    end
    if NoviceGuideUtil == nil then
        NoviceGuideUtil = require "Runtime.System.X3Game.Modules.NoviceGuide.NoviceGuideUtil"
    end
    this.ConditionCheckTypeCN =
    {
        [NoviceGuideDefine.CheckConditionType.Level]     = "等级匹配",
        [NoviceGuideDefine.CheckConditionType.Unlock]    = "系统解锁匹配",
        [NoviceGuideDefine.CheckConditionType.UI]        = "UI条件匹配",
        [NoviceGuideDefine.CheckConditionType.UIControl] = "UI控件条件匹配",
        [NoviceGuideDefine.CheckConditionType.PageUI]    = "页签条件匹配",
        [NoviceGuideDefine.CheckConditionType.Stage]     = "关卡解锁匹配",
        [NoviceGuideDefine.CheckConditionType.Guide]     = "前置引导匹配",
        [NoviceGuideDefine.CheckConditionType.Extra]     = "额外条件匹配",
    }

    this.GuideTriggerTypeCN =
    {
        [NoviceGuideDefine.GuideTriggerType.UIChange] = "界面切换",
        [NoviceGuideDefine.GuideTriggerType.LevelChange] = "等级提升",
        [NoviceGuideDefine.GuideTriggerType.StageFinish] = "完成关卡",
        [NoviceGuideDefine.GuideTriggerType.TabChange] = "Tab页切换",
        [NoviceGuideDefine.GuideTriggerType.SystemUnlock] = "系统解锁",
        [NoviceGuideDefine.GuideTriggerType.MainHomeViewSwitch] = "主界面左右滑屏",
        [NoviceGuideDefine.GuideTriggerType.ClientToGuideMsg] = "其他系统事件",
        [NoviceGuideDefine.GuideTriggerType.UIJump] = "界面跳转",
        [NoviceGuideDefine.GuideTriggerType.GuideFinish] = "引导完成",
    }

    this.GuideContentTypeCN =
    {
        [0] = "空引导",
        [1] = "显示点击引导特效,监听点击事件",
        [2] = "显示长按引导特效",
        [3] = "显示全屏Tips，添加点击监听",
        [4] = "显示滑动引导特效",
        [5] = "调起剧情对话框",
        [6] = "显示UI控件",
        [7] = "隐藏UI控件",
        [8] = "显示拖拽特效",
        [9] = "显示蒙版",
        [10] = "显示规则描述页",
        [11] = "显示区域特效高亮",
        [12] = "添加多个点击事件，任选其一",
        [13] = "隐藏某个UI",
        [14] = "显示手势特效高亮",
        [15] = "跳转到指定界面",
    }

end

function this.TableToString(data)
    local dataStr = ""
    if not table.isnilorempty(data) then
        for i, element in pairs(data) do
            local str
            if type(element) == "table" then
                str = this.TableToString(element)
            else
                str = tostring(element)
            end
            dataStr = dataStr .. string.format("%s,", str)
        end
    end
    return dataStr
end

--- 收集引导相关的信息
---@param guideID number 引导id
---@param checks table 检查结果信息
---@param conditionChecks table 条件检查结果信息
---@param checkResult boolean 是否能触发
function this.CollectCheckGuideInfo(guideID,checks,conditionChecks,checkResult)
    if UNITY_EDITOR then
        if table.isnilorempty(conditionChecks) then
            return
        end
        local checkResults = PoolUtil.GetTable()
        -- 收集各项数据检查的结果
        for i = 1, #conditionChecks do
            table.insert(checkResults, {
                ConditionType = conditionChecks[i].type,
                ConditionTypeDesc = conditionChecks[i].typeDesc,
                ConditionParams = conditionChecks[i].source,
                TargetParams = conditionChecks[i].target,
                Result = conditionChecks[i].result
            })
        end
        -- 把检查结果塞进列表中
        local bll = BllMgr.GetNoviceGuideBLL()
        local cfg = NoviceGuideUtil.GetGuideCfg(guideID)
        table.insert(checks, {
            GuideID = guideID,
            Order = cfg.Order,
            GuideName = tostring(guideID),--cfg.ReMark, 
            IsCompleted = bll:IsGuideFinish(guideID),
            Result = checkResult,
            GuideChecks = checkResults
        })
    end
end

--- 收集引导触发条件的检测信息
---@param checkType NoviceGuideCondition
function this.CollectCheckGuideConditionInfo(checkType,debugTable,condition,source,result)
    if UNITY_EDITOR then
        if debugTable == nil then
            return
        end
        table.insert(debugTable,{
            type = checkType,
            typeDesc = this.ConditionCheckTypeCN[checkType],
            target = condition,
            source = source,
            result = result,
        })
    end
end

--- 发送检查的数据信息到编辑器，用于可视化
function this.SendGuideCheckResult(way, checks)
    if UNITY_EDITOR then
        CS.PapeGames.NoviceGuide.VisualLogger.Log(JsonUtil.Encode(
                {
                    Time = CS.System.DateTime.Now.Ticks,
                    TriggerType = this.GuideTriggerTypeCN[way],
                    TriggerParams = "参数",
                    CheckResults = checks
                }
        ))
    end
end

--TODO @baozhatou 路径替换成新的后，要删掉
function this.SendGuidePathChange(guideId, oldObj)
    if UNITY_EDITOR then
        local newPath = NoviceGuideUtility.GenerateRelativePathStrByUIGo(oldObj.gameObject)
        local msg = JsonUtil.Encode(
                {
                    Type = "Guide",
                    ID = guideId,
                    OldPath = "",
                    NewPath = newPath,
                }
        )
        CS.PapeGames.NoviceGuide.VisualLogger.LogPathChange(msg)
    end
end

--TODO @baozhatou 路径替换成新的后，要删掉
function this.SendGuideContentPathChange(contentId, oldPath, oldObj)
    if not UNITY_EDITOR then return end

    local newPath = NoviceGuideUtility.GenerateRelativePathStrByUIGo(oldObj.gameObject)
    local msg = JsonUtil.Encode(
            {
                Type = "GuideContent",
                ID = contentId,
                OldPath = oldPath,
                NewPath = newPath,
            }
    )
    CS.PapeGames.NoviceGuide.VisualLogger.LogPathChange(msg)
end

--- 执行GuideContent，发送数据信息到Editor
function this.SendExecuteContentInfoToEditor(contentID,contentType)
    if not UNITY_EDITOR then return end
    Debug.LogFormat("[Guide] 执行具体内容%s , Type : %d - %s", contentID,contentType,this.GuideContentTypeCN[contentType])
end

--- 发送当前执行的引导ID到编辑器
function this.SendCurrentGuideInfoToEditor(guideID)
    if UNITY_EDITOR then
        CS.PapeGames.NoviceGuide.VisualLogger.RefreshRunningGuideInfo(guideID)
    end
end

--- 发送当前正在执行的步骤信息ID到编辑器
function this.SendCurrentGuideStepInfoToEditor(stepID)
    if UNITY_EDITOR then
        CS.PapeGames.NoviceGuide.VisualLogger.RefreshRunningStepInfo(stepID)
    end
end

--- 发送引导完成状态的数据给编辑器
function this.SendGuideStatusToEditor(guideId,status)
    CS.PapeGames.NoviceGuide.VisualLogger.RefreshGuideState(guideId,status)
end


function this.ExecuteGM(gmCmd,guideID,serverCmd)
    if not UNITY_EDITOR then return end
    if serverCmd then
        BllMgr.GetGMCommandBLL():SendSeverGM(gmCmd)
    else
        local inputList = {
            [1] ="guide",
            [2] = gmCmd,
            [3] = tostring(guideID)
        }
        BllMgr.GetNoviceGuideBLL():HandleGMCommand(inputList)
    end
end


--region Editor Function

--- 清楚缓存的引导信息
function this.ResetCheckGuideInfo()
    if not UNITY_EDITOR then
        return
    end
    if not table.isnilorempty(NoviceGuideCheckInfoPool) then
        PoolUtil.ReleaseTable(NoviceGuideCheckInfoPool)
    end
    NoviceGuideCheckInfoPool = PoolUtil.GetTable()
end

--- 监听，检查新手引导配置的控件是否存在
function this.UpdateCheckGuideIsNotFound(guideStepCfg,controlName,contentID)
    if not UNITY_EDITOR then
        return
    end
    ---@type NoviceGuideCheckInfo
    this.GetCheckGuideStepInfo(guideStepCfg,controlName,contentID)
    this.UpdateCheckGuideInfo()
end

--- 获取当前正在检查的新手引导的基本信息，没有则创建一个，用于监听
---@private
function this.GetCheckGuideStepInfo(row,controlName,contentID)
    ---@type NoviceGuideCheckInfo
    local target = nil
    for k,v in pairs(NoviceGuideCheckInfoPool) do
        if k == controlName then
            target = v
            break
        end
    end
    if not target then
        local cfg = LuaCfgMgr.Get("Guide", row.GuideGroupID)
        target = {}
        target.Timer = 0
        target.StepID = row.ID
        target.ControlName = controlName
        target.ContentID = contentID
        target.IsChecked = false
        local uiCondition = cfg.UICondition
        if string.find(uiCondition, "&") then
            local mParams = string.split(uiCondition, "&")
            uiCondition = mParams[1];
        end
        target.UICondition = uiCondition
        NoviceGuideCheckInfoPool[controlName] = target
    end
    return target
end

--- tick缓存的引导信息，如果2s还找不到，则弹出tip
---@private
function this.UpdateCheckGuideInfo()
    for k,v in pairs(NoviceGuideCheckInfoPool) do
        if v ~= nil and not v.IsChecked then
            v.Timer = v.Timer + UnityTime.deltaTime
            if v.Timer >= 2 then
                this.ShowTipContent(v)
            end
        end
    end
end

--- 如果找不到，则弹出tip提示控件缺失
---@private
function this.ShowTipContent(v)
    if v == nil then return end
    v.IsChecked = true
    local tipContent = string.format("[NoviceGuide]新手引导 Step：%d Content: %d \n找不到控件 : %s", v.StepID,v.ContentID,v.ControlName)
    if v.UICondition ~= "" and v.UICondition ~= nil then
        local uiOpen = UIMgr.IsOpened(v.UICondition) and "true" or "false"
        local uiInfo = string.format("\nUI条件 - %s ,开启状态 : %s",v.UICondition,uiOpen)
        tipContent = tipContent .. uiInfo
    end
    Debug.LogError(tipContent)
    UICommonUtil.ShowMessageBox(tipContent,{
        {btn_type = GameConst.MessageBoxBtnType.CONFIRM,btn_text = "确定",btn_call = function () end}
    })
end

---@private
local function GetRecordJsonFilePath()
    local root = CS.UnityEngine.Application.dataPath
    root = string.replace(root,"Assets","LuaSourceCode\\Editor\\Guide\\")
    return root .. "GuideStepBindWnd.json";
end

--- 读取本地保存的窗口的记录
---@private
function this.LoadGuideBindWndRecord()
    if not UNITY_EDITOR then
        return
    end
    local assetTablePath = GetRecordJsonFilePath()
    local jsonStr = io.readfile(assetTablePath)
    NoviceGuideBindWnds = JsonUtil.Decode(jsonStr) or {}
end

--- 记录当前能找到的UI的界面
---@private
function this.RecordGuideBindWnd(guideStep,control,controlName,bindWnd)
    local key = tostring(guideStep);
    --if NoviceGuideBindWnds[key] == nil then
    NoviceGuideBindWnds[key] = {
        ["control"] = controlName,
        ['wnd'] = bindWnd,}
    --end
end

--- 将当前记录的数据保存下来
---@private
function this.SaveRecordToLocalFile()
    if not UNITY_EDITOR then
        return
    end
    local jsonFilePath = GetRecordJsonFilePath()
    local jsonStr = JsonUtil.Encode(NoviceGuideBindWnds)
    CS.PapeGames.X3.FileUtility.WriteText(jsonFilePath,jsonStr)
    Debug.LogError("[Guide] Not Error ! Save Json Path ： ", jsonFilePath)
end

--endregion

return NoviceGuideDebug