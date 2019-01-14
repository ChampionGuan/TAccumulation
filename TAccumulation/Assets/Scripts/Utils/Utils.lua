local xluaUtils = nil
local systemWord = nil
local sensitiveWord = nil

LuaHandle.load("bit")
LuaHandle.load("Misc.json")
LuaHandle.load("Common.CSUtils")
LuaHandle.load("Common.UIUtils")
LuaHandle.load("Common.LogicUtils")

Utils = {}

-- 验证两个联盟Id号是否一致
function Utils.IsTheSameGuild(guildId1, guildId2)
    if guildId1 == nil or guildId1 <= 0 or guildId2 == nil or guildId2 <= 0 then
        return false
    end

    return guildId1 == guildId2
end

-- 判断HeroId，如果小于0则是NPC
function Utils.IsNPCId(heroId)
    if #heroId <= 0 then
        return true
    end

    return bit.band(string.byte(heroId, 1), 1) == 1
end

function Utils.band(_data1, _data2)
    if _data1 == nil or _data2 == nil then
        return 0
    end
    return bit.band(_data1, _data2)
end

-- 获取y轴向角度--
function Utils.horizontalAngle(direction)
    return CSharp.Mathf.Atan2(direction.x, direction.z) * CSharp.Mathf.Rad2Deg
end

-- 计算两向量夹角--
function Utils.angleAroundAxis(direA, direB, axis)
    direA = direA - CSharp.Vector3.Project(driA, axis)
    direB = direB - CSharp.Vector3.Project(direB, axis)
    local angle = CSharp.Vector3.Angle(direA, direB)

    local factor = 1
    if CSharp.Vector3.Dot(axis, CSharp.Vector3.Cross(direA, direB)) < 0 then
        factor = -1
    end

    return angle * factor
end

-- 点绕轴旋转某角度后的点位置--
function Utils.rotateRound(position, center, axis, angle)
    local point = CSharp.Quaternion.AngleAxis(angle, axis) * (position - center)
    local resultVec3 = center + point
    return resultVec3
end

-- 获取方向向量,xz平面取前后左右向量，左手坐标系--
function Utils.directionVector(directionType)
    if directionType == Define.DirectionType.Up then
        return CSharp.Vector3.forward
    elseif directionType == Define.DirectionType.Left_up then
        return CSharp.Vector3.Normalize(CSharp.Vector3.left + CSharp.Vector3.forward)
    elseif directionType == Define.DirectionType.Left then
        return CSharp.Vector3.left
    elseif directionType == Define.DirectionType.Left_down then
        return CSharp.Vector3.Normalize(CSharp.Vector3.left + CSharp.Vector3.back)
    elseif directionType == Define.DirectionType.Down then
        return CSharp.Vector3.back
    elseif directionType == Define.DirectionType.Right_down then
        return CSharp.Vector3.Normalize(CSharp.Vector3.right + CSharp.Vector3.back)
    elseif directionType == Define.DirectionType.Right then
        return CSharp.Vector3.right
    elseif directionType == Define.DirectionType.Right_up then
        return CSharp.Vector3.Normalize(CSharp.Vector3.right + CSharp.Vector3.forward)
    end
end

-- 秒数转换(x天:xx:xx:xx)
function Utils.secondConversion(second, hideHour)
    hideHour = hideHour or false
    if type(second) ~= "number" then
        return
    end

    local d = math.floor(second / 86400)
    local h = math.floor((second % 86400) / 3600)
    local m = math.floor(second % 3600 / 60)
    local s = math.floor(second % 60)

    if m < 10 then
        m = "0" .. m
    end

    if s < 10 then
        s = "0" .. s
    end
    if hideHour and d == 0 and h == 0 then
        return m .. ":" .. s
    end

    if h < 10 then
        h = "0" .. h
    end

    if d > 0 then
        return d .. Localization.Day .. h .. ":" .. m .. ":" .. s
    end

    return h .. ":" .. m .. ":" .. s
end

