﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/5/24 14:03
---

----DownloadMgr 只对 实际的分包ID进行操作，为最小单元

---@class SubPackage.DownloadMgr
local DownloadMgr = class("DownloadMgr")

local cs_respatch_mgr_instance = nil
local DownloadUtil = CS.X3Game.Download.DownloadUtils
local cs_application = CS.UnityEngine.Application

local prefsKey = "CHECKMESSAGEBOX"
local showNetWorkMessageBox = false
local deferred = require("Runtime.Common.Deferred")
local this = DownloadMgr

---网络状态
local cs_reachableViaLocalAreaNetwork = CS.UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork
local cs_reachableViaCarrierDataNetwork = CS.UnityEngine.NetworkReachability.ReachableViaCarrierDataNetwork
local cs_notReachable = CS.UnityEngine.NetworkReachability.NotReachable
local IsDownloadInViaCarrier = false

SubPackageUtil = require("Runtime.System.X3Game.Modules.SubPackages.SubPackageUtil")

---@class SubPackage.PackageDownloadType
PackageDownloadType = {
    Single = 0, ---单任务下载
    List = 1     ---多任务下载
}

function DownloadMgr:Init()
    if not SubPackageDownloadMgr.IsValid() then
        return
    end
    ---@type table<int,DownloadMgr.PackageBase>
    self.packageTab = {}
    ---@type string[]
    self.downloadTaskTab = {}
    ---@type table<string,DownloadTask>
    self.downloadPackageTaskTab = {}
    ---@type table<string,DownloadGroup>
    self.downloadPackageGroupTab = {}
    ---@type bool
    self.isInDownload = false
    ---@type DownloadTask[]
    self.autoPauseTaskTab = {}
    cs_respatch_mgr_instance = CS.ResourcesPacker.Runtime.ResPatchManager.Instance
    self.lastNetworkState = cs_application.internetReachability
    EventMgr.AddListener("SubPackageMgr_PackageDownload_Finish", self.OnFinishPackage, self)
    EventMgr.AddListener("SubPackageMgr_TaskDownload_Finish", self.QueueTick, self)

    self.netWorkStateCheck = TimerMgr.AddTimer(1, handler(self, self.NetWorkStateCheck), self, true, 2)
    ---红点逻辑
    self.errorTaskDic = {}
    ---当前处于下载失败的分包任务数量
    self.errorTaskNum = 0
    ---当前处于下载失败的语音包任务数量
    self.errorVoiceTaskNum = 0
end

function DownloadMgr:Clear()
    EventMgr.RemoveListener("SubPackageMgr_PackageDownload_Finish", self.OnFinishPackage, self)
    EventMgr.RemoveListener("SubPackageMgr_TaskDownload_Finish", self.QueueTick, self)
    if self.queueDownloadTick ~= nil then
        self.queueDownloadTick = nil
        TimerMgr.Discard(self.queueDownloadTick)
        table.clear(self.downloadPackageTaskTab)
        table.clear(self.downloadPackageGroupTab)
        table.clear(self.downloadTaskTab)
    end
end

