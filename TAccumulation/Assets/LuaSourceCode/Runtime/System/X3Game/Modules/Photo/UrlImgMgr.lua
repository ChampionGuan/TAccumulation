--- X3@PapeGames
--- UrlImgMgr
--- Created by Tungway
--- Created Date: 2020/12/01
--- Updated by Kan
--- Update Date: 2021/10/25
---@class UrlImgMgr
local UrlImgMgr = {}
local this = UrlImgMgr
local persistentDataPath = CS.UnityEngine.Application.persistentDataPath
local saveRootPath = string.concat(persistentDataPath, "/UrlImg")
local UrlImageDBUtil = require("Runtime.System.X3Game.Modules.Photo.UrlImageDBUtil")
---保存图时本地的最小剩余空间
local SafeSize = 100 --100M
---每次上传自增
local UploadCount = 0
---在本地图片文件系统的业务名称
---@class UrlImgMgr.BizType
UrlImgMgr.BizType = {
    PhotoAlbum = "PhotoAlbum", ---相册
    PhotoAlbumAuto = "PhotoAlbumAuto",
    MHTips = "MHTips", ---弹脸
    ActivityCenter = "ActivityCenter", ---活动相关
    FaceMorph = "FaceMorph", ---捏脸
    HeadIcon = "HeadIcon", ---头像
    HeadBG = "HeadBG", ---个人信息背景
    PlayerShowPhoto = "PlayerShowPhoto", --- 个人信息-照片展示
    Share = "Share", --- 分享
    EasterEggMoment = "EasterEggMoment", ---彩蛋朋友圈图片
    Announcement = "Announcement", ----公告
    ARPhotoAlbum = "ARPhotoAlbum", ---AR拍照
    DynamicCard = "DynamicCard", ---动卡静态图
    Collection = "Collection", ---藏品
    Radio = "Radio", ---广播剧后台播放
    MomentBG = "MomentBG", ---朋友圈头图
    Item = "Item", ---Item 系统
}

---需要加密的业务类别
local needFakeBiz = {
    UrlImgMgr.BizType.PhotoAlbum,
    UrlImgMgr.BizType.MHTips, ---弹脸
    UrlImgMgr.BizType.ActivityCenter, ---活动相关
    UrlImgMgr.BizType.FaceMorph, ---捏脸
    UrlImgMgr.BizType.HeadIcon, ---头像
    UrlImgMgr.BizType.HeadBG, ---个人信息背景
    UrlImgMgr.BizType.PlayerShowPhoto, --- 个人信息-照片展示
    --UrlImgMgr.BizType.Share, --- 分享
    UrlImgMgr.BizType.Announcement, --- 公告
    UrlImgMgr.BizType.ARPhotoAlbum, ---AR拍照
    UrlImgMgr.BizType.DynamicCard, ---动卡静态图
    UrlImgMgr.BizType.Collection, ---藏品
    UrlImgMgr.BizType.Radio, ---广播剧后台播放
    UrlImgMgr.BizType.MomentBG, ---朋友圈头图
    UrlImgMgr.BizType.Item, ---Item 系统
    UrlImgMgr.BizType.EasterEggMoment, ---彩蛋朋友圈图片
}

---本地储存相关，各系统请自行添加
local saveRootPathDic = {
    PhotoAlbum = string.concat(persistentDataPath, "/DeepSpace"),
    PhotoAlbumAuto = string.concat(persistentDataPath, "/DeepSpace"),
    MHTips = string.concat(persistentDataPath, "/UrlImg/MHTips"),
    ActivityCenter = string.concat(persistentDataPath, "/UrlImg/ActivityCenter"),
    FaceMorph = string.concat(persistentDataPath, "/UrlImg/FaceMorph"),
    HeadIcon = string.concat(persistentDataPath, "/UrlImg/HeadIcon"),
    PlayerShowPhoto = string.concat(persistentDataPath, "/UrlImg/PlayerShowPhoto"),
    HeadBG = string.concat(persistentDataPath, "/UrlImg/HeadBG"),
    Share = string.concat(persistentDataPath, "/UrlImg/Share"),
    ARPhotoAlbum = string.concat(persistentDataPath, "/UrlImg/ARPhoto"),
    DynamicCard = string.concat(persistentDataPath, "/UrlImg/DynamicCard"),
    Collection = string.concat(persistentDataPath, "/UrlImg/Collection"),
    Radio = string.concat(persistentDataPath, "/UrlImg/Radio"),
    MomentBG = string.concat(persistentDataPath, "/UrlImg/MomentBG"),
    Item = string.concat(persistentDataPath, "/UrlImg/Item"),
    EasterEggMoment = string.concat(persistentDataPath,"/UrlImg/EasterEggMoment"),
}

---使用平台OSS所需的参数定义
---@class UrlImgMgr.OssChannel
UrlImgMgr.OssChannel = {
    PhotoAlbum = "Photos", ---相册
    Match = "match", ---H5拍照活动
    Common = "Common",
}
---@class UrlImgMgr.EFileSaveCategory
---@field None int 保存大图
---@field Thumb int 保存缩略图
---@field All int 保存缩略图
UrlImgMgr.EFileSaveCategory = {
    None = 1,
    Thumb = 2,
    All = 3,
}
local thumbSuffix = "s"  --缩略图后缀
local textureThumbCompress = 30  --缩率图的 缩小比率
---各业务的图片下载地址
local bizDownloadPreUrlMap = {}
---目前公用的一个地址，其他业务接口也不传入业务类别，先增加一个保底
local _commonPreUrl = ""
---保底图片名称
local _loadingPicNameList = nil
---处理中的文件 图片链接为key,
---@type table<string, table<GameObject, function>>
local _processingDic = {}
---对应一张图被多个节点触发下载的情况
---@type table<string, table<GameObject, function>>
local _attachProcessingDic = {}
local CS_TEXTURE_HELPER = CS.X3Game.TextureUtility
local CS_DIRECTORY_HELPER = CS.System.IO.Directory
local CS_FILE_HELPER = CS.System.IO.File
local CS_DateTime_HELPER = CS.System.DateTime
local CS_URL_IMAGE_UTL = CS.X3Game.GameHelper.UrlImageUtil
local CS_UI_HELPER = CS.X3Game.UIUtility
local CS_WEB_UTIL = CS.X3Game.GameHelper.WebRequestUtil
local CS_DOWNLOAD_UTIL = CS.X3Game.Download.DownloadUtils
local CS_X3FILE_HELPER = CS.PapeGames.X3.FileUtility

