---
--- Created by yutian
--- DateTime: 2021/9/26 12:10
---

ConfigCheck = {}

function ConfigCheck.CheckCfg(path)
    local allCfgPaths = ConfigCheck.GetDirAllFile(path)
    local ok = true
    for i = 0, #allCfgPaths - 1 do
        if string.isnilorempty(allCfgPaths[i]) then goto continue end
        if not tostring(allCfgPaths[i]):find(".lua") then goto continue end
        local cfgName = string.sub(allCfgPaths[i], 1, #allCfgPaths[i] - 4)
        if cfgName == "BattleConst" then goto continue end
        local cfgPath = "Battle.Config." .. cfgName
        local cfg = LuaCfgMgr.GetAll(cfgPath)

        for k,v in pairs(cfg) do
            for _k,_v in pairs(v) do
                if _v~=nil and type(_v) == "function" then
                    local str,cls = _v()
                    if cls and cls.is_need_do_string then
                        local _,res = pcall(load,"cfgCheck="..str)
                        if not res then
                            ok = false
                            ConfigCheck.CheckTemplateArg(str, cfgName, k, _k)
                        end
                    end
                end
            end
        end
        ::continue::
    end
    return ok
end

function ConfigCheck.GetDirAllFile(path)
    local a = io.popen("dir /b ".. string.format('"%s"',path));
    local f = {}
    for l in a:lines() do
        table.insert(f,l)
    end
    a:close()
    return f
end

function ConfigCheck.CheckTemplateArg(str, cfgName, id, keyName)
    str = string.sub(str, 2, #str - 1)

    ConfigCheck.CheckSymbol(str, cfgName, id, keyName)

    ConfigCheck.CheckUpperLower(str, "FInt", cfgName, id, keyName)
    ConfigCheck.CheckUpperLower(str, "FIntM", cfgName, id, keyName)
    ConfigCheck.CheckUpperLower(str, "FVector3M", cfgName, id, keyName)

    --统计 然后检查是否少半边
    local retTbl = {}
    for s in string.gmatch(str, ".") do
        if retTbl[s] then
            retTbl[s] = retTbl[s] + 1
        else
            retTbl[s] = 1
        end
    end
    ConfigCheck.CheckOnlyHalfSymbol(str, retTbl, "(", ")", cfgName, id, keyName)
    ConfigCheck.CheckOnlyHalfSymbol(str, retTbl, "[", "]", cfgName, id, keyName)
    ConfigCheck.CheckOnlyHalfSymbol(str, retTbl, "{", "}", cfgName, id, keyName)
end

function ConfigCheck.CheckSymbol(str, cfgName, id, keyName)
    if str:find'[，。“【】《》]' then
        error(string.format("%s  -  ID:%s  Key:%s 出现部分中文符号 ", cfgName, id, keyName))
    end
    if str:find'%)%w' or str:find'%}%w'  then
        error(string.format("%s  -  ID:%s  Key:%s 括号后出现数字或子母 ", cfgName, id, keyName))
    end
end

function ConfigCheck.CheckUpperLower(str, rightWrite, cfgName, id, keyName)
    local upStr = string.upper(str)
    local upWrite = string.upper(rightWrite)
    local index
    while(true)
    do
        index = string.find(upStr, upWrite, index)
        if index == nil then
            break
        else
            local cfgWrite = string.sub(str, index, index + #rightWrite - 1)
            if cfgWrite ~= rightWrite then
                error(string.format("%s  -  ID:%s  Key:%s  大小写不正确 ", cfgName, id, keyName))
                break
            end
            index = index + 1
        end
    end
end

function ConfigCheck.CheckOnlyHalfSymbol(str, retTbl, str1, str2, cfgName, id, keyName)
    if retTbl[str1] or retTbl[str2] then
        if not retTbl[str1] or not retTbl[str2] or retTbl[str1] ~= retTbl[str2] or (retTbl[str1] + retTbl[str2]) % 2 ~= 0 then
            error(string.format("%s  -  ID:%s  Key:%s  %s%s括号少半边 ", cfgName, id, str1, str2, keyName))
        end
    end
end

return ConfigCheck