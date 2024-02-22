---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-12-24 10:44:50
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MailBLL
local MailBLL = class("MailBLL", BaseBll)

function MailBLL:Init(mails)
    self.proxy = SelfProxyFactory.GetMailProxy()
    self.proxy:AddMails(mails)
end

---设置红点状态
---@param mailId int
---@param isHighLight boolean
function MailBLL:SetRpEnable(mailId, isHighLight)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_MAIL, isHighLight and 1 or 0, mailId)
end

-- 协议发送
---@param mailId int
function MailBLL:SendReadRequest(mailId)
    local messagebody = {}
    messagebody.Mailid = mailId
    GrpcMgr.SendRequest(RpcDefines.ReadMailRequest,messagebody,true)
end

---@param mailId int
function MailBLL:SendDrawRequest(mailId)
    local messagebody = {}
    messagebody.Mailid = mailId
    GrpcMgr.SendRequest(RpcDefines.DrawMailRequest,messagebody,true)
end

---@param mailId int
function MailBLL:SendDeleteRequest(mailId)
    local messagebody = {}
    messagebody.Mailid = mailId
    GrpcMgr.SendRequest(RpcDefines.DeleteMailRequest,messagebody,true)
end

function MailBLL:SendDrawAllRequest()
    local messagebody = {}
    GrpcMgr.SendRequest(RpcDefines.DrawAllMailsRequest,messagebody)
end

function MailBLL:SendDeleteAllRequest()
    local messagebody = {}
    GrpcMgr.SendRequest(RpcDefines.DelReadMailsRequest,messagebody)
end

---@param mails X3Data.Mail[]
---@return boolean
function MailBLL:CheckDrawAll(mails)
    local canDraw = false
    for i = 1, #mails do
        if mails[i]:GetIsReward() == X3DataConst.MailReward.MailRewardCan then
            canDraw = true
        end
    end

    return canDraw
end

---@param mails X3Data.Mail[]
---@return boolean
function MailBLL:CheckDeleteAll(mails)
    for _, v in pairs(mails) do
        if not SelfProxyFactory.GetMailProxy():IsHighLight(v) then
            return true
        end
    end

    return false
end


---短线重连
function MailBLL:GetMailDataRequest()
    local messageBody = PoolUtil.GetTable()

    GrpcMgr.SendRequest(RpcDefines.GetMailDataRequest, messageBody)
    PoolUtil.ReleaseTable(messageBody)
end

return MailBLL