---@class UrlImgMgr.EFileSaveType
UrlImgMgr.EFileSaveType = {
    PNG = 1,
    JPG = 2,
    TGA = 3,
}
---将Texture2D转为Sprite ------9-9BY DL 尽量使用SetImageWithTexture --
---@param tex Texture2D
---@return Sprite Sprite对象
--function UrlImgMgr.Texture2DToSprite(tex)
--    if tex == nil then
--        return nil
--    end
--    return CS_TEXTURE_HELPER.CreateSprite(tex)
--end
---将Image组件上的图设置到另外一个组件上
---@param baseImage Image 带有图像的image组件
---@param target Object 需要接受图像的obj
---@param useNativeSize bool 是否使用原始大小
function UrlImgMgr.SetImageWithObject(baseImage, target, useNativeSize)
    CS_URL_IMAGE_UTL.SetImageWithObject(baseImage, target, useNativeSize and true or false)
end
----交换两个Image组件的sprite
---@param imageA Image 组件A
---@param imageB Image 组件B
function UrlImgMgr.SwapImage(imageA, imageB)
    CS_URL_IMAGE_UTL.SwapImage(imageA, imageB)
end
---将Texture2D在Image控件上展示
---@param tex Texture2D 源贴图
---@param go Object 图片控件
---@param useNativeSize bool 是否使用原始大小
---@param tempBind bool 临时建立绑定关系
function UrlImgMgr.SetImageWithTexture(tex, go, useNativeSize, tempBind)
    if tex == nil or go == nil then
        Debug.LogError("SetImageWithTexture With nil ", tex, go)
        return
    end
    CS_URL_IMAGE_UTL.SetImageWithTexture(tex, go, useNativeSize and true or false, tempBind and true or false)
end

---读取一个Sprite对象, 并设置到Image
---@param go Object
---@param fileName String 原始文件名
---@param biz UrlImgMgr.BizType 业务枚举
---@param ignoreCache bool 是否忽略缓存，默认为false
function UrlImgMgr.SetSpriteFromFile(go, fileName, biz, ignoreCache)
    local result = true
    local needFake = UrlImgMgr.IsNeedFake(biz)
    local fakeName = nil
    local fileFullPath = nil

    fileName = UrlImgMgr._GetFileNameWithPath(fileName)
    if (needFake) then
        fakeName = UrlImageDBUtil.GetFakeName(fileName, biz)
        fileFullPath = UrlImgMgr.GetSaveImgFilePath(fakeName, biz)
        result = UrlImageDBUtil.CheckFile(fileName, fileFullPath, biz)
    end
    if (result) then
        result = UrlImgMgr._SetSpriteFromFile(go, needFake and fakeName or fileName, biz, ignoreCache)
    else
        UrlImgMgr.OnReadyTex(go, biz, fileFullPath)
    end
    return result
end

---从IO内读取一个Sprite对象, 并设置到Image(内部使用)
---@param go Object
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务枚举
---@param ignoreCache bool 是否忽略缓存，默认为false
---@return Boolean 返回是否成功
function UrlImgMgr._SetSpriteFromFile(go, fileName, biz, ignoreCache)
    if go then
        local result = false
        local filePath = UrlImgMgr.GetFileFullString(fileName, biz)
        if (not UrlImgMgr.CheckProcessFile(filePath)) then
            result = UrlImgMgr.SetSpriteWithFullPath(go, filePath, ignoreCache, biz)
        end

        ---未成功时走保底
        if (not result) then
            UrlImgMgr.OnReadyTex(go, biz, filePath)
        else
            UrlImgMgr.RemoveLoadingCom(go)
        end

        return result
    end
    return false
end

---移除Loading菊花
function UrlImgMgr.RemoveLoadingCom(go)
    if (not GameObjectUtil.IsNull(go)) then
        CS_URL_IMAGE_UTL.RemoveLoadingCom(go.transform)
    end
end

function UrlImgMgr.AddLoadingCom(go, imageName)
    if (not GameObjectUtil.IsNull(go)) then
        CS_URL_IMAGE_UTL.AddLoadingCom(go.transform, imageName)
    end
end

---触发下载或加载失败时
---@param go Object
---@param fullPath String 本地文件路径
---@param biz UrlImgMgr.BizType 业务枚举
function UrlImgMgr.OnReadyTex(go, biz, fullPath)
    local imageName = ""

    if (not _loadingPicNameList) then
        _loadingPicNameList = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DYNAMICLOADINGGUARANTEEPICTURE)
    end

    if (biz == UrlImgMgr.BizType.MHTips) then
        imageName = _loadingPicNameList[2]
        --UIUtil.SetImage(go, "x3_com_imgerro_2", nil, true)
    elseif (biz == UrlImgMgr.BizType.ActivityCenter) then
        imageName = _loadingPicNameList[1]
        --UIUtil.SetImage(go, "x3_com_imgerro_1", nil, true)
    elseif (biz == UrlImgMgr.BizType.HeadBG) then
        imageName = _loadingPicNameList[3]
        --UIUtil.SetImage(go, "x3_com_imgerro_3", nil, true)
    else
        imageName = _loadingPicNameList[1]
        --UIUtil.SetImage(go, "x3_com_imgerro_1", nil, true)
    end

    ---此时意味着失败
    if (fullPath) then
        --if ((not UrlImgMgr.CheckProcessFile(fullPath)) and CS_FILE_HELPER.Exists(fullPath)) then
            --Debug.LogWarning("触发删除", fullPath)
            --CS.System.IO.File.Delete(fullPath)
        --end
        UrlImgMgr.AddLoadingCom(go, imageName)
    else
        ---需要确认下，设置图失败的，不能移除，还要考虑下复用的问题
        UrlImgMgr.AddLoadingCom(go, imageName)
    end
end

---是否需要本地校验及伪装
---@param biz UrlImgMgr.BizType 业务枚举
function UrlImgMgr.IsNeedFake(biz)
    if (not biz) then
        Debug.LogWarning("IsNeedFake biz is nil, 前置流程中没有传递对应业务")
    end
    return table.containsvalue(needFakeBiz, biz)
end

---获取文件全路径
function UrlImgMgr.GetFilePath(fileName, biz)
    if (string.isnilorempty(fileName)) then
        Debug.LogError("UrlImgMgr.GetFilePath fileName is nil")
        return
    end

    local fakeName = nil
    ---本地防替换处理
    if (UrlImgMgr.IsNeedFake(biz)) then
        fakeName = UrlImageDBUtil.GetFakeName(fileName)
    end

    local filePath = this.GetFileFullString(fakeName or fileName, biz)
    if (filePath == nil) then
        Debug.LogError("UrlImgMgr.GetFilePath filePath is nil")
        return
    end

    return filePath
end

