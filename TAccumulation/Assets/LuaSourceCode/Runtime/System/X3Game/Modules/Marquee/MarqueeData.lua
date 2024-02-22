﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiangyu.
--- DateTime: 2023/2/17 17:25
---

---@class MarqueeData 服务器下发数据
local MarqueeData = class("MarqueeData")

function MarqueeData:ctor()
    ---@type int 跑马灯id
    self.id = 0
    ---@type int 跑马灯生效时间
    self.enableTime = 0
    ---@type int 跑马灯失效时间
    self.disableTime = 0
    ---@type int 跑马灯展示时间
    self.playTime = 0
    ---@type int 跑马灯已经展示的时间，播放到中途关闭时需要更新这个值
    self.playedTime = 0
    ---@type string 跑马灯内容
    self.description = ""
end

---初始化数据
---@param data pbcmessage.AnnounceCMSConfig 服务器下发数据
function MarqueeData:Init(data)
    self.id = data.ID
    self.enableTime = CMSHelper.GetConvertServerStamp(data.STime)
    self.disableTime = CMSHelper.GetConvertServerStamp(data.ETime)
    
    local jsonData = JsonUtil.Decode(data.Extra)
    self.playTime =  jsonData.broadcast_loop
    
    jsonData = JsonUtil.Decode(data.Content)
    local description = CMSHelper.GetValueByLang(jsonData, "text")
    self.description = description
end

return MarqueeData