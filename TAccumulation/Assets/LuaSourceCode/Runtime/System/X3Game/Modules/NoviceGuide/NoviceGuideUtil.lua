---@class NoviceGuideUtil
local NoviceGuideUtil = {}
local this = NoviceGuideUtil

local UnityTime = CS.UnityEngine.Time
local UIUtility = CS.X3Game.UIUtility

---@class NoviceGuideCheckInfo  -- 检测当前引导步骤的类型
---@field Timer number 计时器，一定时间后如果找不到控件，再弹出tip
---@field ControlName string 控件名字
---@field StepID number 当前引导的stepID
---@field contentID number 当前引导的ContentID
---@field UICondition string UI条件
---@field IsChecked boolean 是否已经检查完成


--- 发送引导开始前的事件
function NoviceGuideUtil.DispatchPreMessage(stepID)
    local row = LuaCfgMgr.Get("GuideStep", stepID)
    if row.PreSendMessage ~= "" then
        local mParam = string.split(row.PreSendMessage, "=")
        if #mParam >= 1 then
            local eventParams = string.split(mParam[2], ",")
            Debug.LogFormat("[Guide] 发送开始事件 , stepID : %d",stepID)
            EventMgr.Dispatch(Const.Event.GUIDE_TO_CLIENT,  table.unpack(eventParams))
        end
    end
end

--- 发送引导结束事件
function NoviceGuideUtil.DispatchEndMessage(stepID)
    local row = this.GetGuideStepCfg(stepID)
    if row.EndSendMessage ~= "" then
        local mParam = string.split(row.EndSendMessage, "=")
        if #mParam >= 1 then
            local eventParams = string.split(mParam[2], ",")
            Debug.LogFormat("[Guide] 发送结束事件 , stepID : %d",stepID)
            EventMgr.Dispatch(Const.Event.GUIDE_TO_CLIENT, table.unpack(eventParams))
        end
    end
end

---@return cfg.Guide
function NoviceGuideUtil.GetGuideCfg(guideID)
    local guideCfg = LuaCfgMgr.Get("Guide", guideID)
    return guideCfg
end

---@return cfg.GuideStep
function NoviceGuideUtil.GetGuideStepCfg(stepID)
    local stepCfg = LuaCfgMgr.Get("GuideStep", stepID)
    return stepCfg
end

---@return cfg.GuideContent
function NoviceGuideUtil.GetGuideContentCfg(contentID)
    local contentCfg = LuaCfgMgr.Get("GuideContent", contentID)
    return contentCfg
end

--- 获取新手引导详细配置
---@return cfg.GuideContent
function NoviceGuideUtil.GetRowContent(contentID)
    local row = this.GetGuideContentCfg(contentID)
    return row
end

--- 排序方法，针对引导内容的类型做排序
---@param contentA number
---@param contentB number
function NoviceGuideUtil.SortGuideContent(contentA,contentB)
    local row1 = this.GetGuideContentCfg(contentA)
    local row2 = this.GetGuideContentCfg(contentB)
    if row1.Type == row2.Type then
        return false
    end
    if row1.Type == 9 then
        return true
    elseif row1.Type == 11 and row2.Type ~= 9 then
        return true
    else
        return false
    end
end

--- 获取UI节点
---@param wnd GameObject ui对象
---@param nodeName string 节点名或节点路径
function NoviceGuideUtil.GetGuideUINode(wnd, nodeName)
    if string.find(nodeName,"ui:") then
        return UIUtility.GetGuideNode(wnd, string.replace(nodeName, "ui:", ""), "Transform")
    else
        return NoviceGuideUtil.GetControlNew(nodeName)
    end
end

local ObjPathType = {
    Type_2DUI = 0,--0:2DUI
    Type_3DUI = 1,--1:3DUI
    Type_3DGO = 2,--2:3D物体
}

---@param str string
---@return pbcmessage.S2StrInt[]
function NoviceGuideUtil.StringToS2StrIntArray(str)
    if string.isnilorempty(str) then
        return nil
    end
    local strs = string.split(str, "|")
    ---@type pbcmessage.S2StrInt[]
    local resultDatas = {}
    for _, str in ipairs(strs) do
        local data = this.StringToS2StrInt(str)
        if nil ~= data then
            table.insert(resultDatas, data)
        end
    end
    return resultDatas
end

---@param str string
---@return pbcmessage.S2StrInt
function NoviceGuideUtil.StringToS2StrInt(str)
    if string.isnilorempty(str) then
        return nil
    end
    local strs = string.split(str, "=")
    if #strs ~= 2 then
        if string.startswith(str,"=") then
            table.insert(strs,1,"")
        else
            return nil
        end
    end
    ---@type pbcmessage.S2StrInt
    local result = {}
    result.StrVal = strs[1]
    result.IntVal = tonumber(strs[2])
    return result
end

