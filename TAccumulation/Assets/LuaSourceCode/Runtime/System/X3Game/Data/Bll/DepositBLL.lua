---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-06 16:21:36
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DepositBLL
local DepositBLL = class("DepositBLL", BaseBll)
local UserCharge = nil
function DepositBLL.Init(charge)
    UserCharge = charge
end

function DepositBLL.GetOrderIdCallBack(orderId)

end

function DepositBLL.ChargeRefreshUpdate(charge)
    UserCharge = charge
    EventMgr.Dispatch("ChargeRefresCallBack", charge)
end


--发送协议相关
function DepositBLL.SendGetOrderId(depositId)
    local messageBody = {}
    messageBody.DepositId = depositId
    if BllMgr.Get("LoginBLL"):GetAccountInfo().Channel == 1 then
        messageBody.PlatformID = BllMgr.Get("LoginBLL"):GetAccountInfo().PlatId
    end
    GrpcMgr.SendRequest(RpcDefines.GetOrderIdRequest, messageBody)
end

function DepositBLL.SendGetPayResult(orderId, depositId)
    local messageBody = {}
    messageBody.OrderId = orderId
    messageBody.DepositId = depositId
    GrpcMgr.SendRequest(RpcDefines.GetPayResultRequest, messageBody)
end

function DepositBLL.SendCancelPay(orderId)
    local messageBody = {}
    messageBody.OrderId = orderId
    GrpcMgr.SendRequest(RpcDefines.CancelPayRequest, messageBody)
end

function DepositBLL.SendFakePay(depositId)
    local messageBody = {}
    messageBody.DepositId = depositId
    if BllMgr.Get("LoginBLL"):GetAccountInfo().Channel == 1 then
        messageBody.PlatformID = BllMgr.Get("LoginBLL"):GetAccountInfo().PlatId
    end
    GrpcMgr.SendRequest(RpcDefines.FakePayRequest, messageBody)
end

function DepositBLL.IsFirstCharge()
    if UserCharge.Total == 0 then
        return true
    end

    return false
end
function DepositBLL:IsFirstChargeById(chargeId)
    if table.containskey(UserCharge.Charges, chargeId) then

    else
        return true
    end
    return false
end

function DepositBLL:GetGoodsByTittleId(tittleId)
    local retTab = {}
    local shopMallCfg = LuaCfgMgr.Get("ShopMall", tittleId)
    if shopMallCfg ~= nil then
        if shopMallCfg.Type == 1 then
            local allCharge = LuaCfgMgr.GetAll("Charge")
            for i = 1, #allCharge do
                if allCharge[i].Active == 1 then
                    table.insert(retTab, allCharge[i])
                end
            end
            table.sort(retTab, function(a, b)
                if a.Sort == b.Sort then
                    return a.ID < b.ID
                else
                    return a.Sort < b.Sort
                end
            end)
        end
    end
    return retTab
end

function DepositBLL:GetShopMallTittleTab()
    local dataTab = {}
    local retTab = LuaCfgMgr.GetAll("ShopMall")
    for i, v in ipairs(retTab) do
        if v.IsShow == 1 then
            dataTab[#dataTab + 1] = v
        end
    end
    table.sort(dataTab, function(a, b)
        if a.Sort == b.Sort then
            return a.ID < b.ID
        else
            return a.Sort < b.Sort
        end
    end)
    return dataTab
end

return DepositBLL