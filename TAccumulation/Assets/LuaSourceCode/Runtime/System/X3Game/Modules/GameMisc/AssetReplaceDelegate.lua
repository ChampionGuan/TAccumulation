﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/11/30 11:34
---
---@class AssetReplaceDelegate
local AssetReplaceDelegate = {}

---替换女主证件照
---@param path string 资源路径
---@param bindingObj GameObject 加载出来的贴图绑定
function AssetReplaceDelegate:ReplacePlayerTexture(path, bindingObj)
    local imgName = UrlImgMgr.GetFileNameWithPath(path)
    if string.isnilorempty(imgName) then
        return nil
    end
    local t = string.split(imgName, ".")
    if #t ~= 0 then
        imgName = t[1]
    end
    return UICommonUtil.GetFaceImageTexture(imgName, bindingObj)
end

return AssetReplaceDelegate