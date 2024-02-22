--region Anchor(是否通用)
local TextAnchor = {
    UpperLeft = 0,
    UpperCenter = 1,
    UpperRight = 2,
    MiddleLeft = 3,
    MiddleCenter = 4,
    MiddleRight = 5,
    LowerLeft = 6,
    LowerCenter = 7,
    LowerRight = 8
}
--endregion

--region Nest-Vector3Array(是否通用)
local Vector3Array = class("Vector3Array")
function Vector3Array:ctor()
    self.value = { Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0) }
end

function Vector3Array:Recycle()
    Vector3.Reset(self.value[1])
    Vector3.Reset(self.value[2])
    Vector3.Reset(self.value[3])
    Vector3.Reset(self.value[4])
end

local Vector3ArrayCreate = function()
    return Vector3Array.new()
end
--endregion

---@class RectTransformUtil
RectTransformUtil = {}

RectTransformUtil.Edge = {
    Left = 0,
    Right = 1,
    Top = 2,
    Bottom = 3
}

RectTransformUtil.Axis = {
    Horizontal = 0,
    Vertical = 1
}

--region RectTransform初始化
local GetWorldCorners_CS = CS.PapeGames.X3.RTUtility.GetWorldCorners
local TryGetRootCanvas = CS.PapeGames.X3.RTUtility.GetCachedRootCanvas
local ResetRTFullScreen = CS.PapeGames.X3.RTUtility.ResetRTFullScreen

local s_UICamera
---@type UnityEngine.Canvas
local s_RootCanvas
local function GetUICamera()
    if s_UICamera then
        return s_UICamera
    end
    s_UICamera = UIMgr.GetUICamera()
    return s_UICamera
end

local function GetRootCanvas(transform)
    if not s_RootCanvas then
        if transform then
            s_RootCanvas = TryGetRootCanvas(transform, true)
        else
            local canvas = UIMgr.GetRootCanvas()
            s_RootCanvas = canvas and canvas.rootCanvas or canvas
        end
    end
    return s_RootCanvas
end

local function Init(transform)
    GetUICamera(transform)
    GetRootCanvas(transform)
end

local Vec3ArrPoolName = "Vec3ArrPool_Len4"
local vector3Pool = nil
local function GetVectorObjectPool()
    if not vector3Pool then
        vector3Pool = ObjectPoolMgr:TryAddPool(Vec3ArrPoolName)
        vector3Pool:SetGetCall(Vector3ArrayCreate)
    end
    return vector3Pool
end

local function ReplaceWorldCorners(vector3Arr, vector1, vector2, vector3, vector4)
    vector3Arr[1]:Set(vector1.x, vector1.y, vector1.z)
    vector3Arr[2]:Set(vector2.x, vector2.y, vector2.z)
    vector3Arr[3]:Set(vector3.x, vector3.y, vector3.z)
    vector3Arr[4]:Set(vector4.x, vector4.y, vector4.z)
end

local function LuaGetWorldCorners(transform, vector3Arr)
    local vector1, vector2, vector3, vector4 = GetWorldCorners_CS(transform)
    ReplaceWorldCorners(vector3Arr, vector1, vector2, vector3, vector4)
end
--endregion

--region 坐标转化
local WorldToScreenPoint = CS.UnityEngine.RectTransformUtility.WorldToScreenPoint
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local ScreenPointToWorldPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle
local RectangleContainsScreenPoint = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint

---1、统一参数顺序：transfrom(RectTransform), position(screen/world), camera
function RectTransformUtil.RectangleContainsScreenPoint(transform, screenPoint, camera)
    camera = camera or GetUICamera()
    return RectangleContainsScreenPoint(screenPoint, transform, camera)
end

---返回两个：1、是否在rect范围内 2、有效的local-pos
function RectTransformUtil.GetLocalPosFromScreenPos(transform, screenPos, camera)
    camera = camera or GetUICamera()
    return ScreenPointToLocalPointInRectangle(transform, screenPos, camera, nil)
end

