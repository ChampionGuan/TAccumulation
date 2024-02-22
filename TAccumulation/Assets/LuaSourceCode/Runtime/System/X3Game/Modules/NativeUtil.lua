﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by PC.
--- DateTime: 2021/3/8 10:47
---
---@class NativeUtil
local NativeUtil = {}
----region
local WebCamHelper = CS.X3Game.WebCamHelper.Instance
--local SDKDefine = require("Runtime.System.X3Game.Modules.SDK.SDKDefine")
--
function NativeUtil.RequestCameraAuthorization(callback)
    WebCamHelper:RequestAuthorization(callback)
end

function NativeUtil.CheckCamAuthorization()
    return WebCamHelper:HasAuthorization()
end
--- type: @class SDKDefine.PermissionTypeInt
function NativeUtil.CheckPermission(type)
    return WebCamHelper:CheckPermission(type)
end

--- type: @class SDKDefine.PermissionTypeInt
function NativeUtil.RequestPermission(type,callback)
    return WebCamHelper:RequestPermission(type,callback)
end

function NativeUtil.NavigateToAppSetting()
    return WebCamHelper:NavigateToAppSetting()
end

--function NativeUtil.CheckCamera()
--    return WebCamHelper:CheckCamera()
--end
--
--function NativeUtil.Play()
--    WebCamHelper:Play()
--end
--
--function NativeUtil.Stop()
--    WebCamHelper:Stop()
--end
--
--function NativeUtil.Pause()
--    WebCamHelper:Pause()
--end
--
--local _callback, _rawImage, _height, _width, _isFront, _waitingForRst
--function NativeUtil.InitWebCamTexture(callback, rawImage, height, width, isFront)
--    if _waitingForRst then
--        return
--    end
--
--    _waitingForRst = true
--    _callback = callback
--    _rawImage = rawImage
--    _height = height
--    _width = width
--    _isFront = isFront
--
--    SDKMgr.SendCheckPermission(SDKDefine.PermissionType.CAMERA, NativeUtil.InitWebCamTextureCallBack)
--end
--
--function NativeUtil.InitWebCamTextureCallBack(result)
--    _waitingForRst = false
--    if result.ret == 0 then
--        Debug.Log("UNITYWEBCAM_HASAUTHOR")
--        if callback then
--            NativeUtil.GetAndBind(_rawImage, _height,_width, _isFront)
--            callback()
--        else
--            NativeUtil.GetAndBind(_rawImage, _height, _width, _isFront)
--        end
--    else
--        SDKMgr.SendPermissionRequest(SDKDefine.PermissionType.CAMERA, function(result)
--            Debug.Log("UNITYWEBCAM_DONOTHASAUTHOR")
--            if result.ret == 0 then
--                if callback then
--                    NativeUtil.GetAndBind(_rawImage, _height, _width, _isFront)
--                    callback()
--                else
--                    NativeUtil.GetAndBind(_rawImage, _height, _width, _isFront)
--                end
--            end
--        end)
--    end
--
--    _callback = nil
--    _rawImage = nil
--    _height = nil
--    _width = nil
--    _isFront = nil
--end
--
--function NativeUtil.GetAndBind(rawImage, height, width, isFront)
--    local result
--    if isFront == nil then
--        result = WebCamHelper:GetWebCamTexture(height, width)
--    else
--        result = WebCamHelper:GetWebCamTexture(height, width, isFront)
--    end
--
--    if rawImage then
--        WebCamHelper:BindRawImage(rawImage, height, width)
--    end
--
--    return result
--end
----endregion

----region native-打开相册-打开相机
--local AlbumMgr = CS.AlbumLib.AlbumMgr
-----拍照回调事件--nativeCB:Action<byte[]>
--function NativeUtil.TakePhoto(nativeCB)
--    AlbumMgr.Instance:TakePhoto(function(luabytes)
--        if nativeCB then
--            nativeCB(luabytes)
--        end
--    end)
--end
--
-----打开相册回调事件--nativeCB:Action<byte[]>
--function NativeUtil.OpenAlbum(nativeCB)
--    AlbumMgr.Instance:OpenAlbum(function(luabytes)
--        if nativeCB then
--            nativeCB(luabytes)
--        end
--    end)
--end
----endregion
--
----region native-人脸捕获
--local FaceValidator = CS.X3FaceValidator.FaceValidator
-----@param picBytes byte[] 图片字节数据
-----@param width int 图片原始宽
-----@param height int 图片原始高
-----@param isCreate boolean 是否刷新脸部模型
-----@param isRelease boolean 是否释放脸部模型
-----@return UnityEngine.Rect 放回人脸区域
--function NativeUtil.TryDetectFace(picBytes, width, height, isCreate, isRelease)
--    ---1、刷新脸部模型
--    if isCreate then
--        local minfacesize = Mathf.Ceil(Mathf.Max(width, height) * 0.05)
--        FaceValidator.CreateMtcnn(minfacesize, 1) ---第二个参数这里固定为1
--    end
--
--    ---2、检测人脸
--    local maxFaceNum = FaceValidator.DetectFace(picBytes, width, height)
--
--    ---3、获取人脸区域
--    local rect = nil
--    if maxFaceNum > 0 then
--        rect = FaceValidator.GetFaceRect()
--    end
--
--    ---4、释放人脸模型
--    if isRelease then FaceValidator.ReleaseMtcnn() end
--    return rect
--end
--
-----放脸部模型
--function NativeUtil.ReleaseMtcnn()
--    FaceValidator.ReleaseMtcnn()
--end
--
----endregion

local TextureUtility = CS.X3Game.TextureUtility
local _nativeDir = CS.UnityEngine.Application.persistentDataPath .. "/NativeImg/"
---@param spritePath string 需要加载的图片Icon路径
---@param savePath string 需要保存的本地相对路径
---@return string 返回本地绝对路径
function NativeUtil.SaveNativeImage(spritePath, savePath)
    if string.isnilorempty(spritePath) then
        return
    end

    savePath = savePath or spritePath
    local filePath = _nativeDir .. savePath
    local sprite = NativeUtil._GetSprite(spritePath)
    ---安卓后台时存储会噶掉
    if sprite and TextureUtility.SaveNativeImage(sprite, filePath) then
        --Debug.LogError("SaveNativeImage End ", spritePath)
        return filePath
    end
end

function NativeUtil._GetSprite(sprite_name)
    local atlas_name = nil
    local is_path = false
    sprite_name, atlas_name, is_path = GameUtil.GetSpriteAndAtlasNames(sprite_name)
    return CS.X3Game.UIUtility.GetSprite(sprite_name, atlas_name, is_path)
end
return NativeUtil