---下载中网络监测
function DownloadMgr:NetWorkStateCheck()
    if (not self:GetIsInDownload()) and #self.autoPauseTaskTab == 0 then
        return
    end
    local internetReachability = cs_application.internetReachability
    local gmEnable = GameHelper.CheckDebugMode(GameConst.DebugMode.GM_MODE)
    if gmEnable and SubPackageUtil.GetCarrierDataDebugState() then
        internetReachability = cs_reachableViaCarrierDataNetwork
    end
    if (self.lastNetworkState ~= internetReachability) then
        ---流量环境暂停当前下载，弹窗，流量后恢复wifi，清理弹窗继续
        if (internetReachability == cs_reachableViaCarrierDataNetwork) and (not IsDownloadInViaCarrier) then
            local checkCfgData = LuaCfgMgr.Get("Confirmation", X3_CFG_CONST.CONFIRMATION_UNLOCK_MODULE_DOWNLOAD)
            local timeTypeData = LuaCfgMgr.Get("TimeType", checkCfgData.TimeType)
            local prefsKey = string.concat(prefsKey, tostring(checkCfgData.ID), tostring(timeTypeData.ID))
            local isJump = PlayerPrefs.GetBool(prefsKey, false)
            if not isJump and (not ErrandMgr.IsAdded(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)) then
                self:PauseNowDownloadTask()
                ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK, function()
                    showNetWorkMessageBox = true
                    self.messageBoxID = UICommonUtil.ShowCheckMessageBox(X3_CFG_CONST.CONFIRMATION_UNLOCK_MODULE_DOWNLOAD, UITextConst.UI_TEXT_30824, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                        ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
                        self:ResumePauseDownloadTask()
                        IsDownloadInViaCarrier = true
                    end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
                        ---取消后清理自动暂停的队列
                        table.clear(self.autoPauseTaskTab)
                        ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
                    end } })
                end)
            end
        elseif (internetReachability == cs_reachableViaLocalAreaNetwork) then
            IsDownloadInViaCarrier = false
            if ErrandMgr.IsAdded(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK) then
                ErrandMgr.ClearByType(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
                if showNetWorkMessageBox then
                    ---指定清理对应的弹窗
                    UICommonUtil.CloseMessageBox(self.messageBoxID)
                    ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
                end
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_30803)
                self:ResumePauseDownloadTask()
            end
        end
        self.lastNetworkState = internetReachability
    end
end


