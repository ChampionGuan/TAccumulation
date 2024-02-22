---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-10 20:31:15
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileChatItem:UICtrl
local MobileChatItem = class("MobileChatItem", UICtrl)

local PlayerControlURL = "Runtime.System.X3Game.Modules.MobileChatItem.MobileChatItemPlayer"
local RoleControlURL = "Runtime.System.X3Game.Modules.MobileChatItem.MobileChatItemRole"
local ChatDefine = require("Runtime.System.X3Game.Modules.MobileChatItem.MobileChatDefine")

function MobileChatItem:Init()
    self.showNodeName = ""
    self.curMsgGuid = 0
end

function MobileChatItem:Reset()
end

function MobileChatItem:Show(data)
    self.CurChat = data
    self.ctrl = nil

    if self.CurChat.Type == ChatDefine.MsgDataType.Line then
        self:ShowFinishLine()
        return
    elseif self.CurChat.Type == ChatDefine.MsgDataType.ManPokePlayer then
        self:ManPokePlayer()
        return
    elseif self.CurChat.Type == ChatDefine.MsgDataType.Tips then
        self:ShowSystemTips()
        return
    end

    local teller = self.CurChat.Conf.Teller

    if teller == ChatDefine.MsgTeller.Player then
        self:SetValue("", "player")
        self.showNodeName = "OCX_MyChat"
    elseif teller == ChatDefine.MsgTeller.Role then
        self:SetValue("", "role")
        self.showNodeName = "OCX_RoleChat"
    end

    if teller == ChatDefine.MsgTeller.Player then
        self:ShowContent("OCX_MyChat", PlayerControlURL)
    elseif teller == ChatDefine.MsgTeller.Role then
        self:ShowContent("OCX_RoleChat", RoleControlURL)
    end
end

---@param curMsgGuid int
function MobileChatItem:SetMsgGuid(curMsgGuid)
    self.curMsgGuid = curMsgGuid
    if self.ctrl then
        self.ctrl:SetMsgGuid(curMsgGuid)
    end
end

function MobileChatItem:ShowContent(ocx_name, url)
    self.ctrl = UICtrl.GetOrAddCtrl(self:GetComponent(ocx_name), url, self)
    self.ctrl:SetMsgGuid(self.curMsgGuid)
    self.ctrl:ShowContent(self.CurChat)
end

function MobileChatItem:ShowFinishLine()
    self:SetValue("", "split")
    self.showNodeName = "OCX_SplitLine"
end

function MobileChatItem:ManPokePlayer()
    local verb, roleName, suffix = BllMgr.GetPhoneMsgBLL():GetContactInfo(self.CurChat.ContactID, 999)
    local str = UITextHelper.GetUIText(string.isnilorempty(suffix) and UITextConst.UI_TEXT_11707 or UITextConst.UI_TEXT_11706, roleName, verb, suffix)
    self:ShowSystemBar(str)
end

function MobileChatItem:ShowSystemTips()
    local str = self.CurChat.Conf.Content
    self:ShowSystemBar(str)
end

function MobileChatItem:ShowCancelBar()
    self:SetValue("", "cancel")
    self.showNodeName = "OCX_CancelBar"

    local tf = self:GetComponent("OCX_CancelBar", "Transform")
    local txtTips = GameObjectUtil.GetComponent(tf, "Tips")
    local roleName = BllMgr.GetMobileContactBLL():GetContactShowName(self.CurChat.ContactID)
    UIUtil.SetText(txtTips, UITextConst.UI_TEXT_11114, roleName)
end

---显示戳一戳
---@param strContext string 显示内容
function MobileChatItem:ShowSystemBar(strContext)
    self:SetValue("", "system")
    self.showNodeName = "OCX_System"
    self:SetText("OCX_txt_Text", strContext)
end

--------------------------通用方法---------------------------------
--显示文字
function MobileChatItem:ShowWords(txtWords, tfBG, strContent, rootName, offsetX)
    self:SetActive(tfBG, true)
    self:SetText(txtWords, strContent)
    UITextHelper.RecalculateTmpHeight(txtWords)
end


function MobileChatItem:PlayMoveInAnimate(isNewMessage, ocxName, strAnimate, guid, chatID)
    --self:StopMotion(ocxName, strAnimate, true)
    if isNewMessage then
        EventMgr.Dispatch("Mobile_Msg_UpdateNewState", guid, chatID)
        self:PlayMotion(ocxName, strAnimate)
        self.CurChat.IsNewMessage = nil
    end
end

return MobileChatItem
