---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-31 11:34:19
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BasePlayerBLL
local BasePlayerBLL = class("BasePlayerBLL", BaseBll)

function BasePlayerBLL:Init(Uid, UserInfo)
    self.PlayerVO = {}
end

function BasePlayerBLL:GetPlayerDetail()
    return self.PlayerDetail
end

function BasePlayerBLL:GetFrameMap()
    return  self.FrameMap
end

function BasePlayerBLL:GetTitleMap()
    return self.TitleMap
end

function BasePlayerBLL:GetMedalMap()
    return self.MedalMap
end

function BasePlayerBLL:IsMainPlayer(userid)
    return true
end

--function BasePlayerBLL:SetHeadIconImgOCX(mSelf,OCXName,setDefaultIcon)
--    if setDefaultIcon then
--        Runtime.Common.SetHeadIconImgOCX(mSelf,OCXName)
--    else
--        Runtime.Common.SetHeadIconImgOCX(mSelf,OCXName, self.PlayerVO.HeadIcon.HeadKey, self.PlayerVO.HeadIcon.HeadVal)
--    end
--end

function BasePlayerBLL:GetUserInfoReply()
end

return BasePlayerBLL