--region ------------------下载相关
function DownloadMgr:PauseNowDownloadTask()
    if not SubPackageDownloadMgr.IsEnable() then
        return
    end
    self.autoPauseTaskTab = {}
    for k, v in pairs(self.downloadPackageTaskTab) do
        if v.downloadState == PackageDownloadState.Downloading or v.downloadState == PackageDownloadState.Wait then
            self.autoPauseTaskTab[#self.autoPauseTaskTab + 1] = v
            v:PauseDownload()
        end
    end
    EventMgr.Dispatch("DownloadUI_UpdateDownloadList")
end

function DownloadMgr:ResumePauseDownloadTask()
    if not SubPackageDownloadMgr.IsEnable() then
        return
    end
    for i, v in ipairs(self.autoPauseTaskTab) do
        v:ResumeDownload()
    end
    table.clear(self.autoPauseTaskTab)
end

function DownloadMgr:OnFinishPackage(packageID)
    if self.packageTab[packageID] ~= nil then
        self.packageTab[packageID]:Clear()
        self.packageTab[packageID] = nil
    end
end

---@param packageID int
function DownloadMgr:DownloadPackage(packageID)
    if not self.HasDownloadedPkgTag(packageID) then
        local tab = self.packageTab[packageID]
        if tab == nil then
            tab = require("Runtime.System.X3Game.Modules.SubPackages.Base.PackageBase").new()
            self.packageTab[packageID] = tab
            tab:SetData(packageID)
        end
        tab:OpenDownload()
    end
end

---@param packageID int
function DownloadMgr:PausePackage(packageID)
    if self.packageTab[packageID] ~= nil then
        self.packageTab[packageID]:PauseDownload()
    end
end

function DownloadMgr:PauseAllPackage()
    for k, v in pairs(self.packageTab) do
        v:PauseDownload()
    end
end

function DownloadMgr:GetPackage(packageID)
    if self.packageTab[packageID] == nil then
        local tab = self.packageTab[packageID]
        if tab == nil then
            tab = require("Runtime.System.X3Game.Modules.SubPackages.Base.PackageBase").new()
            self.packageTab[packageID] = tab
            tab:SetData(packageID)
        end
    end
    return self.packageTab[packageID]
end

---@param packageID int
function DownloadMgr:GetPackageState(packageID)
    if self.packageTab[packageID] ~= nil then
        return self.packageTab[packageID].downloadState
    else
        if self.HasDownloadedPkgTag(packageID) then
            return PackageDownloadState.Finished
        else
            return PackageDownloadState.None
        end
    end
end

---@param packageIDs int
---@return int 下载size
function DownloadMgr:GetDownloadSizeByPackageIDs(packageIDs)
    local downloadSize = 0
    for i, v in ipairs(packageIDs) do
        if self.packageTab[v] ~= nil then
            downloadSize = downloadSize + self.packageTab[v]:GetDownloadSize()
        else
            if self.HasDownloadedPkgTag(v) then
                downloadSize = downloadSize + self.GetChildPackageSize(v)
            end
        end
    end
    return downloadSize
end

---@param packageIDs table
---@return table 传入一个packageIDs，返回没下载过的packageIDs
function DownloadMgr:GetUnFinishPackageIDsByTable(packageIDs)
    local result = {}
    for i, v in ipairs(packageIDs) do
        if self.packageTab[v] ~= nil then
            result[#result + 1] = v
        else
            if not self.HasDownloadedPkgTag(v) then
                result[#result + 1] = v
            end
        end
    end
    return result
end

---获取当前下载速度
function DownloadMgr:GetDownloadSpeed()
    local downloadSpeed = 0
    for k, v in pairs(self.packageTab) do
        downloadSpeed = downloadSpeed + v:GetDownloadSpeed()
    end
    return downloadSpeed
end

function DownloadMgr:GetIsInDownload()
    return self.isInDownload
end

---队列下载
function DownloadMgr:AddDownloadTask(taskID, packages, isNowDownload, moduleID, groupCom)
    if self.downloadPackageTaskTab[taskID] == nil then
        local downloadTask = require("Runtime.System.X3Game.Modules.SubPackages.Base.DownloadTask").new()
        downloadTask:Init(taskID, packages, moduleID, groupCom)
        self.downloadPackageTaskTab[taskID] = downloadTask
        if isNowDownload then
            table.insert(self.downloadTaskTab, 1, downloadTask.taskID)
        else
            self.downloadTaskTab[#self.downloadTaskTab + 1] = downloadTask.taskID
        end
    else
        local taskTab = self.downloadPackageTaskTab[taskID]
        local downloadState = taskTab:GetDownloadState()
        if downloadState == PackageDownloadState.Wait or downloadState == PackageDownloadState.None or downloadState == PackageDownloadState.Failed or downloadState == PackageDownloadState.Pause then
            if isNowDownload then
                self:ResumeDownload(taskID)
            else
                taskTab:ResumeDownload()
            end
        end
    end
    if self.queueDownloadTick == nil then
        self.queueDownloadTick = TimerMgr.AddTimer(0.1, self.QueueTick, self, true)
    end
    self:WriteDownloadData()
end

function DownloadMgr:AddDownloadTaskGroup(taskID, packages, isNowDownload, moduleID, downloadType)
    if(not self.downloadPackageGroupTab[moduleID]) then
        local downloadGroup = require("Runtime.System.X3Game.Modules.SubPackages.Base.DownloadGroup").new()
        self.downloadPackageGroupTab[moduleID] = downloadGroup
    end
    self.downloadPackageGroupTab[moduleID]:Init(taskID, packages, isNowDownload, moduleID, downloadType)
end

function DownloadMgr:QueueTick()
    local isInDownload = false
    local index = 1
    local finishTaskIDTab = {}
    local DownloadTaskID = ""
    while index <= #self.downloadTaskTab do
        local downloadTaskID = self.downloadTaskTab[index]
        local downloadTask = self.downloadPackageTaskTab[downloadTaskID]
        if downloadTask ~= nil then
            local downloadState = downloadTask:GetDownloadState()
            if downloadState == PackageDownloadState.Finished then
                finishTaskIDTab[#finishTaskIDTab + 1] = downloadTaskID
            elseif downloadState == PackageDownloadState.Wait then
                downloadTask:StartDownload()
                isInDownload = true
                DownloadTaskID = downloadTaskID
                break
            elseif downloadState == PackageDownloadState.Downloading then
                downloadTask:StartDownload()
                isInDownload = true
                DownloadTaskID = downloadTaskID
                break
            end
        end
        index = index + 1
    end
    if not string.isnilorempty(DownloadTaskID) then
        for _, v in pairs(self.downloadPackageTaskTab) do
            local downloadState = v:GetDownloadState()
            if downloadState == PackageDownloadState.Downloading and v.taskID ~= DownloadTaskID then
                v:WaitDownload()
            end
        end
    end
    for i, v in ipairs(finishTaskIDTab) do
        EventMgr.Dispatch("SubPackageDownload_TaskFinish", v)
        self.downloadPackageTaskTab[v] = nil
        table.removebyvalue(self.downloadTaskTab, v)
    end
    if #finishTaskIDTab > 0 then
        self:WriteDownloadData()
    end
    EventMgr.Dispatch("SubPackageDownload_Downloading", isInDownload)
    self.isInDownload = isInDownload
end

---@param taskID string
function DownloadMgr:PauseDownloadTask(taskID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        self.downloadPackageTaskTab[taskID]:PauseDownload()
        self:WriteDownloadData()
    end
end

---暂停所有下载
function DownloadMgr:PauseAllDownloadTask()
    for k, v in pairs(self.downloadPackageTaskTab) do
        v:PauseDownload()
    end
    self:WriteDownloadData()
end

function DownloadMgr:ResumeDownload(taskID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        local index = -1
        for i, v in ipairs(self.downloadTaskTab) do
            if v == taskID then
                index = i
                break
            end
        end
        if index ~= -1 then
            table.remove(self.downloadTaskTab, index)
        end
        table.insert(self.downloadTaskTab, 1, taskID)
        self.downloadPackageTaskTab[taskID]:ResumeDownload()
        self:QueueTick()
    end
end

function DownloadMgr:GetDownloadTaskState(taskID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        return self.downloadPackageTaskTab[taskID]:GetDownloadState()
    end
    return PackageDownloadState.None
end

---@param taskID string
---@return bool
---@return int
function DownloadMgr:GetDownloadTaskTotalSize(taskID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        return true, self.downloadPackageTaskTab[taskID]:GetDownloadTaskTotalSize()
    end
    return false, 0
end

function DownloadMgr:DeleteDownloadTask(taskID)
    local isFinish = false
    if self.downloadPackageTaskTab[taskID] ~= nil then
        self.downloadPackageTaskTab[taskID]:DeleteDownload()
        isFinish = true
    end
    table.removebyvalue(self.downloadTaskTab, taskID)
    self.downloadPackageTaskTab[taskID] = nil
    self:WriteDownloadData()
    return isFinish
end

---@param taskID string
---@return int
function DownloadMgr:GetTaskDownloadSize(taskID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        return self:GetDownloadSizeByPackageIDs(self.downloadPackageTaskTab[taskID].downloadPackageIDTab)
    end
    return 0
end

--endregion

--region --------------c# 函数

---@param packageID int
function DownloadMgr.CheckPackageIDValid(packageID)
    if cs_respatch_mgr_instance == nil then
        return
    end
    return cs_respatch_mgr_instance:IsPackageTagValid(packageID)
end

---@param packageID int
function DownloadMgr.DownloadWithPackageID(packageID, onFinish, onProgress)
    if cs_respatch_mgr_instance == nil then
        return
    end
    cs_respatch_mgr_instance:DownloadChildPackage(packageID, onFinish, onProgress)
end

---@param packageID int
function DownloadMgr.PauseWithPackageID(packageID)
    if cs_respatch_mgr_instance == nil then
        return
    end
    cs_respatch_mgr_instance:PauseDownloadChildPackage(packageID)
end

---@param packageID int
---@return bool
function DownloadMgr.HasDownloadedPkgTag(packageID)
    if cs_respatch_mgr_instance == nil then
        return false
    end
    return cs_respatch_mgr_instance:HasDownloadedPkgTag(packageID)
end

---@param packageID int
---@return int
function DownloadMgr.GetChildPackageSize(packageID)
    if cs_respatch_mgr_instance == nil then
        return 0
    end
    return cs_respatch_mgr_instance:GetChildPackageSize(packageID)
end

---@param packageIDList table<int>
---@return int
function DownloadMgr.GetChildrenPackagesSize(packageIDList)
    if cs_respatch_mgr_instance == nil then
        return 0
    end
    return cs_respatch_mgr_instance:GetChildrenPackagesSize(packageIDList)
end

---@param packageID int
---@return int
function DownloadMgr.GetDownloadTotalSize(packageID)
    if cs_respatch_mgr_instance == nil then
        return 0
    end
    local size, contentSize = cs_respatch_mgr_instance:GetChildPackageSize(packageID)
    return size + contentSize
end

---@param packageID int
---@param deleteTempFile bool 是否删除临时文件
---@return bool 删除结果
function DownloadMgr.DeleteChildPackage(packageID, deleteTempFile)
    if cs_respatch_mgr_instance == nil then
        return false
    end
    deleteTempFile = deleteTempFile or false
    ---这个接口，当传deleteTempFile为true时肯定true，其他情况，没下完的会返回false
    return cs_respatch_mgr_instance:DeleteChildPackage(packageID, deleteTempFile)
end

---@param packageID int
---@return int
function DownloadMgr.GetChildPackageTempDownloadedSize(packageID)
    if cs_respatch_mgr_instance == nil then
        return 0
    end
    return cs_respatch_mgr_instance:GetChildPackageTempDownloadedSize(packageID)
end

---@param packageID int
---@return string md5
function DownloadMgr.GetPackageMD5(packageID)
    if cs_respatch_mgr_instance == nil then
        return ""
    end
    return cs_respatch_mgr_instance:GetPackageMD5(packageID)
end

--endregion

--region----------------下载追加

---下载追加
---@param taskID string
---@param packageID int
function DownloadMgr:AddToDownloadList(taskID, packageID)
    if self.downloadPackageTaskTab[taskID] ~= nil then
        self.downloadPackageTaskTab[taskID]:AddPackageID(packageID)
    end
end

---获取正在下载的ModuleID
---@return int[] moduleIDs
function DownloadMgr:GetAllNowDownloadModuleIDs()
    local moduleIDs = {}
    for k, v in pairs(self.downloadPackageTaskTab) do
        if v.moduleID ~= nil then
            moduleIDs[#moduleIDs + 1] = v.moduleID
        end
    end
    return moduleIDs
end

--endregion

---根据packageIDs 获取md5 值
---@public
---@param packageIDs table<int>
function DownloadMgr.GetMD5WithPackageIDs(packageIDs)
    local stringContent = ""
    table.sort(packageIDs, function(a, b)
        return a > b
    end)
    for i, v in ipairs(packageIDs) do
        stringContent = string.concat(stringContent, DownloadMgr.GetPackageMD5(v))
    end
    return DownloadUtil.GetStringMD5(stringContent)
end

--region ---------------下载信息序列化本地
---写入数据
---@private
function DownloadMgr:WriteDownloadData()
    local saveData = {}
    for i, v in ipairs(self.downloadTaskTab) do
        local taskID = v
        local downloadTask = self.downloadPackageTaskTab[taskID]
        if downloadTask ~= nil then
            local taskState = downloadTask:GetDownloadState()
            if taskState == PackageDownloadState.Downloading or taskState == PackageDownloadState.Wait or taskState == PackageDownloadState.Pause then
                local tab = {}
                tab.taskID = downloadTask.taskID
                tab.packageIDs = downloadTask.downloadPackageIDTab
                tab.state = taskState
                tab.md5 = self.GetMD5WithPackageIDs(downloadTask.downloadPackageIDTab)
                tab.moduleID = downloadTask.moduleID
                if(downloadTask.groupCom) then
                    tab.downloadType = downloadTask.groupCom:GetDownloadType()
                end

                saveData[#saveData + 1] = tab
            end
        end
    end
    if #saveData > 0 then
        local str = JsonUtil.Encode(saveData)
        PlayerPrefs.SetString("SubPackage_Downloading", str)
    else
        PlayerPrefs.SetString("SubPackage_Downloading", "")
    end
end

---读取数据
---@private
function DownloadMgr:ReadDownloadData(isShowTips)
    --Debug.LogError("ReadDownloadData ", ReadDownloadData)
    LuaCfgMgr.UnLoad("Module")
    local strJson = PlayerPrefs.GetString("SubPackage_Downloading", "")
    if not string.isnilorempty(strJson) then
        local tab = JsonUtil.Decode(strJson)
        local totalSize = 0
        local diffDownloadTaskTab = {}
        for i, v in ipairs(tab) do
            if not SubPackageUtil.GetFinishWithPackageIDs(v.packageIDs) then
                ---组控件
                if(v.downloadType == PackageDownloadType.List) then
                    if(not self.downloadPackageGroupTab[v.moduleID]) then
                        local downloadGroup = require("Runtime.System.X3Game.Modules.SubPackages.Base.DownloadGroup").new()
                        self.downloadPackageGroupTab[v.moduleID] = downloadGroup
                    end
                    self.downloadPackageGroupTab[v.moduleID]:InitWithSingle(v.taskID, v.downloadType)
                end

                ---判断储存的md5信息和当前md5信息是否一致 不一致进行清除操作
                local md5 = self.GetMD5WithPackageIDs(v.packageIDs)
                local downloadTask = require("Runtime.System.X3Game.Modules.SubPackages.Base.DownloadTask").new()
                downloadTask:Init(v.taskID, v.packageIDs, v.moduleID, self.downloadPackageGroupTab[v.moduleID])
                if v.md5 ~= md5 then
                    diffDownloadTaskTab[#diffDownloadTaskTab + 1] = downloadTask
                end
                if v.state ~= PackageDownloadState.Pause then
                    for _, packageID in ipairs(v.packageIDs) do
                        totalSize = totalSize + self.GetChildPackageSize(packageID)
                    end
                end
                downloadTask:SetDownloadState(v.state)
                self.downloadTaskTab[#self.downloadTaskTab + 1] = v.taskID
                self.downloadPackageTaskTab[v.taskID] = downloadTask

            end
        end
        if isShowTips == nil then
            isShowTips = true
        end
        if isShowTips then
            self:ContinueDownload(totalSize, diffDownloadTaskTab)
        else
            self.queueDownloadTick = TimerMgr.AddTimer(0.1, self.QueueTick, self, true)
            if #diffDownloadTaskTab > 0 then
                for i, v in ipairs(diffDownloadTaskTab) do
                    v:ClearDownload()
                end
                self:WriteDownloadData()
            end
        end
    end
    SubPackageDownloadMgr:LoginCheck()
end
--endregion

---登录检查弹窗
---@param totalSize int 下载的大小
---@param diffDownloadTaskTab table<DownloadTask>
function DownloadMgr:ContinueDownload(totalSize, diffDownloadTaskTab)
    if totalSize ~= 0 then
        local content = string.concat(UITextHelper.GetUIText(UITextConst.UI_TEXT_30846, SubPackageUtil.GetFormatSize(totalSize)),
                #diffDownloadTaskTab > 0 and UITextHelper.GetUIText(UITextConst.UI_TEXT_30862) or "")
        ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_SUBPACKAGE_CONTINUE, function()
            UICommonUtil.ShowMessageBox(content, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                self.CheckDownload(totalSize, function()
                    self.queueDownloadTick = TimerMgr.AddTimer(0.1, self.QueueTick, self, true)
                end, function()
                    for i, v in ipairs(self.downloadTaskTab) do
                        local downloadTask = self.downloadPackageTaskTab[v]
                        downloadTask:PauseDownload()
                        self:WriteDownloadData()
                    end
                end)
                ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_CONTINUE)
            end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
                for i, v in ipairs(self.downloadTaskTab) do
                    local downloadTask = self.downloadPackageTaskTab[v]
                    downloadTask:PauseDownload()
                    self:WriteDownloadData()
                end
                ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_CONTINUE)
            end }
            }, AutoCloseMode.None)
        end)
    else
        if #diffDownloadTaskTab > 0 then
            UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_30863, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM } }, AutoCloseMode.None)
        end
    end
    if #diffDownloadTaskTab > 0 then
        for i, v in ipairs(diffDownloadTaskTab) do
            v:ClearDownload()
        end
        self:WriteDownloadData()
    end
end

--region ----------------------下载检查
---下载前统一检测  检查流程 空间 - 网络（wifi，流量，无网络）
---@param size int
---@param callBack function
function DownloadMgr.CheckDownload(size, callBack, cancelBack)
    ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK, function()
        ---XTBUG-28095 没有判断双倍大小
        size = size * 2
        local d = nil
        this.size = size
        this.downloadCallBack = callBack
        d = this.CheckDiskSize(size)
                :next(this.CheckNetWork)
                :next(function()
            if callBack ~= nil then
                callBack()
            end
            ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
        end, function()
            if cancelBack ~= nil then
                cancelBack()
            end
            ErrandMgr.End(X3_CFG_CONST.POPUP_SUBPACKAGE_NETWORK)
        end)
    end)
end

function DownloadMgr:CheckAgain()
    self:CheckDownload(this.size, this.downloadCallBack)
end

function DownloadMgr.CheckDiskSize(size)
    ---@type deferred
    local d = deferred.new()
    if SubPackageUtil.CheckHaveFreeSpace(size) then
        d:resolve(true)
    else
        local content = UITextHelper.GetUIText(UITextConst.UI_TEXT_5125, SubPackageUtil.GetFormatSize(size))
        DownloadMgr.messageBoxID = UICommonUtil.ShowMessageBox(content, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_30802, btn_call = function()
            d:resolve(true)
        end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
            d:reject(false)
        end
                                               } })
    end
    return d
end

function DownloadMgr.CheckNetWork()
    local d = deferred.new()
    local isWifi = SubPackageUtil.CheckNetworkIsWifi()
    if not isWifi then
        local internetReachability = cs_application.internetReachability
        if internetReachability == cs_notReachable then
            DownloadMgr.messageBoxID = UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_5110, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_30802, btn_call = function()
                local internetReachability = cs_application.internetReachability
                if internetReachability == cs_notReachable then
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5110)
                else
                    d:resolve(false)
                    UICommonUtil.CloseMessageBox(DownloadMgr.messageBoxID)
                end
            end, is_auto_close = false }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
                d:reject(3)
            end }
            })
        else
            UICommonUtil.ShowCheckMessageBox(X3_CFG_CONST.CONFIRMATION_UNLOCK_MODULE_DOWNLOAD, UITextConst.UI_TEXT_30824, { { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                IsDownloadInViaCarrier = true
                d:resolve(true)
            end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_call = function()
                isWifi = SubPackageUtil.CheckNetworkIsWifi()
                if isWifi then
                    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_30803)
                    d:resolve(true)
                else
                    ---LYDJS-31241 取消下载的飘字去除
                    --UICommonUtil.ShowMessage(UITextConst.UI_TEXT_30804)
                    d:reject(4)
                end
            end }
            })
        end
    else
        d:resolve(2)
    end
    return d