--region 保存文件相关
---将包内图转到持久化目录下
---@param spriteName string 图片名称
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务类别
---@return String 保存路径
function UrlImgMgr.SaveSprite(spriteName, fileName, biz)
    if string.isnilorempty(spriteName) or string.isnilorempty(fileName) then
        return
    end
    local fakeName = nil
    fileName = UrlImgMgr.GetBaseName(fileName)
    if (this.IsNeedFake(biz)) then
        fakeName = UrlImageDBUtil.GetFakeName(fileName, biz)
    end
    local filePath = this._GetFileFullURL(fakeName, biz)

    local atlas_name = nil
    local is_path = false
    spriteName, atlas_name, is_path = GameUtil.GetSpriteAndAtlasNames(spriteName)
    local spriteCom = CS_UI_HELPER.GetSprite(spriteName, atlas_name, is_path)

    if spriteCom and CS_TEXTURE_HELPER.SaveNativeImage(spriteCom, filePath) then
        --Debug.LogError("SaveNativeImage End ", spritePath)
        UrlImageDBUtil.UpdateData(fileName, fakeName, filePath)
        --Debug.LogError("fileName ", fileName, " fakeName ", fakeName, " filePath ", filePath)
        return filePath
    end
end

---保存文件至可写目录下
---@param texture Texture2D 文件数据
---@param fileName String 文件名
---@param type UrlImgMgr.EFileSaveType 文件类型
---@param category UrlImgMgr.EFileSaveCategory 保存类别
---@param biz UrlImgMgr.BizType 业务类别
---@return String,String 保存路径,md5String
function UrlImgMgr.SaveFile(texture, fileName, type, category, biz)
    if (texture == nil) then
        Debug.LogError("UrlImgMgr.SaveFile fileData is nil")
        return
    end

    if (string.isnilorempty(fileName)) then
        Debug.LogError("UrlImgMgr.SaveFile fileName is nil")
        return
    end

    local fakeName = nil
    local thumbFakeName = nil
    local thumbFilePath = nil
    local md5String = nil
    --Debug.LogError("UrlImgMgr.SaveFile IsNeedFake ", UrlImgMgr.IsNeedFake(biz), " biz ", biz, " FakeName ", UrlImageDBUtil.GetFakeName(fileName), " category ", category)
    ---本地防替换处理
    if (UrlImgMgr.IsNeedFake(biz)) then
        fakeName = UrlImageDBUtil.GetFakeName(fileName)
    end

    ---缩略图路径
    if (category == UrlImgMgr.EFileSaveCategory.All) then
        local thumbName = UrlImgMgr.GetThumbName(fileName)
        thumbFakeName = UrlImageDBUtil.GetFakeName(thumbName)
        thumbFilePath = UrlImgMgr.GetFilePath(thumbFakeName, biz)
    end

    local isExists, filePath = this._CheckDirectory(fakeName or fileName, biz)
    if isExists then
        return filePath
    end

    if type == UrlImgMgr.EFileSaveType.JPG then
        this._SaveJPGFile(texture, filePath, category, thumbFilePath)
    elseif type == UrlImgMgr.EFileSaveType.PNG then
        this._SavePNGFile(texture, filePath, category, thumbFilePath)
        ---编辑器下额外支持下查看需求
        if UNITY_EDITOR then
            local editorPath = string.replace(filePath, ".bin", ".png")
            this._SavePNGFile(texture, editorPath, category)
        end

        --CS_TEXTURE_HELPER.SaveTextureToPNG(texture, filePath)
    elseif type == UrlImgMgr.EFileSaveType.TGA then
        CS_TEXTURE_HELPER.SaveTextureToTGA(texture, filePath)
    end
    --Debug.Log("<color=#f6ad00>[SaveFile] </color>", filePath)
    ---防替换数据库
    if (fakeName) then
        fileName = UrlImgMgr.GetBaseName(fileName)
        md5String = UrlImageDBUtil.UpdateData(fileName, fakeName, filePath)
        if (category == UrlImgMgr.EFileSaveCategory.All) then
            UrlImageDBUtil.UpdateData(UrlImgMgr.GetThumbName(fileName), thumbFakeName, thumbFilePath)
        end
    end
    return filePath, md5String
end

---保存PNG
---@param tex Texture2D 文件数据
---@param filePath String 保存文件路径
---@param category UrlImgMgr.EFileSaveCategory 保存类别
---@param thumbFilePath String 缩略图路径
function UrlImgMgr._SavePNGFile(tex, filePath, category, thumbFilePath)
    if category == UrlImgMgr.EFileSaveCategory.Thumb then
        --仅保存缩略图
        CS_TEXTURE_HELPER.SaveTextureThumbToPNG(tex, filePath, textureThumbCompress)
    else
        CS_TEXTURE_HELPER.SaveTextureToPNG(tex, filePath, category == UrlImgMgr.EFileSaveCategory.All, textureThumbCompress, thumbFilePath)
    end
end

---保存JPG
---@param tex Texture2D 文件数据
---@param filePath String 保存文件路径
---@param category UrlImgMgr.EFileSaveCategory 保存类别
---@param thumbFilePath String 缩略图路径
function UrlImgMgr._SaveJPGFile(tex, filePath, category, thumbFilePath)
    if category == UrlImgMgr.EFileSaveCategory.Thumb then
        --仅保存缩略图
        CS_TEXTURE_HELPER.SaveTextureThumbToJPG(tex, filePath, textureThumbCompress)
    else
        if (category == UrlImgMgr.EFileSaveCategory.All) then
            CS_TEXTURE_HELPER.SaveTextureThumbToJPG(tex, thumbFilePath, textureThumbCompress)
        end
        CS_TEXTURE_HELPER.SaveTextureToJPG(tex, filePath)
    end
end

---保存纹理至可写目录下
---@param tex Texture2D 纹理
---@param fileName String 文件名
---@param isThumb bool 缩略图
---@param biz UrlImgMgr.BizType 业务枚举
---@return String 保存路径
function UrlImgMgr.SaveTextureToJpgFile(tex, fileName, isThumb, biz)
    if (tex == nil) then
        Debug.LogError("texture2D is nil")
        return
    end
    if (string.isnilorempty(fileName)) then
        Debug.LogError("fileName is nil")
        return
    end

    local category = UrlImgMgr.EFileSaveCategory.None
    if isThumb then
        category = UrlImgMgr.EFileSaveCategory.Thumb
    elseif biz == UrlImgMgr.BizType.PhotoAlbum then
        category = UrlImgMgr.EFileSaveCategory.All
    end

    return this.SaveFile(tex, fileName, UrlImgMgr.EFileSaveType.JPG, category, biz)
end

---保存纹理至可写目录下
---@param tex Texture2D 纹理
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务枚举
---@param category UrlImgMgr.EFileSaveCategory 保存类别
function UrlImgMgr.SaveTextureToPngFile(tex, fileName, biz, category)
    if (tex == nil) then
        Debug.LogError("texture2D is nil")
        return
    end
    if (string.isnilorempty(fileName)) then
        Debug.LogError("fileName is nil")
        return
    end
    local _category = category or UrlImgMgr.EFileSaveCategory.None
    return this.SaveFile(tex, fileName, UrlImgMgr.EFileSaveType.PNG, _category, biz)
