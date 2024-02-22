---
--- ColorHelper
--- Created by zhanbo.
--- DateTime: 2022/8/17 10:21
---
local ColorHelper = {}
---@type CS.UnityEngine.ColorUtility
local colorUtility = nil

---@return CS.UnityEngine.ColorUtility
local function getColorUtility()
    if not colorUtility then
        colorUtility = CS.UnityEngine.ColorUtility
    end
    return colorUtility
end

---@param colorString string
function ColorHelper.TryParseHtmlString(colorString)
    return getColorUtility().TryParseHtmlString(colorString)
end

return ColorHelper
