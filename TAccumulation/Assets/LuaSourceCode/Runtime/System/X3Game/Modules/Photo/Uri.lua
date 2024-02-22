--- X3@PapeGames
--- Uri
---资源定位Uri
---
local SystemFile = CS.System.IO.File
local FileRequest = require("Runtime.System.Framework.GameBase.Network.FileRequest")
local saveRootPath = CS.UnityEngine.Application.persistentDataPath .. "/UrlImg"

---Uri句柄【适配器】
---@class UriHandle
local UriHandle = class("UriHandle")
local _uriHandleID = 0
function UriHandle:ctor(serverUniqueKey)
    ---@public
    ---@field Texture2D texture纹理
    self.texture = nil
    ---@public
    ---@field fileRootDir string 可选的文件相对目录
    self.fileRootDir = nil
    ---@public
    ---@field defineHeader string 可选的自定义Header
    self.defineHeader = nil

    ---@public 第一个是服务器返回的数据第二个文件映射名称
    ---@field successCB fun(string, string) 成功后的回调函数
    self.successCB = nil
    ---@public
    ---@field errorCB fun(string) 失败后的回调函数
    self.errorCB = nil
    ---@public
    ---@field progressCB fun(float) 进度回调
    self.progressCB = nil
    ---@public
    ---@field proResultCB:Action<UnityWebRequest, successCB, ErrorCB> 自定义的处理结果的回调
    self.proResultCB = nil

    _uriHandleID = _uriHandleID + 1
    ---@private local公钥:本地文件名
    self._localUniqueKey = tostring(_uriHandleID)
    ---@private server私钥:远程文件名
    self._serverUniqueKey = serverUniqueKey

    ---@public 本地业务标记
    self._biz = nil

    ---@public 是否为png图片
    self.isPng = false
end

---@param successCB fun(string):void 下载成功的回调【string实际是byte[]】
---@param successCB fun(string, string):void 上传成功的回调
---@param errorCB fun(any):void 失败的回调
---@param progressCB fun(Float):void 进度回调
---@param proResultCB fun(UnityWebRequest, successCB, ErrorCB) 自定义的处理结果的回调
function UriHandle:Subscribe(successCB, errorCB, progressCB, proResultCB)
    self.successCB = successCB
    self.errorCB = errorCB
    self.progressCB = progressCB
    self.proResultCB = proResultCB
end

---@return string local公钥
function UriHandle:GetPublicKey()
    return self._localUniqueKey
end

---@return string server私钥
function UriHandle:GetPrivateKey()
    return self._serverUniqueKey
end

---@param serverUniqueKey string 具有相对唯一性的文件名
function UriHandle:SetPrivateKey(serverUniqueKey)
    self._serverUniqueKey = serverUniqueKey
end

---@param UrlImgMgr.BizType string 业务标记
function UriHandle:SetBiz(biz)
    self._biz = biz
end

---@class Uri
local Uri = class("Uri")
function Uri:ctor()
    ---@type UriHandle[]
    self._handlerDict = {}
    ---@type UriHandle
    self._curHandler = nil
    self._baseHost = nil
end

local _queryfileuploadinfo_req = { ClientFileName = ""}
---@private 请求文件地址
---@param uniqueFileName string 具有相对唯一性的文件名
function Uri:ReqHeadUri(uniqueFileName)
    _queryfileuploadinfo_req.ClientFileName = uniqueFileName
    GrpcMgr.SendRequest(RpcDefines.QueryFileUploadInfoRequest,_queryfileuploadinfo_req)
end