---获取UI节点
---@param pathStr string
---@return UnityEngine.GameObject,bool,string 查到的对象，是否3D物体,绑定的2DViewTag
function NoviceGuideUtil.GetGuideNodeNew(pathStr, typeStr)
    local pathDatas = this.StringToS2StrIntArray(pathStr)
    return this.GetGuideNodeWithNewData(pathDatas, typeStr)
end

---获取UI节点
---@param pathDatas pbcmessage.S2StrInt[]
---@return UnityEngine.GameObject,bool,string 查到的对象，是否3D物体,绑定的2DViewTag
function NoviceGuideUtil.GetGuideNodeWithNewData(pathDatas, typeStr)
    if nil == pathDatas then
        return nil
    end
    local dataLength = table.nums(pathDatas)
    if dataLength == 0 then
        return nil
    end
    local is3DObj = false
    local viewTag = nil
    local firstData = pathDatas[1]
    ---@type UnityEngine.GameObject
    local firstGameObject = nil
    if firstData.IntVal == ObjPathType.Type_2DUI then
        --0:2DUI
        local view = UIMgr.GetViewByTag(firstData.StrVal)
        if view then
            firstGameObject = view.gameObject
            viewTag = firstData.StrVal
        end
    elseif firstData.IntVal == ObjPathType.Type_3DUI then
        --1:3DUI
        firstGameObject = CS.UnityEngine.GameObject.Find(firstData.StrVal)
    elseif firstData.IntVal == ObjPathType.Type_3DGO then
        --2:3D物体
        firstGameObject = CS.UnityEngine.GameObject.Find(firstData.StrVal)
        is3DObj = true
    end
    if nil == firstGameObject then
        return nil
    end
    local resultTransform = firstGameObject.transform
    for i = 2, dataLength do
        resultTransform = this._GetRelativeChild(resultTransform, pathDatas[i])
        if nil == resultTransform then
            return nil
        end
    end
    local result = resultTransform.gameObject
    if not string.isnilorempty(typeStr) then
        result = GameObjectUtil.GetComponent(result, nil, typeStr)
    end
    return result,is3DObj,viewTag
end

---@param parent UnityEngine.Transform
---@param relativePath string
---@return UnityEngine.Transform
function NoviceGuideUtil._GetRelativeChildOCX(parent, relativePath)
    if nil == parent then
        return nil
    end
    local child = GameObjectUtil.GetComponent(parent, relativePath, "Transform", false)
    if child then
        return child
    else
        return parent:Find(relativePath)
    end
end

---@param parent UnityEngine.Transform
---@param pathData pbcmessage.S2StrInt
---@return UnityEngine.Transform
function NoviceGuideUtil._GetRelativeChild(parent, pathData)
    if nil == parent or nil == pathData then
        return nil
    end
    if pathData.IntVal == NoviceGuideDefine.DynamicChildType.None then
        --非动态子节点
        return this._GetRelativeChildOCX(parent, pathData.StrVal)
    else
        ---@type UnityEngine.GameObject
        local childGo
        if pathData.IntVal == NoviceGuideDefine.DynamicChildType.CurSelected then
            childGo = UIUtility.GetSelectedChildCellGo(parent.gameObject)
        else
            childGo = UIUtility.GetDynamicChildCellGo(parent.gameObject, pathData.IntVal)
        end
        if nil == childGo then
            return nil
        end
        if string.isnilorempty(pathData.StrVal) then
            return childGo.transform
        else
            return this._GetRelativeChildOCX(childGo.transform, pathData.StrVal)
        end
    end
end

--- 获取某个控件的相关信息
---@return GameObject, Vector2, boolean, string 控件obj,屏幕坐标,是否是3D对象,所属window
function NoviceGuideUtil.GetControl(controlName)
    if string.find(controlName,"=") then
        return NoviceGuideUtil.GetControlNew(controlName)
    else
        return NoviceGuideUtil.GetControlOld(controlName)
    end
end

function NoviceGuideUtil.GetControlOld(controlName)
    if string.startswith(controlName, "3d:") then
        local control = UIUtility.GetGuideNode(nil, string.replace(controlName, "3d:", ""), "")
        if nil == control then
            return nil, nil, false,nil
        end
        local screenPoint = GlobalCameraMgr.GetUnityMainCamera():WorldToScreenPoint(control.transform.position)
        return control.transform, CS.UnityEngine.Vector2(screenPoint.x, screenPoint.y), true
    elseif string.startswith(controlName, "3dui:") then
        local control = UIUtility.GetGuideNode(nil, string.replace(controlName, "3dui:", ""), "RectTransform")
        if nil == control then
            return nil, nil, false,nil
        end
        local screenPoint = CS.PapeGames.X3.RTUtility.GetCenteredScreenPosition(control)
        return control, screenPoint, false
    else
        local control = nil
        local bindWnd = nil
        local openWindowList = UIMgr.GetOpenList()
        for _, v in ipairs(openWindowList) do
            local temp = this.GetGuideUINode(v.gameObject,controlName)--UIUtility.GetGuideNode(v.gameObject, string.replace(controlName, "ui:", ""), "Transform")
            if temp and temp.gameObject.activeInHierarchy then
                control = temp
                -- editor下记录当前UI所绑定的界面
                if UNITY_EDITOR then
                    bindWnd = v.gameObject.name
                end
            end
            if control then
                break
            end
        end
        if control then
            local screenPoint = CS.PapeGames.X3.RTUtility.GetCenteredScreenPosition(control)
            return control.gameObject, screenPoint, false, bindWnd
        else
            return nil, nil, false,nil
        end
    end
