---GameHttpRequest
--- Created by Tungway.
--- DateTime: 10/25/2022

---@class GameHttpRequest
local GameHttpRequest = class("GameHttpRequest")

---@type HttpRequest
local HttpRequest = require("Runtime.System.Framework.GameBase.Network.HttpRequest")

---通过Get发送Http请求
---@param urlType ServerUrl.UrlType
---@param urlOp ServerUrl.UrlOp
---@param reqData table<string, any> 请求数据
---@param headerData table<string, any> 头数据
---@param onSuccess fun(respTxt:string) 成功后的回调函数
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int) 失败后的回调函数
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
function GameHttpRequest:Get(urlType, urlOp, reqData, headerData, onSuccess, onError, procResultCB,withIndicator)
    local url = ServerUrl:GetUrlWithType(urlType, urlOp, reqData)
    HttpRequest.Get(url, nil, headerData, onSuccess, onError, procResultCB,withIndicator)
end

---通过Get发送Http请求
---@param urlType ServerUrl.UrlType
---@param urlOp ServerUrl.UrlOp
---@param reqData table<string, any> 请求数据
---@param headerData table<string, any> 头数据
---@param onSuccess fun(respTxt:string) 成功后的回调函数
---@param onError fun(errorMsg:string, isNetworkError:boolean, respCode:int) 失败后的回调函数
---@param procResultCB fun(req:UnityWebRequest, onSuccess:fun(respTxt:string), onError:fun(errorMsg:string, isNetworkError:boolean, respCode:int)):void 自定义处理数据的逻辑
function GameHttpRequest:Post(urlType, urlOp, reqData, headerData, onSuccess, onError, procResultCB,withIndicator)
    local url = ServerUrl:GetUrlWithType(urlType, urlOp)
    HttpRequest.Post(url, reqData, headerData, onSuccess, onError, procResultCB,withIndicator)
end

---解析Json数据并返回deferred对象
---@param respTxt string json data
---@param onProcData fun(data:table) 处理数据的回调
---@return deferred
function GameHttpRequest:ParseRespDataAndDeferred(respTxt, onProcData)
    ---@type deferred
    local d = require("Runtime.Common.Deferred").new()
    local data = JsonUtil.Decode(respTxt)
    if data == nil then
        local errorData = {
            errorMsg = string.format("parse data failed: %s", respTxt),
            isNetworkError = false,
            errorCode = 200
        }
        d:reject(errorData)
        return d
    end
    local ret = data["ret"]
    if not ret then
        ret = data["code"]
    end
    if not ret then
        local errorData = {
            errorMsg = string.format("parse data failed: %s", respTxt),
            isNetworkError = false,
            errorCode = 200
        }
        d:reject(errorData)
        return d
    end
    local ret = tonumber(ret)
    if ret > 0 then
        local msg = data["msg"]
        local errorData = {
            errorMsg = string.format("request failed: ret=%s, msg=%s", ret, msg),
            isNetworkError = false,
            errorCode = ret
        }
        d:reject(errorData)
    else
        if onProcData then
            onProcData(data)
        end
        d:resolve(true)
    end
    return d
end

return GameHttpRequest
