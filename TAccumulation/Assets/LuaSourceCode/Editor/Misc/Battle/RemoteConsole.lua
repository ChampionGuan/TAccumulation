﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by PC.
--- DateTime: 2020/11/28 13:36


local log_enable = true
local trace_enable = true
local sb = ""
local fsb = ""
local isEditor = Application.isEditor

local function innerString(root)
    if log_enable then
        if(type(root) ~= "table")then
            return tostring(root);
        else
            local cache = {[root] = "." }
            local function _dump(t,space,name)
                local temp = {}
                for k,v in pairs(t) do
                    local key = tostring(k)
                    if(cache[v])then
                        local tempStr = string.format("[%s]=> %s", key, cache[v]);
                        table.insert(temp, tempStr)
                    elseif type(v) == "table" then
                        local new_key = name .. "." .. key
                        cache[v] = new_key
                        local space = space..string.rep(" ",#key+5);
                        local tableStr = _dump(v, space, new_key);
                        local tempStr = string.format("[%s]=>\n%s%s", key , space, tableStr);
                        table.insert(temp, tempStr)
                    else
                        local tempStr = string.format("[%s]=> %s", key, tostring(v));
                        table.insert(temp, tempStr)
                    end
                end
                return string.format("%s", table.concat(temp,"\n"..space));
            end
           return _dump(root, "","Table")
        end
    end
end

local function parseStr(...)
	local argn = select('#',...)
	for i=1,argn do
		local argv = select(i,...)
		local str = innerString(argv)
		if sb == "" then
			sb = sb .. str
		else
            sb = sb .. "\t"
            sb = sb .. str
		end
	end
	local args = sb
	sb = ""
    return args or ""
end


local socket = require "socket"
local RemoteConsole = XECS.class("RemoteConsole")

function RemoteConsole:ctor(peerIp, peerPort)
    local hostName = socket.dns.gethostname()
    self.localIP = socket.dns.toip(hostName)
    self.peerIp = peerIp or self.localIP
    self.peerPort = peerPort or 8634

    self.udp = socket.udp()
    self.udp:setsockname("127.0.0.1", 10086)
    self.udp = socket.udp()
    self.udp:setsockname("127.0.0.1", 10086)

    self.udp:settimeout(0)
    self.udp:setpeername(self.peerIp, self.peerPort)
    self:print(string.format("客户端连接:%s", CS.UnityEngine.Application.dataPath))
    -- 这边是故意的搞个全局变量，方便使用（正式环境不会运行这里）
    printr = function(target) self:print(target) end
end


function RemoteConsole:print(textString)
    local targetStr = parseStr(textString)
    self.udp:send(targetStr)
end

-- 每次Update都receive一次网络数据
function RemoteConsole:Update()
    local text = self.udp:receive()
    if text then
        self:_RunGM(text)
    end
end

function RemoteConsole:_RunGM(textString)
    Debug.LogFormat("收到GM:"..textString)
    if textString and textString ~= "" then
        --if string.starts(textString, "#") then
        --    local data = {}
        --    data.Msg = textString
        --    Runtime.System.X3Game.Data.Network.send("MessageChat", data)
        --else
            local func = loadstring and loadstring(textString) or load(textString)
            local flag, msg = pcall(func)
            if flag == false then
                local errorMsg = "[GM]异常:"..msg
	            Debug.LogErrorFormat(errorMsg)
                self:print(errorMsg)
	         end
	      --end
    end
end

function RemoteConsole:Destroy()
    if self.udp then
        self:print(string.format("客户端关闭:%s", CS.UnityEngine.Application.dataPath))
        self.udp:close()
        self.udp = nil
    end
end
return RemoteConsole