---返回两个：1、是否在rect范围内 2、有效的world-pos
function RectTransformUtil.GetWorldPosFromScreenPos(transform, screenPos, camera)
    camera = camera or GetUICamera()
    return ScreenPointToWorldPointInRectangle(transform, screenPos, camera, nil)
end

function RectTransformUtil.WorldToScreenPoint(worldPos, camera)
    camera = camera or GetUICamera()
    return WorldToScreenPoint(camera, worldPos)
end

local zeroVector = Vector3.zero
local zeroVector2 = Vector2.zero
---世界坐标转transfrom下本地坐标
function RectTransformUtil.InverseTransformPoint(transform, worldPos)
    if transform and worldPos then
        return transform:InverseTransformPoint(worldPos)
    end
    return zeroVector
end

---transfrom下本地坐标转成世界坐标
function RectTransformUtil.TransformPoint(transform, localPos)
    if transform and localPos then
        return transform:TransformPoint(localPos)
    end
    return zeroVector
end
--endregion

--region RTUtility所有接口
--- get RectTransform's screen pos (actually its pivot pos in screen space)
function RectTransformUtil.GetScreenPos(transform)
    if not transform then
        return Vector2.zero
    end

    Init(transform)
    ---Todo: RectTransform.position may not be right, especially when transform just awake.
    local screenPoint = RectTransformUtil.WorldToScreenPoint(transform.position)
    return screenPoint
end

--- screen pos to RectTransfrom's anchored pos
---@param transform UnityEngine.Transform
---@param screenPos Vector2
---@return Vector2
function RectTransformUtil.ScreenPosToAnchoredPos(transform, screenPos)
    if not transform then
        return Vector2.zero
    end

    Init(transform)

    local localPoint = Vector2.zero
    local parent = transform.parent
    if not parent then
        parent = transform
    else
        local anchorDelta = transform.anchorMax - transform.anchorMin
        ---todo: this step seems to be a little stupid, just need to improve
        local selfPoint = Vector2.zero
        local isInRect = nil
        isInRect, localPoint = RectTransformUtil.GetLocalPosFromScreenPos(parent, screenPos)
        isInRect, selfPoint = RectTransformUtil.GetLocalPosFromScreenPos(parent, RectTransformUtil.GetScreenPos(transform))
        localPoint = localPoint + transform.anchoredPosition - selfPoint
    end
    return localPoint
end

--- set RectTransform's anchored pos with screen pos
function RectTransformUtil.SetScreenPos(transform, screenPos)
    if not transform then
        return
    end
    local anchoredPos = RectTransformUtil.ScreenPosToAnchoredPos(transform, screenPos)
    transform.anchoredPosition = anchoredPos
end

--- set RectTransform's anchored 3D pos with screen pos
--- 在3D模型实例化情况z值会有问题，需要强设0
function RectTransformUtil.SetScreenPos3D(transform, screenPos, useFloor)
    if not transform then
        return
    end
    local anchoredPos = RectTransformUtil.ScreenPosToAnchoredPos3D(transform, screenPos)
    if useFloor then
        transform.anchoredPosition3D = CS.UnityEngine.Vector3(math.floor(anchoredPos.x), math.floor(anchoredPos.y), 0)
    else
        transform.anchoredPosition3D = CS.UnityEngine.Vector3(anchoredPos.x, anchoredPos.y, 0)
    end
end
--- screen pos to RectTransfrom's anchored pos
---@param transform UnityEngine.Transform
---@param screenPos Vector2
---@return Vector2
function RectTransformUtil.ScreenPosToAnchoredPos3D(transform, screenPos)
    if not transform then
        return Vector2.zero
    end
    Init(transform)
    local localPoint = Vector2.zero
    local parent = transform.parent
    if not parent then
        parent = transform
    else
        local isInRect = nil
        isInRect, localPoint = RectTransformUtil.GetLocalPosFromScreenPos(parent, screenPos)
        localPoint = localPoint + transform.anchoredPosition
    end
    return localPoint