end

---保存纹理至可写目录下
---@param spriteName string 图片名称
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务枚举
---@param category UrlImgMgr.EFileSaveCategory 保存类别
function UrlImgMgr.SaveSpriteToPngFile(spriteName, fileName, biz)
    --UrlImgMgr.SaveSpriteToPngFile("b2_card_st_0014", "b2_card_st_0014", UrlImgMgr.BizType.Radio)
    if (spriteName == nil) then
        Debug.LogError("spriteName is nil")
        return
    end
    if (string.isnilorempty(fileName)) then
        Debug.LogError("fileName is nil")
        return
    end
    return this.SaveSprite(spriteName, fileName, biz)
end

---保存纹理至可写目录下
---@param tex Texture2D 纹理
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务枚举
function UrlImgMgr.SaveTextureToTgaFile(tex, fileName, biz)
    if (tex == nil) then
        Debug.LogError("texture2D is nil")
        return
    end
    if (string.isnilorempty(fileName)) then
        Debug.LogError("fileName is nil")
        return
    end

    this.SaveFile(tex, fileName, UrlImgMgr.EFileSaveType.TGA, UrlImgMgr.EFileSaveCategory.None, biz)
end

--endregion

function UrlImgMgr.CheckSafeSize()
    local freeSize = SubPackageUtil.GetDiskFreeSpace()

    return freeSize > SafeSize
end

---从缓存或本地文件中获得一个Texture2D对象
---@param fileName string 文件名
---@param linear bool 是否为linear的，默认为true
---@param ignoreCache bool 是否忽略缓存，默认为false
---@param biz UrlImgMgr.BizType 业务枚举
---@param bindingObj Object 需要绑定的go
---@param singleBind bool 是否单独绑定
---@return Texture2D
function UrlImgMgr.LoadTextureFromFile(fileName, linear, ignoreCache, biz, bindingObj, singleBind)
    if (string.isnilorempty(fileName)) then
        Debug.LogError("fileName is nil")
        return nil
    end
    if linear == nil then
        linear = true
    end
    ignoreCache = ignoreCache or false
    singleBind = singleBind or false
    local orginName = fileName
    if (this.IsNeedFake(biz)) then
        fileName = UrlImageDBUtil.GetFakeName(fileName, biz)
    end

    local tex = nil
    local filePath = this._GetFileFullURL(fileName, biz)
    if (not CS_FILE_HELPER.Exists(filePath)) or (not UrlImageDBUtil.CheckFile(orginName, filePath, biz)) then
        --Debug.LogError(string.format("found no file from path: %s", filePath))
        return nil
    end

    tex = CS_URL_IMAGE_UTL.GetTextureFromFile(fileName, filePath, bindingObj, ignoreCache, linear, biz, singleBind)

    return tex
end

---临时处理复制文件需求
function UrlImgMgr.CopyFileTemp(fromName, biz, toName)
    local fromPath = this._GetFileFullURL(fromName, biz)
    local toPath = this._GetFileFullURL(toName, biz)
    CS_URL_IMAGE_UTL.CopyTexTemp(fromPath, toPath)
end

function UrlImgMgr.CrcTest(name, biz)
    local DownloadUtil = CS.X3Game.Download.DownloadUtils

    local fromPath = this._GetFileFullURL(name, biz)
    Debug.LogError(" name ", name, " crc ", DownloadUtil.GetFileCrc32(fromPath))
end

function UrlImgMgr.Md5Test(name, biz)
    local DownloadUtil = CS.X3Game.Download.DownloadUtils

    local fromPath = this._GetFileFullURL(name, biz)
    Debug.LogError(" name ", name, " md5 ", DownloadUtil.GetFileMD5(fromPath))
end

---为Image设置滤镜
---@param img Image Image实例
---@param lutTexture Texture2D 滤镜Texture资源
function UrlImgMgr.SetFilter(img, lutTexture)
    CS_URL_IMAGE_UTL.SetImageFilter(lutTexture, img)
end

function UrlImgMgr.GetFileFullString(fileName, biz)
    local rootPath = UrlImgMgr._GetRootPath(biz)
    local filePath = string.concat(rootPath, "/", fileName)
    return filePath
end

---通过全路径设置图片
---@param go Object 需要设置图片的GO
---@param filePath string 全路径
---@param ignoreCache bool 是否忽略缓存，默认为false
---@return bool 是否设置成功
function UrlImgMgr.SetSpriteWithFullPath(go, filePath, ignoreCache, biz)
    local fileName = UrlImgMgr.GetFileNameWithPath(filePath)
    if (biz and this.IsNeedFake(biz)) then
        filePath = UrlImageDBUtil.GetFakeName(filePath, biz)
    end
    --if(checkDB ~= false) then
    --    checkDB = true
    --end

    --检查fileName是否能通过DB的校验
    --if (checkDB and (not UrlImageDBUtil.CheckFile(fileName, filePath))) then
    --    return false
    --end
    return CS_URL_IMAGE_UTL.SetImageWithFileName(fileName, filePath, go, ignoreCache and true or false, biz)
end

---设置各业务的下载链接前缀 --- 换用平台版本后不用使用
function UrlImgMgr.SetBizDownloadUrl(biz, url)
    if (biz and url) then
        bizDownloadPreUrlMap[biz] = url

        ---保底
        if (not _commonPreUrl) then
            _commonPreUrl = url
        end
    else
        Debug.LogError("SetBizDownloadUrl arg error")
    end
end

---获取头像地址
---@param iconName String 头像文件名
---@param uid int 账号ID
---@return String 文件名
function UrlImgMgr.GetLocalImgName(iconName, uid)
    uid = uid or PlayerUtil.GetUid()
    return string.concat(iconName, uid)
end

---检查是否在本地已存在该文件
---@param fileName String 文件名
---@return bool,String 1:是否存在该文件,2:存放路径
function UrlImgMgr._CheckDirectory(fileName, biz)
    local filePath = this._GetFileFullURL(fileName, biz)
    local rootPath = this._GetRootPath(biz)
    if (not CS_DIRECTORY_HELPER.Exists(rootPath)) then
        CS_DIRECTORY_HELPER.CreateDirectory(rootPath)
    else
        if (CS_DIRECTORY_HELPER.Exists(filePath)) then
            return true, filePath
        end
    end

    return false, filePath
end

function UrlImgMgr._GetRootPath(biz)
    local rootPath = (biz and saveRootPathDic[biz]) and saveRootPathDic[biz] or saveRootPath
    return rootPath
end

