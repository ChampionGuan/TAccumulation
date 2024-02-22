---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-11-21 20:51:44
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

require "Runtime.System.X3Game.Data.Bll.MobileContactBLL"

---@class MobileChatBLL
local MobileChatBLL = class("MobileChatBLL", BaseBll)

function MobileChatBLL:OnInit()

end

function MobileChatBLL:CheckCondition(id, datas)
    BllMgr.GetPhoneMsgBLL():CheckCondition(id, datas)
end


return MobileChatBLL