-- 秒数转换(x天x小时x分钟x秒)
function Utils.secondConversion2(second)
    if type(second) ~= "number" or second < 0 then
        return
    end

    local desc, day, hour, minute = ""
    second = math.floor(second)

    day = math.modf(second / 86400)
    second = second - day * 86400

    hour = math.modf(second / 3600)
    second = second - hour * 3600

    minute = math.modf(second / 60)
    second = second - minute * 60

    if day > 0 then
        desc = day .. Localization.Day
    end
    if hour > 0 then
        desc = desc .. hour .. Localization.Hour
    end
    if minute > 0 then
        desc = desc .. minute .. Localization.Minute
    end
    if second > 0 then
        desc = desc .. second .. Localization.Second
    end
    return desc
end

-- 秒数转换(N分钟前,N小时前,N天前)
function Utils.secondFuzzyConversion(second)
    if type(second) ~= "number" or second < 0 then
        return
    end

    if second < 60 then
        return Localization.JustNow
    elseif second < 3600 then
        return math.floor(second / 60) .. Localization.MinutesAgo
    elseif second < 86400 then
        return math.floor(second / 3600) .. Localization.HoursAgo
    else
        return math.floor(second / 86400) .. Localization.DaysAgo
    end
end

-- 秒数转换(N秒,N分钟,小时,天)
function Utils.secondFuzzyConversion2(second)
    if type(second) ~= "number" or second < 0 then
        return
    end

    if second < 60 then
        return math.floor(second) .. Localization.Second
    elseif second < 3600 then
        return math.floor(second / 60) .. Localization.Minute
    elseif second < 86400 then
        return math.floor(second / 3600) .. Localization.Hour
    else
        return math.floor(second / 86400) .. Localization.Day
    end
end

-- 是否是中文
function Utils.isChinese(text)
    if type(text) ~= "string" then
        return false
    end

    for i = 1, string.len(text) do
        asc2 = string.byte(text, i, i)

        if asc2 <= 127 then
            UIManager.showMessage("C_Utils_IsNotChinese")
            return false
        end
    end

    return true
end

-- 是否含有中文(正则表达式)
local regex = CSharp.Regex("[\\u4e00-\\u9fa5]")
function Utils.isContainChinese(text)
    if regex:IsMatch(text) then
        return true
    else
        return false
    end
end

-- 是否有敏感词
function Utils.isSensitiveWord(text)
    if type(text) ~= "string" then
        return false
    end
    if nil == sensitiveWord then
        sensitiveWord = LuaHandle.load("Config.SensitiveWordConfig")
    end
    -- 如果是渠道登陆，走服务器的屏蔽字逻辑
    -- if Common.Account.pfType == Define.LoginPlatform.Tencent then
    --     return false
    -- end
    local id1, id2
    for k, v in pairs(sensitiveWord) do
        id1, id2 = string.find(text, v)
        if nil ~= id1 then
            if string.sub(text, id1, id2) == v then
                return true
            end
        end
    end

    return false
end

-- 敏感词替换
-- isReplace = true 敏感词替换*
function Utils.sensitiveWordReplace(text, isReplace)
    if type(text) ~= "string" then
        return ""
    end
    if nil == sensitiveWord then
        sensitiveWord = LuaHandle.load("Config.SensitiveWordConfig")
    end
    -- 如果是渠道登陆，走服务器的屏蔽字逻辑
    -- if Common.Account.pfType == Define.LoginPlatform.Tencent then
    --     return text
    -- end
    local id1, id2, str
    for k, v in pairs(sensitiveWord) do
        id1, id2 = string.find(text, v)
        if nil ~= id1 then
            if string.sub(text, id1, id2) == v then
                str = ""
                for i = 1, Utils.stringLen_1(v) do
                    if isReplace then
                        str = str .. "*"
                    else
                        str = str .. ""
                    end
                end
                text = string.gsub(text, v, str)
            end
        end
    end

    return text
end

-- 是否有系统词
function Utils.isSystemWord(text)
    if type(text) ~= "string" then
        return false
    end
    if nil == systemWord then
        systemWord = LuaHandle.load("Config.SystemWordConfig")
    end
    for _, v in pairs(systemWord) do
        if v == text then
            return true
        end
    end

    return false
end

