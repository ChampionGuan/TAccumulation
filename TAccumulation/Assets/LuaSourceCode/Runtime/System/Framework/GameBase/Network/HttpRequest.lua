---@class HttpRequest
local HttpRequest = {}
local XluaUtil = require("Runtime.Common.BuildIn.xlua.util")
---@type UnityWebRequest
local CS_UnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
local CS_UnityWebRequestCertificator = CS.X3Game.Networking.UnityWebRequestCertificator
local CS_UnityWebRequestExtension = CS.X3Game.Networking.UnityWebRequestExtension
local CS_CoroutineProxy = CS.PapeGames.X3.CoroutineProxy

local indicatorCount = 0
local indicatorStr = nil
local indicatorTime = 0
---显示或隐藏菊花（使用计数）
---@param enable boolean
---@param text string | number
---@param needDelay boolean
local function ExeShowIndicator(enable, text, needDelay)
    needDelay = needDelay or false
    if enable == true then
        indicatorCount = indicatorCount + 1
        if needDelay then
            UICommonUtil.SetIndicatorEnableWithDelay(0.5, GameConst.IndicatorType.HTTP_CONNECTING, true, text, GameConst.IndicatorShowType.NET_WORK, false, true)
        else
            indicatorStr = nil
            indicatorTime = 0
            UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.HTTP_CONNECTING, true, text, GameConst.IndicatorShowType.NET_WORK, false, true)
        end
    else
        indicatorCount = math.max(0, indicatorCount - 1)
        if (indicatorCount == 0) then
            UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.HTTP_CONNECTING, false)
        end
    end
end

---清除菊花（不做计数）
local function ClearIndicator()
    indicatorCount = 0
    UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.HTTP_CONNECTING, false)
end

---request请求过期时间（秒）
---@type int
local REQUEST_TIME_OUT = 5

---格式化Url Get时的数据
---@param mainUrl string 主Url
---@param data table|string
---@return string
local function formatUrlGetData(mainUrl, data)
    local ret = ""
    if data == nil then
        return mainUrl and mainUrl or ret
    end
    local tmpTbl = PoolUtil.GetTable()
    if type(data) == "table" then
        for k, v in pairs(data) do
            if #tmpTbl > 0 then
                table.insert(tmpTbl, "&")
            end
            table.insert(tmpTbl, k)
            table.insert(tmpTbl, "=")
            table.insert(tmpTbl, v)
        end
    elseif type(data) == "string" then
        table.insert(tmpTbl, data)
    end

    if #tmpTbl > 0 then
        if (mainUrl ~= nil) then
            if string.find(ret, "?", 1, true) ~= nil then
                table.insert(tmpTbl, 1, "&")
            else
                table.insert(tmpTbl, 1, "?")
            end
            table.insert(tmpTbl, 1, mainUrl)
        end
        ret = table.concat(tmpTbl)
    end
    PoolUtil.ReleaseTable(tmpTbl)
    return ret
end

---默认的处理Request结果的逻辑
---@param req UnityWebRequest
---@param onSuccess fun(respTxt:string):void
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int):void
local function defaultProcResult (req, onSuccess, onError)
    local respCode = req.responseCode
    if respCode == 200 then
        ---ResponseCode 200，正常返回
        local respTxt = req.downloadHandler.text
        Debug.LogFormat("HttpRequest: (%s) respTxt: %s", req.url, respTxt)
        if (onSuccess ~= nil) then
            onSuccess(respTxt)
        end
    else
        local isNetworkError = req.isNetworkError or req.isHttpError
        Debug.LogErrorFormat("HttpRequest: (%s) resp error: errorMsg=%s, networkError=%s, respCode=%s", req.url, req.error, isNetworkError, respCode)
        if (onError ~= nil) then
            onError(req.error, isNetworkError, respCode)
        end
    end
end

---执行Post
---@param url string
---@param data table
---@param headerData table<string, any> 自定义header信息
---@param onSuccess fun(respTxt:string):void
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int):void
---@param proResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
---@param isForm bool 是否为表单形式
local function exePost(url, data, headerData, onSuccess, onError, proResultCB, isForm, withIndicator)
    if withIndicator == nil then
        withIndicator = true
    end
    local req = CS_UnityWebRequest.Post(url, "POST")
    req:SetRequestHeader("connection", "close")
    if (isForm) then
        req:SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    else
        req:SetRequestHeader("Content-Type", "application/json")
    end
    req:SetRequestHeader("Accept", "application/json")
    if headerData then
        for k, v in pairs(headerData) do
            req:SetRequestHeader(tostring(k), tostring(v))
        end
    end
    req.timeout = REQUEST_TIME_OUT

    ---for certificate purpose
    req.certificateHandler = CS_UnityWebRequestCertificator()
    local dataStr = nil
    if (isForm) then
        dataStr = data
    else
        if data ~= nil then
            dataStr = JsonUtil.Encode(data)
        end
    end

    if dataStr ~= nil then
        CS_UnityWebRequestExtension.SetUploadHandlerRaw(req, dataStr)
        Debug.LogFormat("HttpRequest: (%s) post data:(%s)", req.url, dataStr)
    end
    if withIndicator then
        ExeShowIndicator(true, UITextHelper.GetUIText(UITextConst.UI_TEXT_5199), true)
    end
    req:SendWebRequest()
    Debug.LogFormat("HttpRequest: (%s) post", url)
    while (not req.isDone) do
        coroutine.yield(nil)
    end
    Debug.LogFormat("HttpRequest: (%s) responsed", url)
    if withIndicator then
        ExeShowIndicator(false)
    end
    if proResultCB ~= nil then
        proResultCB(req, onSuccess, onError)
    else
        defaultProcResult(req, onSuccess, onError)
    end