end
--endregion

---更新下载异常任务红点状态 ---删除下载后也要处理 ---进入时执行空间的判断
---@param taskId int
---@param isError bool 是否为错误状态
---@param isNormal bool 是否为分包下载（与多语音面板区分
function DownloadMgr:UpdateErrorTask(taskId, isError, isNormal)
    if isError and (not self.errorTaskDic[taskId]) then
        self.errorTaskDic[taskId] = true
        if (isNormal) then
            self.errorTaskNum = self.errorTaskNum + 1
        else
            self.errorVoiceTaskNum = self.errorVoiceTaskNum + 1
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_SETTING_LANGUAGE, self.errorVoiceTaskNum, 3) ---identift id 为列表中的位置
        end
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUBPACKAGE_ABNORMAL, self.errorTaskNum)
    else
        if (self.errorTaskDic[taskId] and (not isError)) then
            self.errorTaskDic[taskId] = nil
            if (isNormal) then
                if (self.errorTaskNum > 0) then
                    self.errorTaskNum = self.errorTaskNum - 1
                end
            else
                if (self.errorVoiceTaskNum > 0) then
                    self.errorVoiceTaskNum = self.errorVoiceTaskNum - 1
                    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PLAYERINFO_SETTING_LANGUAGE, self.errorVoiceTaskNum, 3) ---identift id 为列表中的位置
                end
            end
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_SUBPACKAGE_ABNORMAL, self.errorTaskNum)
        end
    end
    --Debug.LogError("taskId ", taskId, " isError ", isError, " self.errorTaskNum ", self.errorTaskNum)