---@private 相应文件地址
function Uri:FetchHeadUri(serverRep)
    local handler = self._handlerDict[serverRep.ClientFileName]
    if not handler then
        print("===LLM:不存在对应的适配器句柄===", serverRep.ClientFileName)
        return
    end


    handler:SetPrivateKey(serverRep.UploadFileName)
    handler.defineHeader = serverRep.Header
    self:__TransferFile(handler)
    ---这里要回收
    self._handlerDict[serverRep.ClientFileName] = nil
    ---上传文件

    ----成功返回文件UrlName
    local successCB = handler.successCB
    local serverPublicKey = handler:GetPrivateKey()

    if successCB then
        local successNestedCB = function()
            local fullUrl = string.format("%s/%s", self._baseHost, serverPublicKey)
            successCB(fullUrl)
        end
        handler.successCB = successNestedCB
    end

    if(handler.texture) then
        local localUrl = handler.isPng and UrlImgMgr.SaveTextureToPngFile(handler.texture, serverPublicKey, handler._biz) or UrlImgMgr.SaveTextureToJpgFile(handler.texture, serverPublicKey, nil, handler._biz)
        if(localUrl) then
            FileRequest.Upload(serverRep.SignedURL,localUrl,handler.successCB,handler.errorCB,handler.progressCB,handler.proResultCB,serverRep.Header)
        else
            if(handler.errorCB) then
                handler.errorCB()
            end
            Debug.LogError("localUrl is nil")
        end
    else
        Debug.LogError("handler texture not exist!")
    end
    print("====LLM:Uri--FetchHeadUri===", self._baseHost, serverPublicKey)
end

---@private 转移本地文件到服务器命名的文件
---@param handler UriHandle 资源定位句柄【默认为当前句柄】
function Uri:__TransferFile(handler)
    handler.fileRootDir = handler.fileRootDir or saveRootPath
    local filePath = handler.fileRootDir .. "/" .. handler:GetPublicKey()
    if SystemFile.Exists(filePath) then
        local newfilePath = handler.fileRootDir .. "/" .. handler:GetPrivateKey()
        if SystemFile.Exists(newfilePath) then
            SystemFile.Delete(newfilePath)
        end
        SystemFile.Move(filePath, newfilePath)
    end
end

------------------------------------------------------------------------------------------------------------------------
---@public 对外接口
------------------------------------------------------------------------------------------------------------------------
---
---@public
---设置下载域名
---@param host string 前缀域名 ---在EnterGameState赋值的
function Uri:SetHost(host)
    self._baseHost = host
end

---@public 获取请求句柄
---@param serverPrivateKey string 指定服务器私钥,可nil
---@param UrlImgMgr.BizType string 业务标记
---@return UriHandle
function Uri:GetHandler(serverPrivateKey, biz)
    ----UriHandle:可回收对象
    local _handler = UriHandle.new(serverPrivateKey)
    _handler:SetBiz(biz)
    self._handlerDict[_handler:GetPublicKey()] = _handler
    self._curHandler = _handler
    return _handler
end

---@public 上传文件
---@param handler UriHandle 资源定位句柄【默认为当前句柄】
function Uri:Upload(handler)
    handler = handler or self._curHandler
    self:ReqHeadUri(handler:GetPublicKey())
end

---@public 下载文件
---@param handler UriHandle 资源定位句柄【默认为当前句柄】
function Uri:Download(handler)
    handler = handler or self._curHandler
    if not handler then
        print("LLM:===参数异常=Uri:Download(handler)===")
        return
    end

    assert(not string.isnilorempty(self._baseHost))
    local fullUrl = string.format("%s/%s", self._baseHost , handler:GetPrivateKey())
    local localPath = string.format("%s/%s", handler.fileRootDir , handler:GetPrivateKey())
    --FileRequest.DownloadByHandler(fullUrl, handler)
    FileRequest.Download(fullUrl,localPath, function(data)
        if handler.successCB ~= nil then
            handler.successCB(data,handler._serverUniqueKey)
        end
    end ,handler.errorCB,function(progress)
        if handler.progressCB then
            handler.progressCB(progress,handler._serverUniqueKey)
        end
    end,handler.proResultCB)
end

Uri = Uri.new()
return Uri