end
function RectTransformUtil.GetLocalAnchoredPos(srcRt, dstRt)
    local srcScreenPos = RectTransformUtil.GetScreenPos(srcRt)
    local localPoint = RectTransformUtil.ScreenPosToAnchoredPos(dstRt, srcScreenPos)
    return localPoint
end

--- <summary>
--- get rect of RectTransform in screen space,
--- get rect of RootCanvas in screen space if transform is null
local CSRect = CS.UnityEngine.Rect
function RectTransformUtil.GetScreenRect(theRT)
    if not theRT then
        Init()
        theRT = s_RootCanvas.transform
    else
        Init(theRT)
    end

    local s_TmpVec3ArrObj = GetVectorObjectPool():Get()
    local s_TmpVec3Arr = s_TmpVec3ArrObj.value
    LuaGetWorldCorners(theRT, s_TmpVec3Arr)
    local _tepValue = RectTransformUtil.WorldToScreenPoint(s_TmpVec3Arr[1])
    s_TmpVec3Arr[1]:Set(_tepValue.x, _tepValue.y, _tepValue.z)
    _tepValue = RectTransformUtil.WorldToScreenPoint(s_TmpVec3Arr[2])
    s_TmpVec3Arr[2]:Set(_tepValue.x, _tepValue.y, _tepValue.z)
    _tepValue = RectTransformUtil.WorldToScreenPoint(s_TmpVec3Arr[3])
    s_TmpVec3Arr[3]:Set(_tepValue.x, _tepValue.y, _tepValue.z)
    _tepValue = RectTransformUtil.WorldToScreenPoint(s_TmpVec3Arr[4])
    s_TmpVec3Arr[4]:Set(_tepValue.x, _tepValue.y, _tepValue.z)

    local rect = CSRect()
    rect.xMin = Mathf.Min(s_TmpVec3Arr[1].x, s_TmpVec3Arr[2].x, s_TmpVec3Arr[3].x, s_TmpVec3Arr[4].x)
    rect.xMax = Mathf.Max(s_TmpVec3Arr[1].x, s_TmpVec3Arr[2].x, s_TmpVec3Arr[3].x, s_TmpVec3Arr[4].x)
    rect.yMin = Mathf.Min(s_TmpVec3Arr[1].y, s_TmpVec3Arr[2].y, s_TmpVec3Arr[3].y, s_TmpVec3Arr[4].y)
    rect.yMax = Mathf.Max(s_TmpVec3Arr[1].y, s_TmpVec3Arr[2].y, s_TmpVec3Arr[3].y, s_TmpVec3Arr[4].y)

    GetVectorObjectPool():Recycle(s_TmpVec3ArrObj)
    return rect
end

---@return UnityEngine.Transform
function RectTransformUtil.GetRootCanvasTransform(theRT)
    if not s_RootCanvas then
        GetRootCanvas(theRT)
    end
    return s_RootCanvas.transform
end

--- Get AnchoredPosition(local point) of srcRT's pivot in dstRT
function RectTransformUtil.ToLocalPoint(srcRT, dstRT)
    local screenPos = RectTransformUtil.WorldToScreenPoint(srcRT.position)
    local isInRect, localPos = RectTransformUtil.GetLocalPosFromScreenPos(dstRT, screenPos)
    return localPos
end

function RectTransformUtil.RootCanvasScaledSize(transform)
    if not s_RootCanvas then
        s_RootCanvas = TryGetRootCanvas(transform)
    end
    return s_RootCanvas.rect.size
end

function RectTransformUtil.GetRootCanvasPlaneDistance()
    if not s_RootCanvas then
        s_RootCanvas = GetRootCanvas()
    end
    return s_RootCanvas.planeDistance
end

