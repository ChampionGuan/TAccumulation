---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-20 18:00:13
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class InformationBLL
local InformationBLL = class("InformationBLL", BaseBll)

function InformationBLL:Init()
    self.loveData = BllMgr.GetLovePointBLL():GetLoveData()
end

---是否已收藏对话
---@param roleId int
---@param dialogueId int cfg.PhoneCall.ID
---@param nodeId int cfg.PhoneCallConversation.ID
function InformationBLL:IsCollectDialogue(roleId, dialogueId, nodeId)
    local isCollect = self.loveData:GetIsFavoriteDialogue(roleId, dialogueId, nodeId)
    return isCollect
end

---是否已收藏广播
---@param roleId int
---@param broadcastId int cfg.PhoneCall.ID
---@param subtitleID int cfg.PhoneCallConversation.ID
function InformationBLL:IsCollectBroadcast(roleId, broadcastId, subtitleID)
    local isCollect = self.loveData:GetIsFavoriteBroadCast(roleId, broadcastId, subtitleID)
    return isCollect
end

---是否已收藏短信
---@param roleId int
---@param callID int cfg.PhoneCall.ID
---@param conversation int cfg.PhoneCallConversation.ID
function InformationBLL:IsCollectPhoneCall(roleId, callID, conversation)
    local isCollect = self.loveData:GetIsFavoritePhoneCall(roleId, callID, conversation)
    return isCollect
end

--发送收藏语音
---@param roleId int
---@param dialogueId int 剧情id
---@param nodeId int 节点id
---@param chooseOrCancel bool 选择或取消
function InformationBLL:SendCollectQuotation(roleId, dialogueId, nodeId, chooseOrCancel)
    if chooseOrCancel and not self:CheckCanCollectQuotation(roleId) then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_10032)
        return
    end
    local msgCollectQuotation = PoolUtil.GetTable()
    msgCollectQuotation.ChooseOrCancel = chooseOrCancel
    msgCollectQuotation.DialogueId = dialogueId
    msgCollectQuotation.ManType = roleId
    msgCollectQuotation.NodeId = nodeId
    GrpcMgr.SendRequest(RpcDefines.CollectQuotationRequest, msgCollectQuotation, true)
    PoolUtil.ReleaseTable(msgCollectQuotation)
end

---收藏广播剧
---@param roleId int
---@param broadcastingPlayID int 广播剧id
---@param subtitleID int 子id
---@param chooseOrCancel bool 选择或取消
function InformationBLL:SendCollectBroadcasting(roleId, broadcastingPlayID, subtitleID, chooseOrCancel)
    if chooseOrCancel and not self:CheckCanCollectQuotation(roleId) then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_10032)
        return
    end
    local msgCollectBroadcasting = PoolUtil.GetTable()
    msgCollectBroadcasting.ChooseOrCancel = chooseOrCancel
    msgCollectBroadcasting.BroadcastingPlayID = broadcastingPlayID
    msgCollectBroadcasting.SubtitleID = subtitleID
    msgCollectBroadcasting.ManType = roleId
    GrpcMgr.SendRequest(RpcDefines.CollectBroadcastingRequest, msgCollectBroadcasting, true)
    PoolUtil.ReleaseTable(msgCollectBroadcasting)
end

---@param roleId int
function InformationBLL:CheckCanCollectQuotation(roleId)
    self.voiceData = self.loveData:GetVoiceData(roleId)
    local curNum = table.nums(self.voiceData:GetAllData(1))
    local maxCollectNum = self:GetMaxCollectionNum(roleId)
    return curNum < maxCollectNum
end

---@param roleId int 
function InformationBLL:GetMaxCollectionNum(roleId)
    local roleData = BllMgr.GetRoleBLL():GetRole(roleId)
    if roleData then
        local roleLevel = roleData.LoveLevel
        local loveCfg = LuaCfgMgr.Get("LovePointLevel", roleLevel)
        if loveCfg then
            return loveCfg.VoiceCollection or 0
        end
    end
    return 0
end

--确认情报
function InformationBLL:SendConfirmInformation(roleId, informationList)
    local messageBody = {}
    messageBody.ManType = roleId
    messageBody.InformationList = informationList
    GrpcMgr.SendRequest(RpcDefines.ConfirmInformationRequest, messageBody)
end

return InformationBLL