end

---是否存在下载异常的
---@return bool
function DownloadMgr:GetErrorTaskState()
    if self.errorTaskNum ~= nil and self.errorVoiceTaskNum ~= nil then
        return (self.errorTaskNum > 0 or self.errorVoiceTaskNum > 0) and true or false
    end
    return false
end

---是否为分包异常
---@return bool
function DownloadMgr:GetSubErrorTaskState()
    return (self.errorTaskNum and self.errorTaskNum > 0) and true or false
end

---是否为语音包异常
---@return bool
function DownloadMgr:GetVoiceErrorTaskState()
    return (self.errorVoiceTaskNum and self.errorVoiceTaskNum > 0) and true or false
end

---获取分包及语音包下载中的任务数量
---@return number, number 分包下载中的数量，语音下载中的数量
function DownloadMgr:GetDownloadingNum()
    local subNum = 0
    local voiceNum = 0
    for k, v in pairs(self.downloadPackageTaskTab) do
        if v.downloadState == PackageDownloadState.Downloading then
            if (v:GetNormalState()) then
                subNum = subNum + 1
            else
                voiceNum = voiceNum + 1
            end
        end
    end
    return subNum, voiceNum
end

---按照进行中的task来执行空间的判断
function DownloadMgr:CheckDiskSizeWithTask()
    local leftDownloadSize = 0
    for k, v in pairs(self.downloadPackageTaskTab) do
        if v.downloadState == PackageDownloadState.Downloading or v.downloadState == PackageDownloadState.Wait then
            leftDownloadSize = leftDownloadSize + v:GetLeftDownloadSize()
        end
    end
    local result = SubPackageUtil.CheckHaveFreeSpace(leftDownloadSize)
    if (not result) then
        --UICommonUtil.ShowMessage(UITextConst.UI_TEXT_30807)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_MAINHOME_SUBPACKAGE, 1)
    else
        if (RedPointMgr.GetCount(X3_CFG_CONST.RED_MAINHOME_SUBPACKAGE) > 0 and self.errorTaskNum == 0 and self.errorVoiceTaskNum == 0) then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_MAINHOME_SUBPACKAGE, 0)
        end
    end
end

---@return int[]
function DownloadMgr:GetAllDownloadTaskSubModuleIDs()
    local subModules = {}
    for k, v in pairs(self.downloadPackageTaskTab) do
        ---@type DownloadTask
        local downloadTask = v
        if downloadTask:GetNormalState() then
            for i, subModuleID in ipairs(downloadTask.subModuleIDs) do
                subModules[#subModules + 1] = subModuleID
            end
        end
    end
    return subModules
end

function DownloadMgr:ReInit()
    cs_respatch_mgr_instance = CS.ResourcesPacker.Runtime.ResPatchManager.Instance
end

function DownloadMgr:Destroy()
    if cs_respatch_mgr_instance then
        cs_respatch_mgr_instance:StopAllDownload()
        xlua.release(cs_respatch_mgr_instance)
        LuaUtil.GC()
    end
    cs_respatch_mgr_instance = nil
    CS.ResourcesPacker.Runtime.ResPatchManager.DestroyInstance()
end

return DownloadMgr