end

--- 获取某个控件的相关信息
---@param pathData cfg.s2strint[]
---@return GameObject, Vector2, boolean, string 控件obj,屏幕坐标,是否是3D对象,所属window
function NoviceGuideUtil.GetControlWithPathData(pathData)
    local go, is3DObj, bind2DViewTag = this.GetGuideNodeWithNewData(pathData)
    if nil == go then
        return nil, nil, false,nil
    end
    if is3DObj then
        local screenPoint = GlobalCameraMgr.GetUnityMainCamera():WorldToScreenPoint(go.transform.position)
        return go.transform, CS.UnityEngine.Vector2(screenPoint.x, screenPoint.y), true
    else
        local rectTransform = GameObjectUtil.GetComponent(go, nil, "RectTransform")
        if nil == rectTransform then
            return nil, nil, false,nil
        end
        local screenPoint = CS.PapeGames.X3.RTUtility.GetCenteredScreenPosition(rectTransform)
        return rectTransform, screenPoint, false, bind2DViewTag
    end
end

--- 获取某个控件的相关信息
---@return GameObject, Vector2, boolean, string 控件obj,屏幕坐标,是否是3D对象,所属window
function NoviceGuideUtil.GetControlNew(controlName)
    local go, is3DObj, bind2DViewTag = this.GetGuideNodeNew(controlName)
    if nil == go then
        return nil, nil, false,nil
    end
    if is3DObj then
        local screenPoint = GlobalCameraMgr.GetUnityMainCamera():WorldToScreenPoint(go.transform.position)
        return go.transform, CS.UnityEngine.Vector2(screenPoint.x, screenPoint.y), true
    else
        local rectTransform = GameObjectUtil.GetComponent(go, nil, "RectTransform")
        if nil == rectTransform then
            return nil, nil, false,nil
        end
        local screenPoint = CS.PapeGames.X3.RTUtility.GetCenteredScreenPosition(rectTransform)
        return rectTransform, screenPoint, false, bind2DViewTag
    end
end

--- 获取UI控件的大小
---@param control GameObject 控件对象
---@param autoScale boolean 是否自动适配大小
function NoviceGuideUtil.Get2DControlSize(control,autoScale)
    local controlSize
    if (control.transform.sizeDelta.x ~= 0 and control.transform.sizeDelta.y ~= 0) or
            (not string.isnilorempty(autoScale)) then
        local globalScale = UIMgr.GetRootCanvas() and UIMgr.GetRootCanvas().scaleFactor or 1
        local screenRect = UIUtility.RectTransformToScreenSpace(control.transform, UIMgr.GetUICamera())
        controlSize = screenRect.size / globalScale
    end
    return controlSize
end

--- 检查是否允许开启引导
---@private
---@param guideType NoviceGuide_TriggerType 引导类型
function NoviceGuideUtil.CheckGuideEnable(guideType)
    -- 只有GM能控制引导是否开关，非GM包默认开启
    if not DEBUG_GM then
        return true
    end

    -- 先检查引导总开关是否开启
    if not this.GetOpenStatus() then
        return false
    end
    --- 如果是条件类型引导
    if guideType == NoviceGuideDefine.NoviceGuideType.Auto then
        if not this.GetAutoOpenStatus() then
            return false
        end
    end
    --- 如果是事件类型引导
    if guideType == NoviceGuideDefine.NoviceGuideType.Manual then
        if not this.GetManualOpenStatus() then
            return false
        end
    end
    -- 默认开启
    return true
end

--- GM Toggle ,是否开启引导
---@private
function NoviceGuideUtil.GetOpenStatus()
    return PlayerPrefs.GetBool("GuideOpen", true)
end

--- GM Toggle ,是否开启条件型引导
---@private
function NoviceGuideUtil.GetAutoOpenStatus()
    return PlayerPrefs.GetBool("GuideAutoGuideOpen", true)
end

--- GM Toggle ,是否开启事件型引导
---@private
function NoviceGuideUtil.GetManualOpenStatus()
    return PlayerPrefs.GetBool("GuideManualGuideOpen", true)
end

--- GM 清理所有的GM设置的数据，恢复默认值
---@private
function NoviceGuideUtil.ClearPlayerPrefs()
    PlayerPrefs.DeleteKey("GuideAutoGuideOpen")
    PlayerPrefs.DeleteKey("GuideManualGuideOpen")
    PlayerPrefs.DeleteKey("GuideOpen")
end

return NoviceGuideUtil