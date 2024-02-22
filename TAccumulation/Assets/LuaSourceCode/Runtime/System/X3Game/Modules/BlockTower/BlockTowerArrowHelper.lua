---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-03-16 17:16:25
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---叠叠乐箭头指示控制器
---@class BlockTowerArrowHelper
local BlockTowerArrowHelper = class("BlockTowerArrowHelper")

---@param gameController BlockTowerGameController
function BlockTowerArrowHelper:Init(gameController)
    ---@type BlockTowerGameController
    self.gameController = gameController
    ---@type float 箭头速度，实际速度和距离成正比，越大越快
    self.speed = 0.1
    ---@type int 箭头密度，可以保证距离变大时单个箭头的大小不发生变化，数值为10代表1米长度有10个箭头，0.5米有5个
    self.arrowTimes = 10
    self.arrow = Res.LoadGameObject(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.BLOCKTOWERARROWPATH))
    self.rectTransform = GameObjectUtil.GetComponent(self.arrow, "", "RectTransform")
    self.rawImage = GameObjectUtil.GetComponent(self.arrow, "", "RawImage")
end

---Update函数
function BlockTowerArrowHelper:Update()
    local raycastData = self.gameController:GetRaycastData()
    local gameData = self.gameController:GetGameData()
    if raycastData.dragging ~= 0 and gameData.showArrow == true then
        local bodyPoint = gameData.arrowStartPos
        local screenPoint = gameData.arrowEndPos
        GameObjectUtil.SetPosition(self.arrow, bodyPoint)
        local endVector = screenPoint - bodyPoint
        endVector.y = 0
        local startVector = Vector3.Temp(1, 0, 0)
        local cross = Vector3.Cross(startVector, endVector)
        local angleY = Vector3.Angle(startVector, Vector3.Temp(endVector.x, endVector.y, endVector.z))
        if cross.y < 0 then
            angleY = 360 - angleY
        end
        GameObjectUtil.SetEulerAngles(self.arrow, self.arrow.transform.eulerAngles.x, angleY, self.arrow.transform.eulerAngles.z)
        local distance = Vector3.Distance(bodyPoint, screenPoint)
        GameObjectUtil.SetSizeDeltaXY(self.rectTransform, distance, self.rectTransform.sizeDelta.y)
        local uvRectW = distance * self.arrowTimes
        local uvRectX = math.fmod(self.rawImage.uvRect.x - self.speed * distance, 1)
        local uvRectY = self.rawImage.uvRect.y
        local uvRectH = self.rawImage.uvRect.height
        self.rawImage.uvRect = CS.UnityEngine.Rect(uvRectX, uvRectY, uvRectW, uvRectH)
        GameObjectUtil.SetActive(self.arrow, true)
    else
        GameObjectUtil.SetActive(self.arrow, false)
    end
end

---
function BlockTowerArrowHelper:Destroy()
    Res.DiscardGameObject(self.arrow)
end

return BlockTowerArrowHelper