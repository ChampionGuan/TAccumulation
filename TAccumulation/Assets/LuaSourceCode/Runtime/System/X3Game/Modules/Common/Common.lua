--用于公用接口
---@class Common
local Common = {}

--region 时间处理
function Common.GetTimeSecond(beginTime)
    local ts = GrpcMgr.GetServerTime() - beginTime
    return ts.TotalSeconds
end

function Common.GetTimeByStr(timeStr)
    local timeArr = string.split(timeStr, "=")
    if(#timeArr == 2) then
        local strRetTime = timeArr[1] .. " " .. timeArr[2]
        local result, retTime = CS.System.DateTimeOffset.TryParseExact(strRetTime, "yyyyMMdd HH:mm:ss", CS.System.Globalization.CultureInfo.CurrentCulture, CS.System.Globalization.DateTimeStyles.None)
        return retTime
    else
        if(timeStr ~= "0") then
            Debug.LogError("Common.GetTimeByStr Split Error")
        end
        return 0
    end

end

function Common.GetTimeByTimeStamp(timeStamp)
    return CS.System.DateTimeOffset.FromUnixTimeSeconds(timeStamp)
end

--endregion

--region字符串处理

function Common.SearchResultText(content, searchString, showLength)
    local minIndex, maxIndex = string.utf8find(content, searchString)
    local showContent = content
    if minIndex ~= nil then
        local length = string.utf8len(content)
        local startIndex = math.ceil(math.max(1, minIndex - showLength / 2))
        local endIndex = math.ceil(math.min(length, maxIndex + showLength / 2))
        local prefix = ""
        local suffix = ""
        --字数补足
        if endIndex - startIndex < showLength then
            if startIndex == 1 then
                endIndex = math.min(startIndex + showLength, length)
            elseif endIndex == length then
                startIndex = math.max(endIndex - showLength, 1)
            end
        end
        if startIndex ~= 1 then
            prefix = "..."
            startIndex = startIndex + 3
        end
        if endIndex ~= length then
            suffix = "..."
            endIndex = endIndex - 3
        end

        showContent = string.concat(prefix, string.utf8sub(content, startIndex, endIndex), suffix)
    end

    return minIndex ~= nil, showContent
end

function Common.MarkText(content, keyWords, prefix, suffix)
    if string.isnilorempty(content) == false and
            string.isnilorempty(keyWords) == false then
        local text = string.gsub(content, keyWords,
                function(x)
                    return string.concat(prefix, x, suffix)
                end)
        return text
    else
        return content
    end
end

local ColorRed = string.concat("<color=",LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEMSGKEYWORDSCOLOR), ">")
local ColorEnd = "</color>"

function Common.ShowKeyWordsCenter(content, keywords, totalWidth, fontSize)
    local showLength = math.ceil(totalWidth / fontSize)

    local isEdit, strResult = Common.SearchResultText(content, keywords, showLength)
    return Common.MarkText(strResult, keywords, ColorRed, ColorEnd)
end

return Common

--endregion