---对于外部业务来说，认为仅SetUrlImage接口可以附加下载，针对相册的特殊需求，先放到相册内处理
function UrlImgMgr.ReadyAlbumDownload(fileName, biz, fullUrl)
    ---标记处理中
    local fileFullPath = UrlImgMgr.GetSaveImgFilePath(this.IsNeedFake(biz) and UrlImageDBUtil.GetFakeName(fileName, biz) or fileName, biz)
    _processingDic[fileFullPath] = true
    _processingDic[fullUrl] = fileFullPath

end

function UrlImgMgr.OnAlbumDownloaded(fileName, biz, fullUrl)
    local fileFullPath = UrlImgMgr.GetSaveImgFilePath(this.IsNeedFake(biz) and UrlImageDBUtil.GetFakeName(fileName, biz) or fileName, biz)
    _processingDic[fileFullPath] = false
    _processingDic[fullUrl] = nil
end

---明确的下载行为
---@param fileName string  要下载的文件名称
---@param successCB function 成功回调
---@param errorCB function 失败回调
---@param progressCB function 进度回调
---@param biz UrlImgMgr.BizType 业务类型
---@param fullUrl string 仅拥有完整外链的图片才需传入
function UrlImgMgr.DownloadTex2D(fileName, successCB, errorCB, progressCB, biz, fullUrl)
    if (UrlImgMgr.Exists(fileName, biz)) then
        Debug.LogError("没有检查不要下载，不予执行成功回调（本地文件已存在）")
        if (errorCB) then
            errorCB()
        end
        return
    end

    local endLessUrl = bizDownloadPreUrlMap[biz] or _commonPreUrl
    if (not endLessUrl) then
        Debug.LogError("UrlImgMgr.DownloadTex2D No Pre Url")
        return
    end
    local localPath = UrlImgMgr._GetRootPath(biz)
    local serverfullUrl = fullUrl or fileName--string.format("%s/%s", endLessUrl, fileName)
    local localFullPath = ""
    if (this.IsNeedFake(biz)) then
        localFullPath = string.format("%s/%s", localPath, UrlImageDBUtil.GetFakeName(fileName, biz))
    else
        localFullPath = string.format("%s/%s", localPath, fileName)
    end
    --Debug.LogError("准备下载 11 ", serverfullUrl, " localFullPath ", localFullPath, " fileName ", fileName)
    CS_URL_IMAGE_UTL.DownLoadTexture2D(fileName, serverfullUrl, localFullPath, successCB or nil, errorCB or nil, progressCB or nil)
end

---更新tex缓存
---@param fileName string  要更新的文件名称
---@param bindingObj Object 绑定go
---@param biz UrlImgMgr.BizType 业务类型
---@param linear bool 是否为线性贴图
function UrlImgMgr.UpdateTexCache(fileName, bindingObj, biz, linear)
    if (linear == nil) then
        linear = true
    end
    local needFake = UrlImgMgr.IsNeedFake(biz)
    local fileFullPath = UrlImgMgr.GetSaveImgFilePath(needFake and UrlImageDBUtil.GetFakeName(fileName, biz) or fileName, biz)
    CS_URL_IMAGE_UTL.UpdateTexCache(fileFullPath, bindingObj, linear)
end

---仅供外部自行上传图片后，需要更新伪装所需
---@param fileName string 文件名
---@param biz UrlImgMgr.BizType 业务类型
function UrlImgMgr.UpdateFakeDBData(fileName, biz)
    local needFake = UrlImgMgr.IsNeedFake(biz)
    if (needFake) then
        local fakeName = UrlImageDBUtil.GetFakeName(fileName, biz)
        local fileFullPath = UrlImgMgr.GetSaveImgFilePath(fakeName, biz)
        if (CS_FILE_HELPER.Exists(fileFullPath)) then
            UrlImageDBUtil.UpdateData(fileName, fakeName, fileFullPath)
        end
    end
end

---用于下载完成时，进行一次文件大小是否匹配的检查
function UrlImgMgr._OnCSDownloadComplete(req)
    if(req and req.GetResponseHeader) then
        local contentLength = req:GetResponseHeader("Content-Length")
        if(not string.isnilorempty(contentLength)) then
            local requestUrl = req.url
            local cachePath = UrlImgMgr.CheckProcessFile(requestUrl)
            if(cachePath) then
                local curLength = CS_DOWNLOAD_UTIL.GetFileLength(cachePath)
                return curLength == tonumber(contentLength)
            end
        end
    end
    return true;
end

