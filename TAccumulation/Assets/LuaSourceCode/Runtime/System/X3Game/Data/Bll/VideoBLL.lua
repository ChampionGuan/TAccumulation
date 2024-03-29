﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/11/25 15:26
---@class VideoBLL
local VideoBLL = class("VideoBLL", BaseBll)
local FileCheckUtil = require("Runtime.System.X3Game.Modules.FileCheckUtil")
local videoManifestName = "video_manifest.json"
function VideoBLL:OnInit()
    ---@type table<string,number>
    self.videoCrcByPathDic = {}
    self.localPath = nil
    self.videoPath = nil
    if UNITY_EDITOR then
        self.localPath = CS.UnityEngine.Application.dataPath
        self.videoPath = "../Video/Real"
    else
        self.localPath = CS.UnityEngine.Application.persistentDataPath
        self.videoPath = "Video/Real"
    end
    self:InitVideoCrcInfo()
end

function VideoBLL:InitVideoCrcInfo()
    if UNITY_EDITOR then
        return
    end
    local videoManifestPath = nil
    videoManifestPath = CS.System.IO.Path.Combine(self.localPath, self.videoPath, videoManifestName)
    local text = CS.PapeGames.X3.FileUtility.ReadText(videoManifestPath)
    if not string.isnilorempty(text) then
        text = CS.X3Game.AESHelper.AesDecrypt(text)
        local jsonData = JsonUtil.Decode(text)
        for i = 1, #jsonData.crcInfoList do
            local videoCrcInfo = jsonData.crcInfoList[i]
            local videoVideoPath = videoCrcInfo.videoPath
            self.videoCrcByPathDic[videoVideoPath] = tonumber(videoCrcInfo.hash32)
        end
    end
end

---视频校验是否通过
---@param videoPath string 视频路径
---@return bool
function VideoBLL:CheckVideoCrc(videoPath)
    if UNITY_EDITOR then
        return true
    end
    local ret = false
    local relativePath = nil
    local videoIndex = string.find(videoPath, "Video", 1, true)
    if videoIndex then
        relativePath = string.sub(videoPath, videoIndex)
        relativePath = string.gsub(relativePath, "\\", "/")
    else
        relativePath = videoPath
    end
    local curHash32 = FileCheckUtil.GetPartOfFileXXHash32Natively(videoPath)
    local videoHash32 = self.videoCrcByPathDic[relativePath]
    if videoHash32 == curHash32 then
        ret = true
    end
    return ret
end

return VideoBLL