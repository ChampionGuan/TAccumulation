---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-15 17:36:45
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class RedPointUtil

--require "Runtime.System.X3Game.Data.Bll.MobileContactBLL"
--require "Runtime.System.X3Game.Data.Bll.MobileChatBLL"


------红点统一处理-----------
local RedPointUtil = {}

---首次初始化
function RedPointUtil.Init()
    BllMgr.GetBagBLL():InitBagRP()
    BllMgr.GetFashionBLL():RefreshRp()
    BllMgr.GetSpecialDateBLL():InitRed()
    BllMgr.GetCardBLL():CheckCardAllRed()
    --RedPointUtil.CheckBubbleAndHeadIconRed()
    --MobileContactBLL.CheckBubbleRed()
    --MobileContactBLL.CheckBackgroundRed()
end

---Clear
function RedPointUtil.Clear()
end


---检查气泡和头像更换红点
---@param contactId int 联系人ID
function RedPointUtil.CheckBubbleAndHeadIconRed(contactId)
    if not contactId then
        local ContactList = BllMgr.GetMobileContactBLL():GetAllContact()
        for k, v in pairs(ContactList) do
            RedPointUtil.CheckBubbleAndHeadIconRed(k)
        end
        return
    end

    --第一次拦截，看当前联系人是否有新的气泡话题或换头像话题
    local bubbleAndHeadIconChatList = BllMgr.GetPhoneMsgBLL():GetChatEventList(contactId)
    local recommendDic = {}
    for i = 1, #bubbleAndHeadIconChatList do
        local msg = LuaCfgMgr.Get("PhoneMsg", bubbleAndHeadIconChatList[i])
        recommendDic[msg.Type] = msg.ID
    end

    local hasHeadIcon = recommendDic[6] ~= nil or false
    local hasBubble = recommendDic[7] ~= nil or false

    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_HEAD_TOPIC, hasHeadIcon and 1 or 0, contactId)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_PERSONALITY_BUBBLE_TOPIC, hasBubble and 1 or 0, contactId)
end

return RedPointUtil