-- ubb替换，正则表达式替换
-- 参考：https://blog.csdn.net/edwardfay/article/details/790809
function Utils.UBBReplace(text)
    text = CSharp.Regex.Replace(text, "\\[b\\](.+?)\\[/b\\]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[i\\](.+?)\\[/i\\]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[u\\](.+?)\\[/u\\]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[img](?<img>.+?)\\[/img]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[url](?<url>.+?)\\[/url]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[size=(?<size>.+?)](?<text>.+?)\\[/size]", "$2", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[color=(?<color>.+?)](?<text>.+?)\\[/color]", "$2", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[img=(?<img>.+?)\\[/img]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[url=(?<url>.+?)\\[/url]", "$1", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[b\\]", "", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[i\\]", "", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[u\\]", "", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[size=(?<size>.+?)]", "", CSharp.RegexOptions.IgnoreCase)
    text = CSharp.Regex.Replace(text, "\\[color=(?<color>.+?)]", "", CSharp.RegexOptions.IgnoreCase)
    return text
end

-- 是否为合法名称
-- 特殊字符限制：为帮助玩家之间关于目标名字的交流，角色起名/改名、联盟命名/改名、武将起名/改名只可使用简体中文、数字、字母（聊天不做特殊字符限制）。
function Utils.isLegalName(str, minLen, maxLen, title)
    if type(str) ~= "string" then
        return
    end

    -- 设置默认值
    minLen = minLen or 4
    maxLen = maxLen or 14

    -- 字符串长度
    local strLen = Utils.stringLen_2(str)
    local myTitle = ""

    -- 具体内容
    if title ~= nil and type(title) == "string" then
        myTitle = title
    end

    -- 最小长度
    if strLen < minLen then
        UIManager.showTip({content = string.format(Localization.Utils_NameIsTooShort, myTitle, minLen), result = false})
        return false
    end

    -- 最大长度
    if strLen > maxLen then
        UIManager.showTip({content = string.format(Localization.Utils_NameIsTooLong, myTitle, maxLen), result = false})
        return false
    end

    -- 敏感词
    -- 如果是渠道登陆，走服务器的屏蔽字逻辑
    -- if Common.Account.pfType ~= Define.LoginPlatform.Tencent then
    if Utils.isSensitiveWord(str) then
        UIManager.showMessage("C_Utils_IsSensitiveWord")
        return false
    end
    -- end

    -- 系统词不给用
    if Utils.isSystemWord(str) then
        UIManager.showTip({content = string.format(Localization.Utils_IsSystemWord, str), result = false})
        return false
    end

    -- 字母或数字
    -- string.find(str,"%W") == nil
    -- local result = CSharp.StringTools.CalculateChineseWord(str)

    -- if not result then
    --     UIManager.showMessage("C_Utils_IsNotLegalName")
    -- end

    return true
end

-- 获得key值不规律的table的长度
function Utils.GetTableLength(table)
    if type(table) ~= "table" then
        return 0
    end

    local count = 0

    for k, v in pairs(table) do
        if v ~= nil then
            count = count + 1
        end
    end

    return count
end

-- 判断table是否存在
function Utils.isContainsValue(_table, _value)
    if type(_table) ~= "table" or _value == nil then
        return false
    end

    for k, v in pairs(_table) do
        if _value == v then
            return true
        end
    end

    return false
end