---参数：TextAnchor
function RectTransformUtil.TextAnchorToVector(anchorValue)
    local dir = Vector2.zero
    local anchor = anchorValue
    if type(anchorValue) ~= "number" then
        local anchorName = tostring(anchorValue)
        anchor = tonumber(string.sub(anchorName, -1, -1)) ---长度最大一位
    end

    if anchor == TextAnchor.LowerLeft then
    elseif anchor == TextAnchor.LowerRight then
        dir:Set(1, 0)
    elseif anchor == TextAnchor.LowerCenter then
        dir:Set(0.5, 0)
    elseif anchor == TextAnchor.MiddleLeft then
        dir:Set(0, 0.5)
    elseif anchor == TextAnchor.MiddleRight then
        dir:Set(1, 0.5)
    elseif anchor == TextAnchor.MiddleCenter then
        dir:Set(0.5, 0.5)
    elseif anchor == TextAnchor.UpperLeft then
        dir:Set(0, 1)
    elseif anchor == TextAnchor.UpperRight then
        dir:Set(1, 1)
    elseif anchor == TextAnchor.UpperCenter then
        dir:Set(0.5, 1)
    end
    return dir
end

--- 两个参数是Vector3 ,  Vector3[]
--- 是否在RectTransfrom的rect区域内
---@param point Vector3
---@param corners Vector3[] 4
function RectTransformUtil.IsPointInSquareByCorners(point, corners)
    local a_temp = GetVectorObjectPool():Get()
    local angle = 0
    local a_tempVectorArr = a_temp.value
    for i = 1, #corners do
        a_tempVectorArr[i] = point - corners[i]
    end

    local tempCornersLen = #a_tempVectorArr
    for i = 1, tempCornersLen do
        if (i == tempCornersLen) then
            angle = angle + Vector3.Angle(a_tempVectorArr[i], a_tempVectorArr[1])
        else
            angle = angle + Vector3.Angle(a_tempVectorArr[i], a_tempVectorArr[i + 1])
        end
    end

    GetVectorObjectPool():Recycle(a_temp)
    angle = Mathf.Round(angle) ---0.5一位四舍五入
    --angle = angle - Mathf.Floor(angle) >= 0.5 and Mathf.Ceil(angle) or Mathf.Floor(angle)
    return Mathf.Approximately(angle, 360)
end

