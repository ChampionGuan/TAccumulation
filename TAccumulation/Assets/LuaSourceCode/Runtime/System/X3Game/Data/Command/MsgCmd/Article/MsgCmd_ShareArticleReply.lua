﻿--- Generated by AutoGen
---
---@class MsgCmd_ShareArticleReply
local MsgCmd_ShareArticleReply = class("MsgCmd_ShareArticleReply", require("Runtime.System.Framework.GameBase.Misc.SimpleCommand"))

---Command执行
---@param data pbcmessage.ShareArticleReply
function MsgCmd_ShareArticleReply:Execute(data,request)
    SelfProxyFactory.GetArticleProxy():OnShareArticleReply(data,request)
    EventMgr.Dispatch("ShareArticleCallBack", data)
    local retReward = {}
    for k, v in pairs(data.RewardList) do
        local itemTypeCfg = LuaCfgMgr.Get("ItemType", v.Type)
        if itemTypeCfg ~= nil then
            if v.Type == 0 or itemTypeCfg.Display == 1 then
                table.insert(retReward, v)
            end
        end
    end
    if #retReward > 0 then
        UICommonUtil.ShowRewardPopTips(retReward, 1)
    end
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11421)
end

return MsgCmd_ShareArticleReply