-- 根据value取出table中的key
function Utils.GetTableKey(_table, _value)
    if type(_table) ~= "table" or _value == nil then
        return nil
    end
    for k, v in pairs(_table) do
        if _value == v then
            return k
        end
    end
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function Utils.stringSplit(str, split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + 1, #str)
    end

    return sub_str_tab
end

-- 返回:字符串长度(中文占一个字节),一般用于字符替换，比如一个汉字替换为一个*
function Utils.stringLen_1(str)
    if nil == str then
        return 0
    end

    local _, count = string.gsub(str, "[^\128-\193]", "")
    return count
end

-- 返回:字符串长度(中文占二个字节),策划说用中文两个字节来判断长度
function Utils.stringLen_2(str)
    if nil == str then
        return 0
    end

    local len = #str
    local curByte, byteCount
    for i = 1, len do
        byteCount = 1
        curByte = string.byte(str, i)
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end

        i = i + byteCount - 1

        -- 判断如果为汉字,lua里默认就是三个字符，蛋疼
        if byteCount ~= 1 then
            len = len - 1
        end
    end
    return len
end

-- 返回:字符串长度(中文占三个字节)，lua里默认就是三个字节
function Utils.stringLen_3(str)
    if nil == str then
        return 0
    end
    return #(str)
end

-- 返回:制定长度字符串，和截取后的字符(中文占一个字节)
function Utils.stringSub_1(str, startLen, endLen)
    if nil == str then
        return ""
    end
    return CSharp.LogicUtils.Substring(str, startLen, endLen)
end

-- 返回:制定长度字符串，和截取后的字符(中文占二个字节)
function Utils.stringSub_2(str, startLen, endLen)
    if nil == str then
        return ""
    end

    local calcLen = 0
    local startId, endId = -1, -1
    local curByte, byteCount
    for i = 1, #str do
        byteCount = 1
        curByte = string.byte(str, i)
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        calcLen = calcLen + 1

        -- 判断如果为汉字,lua里默认就是三个字符，蛋疼
        if byteCount ~= 1 then
            calcLen = calcLen - 1

            if startId == -1 and (calcLen == startLen or calcLen + 1 == startLen or calcLen + 2 == startLen) then
                startId = i
            end
            if endId == -1 and (calcLen == endLen or calcLen + 1 == endLen or calcLen + 2 == endLen) then
                endId = i + 2
            end
        else
            if startId == -1 and calcLen == startLen then
                startId = i
            end
            if endId == -1 and calcLen == endLen then
                endId = i
            end
        end

        i = i + byteCount - 1
    end
    if startId == -1 then
        startId = 1
    end
    if endId == -1 then
        endId = #str
    end
    return string.sub(str, startId, endId)
end

-- 深拷贝
function Utils.deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

-- 计算剩余次数, 服务端给出最大次数, 恢复间隔和开始恢复时间
function Utils.GetTimesByFixedFormula(maxTimes, recoveryDuration, startRecoveryTime)
    local count =
        math.min(maxTimes, math.floor((TimerManager.curServerTimestamp - startRecoveryTime) / recoveryDuration))
    return math.max(0, count)
end

function Utils.DebugLog(...)
    Utils.LogHandle("LOG", ...)
end

function Utils.DebugWarning(...)
    Utils.LogHandle("WARNING", ...)
end

function Utils.DebugError(...)
    Utils.LogHandle("ERROR", ...)
end

function Utils.DebugFatal(...)
    Utils.LogHandle("FATAL", ...)
end

function Utils.LogHandle(logType, ...)
    local argsTable = {...}
    local commonOut = argsTable[1]
    local output = ""
    if type(commonOut) == "string" then
        local formatOut = string.format(...)
        if commonOut ~= formatOut then
            output = formatOut
        else
            local count = select("#", ...)
            for i = 1, count do
                if i == 1 then
                    output = argsTable[i]
                else
                    output = string.format("%s\t%s", output, argsTable[i])
                end
            end
        end
    end
    local format = ""
    local pushLogToServer = false
    if logType == "LOG" then
        format = "<color=#00FF39>[Log] %s </color>"
        pushLogToServer = MiscConfig.ShouldLogPushToServer
    elseif logType == "WARNING" then
        format = "<color=0041FF>[Warning] %s </color>"
        pushLogToServer = MiscConfig.ShouldWarningPushToServer
    elseif logType == "ERROR" then
        format = "<color=#C700FF>[Error] %s </color>"
        pushLogToServer = MiscConfig.ShouldErrorPushToServer
    elseif logType == "FATAL" then
        format = "<color=#FF0000>[Fatal] %s </color>"
        pushLogToServer = MiscConfig.ShouldFatalPushToServer
    end
    format = format .. "\n" .. debug.traceback()
    if Common.DebugMode then
        -- 只有当编译的版本是Debug版本时, print函数才能将调试信息输出, 下同
        print(string.format(format, output))
    end
    if pushLogToServer then
        DataTrunk.PlayerInfo.MiscData.C2SClientLogProto(type, output)
    end
end

-- 资源显示处理(海外版)
-- count : int 资源数量
-- function Utils.ResourceHandler(count)
--     if type(count) ~= "number" then
--         return
--     end

--     if count > 10000 then
--         if count > 1000000000 then
--             return math.floor(count / 1000000000) .. "B"
--         elseif count > 1000000 then
--             return math.floor(count / 1000000) .. "M"
--         else
--             return math.floor(count / 1000) .. "K"
--         end
--     else
--         return count
--     end
-- end

-- 资源显示规则(中文版)
function Utils.ResourceHandler(count)
    if type(count) ~= "number" then
        return
    end

    -- 不要四舍五入，并干掉他妈的0
    local function NumberFunctionWithoutRoundFunctionAndGetRidOfTheFuckingZero(num, rate)
        num = math.floor(num / (rate / 10)) / 10

        if num % 1 == 0 then
            return num
        else
            return string.format("%.1f", num)
        end
    end

    if count < 10000 then
        return count
    elseif count < 100000000 then
        return NumberFunctionWithoutRoundFunctionAndGetRidOfTheFuckingZero(count, 10000) .. Localization.TenThousand
    else
        return NumberFunctionWithoutRoundFunctionAndGetRidOfTheFuckingZero(count, 100000000) ..
            Localization.HundredMillion
    end
end

-- 百分比处理统一接口
-- return string
function Utils.NumPercentHandler(num)
    if num == nil or type(num) ~= "number" then
        return ""
    end

    return string.format("%.2f", num * 100) .. "%"
end

-- 检测fgui对象是否被销毁（uiObject类型）
function Utils.uITargetIsNil(uiTarget)
    if
        nil == uiTarget or nil == uiTarget.displayObject or uiTarget.displayObject.isDisposed or
            uiTarget.displayObject.gameObject:Equals(nil)
     then
        return true
    else
        return false
    end
end

-- 检测unity对象是否被销毁(Object类型)
function Utils.unityTargetIsNil(unityTarget)
    if nil == unityTarget or (CSharp.LogicUtils.IsNil(unityTarget)) then
        return true
    else
        return false
    end
end

-- 是否处在编辑器中
function Utils.isEditor()
    if
        CSharp.Application.platform == CSharp.RuntimePlatform.WindowsEditor or
            CSharp.Application.platform == CSharp.RuntimePlatform.OSXEditor or
            CSharp.Application.platform == CSharp.RuntimePlatform.LinuxEditor
     then
        return true
    end

    return false
end

-- 复制到剪贴板
-- content:string // 内容
function Utils.Copy(content)
    CSharp.LogicUtils.Copy(content)
    UIManager.showMessage("C_CopySuccess")
end

-- 解析服务器json
function Utils.ParseServerJsonMsg(data)
    if data == nil then
        Utils.DebugError("server data is nil")
        return ""
    end
    local content = nil
    if string.find(data, "{{JSON}}") == 1 then
        data = string.gsub(data, "{{JSON}}", "")
        local decode = json.decode(data)
        if decode == nil then
            return ""
        end
        content = DataTrunk.ConfigInfo.LocalizationServerConfig.getValue((decode["i18nkey"]))
        if content == nil then
            return ""
        end
        for k, v in pairs(decode) do
            if k ~= nil and v ~= nil then
                if string.match(k, "i18n*") then
                    -- 预留下来
                else
                    local targetStr = "{{" .. k .. "}}"
                    if string.find(v, "{{KEY}}") == 1 then
                        v = string.gsub(v, "{{KEY}}", "")
                        v = DataTrunk.ConfigInfo.LocalizationServerConfig.getValue(v)
                    end
                    content = string.gsub(content, targetStr, v)
                end
            end
        end
    else
        content = data
    end

    return content
end

-- 检测是否在范围
function Utils.checkInRange(point, range)
    if point.x >= range.x and point.x <= range.y and point.y >= range.z and point.y <= range.w then
        return true
    end
    return false
end

-- 标准话，字符串拼接
function Utils.spliceStr(content, ...)
    if nil ~= ... then
        return string.format(content, ...)
    else
        return content
    end
end

-- 销毁场景中的3D对象 transform 对象
function Utils.DestroyGameObjectImmediate(obj)
    if obj ~= nil then
        CSharp.GameObject.DestroyImmediate(obj)
    end
end

-- 检测兵种克制
function Utils.CheckRaceRestrain(race1, race2)
    local isRestrain = false
    if race1 == Define.RaceType.Infantry then
        if race2 == Define.RaceType.Cavalry or race2 == Define.RaceType.Archer then
            isRestrain = true
        end
    elseif race1 == Define.RaceType.Cavalry then
        if race2 == Define.RaceType.Chariots or race2 == Define.RaceType.Catapult then
            isRestrain = true
        end
    elseif race1 == Define.RaceType.Archer then
        if race2 == Define.RaceType.Cavalry or race2 == Define.RaceType.Catapult then
            isRestrain = true
        end
    elseif race1 == Define.RaceType.Chariots then
        if race2 == Define.RaceType.Infantry or race2 == Define.RaceType.Archer then
            isRestrain = true
        end
    elseif race1 == Define.RaceType.Catapult then
        if race2 == Define.RaceType.Infantry or race2 == Define.RaceType.Chariots then
            isRestrain = true
        end
    end
    return isRestrain
end

function Utils.GetAttackDistanceByRaceType(_racetype)
    if not _racetype then
        return Define.AttackDistanceType.None
    end
    if _racetype == Define.RaceType.Archer or _racetype == Define.RaceType.Catapult then
        return Define.AttackDistanceType.Far
    end
    return Define.AttackDistanceType.Near
end

-- 获得队伍的战力 troopsInfo为所带军队的信息, 是CaptainInfoClass或者MonsterCaptainClass的一个table
function Utils.GetTroopsFightAmount(troopsInfo)
    if troopsInfo == nil or type(troopsInfo) ~= "table" then
        return 0
    end

    local fightAmounts = {}
    for k, v in pairs(troopsInfo) do
        if v ~= nil and v.FightAmount ~= nil then
            table.insert(fightAmounts, v.FightAmount)
        end
    end

    fightAmount = Utils.GetTroopsFightAmount_2(fightAmounts)

    return fightAmount
end

-- 获得队伍的战力 fightAmounts为table，存储武将的战斗力
function Utils.GetTroopsFightAmount_2(fightAmounts)
    if fightAmounts == nil then
        return 0
    end

    -- 新版战力计算
    local fightAmount = 0
    for k, v in pairs(fightAmounts) do
        fightAmount = fightAmount + math.pow(v, 3)
    end

    fightAmount = math.floor(math.pow(fightAmount, 1 / 3))

    return fightAmount
end

-- byte 转int数字  服务器提供的方法。需要此类型转换，将bytes转换为int。
-- 君主id bytes---> int
function Utils.ByteToInt(byte)
    if byte == nil then
        Utils.DebugError("byte is nil")
        return nil
    end
    local byteTab = {}
    for i = 1, string.len(byte) do
        table.insert(byteTab, string.byte(string.sub(byte, i, i)))
    end
    if #byteTab == 0 then
        return 0
    elseif #byteTab == 1 then
        if byteTab[0] == 1 then
            return -9223372036854775808
        end
    elseif #byteTab > 8 then
        return 0
    end
    local p = 1
    local a = 0
    for i = 1, #byteTab do
        a = a + byteTab[i] * p
        p = p * 256
    end
    local x = tonumber(a / 2)
    if a % 2 == 1 then
        x = -x
    end
    return x
end

-- int 转byte数字  服务器提供的方法。需要此类型转换，将int转换为bytes。
-- _int:必须是number类型
function Utils.IntToBytes(_int)
    if _int == nil then
        Utils.DebugError("_int is nil by Utils in 865")
        return nil
    end
    -- 保护下
    if type(_int) ~= "number" then
        local ok, int = pcall(tonumber, _int)
        if ok then
            _int = int
        else
            Utils.DebugError("_int is nil by Utils in 864")
            return nil
        end
    end

    if _int == 0 then
        return nil
    end

    local tab = ""
    if _int == -9223372036854775808 then
        tab = "1"
        return tab
    end

    local x = 0
    if _int < 0 then
        x = (-_int * 2) + 1
    else
        x = _int * 2
    end

    local bn = 8
    local n = 256
    for i = 1, 8, 1 do
        if x < n then
            bn = i
            break
        else
            n = n * 256
        end
    end

    for i = 1, bn do
        tab = tab .. string.char(math.floor(x % 256))
        x = x / 256
    end
    return tab
end

-- monosize
function Utils.MonoUsedSize()
    return CSharp.LogicUtils.MonoUsedSize()
end
-- SystemGC
function Utils.SystemGC()
    CSharp.LogicUtils.SystemGC()
end

-- LuaGC
function Utils.LuaGC()
    CSharp.LogicUtils.LuaGC()
end

-- 这是大GC，使用时请问panda
-- 尽量不要调这个，现在用在切换场景时调用
--会触发UnloadUnusedAsset、LuaGC、SystemGC
function Utils.FullGC()
    CSharp.LogicUtils.FullGC()
end

-- 计算自己城池到当前位置的距离
function Utils.GetDistanceFormMyCity(iOddQX, iOddQY)
    local dist = -1
    local myCity = DataTrunk.PlayerInfo.RegionBaseData.GetBaseInfo(DataTrunk.PlayerInfo.MonarchsData.Id)
    if myCity ~= nil then
        dist = DataTrunk.PlayerInfo.RegionData.OddQOffsetDist(iOddQX, iOddQY, myCity.BaseX, myCity.BaseY)
    end

    return dist
end

-- 协程开始
-- Utils.CoroutineStart(function() coroutine.yield(CSharp.WaitForSeconds(5)) end)
function Utils.CoroutineStart(...)
    if nil == xluaUtils then
        xluaUtils = LuaHandle.load("Misc.xluaUtils")
    end
    return CSharp.GameManager.Instance:StartCoroutine(xluaUtils.cs_generator(...))
end

-- 协程结束
-- Utils.CoroutineStop(参数为协程开始时返回的值)
function Utils.CoroutineStop(coroutine)
    return CSharp.GameManager.Instance:StopCoroutine(coroutine)
end

-- declare local variables
--// exportstring( string )
--// returns a "Lua" portable version of the string
local function exportstring(s)
    return string.format("%q", s)
end

--// The Save Function
function Utils.save(tbl, filename)
    local charS, charE = "   ", "\n"
    local file, err = io.open(filename, "wb")
    if err then
        return err
    end

    -- initiate variables for save procedure
    local tables, lookup = {tbl}, {[tbl] = 1}
    file:write("return {" .. charE)

    for idx, t in ipairs(tables) do
        file:write("-- Table: {" .. idx .. "}" .. charE)
        file:write("{" .. charE)
        local thandled = {}

        for i, v in ipairs(t) do
            thandled[i] = true
            local stype = type(v)
            -- only handle value
            if stype == "table" then
                if not lookup[v] then
                    table.insert(tables, v)
                    lookup[v] = #tables
                end
                file:write(charS .. "{" .. lookup[v] .. "}," .. charE)
            elseif stype == "string" then
                file:write(charS .. exportstring(v) .. "," .. charE)
            elseif stype == "number" then
                file:write(charS .. tostring(v) .. "," .. charE)
            end
        end

        for i, v in pairs(t) do
            -- escape handled values
            if (not thandled[i]) then
                local str = ""
                local stype = type(i)
                -- handle index
                if stype == "table" then
                    if not lookup[i] then
                        table.insert(tables, i)
                        lookup[i] = #tables
                    end
                    str = charS .. "[{" .. lookup[i] .. "}]="
                elseif stype == "string" then
                    str = charS .. "[" .. exportstring(i) .. "]="
                elseif stype == "number" then
                    str = charS .. "[" .. tostring(i) .. "]="
                end

                if str ~= "" then
                    stype = type(v)
                    -- handle value
                    if stype == "table" then
                        if not lookup[v] then
                            table.insert(tables, v)
                            lookup[v] = #tables
                        end
                        file:write(str .. "{" .. lookup[v] .. "}," .. charE)
                    elseif stype == "string" then
                        file:write(str .. exportstring(v) .. "," .. charE)
                    elseif stype == "number" then
                        file:write(str .. tostring(v) .. "," .. charE)
                    end
                end
            end
        end
        file:write("}," .. charE)
    end
    file:write("}")
    file:close()
end

--// The Load Function
function Utils.load(sfile)
    local ftables, err = loadfile(sfile)
    if err then
        return _, err
    end
    local tables = ftables()
    for idx = 1, #tables do
        local tolinki = {}
        for i, v in pairs(tables[idx]) do
            if type(v) == "table" then
                tables[idx][i] = tables[v[1]]
            end
            if type(i) == "table" and tables[i[1]] then
                table.insert(tolinki, {i, tables[i[1]]})
            end
        end
        -- link indices
        for _, v in ipairs(tolinki) do
            tables[idx][v[2]], tables[idx][v[1]] = tables[idx][v[1]], nil
        end
    end
    return tables[1]
end
