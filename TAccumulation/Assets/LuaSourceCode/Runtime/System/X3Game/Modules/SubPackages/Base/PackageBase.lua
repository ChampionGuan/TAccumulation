---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-16 14:15:57
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DownloadMgr.PackageBase
local PackageBase = class("PackageBase")

local OperationType = CS.ResourcesPacker.Runtime.OperationType

function PackageBase:ctor()
    self.downloadSize = 0
    self.lastDownloadSize = 0
    self.speedSzie = 0
end

function PackageBase:SetData(packageID)
    self.packageID = packageID
    self.isFinish = DownloadMgr.HasDownloadedPkgTag(self.packageID)
    self.downloadState = PackageDownloadState.None
    if not self.isFinish then
        self.lastDownloadSize = DownloadMgr.GetChildPackageTempDownloadedSize(self.packageID)
    end
end

---@param packageDownloadState SubPackage.PackageDownloadState
function PackageBase:SetDownloadState(packageDownloadState)
    self.downloadState = packageDownloadState
end

function PackageBase:OnFinish(operationType, msg)
    if operationType == OperationType.Success then
        self.isFinish = true
        self.downloadState = PackageDownloadState.Finished
        EventMgr.Dispatch("SubPackageMgr_PackageDownload_Finish", self.packageID)
        EventMgr.Dispatch("SubPackageMgr_PackageDownload_UI_Finish", self.packageID)
    else
        self.isFinish = false
        print(msg)
        if operationType == OperationType.DiskSpaceFull then
            EventMgr.Dispatch("SubPackageMgr_PackageDownload_DiskFull", self.packageID)
        elseif(operationType == OperationType.CancelDownloaded) then

        else
            EventMgr.Dispatch("SubPackageMgr_PackageDownload_Failed", self.packageID, msg)
        end
    end
end

local count = 0
function PackageBase:OnProgress(type, size, totalSize)
    self.downloadState = PackageDownloadState.Downloading
    if type == ResDownloadGroupType.Download then
        if not self.lastTime then
            self.lastTime = CS.UnityEngine.Time.realtimeSinceStartup
        end
        if SubPackageUtil.GetDiskFreeSpace() < SubPackageDownloadMgr.MIN_SURPLUS_SPACE then
            EventMgr.Dispatch("SubPackageMgr_PackageDownload_DiskFull", self.packageID)
        end
        self.downloadSize = size
        if self.downloadSize ~= 0 and count > 5 then
            self.downloadTime = CS.UnityEngine.Time.realtimeSinceStartup - self.lastTime
            self.lastTime = CS.UnityEngine.Time.realtimeSinceStartup
            self.speedSzie = (self.downloadSize - self.lastDownloadSize) / self.downloadTime
            self.lastDownloadSize = math.max(self.lastDownloadSize, self.downloadSize)
            count = 0
        end
        count = count + 1
        EventMgr.Dispatch("SubPackageMgr_PackageDownload_Downloading", self.packageID)
        EventMgr.Dispatch("SubPackageMgr_PackageDownload_UI_Downloading", self.packageID, self:GetDownloadSize(), self:GetTotalSize())
    end
end

function PackageBase:OpenDownload()
    if self.downloadState ~= PackageDownloadState.Downloading or self.downloadState ~= PackageDownloadState.Finished then
        self.lastTime = CS.UnityEngine.Time.realtimeSinceStartup
        self.downloadState = PackageDownloadState.Downloading
        DownloadMgr.DownloadWithPackageID(self.packageID, handler(self, self.OnFinish), handler(self, self.OnProgress))
    end
end

function PackageBase:PauseDownload()
    if self.downloadState == PackageDownloadState.Downloading then
        DownloadMgr.PauseWithPackageID(self.packageID)
        self.downloadState = PackageDownloadState.Pause
    end
end

function PackageBase:GetTotalSize()
    if not self.totalSize or not self.zipSize then
        self.totalSize, self.zipSize = DownloadMgr.GetChildPackageSize(self.packageID)
    end
    return self.totalSize
end

--获取当前包最大的size 解压大小和压缩包大小
function PackageBase:GetMaxTotalSize()
    if not self.totalSize or not self.zipSize then
        self.totalSize, self.zipSize = DownloadMgr.GetChildPackageSize(self.packageID)
    end
    return self.totalSize + self.zipSize
end

function PackageBase:GetDownloadSize()
    if self.totalSize == nil then
        self:GetTotalSize()
    end
    if self.downloadState == PackageDownloadState.Finished then
        self.lastDownloadSize = self.totalSize
    end
    return math.min(self.lastDownloadSize, self.totalSize)
end

function PackageBase:GetDownloadSpeed()
    if self.downloadState == PackageDownloadState.Downloading then
        return self.speedSzie
    end
    return 0
end

function PackageBase:GetDownloadState()
    return self.downloadState
end

function PackageBase:DelPackage(deleteTempFile)
    --local isFinish = DownloadMgr.DeleteChildPackage(self.packageID, deleteTempFile)
    --if isFinish then
    --    self:Clear()
    --end
    DownloadMgr.DeleteChildPackage(self.packageID, deleteTempFile)
    self:Clear()
    return isFinish
end

function PackageBase:Clear()
    self.lastDownloadSize = 0
    self.speedSzie = 0
    self.downloadState = PackageDownloadState.None
end

return PackageBase