end

---执行Get
---@param url string
---@param data table|string get数据
---@param headerData table<string, any> 自定义header信息
---@param onSuccess fun(respTxt:string):void 成功后的返回
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int):void
---@param proResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
local function exeGet(url, data, headerData, onSuccess, onError, proResultCB, withIndicator)
    if withIndicator == nil then
        withIndicator = true
    end
    url = formatUrlGetData(url, data)
    local req = CS_UnityWebRequest.Get(url)
    req:SetRequestHeader("connection", "close")
    req:SetRequestHeader("Content-Type", "application/json")
    req:SetRequestHeader("Accept", "application/json")
    ---for certificate purpose
    if headerData then
        for k, v in pairs(headerData) do
            req:SetRequestHeader(k, v)
        end
    end
    req.certificateHandler = CS_UnityWebRequestCertificator()
    req.timeout = REQUEST_TIME_OUT
    if withIndicator then
        ExeShowIndicator(true, UITextHelper.GetUIText(UITextConst.UI_TEXT_5199), true)
    end
    req:SendWebRequest()
    Debug.LogFormat("HttpRequest: (%s) get", url)
    while (not req.isDone) do
        coroutine.yield(nil)
    end
    Debug.LogFormat("HttpRequest: (%s) responsed", url)
    if withIndicator then
        ExeShowIndicator(false)
    end
    if proResultCB ~= nil then
        proResultCB(req, onSuccess, onError)
    else
        defaultProcResult(req, onSuccess, onError)
    end
end

---执行Post方法
---@param url string 请求地址
---@param data table|string 请求数据
---@param headerData table<string, any> 头文件信息
---@param onSuccess fun(respTxt:string) 成功后的回调函数
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int):void
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
---@param isForm bool 是否为表单形式
function HttpRequest.Post(url, data, headerData, onSuccess, onError, procResultCB, isForm, withIndicator)
    CS_CoroutineProxy.Instance:StartCoroutine(XluaUtil.cs_generator(exePost, url, data, headerData, onSuccess, onError, procResultCB, isForm, withIndicator))
end

---执行Get方法
---@param url string 请求地址
---@param data table 请求数据
---@param headerData table<string, any> 头文件信息
---@param onSuccess fun(respTxt:string) 成功后的回调函数
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int):void
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
function HttpRequest.Get(url, data, headerData, onSuccess, onError, procResultCB, withIndicator)
    CS_CoroutineProxy.Instance:StartCoroutine(XluaUtil.cs_generator(exeGet, url, data, headerData, onSuccess, onError, procResultCB, withIndicator))
end

local deferred = require("Runtime.Common.Deferred")

---执行Post方法(Deferred)
---@param url string 请求地址
---@param data table 请求数据
---@param headerData table<string, any> 头文件信息
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
function HttpRequest.PostDeferred(url, data, headerData, procResultCB)
    local d = deferred.new()
    HttpRequest.Post(url, data, headerData,
            function(respTxt)
                d:resolve(respTxt)
            end,
            function(errorMsg, isNetworkError, respCode)
                local errorData = {
                    errorMsg = errorMsg,
                    isNetworkError = isNetworkError,
                    errorCode = respCode
                }
                d:reject(errorData)
            end,
            procResultCB)
    return d
end

---执行Get方法(Deferred)
---@param url string 请求地址
---@param data table 请求数据
---@param headerData table<string, any> 头文件信息
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
function HttpRequest.GetDeferred(url, data, headerData, procResultCB,withIndicator)
    local d = deferred.new()
    HttpRequest.Get(url, data, headerData,
            function(respTxt)
                d:resolve(respTxt)
            end,
            function(errorMsg, isNetworkError, respCode)
                local errorData = {
                    errorMsg = errorMsg,
                    isNetworkError = isNetworkError,
                    errorCode = respCode
                }
                d:reject(errorData)
            end,
            procResultCB,withIndicator)
    return d
end

return HttpRequest