--- X3@PapeGames
--- FileRequest
---文件上传下载类

---@class FileRequest 文件上传下载类
local FileRequest = {}
local xluaUtil = require("Runtime.Common.BuildIn.xlua.util")
local csUnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
local csDownLoadHandlerFile = CS.UnityEngine.Networking.DownloadHandlerFile
local csUpLoadHandlerFile = CS.UnityEngine.Networking.UploadHandlerFile
local csCoroutineProxy = CS.PapeGames.X3.CoroutineProxy

---@private
---处理上传结果
---@param req UnityWebRequect
---@param successCB fun(resp:string):void 成功的回调
---@param errorCB fun(error:string):void 失败的回调
---@return void
local procResultUpload = function(req, successCB, errorCB)
    if req.isNetworkError then
        ---网络错误
        Debug.LogError("resp error: network error")
        if (errorCB ~= nil) then
            errorCB(req.error)
        end
    elseif req.responseCode == 200 then
        ---ResponseCode 200，正常返回
        --local respTxt = req.downloadHandler.text
        --print("respTxt: ", respTxt)
        if (successCB ~= nil) then
            successCB()
        end
    else
        ---其它错误
        Debug.LogError("resp error: ", req.error)
        if (errorCB ~= nil) then
            errorCB(req.error)
        end
    end
end

---@private
---处理下载结果
---todo:用此方法下载会导致在Mono层产生一份内存数据
---@param req UnityWebRequect
---@param successCB fun(resp:byte[]):void 成功的回调
---@param errorCB fun(error:string):void 失败的回调
---@return void
local procResultDownload = function(req, successCB, errorCB)
    if req.isNetworkError then
        ---网络错误
        Debug.LogError("resp error: network error")
        if (errorCB ~= nil) then
            errorCB(req.error)
        end
    elseif req.responseCode == 200 then
        ---ResponseCode 200，正常返回
        --local respBytes = req.downloadHandler.data
        --print("respBytes: ", respBytes.Length)
        if (successCB ~= nil) then
            successCB()
        end
    else
        ---其它错误
        Debug.LogError("resp error: ", req.error)
        if (errorCB ~= nil) then
            errorCB(req.error)
        end
    end
end

---@private
---执行上传
---todo:用此方法上传会导致在Mono层产生一份内存数据
---@param url string
---@param fileUrl string 上传buffer
---@param successCB fun(resp:string):void 成功的回调
---@param errorCB fun(error:string):void 失败的回调
---@param progressCB fun(p:float):void 进度回调
---@param proResultCB fun(req:UnityWebRequest, successCB:fun(string), errorCB:fun(string)):void 自定义处理结果函数
---@param headInfo table 头文件信息
---@return void
local exeUpload = function(url, fileUrl, successCB, errorCB, progressCB, proResultCB, headInfo)
    local req = csUnityWebRequest(url, "PUT")
    req.uploadHandler = csUpLoadHandlerFile(fileUrl)
    if headInfo and headInfo.ContentType then
        req.uploadHandler.contentType = headInfo.ContentType
    end
    req:SendWebRequest()
    local tooFast = true
    while (not req.isDone) do
        if progressCB ~= nil then
            progressCB(req.uploadProgress)
        end
        if(req.uploadProgress > 0) then
            tooFast = false
        end
        coroutine.yield(nil)
    end

    if(tooFast) then
        if progressCB ~= nil then
            progressCB(1)
        end
    end

    if proResultCB ~= nil then
        proResultCB(req, successCB, errorCB)
    else
        procResultUpload(req, successCB, errorCB)
    end
    req:Dispose()
end

---@private
---执行下载
---@param url string
---@param localUrl string 上传本地路径
---@param successCB fun(resp:string):void 成功的回调
---@param errorCB fun(error:string):void 失败的回调
---@param progressCB fun(p:float):void 进度回调
---@param proResultCB fun(req:UnityWebRequest, successCB:fun(string), errorCB:fun(string)):void 自定义处理结果函数
---@return void
local exeDownload = function(url, localUrl, successCB, errorCB, progressCB, proResultCB)
    local req = csUnityWebRequest(url)
    req.downloadHandler = csDownLoadHandlerFile(localUrl, true)
    req:SendWebRequest()
    while (not req.isDone) do
        if progressCB ~= nil then
            progressCB(req.downloadProgress)
        end
        --print(string.format("(%s) downloading...", url))
        coroutine.yield(nil)
    end
    if progressCB ~= nil then
        progressCB(req.downloadProgress)
    end
    if proResultCB ~= nil then
        proResultCB(req, successCB, errorCB)
    else
        procResultDownload(req, successCB, errorCB)
    end
end

---@public
---执行Post方法
---@param url string 请求地址
---@param fileUrl string 上传文件所在的路径
---@param successCB fun(fileName:string) 成功后的回调函数
---@param errorCB fun() 失败后的回调函数
---@param progressCB fun(p:float) 进度回调
---@param proResultCB fun(req:UnityWebRequest, successCB:fun(string), errorCB:fun()) 自定义的处理结果的回调
---@param headInfo table 头文件信息
function FileRequest.Upload(url, fileUrl, successCB, errorCB, progressCB, proResultCB, headInfo)
    csCoroutineProxy.StartCoroutine(xluaUtil.cs_generator(exeUpload, url, fileUrl, successCB, errorCB, progressCB, proResultCB, headInfo))
end

---@public
---执行Get方法
---@param url string 请求地址
---@param localUrl string 文件下载地址
---@param successCB fun(string) 成功后的回调函数
---@param errorCB fun(msg:string):void 失败后的回调函数
---@param progressCB fun(p:float):void 进度回调
---@param progressCB fun(req:UnityWebRequest, successCB:fun(string), errorCB:fun()) 自定义的处理结果的回调
function FileRequest.Download(url, localUrl, successCB, errorCB, progressCB, proResultCB)
    csCoroutineProxy.StartCoroutine(xluaUtil.cs_generator(exeDownload, url, localUrl, successCB, errorCB, progressCB, proResultCB))
end

return FileRequest