-----@param point Vector3
-----@param squareParas  UnityEngine.Transform (宿主transfrom)/ Vector3[] (table数组--或是来自c#的数组)
-----@return boolean 当前point是否在RectTransfrom的rect四角区域内
function RectTransformUtil.IsPointInSquare(point, squareParas)
    local a_temp = GetVectorObjectPool():Get()
    if type(squareParas) == "userdata" then
        local transform = squareParas
        LuaGetWorldCorners(transform, a_temp.value)
    else
        local vector3List = squareParas
        assert(squareParas and #squareParas == 4)
        ReplaceWorldCorners(a_temp.value, vector3List[1], vector3List[2], vector3List[3], vector3List[4])
    end

    if type(point) == "userdata" then
        point = Vector3(point.x, point.y, point.z)
    end

    local is_in = RectTransformUtil.IsPointInSquareByCorners(point, a_temp.value)
    GetVectorObjectPool():Recycle(a_temp)
    return is_in
end

--- 两个参数是Vector3[] ,  Vector3
---@param points Vector3
---@param direction Vector3
---@return Vector2
function RectTransformUtil.GetProjectionSection(points, direction)
    local m_min = Mathf.FloatMaxValue
    local m_max = Mathf.FloatMinValue
    local temp
    for i = 1, #points do
        temp = Vector3.Dot(points[i], direction)
        if temp < m_min then
            m_min = temp
        end
        if temp > m_max then
            m_max = temp
        end
    end
    return Vector2(m_min, m_max)
end

--- 两个参数是Vector2
---@param a Vector2
---@param b Vector2
---@return boolean
function RectTransformUtil.IsSectionCross(a, b)
    return (Mathf.Max(a.x, a.y) >= Mathf.Min(b.x, b.y)) and (Mathf.Min(a.x, a.y) <= Mathf.Max(b.x, b.y))
end

--- 两个参数是RectTransform相交状态

local Vector3Right = Vector3.right
local Vector3Up = Vector3.up
-----@param vectorList1 Vector3[]
-----@param vectorList2 Vector3[]
-----@return int number-relationState 0:不相交，1:相交,2:包含
function RectTransformUtil.GetRelationByCorners(vectorList1, vectorList2)
    local relationState = -1
    local a_x = RectTransformUtil.GetProjectionSection(vectorList1, Vector3Right)
    local a_y = RectTransformUtil.GetProjectionSection(vectorList1, Vector3Up)
    local b_x = RectTransformUtil.GetProjectionSection(vectorList2, Vector3Right)
    local b_y = RectTransformUtil.GetProjectionSection(vectorList2, Vector3Up)

    if (not RectTransformUtil.IsSectionCross(a_x, b_x)) or (not RectTransformUtil.IsSectionCross(a_y, b_y)) then
        ---只要有一个投影区间不重叠，就不相交
        relationState = 0
    else
        if Mathf.Approximately(a_x.x, b_x.x) and Mathf.Approximately(a_x.y, b_x.y)
                and Mathf.Approximately(a_y.x, b_y.x) and Mathf.Approximately(a_y.y, b_y.y) then
            relationState = 2
        else
            relationState = 1
            local a_contains_count, b_contains_count = 0, 0
            local count = #vectorList1
            for i = 1, count do
                if RectTransformUtil.IsPointInSquareByCorners(vectorList1[i], vectorList2) then
                    b_contains_count = b_contains_count + 1
                end
            end
            if b_contains_count ~= count then
                for i = 1, #vectorList2 do
                    if RectTransformUtil.IsPointInSquareByCorners(vectorList2[i], vectorList1) then
                        a_contains_count = a_contains_count + 1
                    end
                end
            end

            if a_contains_count == b_contains_count and a_contains_count == 0 then
                relationState = 0
                local idx = 1
                local IsSegmentCross = RectTransformUtil.IsSegmentCross
                ---检测线段相交
                while idx <= count and relationState == 0 do
                    for k = 1, count do
                        if (IsSegmentCross(vectorList1[idx], vectorList1[idx + 1 > count and 1 or idx + 1], vectorList2[k], vectorList2[k + 1 > count and 1 or k + 1])) then
                            relationState = 1
                            break
                        end
                    end
                    idx = idx + 1
                end
            else
                if Mathf.Max(a_contains_count, b_contains_count) == count then
                    relationState = 2
                end
            end
        end
    end
    return relationState
end

---检测线段是否相交
---@param a Vector3
---@param b Vector3
---@param c Vector3
---@param d Vector3
---@return boolean
function RectTransformUtil.IsSegmentCross(a, b, c, d)
    if not a or not b or not c or not d then
        return false
    end
    local ab = b - a
    local ca = a - c
    local cd = d - c

    local v1 = Vector3.Cross(ca, cd)

    if (Mathf.Abs(Vector3.Dot(v1, ab)) > 0) then
        return false
    end

    if Mathf.Approximately(Vector3.Cross(ab, cd).sqrMagnitude, 0.0001) then
        --平行
        return false
    end

    local ad = d - a
    local cb = b - c
    ---- 快速排斥
    --if (Mathf.Min(a.x, b.x) > Mathf.Max(c.x, d.x) or Mathf.Max(a.x, b.x) < Mathf.Min(c.x, d.x)
    --        or Mathf.Min(a.y, b.y) > Mathf.Max(c.y, d.y) or Mathf.Max(a.y, b.y) < Mathf.Min(c.y, d.y)
    --        or Mathf.Min(a.z, b.z) > Mathf.Max(c.z, d.z) or Mathf.Max(a.z, b.z) < Mathf.Min(c.z, d.z)
    --) then
    --    return false
    --end

    -- 跨立试验
    if (Vector3.Dot(Vector3.Cross(-ca, ab), Vector3.Cross(ab, ad)) > 0 and Vector3.Dot(Vector3.Cross(ca, cd), Vector3.Cross(cd, cb)) > 0) then
        return true
    end
    return false
end

--- 两个参数是RectTransform相交状态
-----@param transform1 UnityEngine.Transform
-----@param transform2 UnityEngine.Transform
-----@return int number-relationState 0:不相交，1:相交,2:包含
function RectTransformUtil.GetRelation(transform1, transform2)
    local a_temp = GetVectorObjectPool():Get()
    local b_temp = GetVectorObjectPool():Get()
    LuaGetWorldCorners(transform1, a_temp.value)
    LuaGetWorldCorners(transform2, b_temp.value)
    local relationState = RectTransformUtil.GetRelationByCorners(a_temp.value, b_temp.value)
    GetVectorObjectPool():Recycle(a_temp)
    GetVectorObjectPool():Recycle(b_temp)
    return relationState
end

--- <summary>
--- 通过将自己RT上的某个锚点与参考RT上的某个锚点进行叠加（Pinning）得到自己RT的AnchoredPosition
--- 若参考RT为Null则将Root Canvas作为参考RT
function RectTransformUtil.GetRelativeAnchoredPos(selfRT, selfAnchoredPos, selfSreenRect,
                                                  selfScreenPos, selfAnchor, refAnchor, refRT, keepX, keepY)

    if not selfRT then
        return zeroVector2
    end
    if keepX and keepY then
        return selfAnchoredPos
    end

    local refRect = RectTransformUtil.GetScreenRect(refRT)

    local screenPos = refRect.position + Vector2Helper.MulVec2(refRect.size, refAnchor)
    screenPos = screenPos + (selfScreenPos - selfSreenRect.position) - Vector2Helper.MulVec2(selfSreenRect.size, selfAnchor)

    local anchoredPos = RectTransformUtil.ScreenPosToAnchoredPos(selfRT, screenPos)
    if keepX then
        anchoredPos.x = selfAnchoredPos.x
    end

    if keepY then
        anchoredPos.y = selfAnchoredPos.y
    end
    return anchoredPos
end

-----通过将自己RT上的某个锚点与参考RT上的某个锚点进行叠加（Pinning）得到自己RT的AnchoredPosition
-----若参考RT为Null则将Root Canvas作为参考RT
-----@param selfRT UnityEngine.Transform 自己的RT
-----@param selfAnchor UnityEngine.TextAnchor | Vector2 相对参数 左下角对应锚点值为(0,0)，右上角对应锚点值为(1,1)
-----@param refAnchor UnityEngine.TextAnchor |Vector2 相对参数 左下角对应锚点值为(0,0)，右上角对应锚点值为(1,1)
-----@param refRT UnityEngine.Transform 自己的RT
-----@param keepX boolean 是否保持自己RT的anchoredPosition.x
-----@param keepY boolean 是否保持自己RT的anchoredPosition.y
-----@return Vector2 变换之后SelfRT的AnchoredPosition
function RectTransformUtil.PinRectTransformAnchors(selfRT, selfAnchor, refAnchor, refRT, keepX, keepY)
    if not selfRT then
        return zeroVector2
    end
    if keepX and keepY then
        return selfRT.anchoredPosition
    end

    local selfAnchorVector = selfAnchor.x and selfAnchor or RectTransformUtil.TextAnchorToVector(selfAnchor)
    local refAnchorVector = refAnchor.x and refAnchor or RectTransformUtil.TextAnchorToVector(refAnchor)

    return RectTransformUtil.GetRelativeAnchoredPos(selfRT, selfRT.anchoredPosition,
            RectTransformUtil.GetScreenRect(selfRT), RectTransformUtil.GetScreenPos(selfRT),
            selfAnchorVector, refAnchorVector, refRT, keepX, keepY)
end
--endregion

local UnityRect = CS.UnityEngine.Rect
local CameraUtility = CS.X3Game.CameraUtility
---@param camera UnityEngine.Camera
---@param relativeWorldPos Vector3
---@param radiusX float
----@param radiusY float
---@return UnityEngine.Rect
function RectTransformUtil.GetScreenRectByRadius(camera, relativeWorldPos, radiusX, radiusY)
    if camera and relativeWorldPos and radiusX and radiusY then
        local maxRelativePos = relativeWorldPos + Vector3(radiusX, radiusY, 0)
        local minRelativePos = relativeWorldPos - Vector3(radiusX, radiusY, 0)
        local _ScreenPos1 = camera:WorldToScreenPoint(minRelativePos)
        local _ScreenPos2 = camera:WorldToScreenPoint(maxRelativePos)

        local screenSize = CameraUtility.GetScreenSize()
        ---因为坐标起始方向有可能不一致，左下角 | 右上角
        local minScreenPos = Vector3(Mathf.Min(_ScreenPos1.x, _ScreenPos2.x), Mathf.Min(_ScreenPos1.y, _ScreenPos2.y))
        local maxScreenPos = Vector3(Mathf.Max(_ScreenPos1.x, _ScreenPos2.x), Mathf.Max(_ScreenPos1.y, _ScreenPos2.y))

        local size_width = Mathf.Floor(maxScreenPos.x - minScreenPos.x)
        local size_height = Mathf.Floor(maxScreenPos.y - minScreenPos.y)

        --local size = Mathf.Max(size_width, size_height) ---1、默认取最大值 2、宽高适配
        --if minScreenPos.x + size_height > screenSize.x then
        --    size = size_width
        --end
        --
        --if minScreenPos.y + size_width > screenSize.y then
        --    size = size_height
        --end

        --return UnityRect(minScreenPos.x, minScreenPos.y, size, size)

        ---需要支持长方形截图
        size_width = Mathf.Min(size_width, screenSize.x)
        size_height = Mathf.Min(size_height, screenSize.y)
        return UnityRect(minScreenPos.x, minScreenPos.y, size_width, size_height)
    end
end

---@return Rect
function RectTransformUtil.GetScreenRectByScreen(screenShotSize, offset, rectHeight, scale)
    if screenShotSize and offset and rectHeight and scale then
        local screenSize = screenShotSize
        local scaleY = screenSize.y / 1920
        local finalOffset = offset * scaleY
        local size_height = Mathf.Floor(rectHeight * scaleY)
        local size_width = Mathf.Floor(size_height * scale)

        return UnityRect(screenSize.x / 2 - size_width / 2 + finalOffset.x, screenSize.y / 2 - size_height / 2 + finalOffset.y, size_width, size_height)
    end
end

---@param rect Rect 屏幕上rect，左下角坐标
---@return Rect
function RectTransformUtil.GetCaptureRect(rect)
    local screenSize = CameraUtility.GetScreenSize()
    local x, y, w, h = rect.x, rect.y, rect.width, rect.height

    if UNITY_EDITOR or Application.IsWindows() then
        y = screenSize.y - y - h
    end

    local min_x, min_y, max_x, max_y = x, y, x + w, y + h
    if max_x < 0 then
        max_x = w
        min_x = 0
    end

    if min_x > screenSize.x then
        max_x = screenSize.x
        min_x = max_x - w
    end

    if max_y < 0 then
        max_y = h
        min_y = 0
    end

    if min_y > screenSize.y then
        max_y = screenSize.y
        min_y = max_y - h
    end

    min_x = Mathf.Clamp(min_x, 0, screenSize.x)
    max_x = Mathf.Clamp(max_x, 0, screenSize.x)
    min_y = Mathf.Clamp(min_y, 0, screenSize.y)
    max_y = Mathf.Clamp(max_y, 0, screenSize.y)
    w = max_x - min_x
    h = max_y - min_y

    return CS.UnityEngine.Rect(min_x, min_y, w, h)
end

function RectTransformUtil.ResetRTFullScreen(rt)
    ResetRTFullScreen(rt)
end

---对比测试CS.PapeGames.X3UI.RTUtility
--RectTransformUtil = CS.PapeGames.X3UI.RTUtility