---设置一张网络图片(如为缩略图，则可能从大图上取) ---方法太长了，下个迭代拆分下 12.17 by dl
---@param UObject UObject 图片控件
---@param fileName string 图片文件名
---@param onComplete fun(Boolean) 完成后的回调
---@param isThumb fun(Boolean) 是否使用缩略图
---@param biz UrlImgMgr.BizType 业务类型
---@param fullUrl string 仅拥有完整外链的图片才需传入
---@param dontSet bool 是否无需自动设置图片 ---临时改动，0205分支已调整为解注册做法
function UrlImgMgr.SetUrlImage(UObject, fileName, onComplete, isThumb, biz, fullUrl, dontSet)
    --Debug.LogWarning("SetUrlImage ", fileName, " isThumb ", isThumb, " biz ", biz, " fullUrl ", fullUrl)
    if string.isnilorempty(fileName) then
        return
    end

    --如果fileName包含/，则分割出文件名
    local fileNameArr = string.split(fileName, "/")
    if fileNameArr and #fileNameArr > 1 then
        fullUrl = fileName
        fileName = fileNameArr[#fileNameArr]
    end

    --如果fileName包含后缀，则去除后缀
    fileNameArr = string.split(fileName, ".")
    if fileNameArr and #fileNameArr > 1 then
        fileName = fileNameArr[1]
    end

    ---本地防替换处理
    ---大图的fakeName
    local fakeName = nil
    local needFake = UrlImgMgr.IsNeedFake(biz)

    ---缩略图文件名
    local thumbFileName = UrlImgMgr.GetThumbName(fileName)
    ---对应要处理的基础文件名（大图或缩略图文件名）
    local baseCurFileName = isThumb and thumbFileName or fileName

    ---大图文件路径
    local fileFullPath = ""
    ---需要处理的文件路径（大图或缩略图文件名）
    local curFileFullPath = ""
    ---伪装文件
    if (needFake) then
        fakeName = UrlImageDBUtil.GetFakeName(fileName, biz)
        thumbFileName = UrlImageDBUtil.GetFakeName(thumbFileName)
        fileFullPath = UrlImgMgr.GetSaveImgFilePath(fakeName, biz)
        curFileFullPath = isThumb and UrlImgMgr.GetSaveImgFilePath(thumbFileName, biz) or fileFullPath
    else
        fileFullPath = UrlImgMgr.GetSaveImgFilePath(fileName, biz)
        curFileFullPath = isThumb and UrlImgMgr.GetSaveImgFilePath(thumbFileName, biz) or fileFullPath
    end

    ---已经在下载中的，准备加到回调列表中处理
    local isProcess = UrlImgMgr.CheckProcessFile(fileFullPath)
    local checkResult = false

    ---下载中的不可直接设置，本地图还没处理好
    if (not isProcess) then
        ---验证本地是否已存在
        local fileExist = CS_FILE_HELPER.Exists(curFileFullPath)
        checkResult = fileExist
        if (needFake and fileExist) then
            checkResult = UrlImageDBUtil.CheckFile(baseCurFileName, curFileFullPath, biz)
            ---本地存在，不在下载中，校验未通过，直接删除
        if ((not UrlImgMgr.CheckProcessFile(fileFullPath)) and fileExist and (not checkResult) and fullUrl) then
                ---这里如果是小图，需要确保不会删除大图，所以使用curFileFullPath
                Debug.LogWarning("SetUrlImage 删除本地文件 ", curFileFullPath)
                CS_FILE_HELPER.Delete(curFileFullPath)
            end
        end
    end
    ------------下载组件的cache去除
    if (checkResult) then
        if(not dontSet) then
            checkResult = UrlImgMgr.SetSpriteFromFile(UObject, baseCurFileName, biz)
        end
        if (onComplete) then
            onComplete(checkResult, baseCurFileName)
        end
        ---有时下载完毕，但是下载到的文件是不完整或内容缺失的，需要处理下
        if (not checkResult) then
            Debug.LogWarning("SetUrlImage 下载到了错误的文件，直接删除 ", fileFullPath)
            CS_FILE_HELPER.Delete(fileFullPath)
        end
        return
    else
        ---本地不存在时，按是否为缩略图处理
        ---缩略图先检查本地是否有大图
        local needThumb = false
        if (isThumb and (not isProcess)) then
            ---假如大图存在时，生成小图赋值即可
            if (CS_FILE_HELPER.Exists(fileFullPath)) then
                local result = true
                if (needFake) then
                    result = UrlImageDBUtil.CheckFile(fileName, fileFullPath, biz)
                end
                if (result) then
                    CS_URL_IMAGE_UTL.SetThumbImage(fileFullPath, curFileFullPath, UObject, biz)
                    ---有时内存里有，但是本地文件已经被删掉了
                    UrlImageDBUtil.UpdateData(baseCurFileName, thumbFileName, curFileFullPath)
                else
                    ---大图失效时，直接删除
                    CS_FILE_HELPER.Delete(fileFullPath)
                end

                if(result) then
                    if (onComplete) then
                        onComplete(result)
                    end
                    return
                else
                    needThumb = true
                end
            else
                needThumb = true
            end
        end
        --准备走下载流程
        local successFunc = nil
        local failFunc = nil

        ---成功回调
        successFunc = function()
            --Debug.LogError("下载成功，准备触发 ", UrlImgMgr.GetBaseName(fileFullPath))
            UrlImgMgr._RemoveProcessFile(fileFullPath, fullUrl)
            if (needThumb) then
                UrlImgMgr.RemoveLoadingCom(UObject)
                UrlImageDBUtil.UpdateData(fileName, fakeName, fileFullPath)
            else
                UrlImageDBUtil.UpdateData(fileName, fakeName, fileFullPath)
            end
            ---只有下载的回调才可触发回调队列
            UrlImgMgr.HandleProcessCallback(fileFullPath, true)
        end
        failFunc = function()
            --Debug.LogError("下载失败，准备触发 ", UrlImgMgr.GetBaseName(fileFullPath))
            UrlImgMgr._RemoveProcessFile(fileFullPath, fullUrl)
            ---只有下载的回调才可触发回调队列
            UrlImgMgr.HandleProcessCallback(fileFullPath, false)
        end
        ---触发下载的回调队列中直接放置标记位，追加的则放入包装后的回调
        UrlImgMgr._AddProcessFile(fileFullPath, fullUrl)
        UrlImgMgr.AddAttachProcessFile(fileFullPath, UObject, function(downloadResult)
            local result = false
            if (downloadResult) then
                if (needThumb) then
                    result = CS_URL_IMAGE_UTL.SetThumbImage(fileFullPath, curFileFullPath, UObject, biz)
                    CS_URL_IMAGE_UTL.RemoveLoadingCom(UObject)
                    if (result) then
                        UrlImageDBUtil.UpdateData(baseCurFileName, thumbFileName, curFileFullPath)
                    end
                else
                    result = UrlImgMgr.SetSpriteFromFile(UObject, fileName, biz, false)
                end
            end
            if (onComplete) then
                onComplete(result)
            end
        end)
        Debug.Log("有正在处理的下载, 先加载到队列中 ", fileFullPath)

        --Debug.LogError("准备下载，加入基础的process ", UrlImgMgr.GetBaseName(fileFullPath))

        ---先用保底图
        UrlImgMgr.OnReadyTex(UObject, biz)
        ---本地没有，准备下载
        if (not isProcess) then
            UrlImgMgr.DownloadTex2D(fileName, successFunc, failFunc, nil, biz, fullUrl)
        end
    end
end

---取消对应节点的下载回调，仅为特殊需求预留
---@param obj UObject
function UrlImgMgr.RemoveUrlImageCallback(obj)
    local delTable = PoolUtil.GetTable()
    --for path, goDic in pairs(_processingDic) do
    --    for go, cb in pairs(goDic) do
    --        if(go == obj) then
    --            table.insert(delTable, path)
    --        end
    --    end
    --end
    for path, goDic in pairs(_attachProcessingDic) do
        for go, cb in pairs(goDic) do
            if (go == obj) then
                table.insert(delTable, path)
            end
        end
    end

    for i = 1, #delTable do
        --_processingDic[delTable[i]][obj] = nil;
        _attachProcessingDic[delTable[i]][obj] = nil;
    end
    PoolUtil.ReleaseTable(delTable)
end

---记录对应文件是否在处理中
---@param fileFullPath string
function UrlImgMgr._AddProcessFile(fileFullPath, fullUrl)
    --if(not _processingDic[fileFullPath]) then
    --    _processingDic[fileFullPath] = {}--PoolUtil.GetTable()
    --end
    --_processingDic[fileFullPath][obj] = callback
    _processingDic[fileFullPath] = true
    if(fullUrl) then
        _processingDic[fullUrl] = fileFullPath
    end

end

---
function UrlImgMgr._RemoveProcessFile(fileFullPath, fullUrl)
    _processingDic[fileFullPath] = nil
    if(fullUrl) then
        _processingDic[fullUrl] = nil
    end
end


function UrlImgMgr.CheckProcessFile(arg)
    return _processingDic[arg]
end

---增加需要同步触发的事件
function UrlImgMgr.AddAttachProcessFile(fileFullPath, obj, callback)
    if (not _attachProcessingDic[fileFullPath]) then
        _attachProcessingDic[fileFullPath] = {}--PoolUtil.GetTable() ---12.24 这里会拿到dialog的table，导致dialog错误，周一沟通下
    end
    _attachProcessingDic[fileFullPath][obj] = callback
end

---下载完成后，触发所有回调
---@param obj UObject
---@param result bool 下载结果
function UrlImgMgr.HandleProcessCallback(fileFullPath, result)
    --Debug.LogError("HandleProcessCallback，准备触发 ", UrlImgMgr.GetBaseName(fileFullPath))
    if (_attachProcessingDic[fileFullPath]) then
        for node, cb in pairs(_attachProcessingDic[fileFullPath]) do
            --Debug.LogError("fileFullPath ", node, " cb ", cb, " node.activeInHierarchy ", node.activeInHierarchy, " result ", result)
            if ((not GameObjectUtil.IsNull(node)) and node.gameObject and node.gameObject.activeInHierarchy) then
                cb(result);
            end
        end
    end
    _attachProcessingDic[fileFullPath] = nil

    --PoolUtil.ReleaseTable(_processingDic[fileFullPath])
end

---上传图片
---@param tex Texture2D 纹理
---@param successCB fun(fileName:String):void 成功的回调(第二个参数是服务器私钥)
---@param errorCB fun(any):void 失败的回调
---@param progressCB fun(Float):void 进度回调
---@param biz UrlImgMgr.BizType 业务类型
---@param isPng boolean 是否为png格式
function UrlImgMgr.Upload(tex, successCB, errorCB, progressCB, biz, isPng)
    if (not UNITY_EDITOR) then
        Debug.LogError("UrlImgMgr.Upload error, don't use in mobile")
        return
    end

    local handler = Uri:GetHandler(nil, biz)
    handler.texture = tex
    handler.isPng = isPng
    handler.fileRootDir = this._GetRootPath(biz)--saveRootPath
    handler:Subscribe(successCB, errorCB, progressCB)
    Uri:Upload(handler)
end

---编辑器与RUNTIME分情况处理
---@param tex Texture2D 纹理
---@param successCB fun(fileName:String):void 成功的回调(第二个参数是服务器私钥)
---@param errorCB fun(any):void 失败的回调
---@param progressCB fun(Float):void 进度回调
---@param channel UrlImgMgr.OssChannel oss场景
---@param biz UrlImgMgr.BizType 业务类型
---@param isPng boolean 是否为png格式
function UrlImgMgr.UploadTexture(texture, successCB, errorCB, progressCB, channel, biz, isPng)
    if (UNITY_EDITOR) then
        if (not biz) then
            Debug.LogError("UploadTexture biz is nil, 使用时需要传递对应业务")
        end
        UrlImgMgr.Upload(texture, successCB, errorCB, progressCB, biz, isPng)
    else
        UrlImgMgr.UploadWithSDK(texture, successCB, errorCB, channel, biz, isPng)
    end
end

---@param biz UrlImgMgr.BizType 业务类型
function UrlImgMgr.UploadWithSDK(texture, successCB, errorCB, channel, biz, isPng)
    local fileName = "Upload" .. os.time() .. UploadCount
    local filePath = isPng and UrlImgMgr.SaveTextureToPngFile(texture, fileName, biz) or UrlImgMgr.SaveTextureToJpgFile(texture, fileName, nil, biz)
    local callback = function(result)
        if (result.ret == 0) then
            local headLessName = UrlImgMgr.GetFileNameWithPath(result.url)
            local resultName = UrlImgMgr.IsNeedFake(biz) and UrlImageDBUtil.GetFakeName(headLessName, biz)
            local newfilePath = UrlImgMgr.GetSaveImgFilePath(resultName, biz)
            if CS_FILE_HELPER.Exists(newfilePath) then
                CS_FILE_HELPER.Delete(newfilePath)
            end
            ---确认下本地文件是否应该删除（这里直接把本地文件名换成云端文件名了）---这里上面和下面会更新两次DB数据
            CS_FILE_HELPER.Move(filePath, newfilePath)
            if (UrlImgMgr.IsNeedFake(biz)) then
                UrlImageDBUtil.UpdateData(headLessName, resultName, newfilePath)
            end
            if (successCB) then
                successCB(result.url);
            end
            Debug.LogWarning("UrlImgMgr.Upload success", result.url, " resultName ", resultName, " filePath ", filePath, " newfilePath ", newfilePath)
        else
            Debug.LogError("UrlImgMgr.Upload ERROR ", filePath, result.msg, " channel ", channel)
            if (errorCB) then
                errorCB();
            end
        end
    end
    UploadCount = UploadCount + 1
    ---上传成功后，本地文件应该改名
    --Debug.LogError("filePath ", filePath, " channel or UrlImgMgr.OssChannel.PhotoAlbum ", channel or UrlImgMgr.OssChannel.PhotoAlbum)
    SDKMgr.OSSUpLoad(channel or GameConst.OSSType.PhotoAlbum, filePath, nil, "photo", nil, callback)
end

---检测本地图是否存在且能通过校验
---@param fileName string 图片文件名
---@param biz UrlImgMgr.BizType 业务类型
---@return bool
function UrlImgMgr.CheckFile(fileName, biz, isThumb)
    --Debug.LogWarning("CheckFile ", fileName)
    if (UrlImgMgr.Exists(fileName, biz, isThumb)) then
        local curFileName = isThumb and UrlImgMgr.GetThumbName(fileName) or fileName
        local fakeName = UrlImageDBUtil.GetFakeName(curFileName, biz)
        local curFileFullPath = UrlImgMgr.GetSaveImgFilePath(fakeName, biz)
        --Debug.LogWarning("CheckFile Result ", UrlImageDBUtil.CheckFile(curFileName, curFileFullPath), " - curFileName ", curFileName, " path ", curFileFullPath)

        return UrlImageDBUtil.CheckFile(curFileName, curFileFullPath, biz)
    end
end

---临时建立绑定关系
---@param texture Texture2D 纹理
---@param go GameObject 需要绑定的go
---@param biz UrlImgMgr.BizType 业务类型
function UrlImgMgr.CacheTexDic(texture, go, biz)
    if (not texture or not go) then
        Debug.LogError("CacheTexDic error ", texture, go)
        return
    end
    CS_URL_IMAGE_UTL.CacheTexDic(texture, go, biz)
end

---获取文件名
---@param prefix string 文件名前缀
---@return string 文件名
function UrlImgMgr.GetFileName(prefix)
    prefix = prefix or ""
    local strTime = CS_DateTime_HELPER.Now:ToString("yyyyMMddHHmmssfff")
    local uid = BllMgr.Get("LoginBLL"):GetAccountId()
    return string.concat(prefix, "_", uid, "_", strTime)
end

---检测文件是否存在 ---不会进行防替换的操作，外部业务请直接使用UrlImgMgr.Exists
---@param file_name string
---@return boolean
function UrlImgMgr.IsImgFileExist(file_name, biz)
    local path = UrlImgMgr.GetSaveImgFilePath(file_name, biz)
    return not string.isnilorempty(path) and CS_FILE_HELPER.Exists(path)
end

---判定指定文件是否存在
---@param fileName String 文件名
---@param biz UrlImgMgr.BizType 业务类型
---@param isThumb bool 是否为缩略图
---@return Boolean
function UrlImgMgr.Exists(fileName, biz, isThumb)
    if string.isnilorempty(fileName) then
        return false
    end
    if (this.IsNeedFake(biz)) then
        fileName = isThumb and UrlImgMgr.GetThumbName(fileName) or fileName
        fileName = UrlImageDBUtil.GetFakeName(fileName, biz)
    end

    local filePath = this._GetFileFullURL(fileName, biz)
    return CS_FILE_HELPER.Exists(filePath)
end

function UrlImgMgr._GetFileNameWithPath(fileName)
    --如果fileName包含/，则分割出文件名
    local fileNameArr = string.split(fileName, "/")
    if fileNameArr and #fileNameArr > 1 then
        fileName = fileNameArr[#fileNameArr]
    end
    return fileName
end

---获取对应文件路径
---@param fileName String 文件名
---@return String
function UrlImgMgr._GetFileFullURL(fileName, biz)
    local rootPath = UrlImgMgr._GetRootPath(biz)
    return string.concat(rootPath, "/", fileName)
end

---获取对应文件的本地路径
---@param isThumb bool 是否为缩略图
function UrlImgMgr.GetFileRealPath(fileName, biz, isThumb)
    if (this.IsNeedFake(biz)) then
        fileName = isThumb and UrlImgMgr.GetThumbName(fileName) or fileName
        fileName = UrlImageDBUtil.GetFakeName(fileName, biz)
    end

    local filePath = this._GetFileFullURL(fileName, biz)
    return filePath
end

---获取img路径
---@param file_name string
---@return string
function UrlImgMgr.GetSaveImgFilePath(file_name, biz)
    local rootPath = this._GetRootPath(biz)
    return not string.isnilorempty(file_name) and string.concat(rootPath, "/", file_name) or ""
end

---压缩Texture
---@param source Texture2D 源贴图
---@param targetWidth int 压缩的目标宽度
---@param targetHeight int 压缩的目标高度
---@param linear bool 是否为线性贴图
---@return Texture2D 压缩后的贴图
function UrlImgMgr.CompressTextureBySize(source, targetWidth, targetHeight, isLiner)
    if isLiner == nil then
        isLiner = true
    end
    targetWidth = math.floor(targetWidth)
    targetHeight = math.floor(targetHeight)
    return CS_TEXTURE_HELPER.CompressTextureBySize(source, targetWidth, targetHeight, isLiner)
end

-----从路径，或带后缀的文件名中获取基础文件名 Endless
function UrlImgMgr.GetBaseName(fileName)
    --如果fileName包含/，则分割出文件名
    local fileNameArr = string.split(fileName, "/")
    if fileNameArr and #fileNameArr > 1 then
        fileName = fileNameArr[#fileNameArr]
    end

    --如果fileName包含后缀，则去除后缀
    fileNameArr = string.split(fileName, ".")
    if fileNameArr and #fileNameArr > 1 then
        fileName = fileNameArr[1]
    end
    return fileName
end

---获取文件缩略名
function UrlImgMgr.GetThumbName(fileName)
    fileName = UrlImgMgr.GetBaseName(fileName)
    return string.concat(fileName, thumbSuffix)
end

--从url中分割出文件名----带后缀版本
---@param url string 图片路径
function UrlImgMgr.GetFileNameWithPath(url)
    if (string.isnilorempty(url)) then
        return ""
    end
    local t = string.split(url, "/")
    if #t == 0 then
        return url
    else
        return t[#t]
    end
end

---删除已存在的文件
---@param file_name string
---@param biz UrlImgMgr.BizType 功能类型
function UrlImgMgr.DeleteImgFile(file_name, biz)
    if (this.IsNeedFake(biz)) then
        file_name = UrlImageDBUtil.GetFakeName(file_name, biz)
        UrlImageDBUtil.DelData(file_name)
    end


    --Debug.LogError(" UrlImgMgr.DeleteImgFile ", file_name, " b ", biz, " exist ", UrlImgMgr.IsImgFileExist(file_name, biz))

    if UrlImgMgr.Exists(file_name, biz) then
        local smallName = UrlImgMgr.GetThumbName(file_name)
        if (this.IsNeedFake(biz)) then
            smallName = UrlImageDBUtil.GetFakeName(smallName, biz)
        end
        local samll_path = UrlImgMgr.GetSaveImgFilePath(smallName, biz)
        local path = UrlImgMgr.GetSaveImgFilePath(file_name, biz)
        CS.System.IO.File.Delete(path)
        CS.System.IO.File.Delete(samll_path)
    end
end

---依托白名单来清除指定路径下的文件---如果对应业务进行了本地伪装（现在应该是全部），请不要传入后缀
---@param biz UrlImgMgr.BizType 功能类型
---@param whiteTable table<string> 白名单
function UrlImgMgr.ClearFiles(biz, whiteTable)
    local path = saveRootPathDic[biz]

    if (string.isnilorempty(path)) then
        return
    end
    if(not (CS_DIRECTORY_HELPER.Exists and CS_DIRECTORY_HELPER.Exists(path))) then
        return
    end

    local files = CS_X3FILE_HELPER.GetAllFilesListInDir(path, "*")
    for i = 0, files.Count - 1 do
        local fileName = UrlImgMgr.GetBaseName(files[i])
        local contains = false
        --Debug.LogError("UrlImgMgr.ClearFiles ", fileName, " files.Count ", files.Count)
        for j = 1, #whiteTable do
            local whiteName = whiteTable[j]
            if (string.find(fileName, whiteName, 1, true)) then
                contains = true
            end
        end
        if not contains then
            UrlImgMgr.DeleteImgFile(fileName, biz)
        end
    end
end


function UrlImgMgr.Init()
    CS_WEB_UTIL.DownloadCompleteFunc = UrlImgMgr._OnCSDownloadComplete
end

function UrlImgMgr.Clear()
    if(CS_WEB_UTIL.DownloadCompleteFunc) then
        CS_WEB_UTIL.DownloadCompleteFunc = nil
    end
end


return UrlImgMgr
