﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu
--- DateTime: 2020/11/13 14:25
---统一管理ui相关的通用业务（tips，messageBox，loading等）
---@class UICommonUtil
local UICommonUtil = {}
local messageBoxId = 0
--[[
    eg:（没有按钮）UICommonUtil.ShowMessageBox("测试")
    eg：（单个：确定按钮）
    UICommonUtil.ShowMessageBox("测试",{
        {btn_type = GameConst.MessageBoxBtnType.CONFIRM,btn_text = "确定",btn_call = function () Debug.LogError("确定回调") end}
    })
    eg:（两个按钮：确定，取消）
    UICommonUtil.ShowMessageBox("测试",{
        {btn_type = GameConst.MessageBoxBtnType.CANCEL,btn_text = "返回",btn_call = function () Debug.LogError("返回回调") end},
        {btn_type = GameConst.MessageBoxBtnType.CONFIRM,btn_text = "确定",btn_call = function () Debug.LogError("确定回调") end}
    })
    eg：（三个按钮：）
    UICommonUtil.ShowMessageBox("测试",{
        {btn_type = GameConst.MessageBoxBtnType.CANCEL,btn_text = "返回",btn_call = function () Debug.LogError("返回回调") end},
        {btn_type = GameConst.MessageBoxBtnType.CONFIRM,btn_text = "确定",btn_call = function () Debug.LogError("确定回调") end},
        {btn_type = GameConst.MessageBoxBtnType.EXTENSION,btn_text = "其他",btn_call = function () Debug.LogError("其他回调") end}
    })
--]]


---btn_type:按钮类型 GameConst.MessageBoxBtnType；
---btn_call:按钮回调;
---btn_text:按钮文本（每个类型都有默认值）;
---is_auto_close:回调之后是否需要自动关闭按钮，默认是true,如果需要根据回调控制是否需要关闭按钮，可以在对应的回调中返回true(关闭)/false（不关闭）
---@class _btn_param
---@field btn_type GameConst.MessageBoxBtnType
---@field btn_call function
---@field btn_text string | number
---@field is_auto_close boolean
---@param content string|number 文本id或者文本内容 默认空字符串
---@param data _btn_param [] 数据列表 {{btn_type,btn_call,btn_text,is_auto_close}}
---@param auto_close_mode AutoCloseMode 是否允许点击空白关闭界面（默认是点击空白关闭）:（根据策划潜规则：1 没有按钮列表的默认是点击空白关闭，2 针对单个按钮的也是默认关闭并相应对应回调 ）
---@param auto_close_click_type GameConst.MessageBoxBtnType 点击空白关闭界面之后回调类型
---@param is_replace boolean (true:替换当前栈,界面关闭之后不再恢复当前栈,false:不替换当前栈,直接入栈,等界面关闭之后恢复当前栈)
function UICommonUtil.ShowMessageBox(content, data, auto_close_mode, auto_close_click_type, is_replace, ...)
    EventMgr.Dispatch(Const.Event.SET_MESSAGE_BOX_ENABLE, true, content, data, auto_close_mode, auto_close_click_type, is_replace, ...)
    return messageBoxId
end

---@param openParam _ViewInfo  PapeGames.X3UI.ViewInfo
function UICommonUtil.ShowMessageBoxWithOpenParam(openParam, ...)
    EventMgr.Dispatch(Const.Event.SET_MESSAGE_BOX_ENABLE_WITH_OPEN_PARAM, openParam, true, ...)
    return messageBoxId
end

---动态切换messageBox的打开相关属性
---@param panelOrder int default 20
function UICommonUtil.ChangeMessageBoxOpenType(panelOrder, ...)
    EventMgr.Dispatch(Const.Event.CHANGE_MESSAGE_BOX_PANEL_TYPE, panelOrder, ...)
end

---修改当前messageBox的内容显示
---@param content string | number 文本内容或者文本id
function UICommonUtil.ChangeMessageBoxContent(content)
    EventMgr.Dispatch(Const.Event.CHANGE_MESSAGE_BOX_CONTENT, content)
end

---关闭指定messageBox
---@param id int
function UICommonUtil.CloseMessageBox(id)
    if not id then
        return
    end
    EventMgr.Dispatch(Const.Event.SET_MESSAGE_BOX_ENABLE,false, id)
end

---强制关闭当前messageBox
---@param isAll boolean
function UICommonUtil.ForceCloseMessageBox(isAll)
    if isAll then
        EventMgr.Dispatch(Const.Event.CLOSE_ALL_MESSAGE_BOX)
    else
        EventMgr.Dispatch(Const.Event.SET_MESSAGE_BOX_ENABLE, false)
    end

end

---强制关闭当前loading
function UICommonUtil.ForceCloseLoading()
    EventMgr.Dispatch(Const.Event.CLOSE_ALL_LOADING)
end

---打开CheckBox弹窗 如果已经设置了不再提醒，则直接执行 确认按钮的回调
---@param checkConst int ConfirmationID
---@param content string|number 文本id或者文本内容 默认空字符串
---@param data _btn_param [] 数据列表 {{btn_type,btn_call,btn_text,is_auto_close}}
---@param auto_close_mode AutoCloseMode 是否允许点击空白关闭界面（默认是不处理）:（根据策划潜规则：1 没有按钮列表的默认是点击空白关闭，2 针对单个按钮的也是默认关闭并相应对应回调 ）
---@param auto_close_click_type GameConst.MessageBoxBtnType 点击空白关闭界面之后回调类型
---@param is_replace boolean (true:替换当前栈,界面关闭之后不再恢复当前栈,false:不替换当前栈,直接入栈,等界面关闭之后恢复当前栈)
---@return int
function UICommonUtil.ShowCheckMessageBox(checkConst, content, data, auto_close_mode, auto_close_click_type, is_replace, ...)
    ---@type CheckMessageBox
    local CheckMessageBox = require("Runtime.System.X3Game.Modules.MessageBox.CheckMessageBox")
    return CheckMessageBox:OpenCheckMessageBox(checkConst, content, data, auto_close_mode, auto_close_click_type, is_replace, ...)
end


--[[
    显示:UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.NETWORK_CONNECTING,true,"等待内容。。。")
    隐藏:UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.NETWORK_CONNECTING,false)
--]]
---设置菊花等待界面，eg:
---打开：UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.DEFAULT,true,"测试") or UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.DEFAULT,true,1001)
---关闭:UICommonUtil.SetIndicatorEnable(GameConst.IndicatorType.DEFAULT,false)
---关闭当前所有: UICommonUtil.SetIndicatorEnable(false)
---@param indicator_type number | string | boolean 自定义的唯一id：当为boolean的时候(关闭所有等待)
---@param is_enable boolean 是否关闭
---@param text_id_or_str number | string 字符串有默认字符串
---@param show_style GameConst.IndicatorShowType 显示样式 默认
---@param is_blur boolean 是否模糊 （默认不模糊）
---@param is_mask boolean 是否半透黑（默认没有半透黑）
function UICommonUtil.SetIndicatorEnable(indicator_type, is_enable, text_id_or_str, show_style, is_blur, is_mask, ...)
    EventMgr.Dispatch(Const.Event.SET_INDICATOR_ENABLE, indicator_type, is_enable, text_id_or_str, show_style, is_blur, is_mask, ...)
end

---参数列表 text_id_or_str string | number 文本内容或者文本id
---@param delay float 延时关闭或者打开
---@see UICommonUtil.SetIndicatorEnable
function UICommonUtil.SetIndicatorEnableWithDelay(delay, ...)
    delay = delay and delay or 0
    EventMgr.Dispatch(Const.Event.SET_INDICATOR_ENABLE_WITH_DELAY, delay, ...)
end

---设置GrabFocusWnd
---@param grabFocus_type GameConst.GrabFocusType
---@param is_enable boolean 是否关闭
function UICommonUtil.SetGrabFocusEnable(grabFocus_type, is_enable, ...)
    EventMgr.Dispatch(Const.Event.SET_GRABFOCUS_ENABLE, grabFocus_type, is_enable, ...)
end


--[[
    显示:UICommonUtil.SetLoadingEnable(GameConst.LoadingType.DEFAULT,true)
    隐藏:UICommonUtil.SetLoadingEnable(GameConst.LoadingType.DEFAULT,false)
    如果特殊需求，可以添加对应参数列表：isFakeLoading，fakeLoadingFullValue，fakeLoadingDuration
--]]
---设置loading界面
---loading_type:使用的时候需要自行定义
---打开:UICommonUtil.SetLoadingEnable(GameConst.LoadingType.DEFAULT,true)
---关闭:UICommonUtil.SetLoadingEnable(GameConst.LoadingType.DEFAULT,false)
---关闭所有类型控制: UICommonUtil.SetLoadingEnable(false)
---参数列表：
---isFakeLoading
---fakeLoadingFullValue 最终进度[0-1]，默认0.5
---fakeLoadingDuration 进度总时间
---@param loading_type number GameConst.LoadingType or boolean(强制关闭loading界面)
---@param is_enable boolean
function UICommonUtil.SetLoadingEnable(loading_type, is_enable, ...)
    Debug.LogFormat("UICommonUtil.SetLoadingEnable is_enable=[%s],loading_type=[%s]", is_enable, loading_type)
    EventMgr.Dispatch(Const.Event.SET_LOADING_ENABLE, loading_type, is_enable, ...)
end

---@class _ViewInfo
---@field IsFullScreen boolean
---@field IsFocusable boolean
---@field PanelOrder int
---@field MoveInCallBack function Loading界面渐入动效结束回调
---@field MoveOutCallBack function Loading界面渐出动效结束回调
---@field IsPlayMoveIn bool 是否播放MoveIn动效
---@field IsPlayMoveOut bool 是否播放MoveOut动效
---@param openParam _ViewInfo  PapeGames.X3UI.ViewInfo
---@param loading_type number GameConst.LoadingType or boolean(强制关闭loading界面)
---@param is_enable boolean
function UICommonUtil.SetLoadingEnableWithOpenParam(openParam, loading_type, is_enable, ...)
    Debug.LogFormat("UICommonUtil.SetLoadingEnableWithOpenParam is_enable=[%s],loading_type=[%s] ", is_enable, loading_type)
    EventMgr.Dispatch(Const.Event.SET_LOADING_ENABLE_WITH_OPEN_PARAM, openParam, loading_type, is_enable, ...)
end

---设置loading的progress进度
---@param progress float
---@param isAutoClose boolean 是否自动关闭当前progress
function UICommonUtil.SetLoadingProgress(progress, isAutoClose)
    EventMgr.Dispatch("SetLoadingProgress", progress, isAutoClose)
end

--[[
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5001) --配置表文字
    UICommonUtil.ShowMessage("提示一下") --文本显示
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5000,"测试") --带参数的
--]]
---通用tips显示，支持参数
---@param text_or_id string|number
function UICommonUtil.ShowMessage(text_or_id, ...)
    EventMgr.Dispatch(Const.Event.SET_TIPS_ENABLE, true, text_or_id, ...)
end

--region 黑白屏过渡

local ScreenTransitionUtil = require("Runtime.System.X3Game.Modules.ScreenTransition.ScreenTransitionUtil")
---黑屏渐入
---@param duration number 持续时间
---@param onComplete function 结束回调
function UICommonUtil.SceneBlackScreenIn(duration, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.InOnly, 0, duration, nil, onComplete)
end
---黑屏渐出
---@param duration number 持续时间
---@param onComplete function 结束回调
function UICommonUtil.SceneBlackScreenOut(duration, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.OutOnly, 0, duration, nil, onComplete)
end
---黑屏过渡
---@param duration number 持续时间（包括变黑和恢复两个过程）
---@param onBlackOut function 屏幕全黑时的回调
---@param onComplete function 结束回调
function UICommonUtil.SceneBlackScreen(duration, onBlackOut, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.InOut, 0, duration, onBlackOut, onComplete)
end

---白屏渐入
---@param duration number 持续时间
---@param onComplete function 结束回调
function UICommonUtil.SceneWhiteScreenIn(duration, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.InOnly, 2, duration, nil, onComplete)
end

---白屏渐出
---@param duration number 持续时间
---@param onComplete function 结束回调
function UICommonUtil.SceneWhiteScreenOut(duration, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.OutOnly, 2, duration, nil, onComplete)
end

---白屏过渡
---@param duration number 持续时间（包括变白和恢复两个过程）
---@param onWhiteOut function 屏幕全白时的回调
---@param onComplete function 结束回调
function UICommonUtil.SceneWhiteScreen(duration, onWhiteOut, onComplete)
    ScreenTransitionUtil.ScreenTransition(ScreenTransitionUtil.TransitionTypeEnum.InOut, 2, duration, onWhiteOut, onComplete)
end

---清除过渡
function UICommonUtil.ScreenTransitionClear(forceClear)
    ScreenTransitionUtil.ScreenTransitionClear(forceClear)
end

---全屏白屏渐入，挡在UI前
---@param onComplete function 结束回调
---@param needCut boolean 是否不需要动画
function UICommonUtil.WhiteScreenIn(onComplete, needCut)
    ScreenTransitionUtil.WhiteScreenIn(onComplete, needCut)
end

---全屏白屏渐出，挡在UI前
---@param onComplete function 结束回调
function UICommonUtil.WhiteScreenOut(onComplete)
    ScreenTransitionUtil.WhiteScreenOut(onComplete)
end

---全屏黑屏渐入，挡在UI前
---@param onComplete function 结束回调
---@param needCut boolean 是否不需要动画
function UICommonUtil.BlackScreenIn(onComplete, needCut)
    ScreenTransitionUtil.BlackScreenIn(onComplete, needCut)
end

---全屏黑屏渐出，挡在UI前
---@param onComplete function 结束回调
function UICommonUtil.BlackScreenOut(onComplete)
    ScreenTransitionUtil.BlackScreenOut(onComplete)
end

---根据黑白屏状态清理界面
---@param onComplete function 结束回调
function UICommonUtil.ClearScreen(onComplete)
    ScreenTransitionUtil.ClearScreen(onComplete)
end

---直接关掉黑白屏界面
function UICommonUtil.CloseScreen()
    ScreenTransitionUtil.CloseScreen()
end
--endregion

--region 全屏三段式动效

function UICommonUtil.ThreeStageMotionIn(key, onComplete)
    ScreenTransitionUtil.ThreeStageMotionIn(key, onComplete)
end

function UICommonUtil.ThreeStageMotionOut(key, onOutStart, onOutComplete)
    ScreenTransitionUtil.ThreeStageMotionOut(key, onOutStart, onOutComplete)
end

function UICommonUtil.ThreeStageMotionStop(key)
    ScreenTransitionUtil.ThreeStageMotionStop(key)
end

--endregion

---@param obj UObject
---@param sprite_name string
---@param uid int
function UICommonUtil.TrySetImageWithLocalFile(obj, sprite_name, uid)
    local cfg = LuaCfgMgr.Get("LocalImageNames", sprite_name)
    if cfg and BllMgr.GetOthersBLL():IsMainPlayer() then
        local localImgName = UrlImgMgr.GetLocalImgName(sprite_name, uid, cfg.BizType)
        if UrlImgMgr.CheckFile(localImgName, cfg.BizType) and
                UrlImgMgr.SetSpriteFromFile(obj, localImgName, cfg.BizType) then
            return
        end

        UIUtil.SetImage(obj, sprite_name)
        uid = uid or PlayerUtil.GetUid()
        if uid ~= nil and uid ~= 0 then
            Debug.LogFormat("本地图片读取失败，采用保底图，【%s】", sprite_name)
        end
    else
        UIUtil.SetImage(obj, sprite_name)
    end
end

function UICommonUtil.GetFaceImageTexture(imgName, bindingObj)
    local faceIconPath = UrlImgMgr.GetLocalImgName(imgName, nil, UrlImgMgr.BizType.HeadIcon)
    local tex = UrlImgMgr.LoadTextureFromFile(faceIconPath, false, false, UrlImgMgr.BizType.HeadIcon, bindingObj)
    if tex == nil then
        local sprite = UIUtil.GetSprite(imgName, bindingObj)
        if sprite ~= nil then
            tex = sprite.texture
            local uid = PlayerUtil.GetUid()
            if uid ~= nil and uid ~= 0 then
                Debug.LogErrorFormat("本地图片读取失败，采用保底图，【%s】", imgName)
            end
        else
            Debug.LogErrorFormat("本地图片读取失败，保底图不存在，【%s】", imgName)
        end
    end

    return tex
end

---截图GameObject
local captureLogic = nil

---切换截图界面
---@param enable boolean 开启截图界面
---@param callback fun 截图完成回调
---@param motionKey string 关闭截图界面的动效Key
function UICommonUtil.SetCaptureEnable(enable, callback, motionKey)
    if enable then
        if captureLogic == nil then
            local go = Res.LoadGameObject(UIMgr.GetUIPrefabAssetPath(UIConf.CaptureTextureWnd))
            captureLogic = UICtrl.GetOrAddCtrl(go, "Runtime.System.X3Game.UI.UIView.CaptureTextureWnd.CaptureTextureLogic")
        end
        captureLogic:CaptureTexture(callback)
        --[[        if UIMgr.IsOpened(UIConf.CaptureTextureWnd) == false then
                    UIMgr.Open(UIConf.CaptureTextureWnd, callback)
                end]]
    else
        if captureLogic ~= nil then
            captureLogic:OnClose(motionKey)
            captureLogic = nil
        end
        --[[        if UIMgr.IsOpened(UIConf.CaptureTextureWnd) then
                    UIMgr.Close(UIConf.CaptureTextureWnd)
                end]]
    end
end

--region ItemTips
---显示通用道具tips
---@param item number|cfg.s3int|pbcmessage.S3Int 道具
---@param tipsType Define.ItemTipsType 道具tips类型
---@param param itemTipsExtraParam cdData可以复写
---@param cdData table 限时道具服务器数据
---@param clickTrans Transform
function UICommonUtil.ShowItemTips(item, tipsType, param, cdData, itemType, clickTrans)
    ---@type cfg.Item
    local itemId
    local itemCfg

    if type(item) == "number" then
        itemId = item
        itemCfg = BllMgr.GetItemBLL():GetItemShowCfg(itemId, itemType)
    else
        itemId = item.ID or item.Id
        itemCfg = BllMgr.GetItemBLL():GetItemShowCfg(itemId, itemType or item.Type)
    end

    if itemCfg == nil then
        return
    end

    local extraParam = param or {}
    extraParam.cdData = cdData

    if BllMgr.GetItemBLL():IsPackageItem(itemCfg.Type) then
        UIMgr.Open(UIConf.GiftItemTipsWnd, itemCfg, tipsType == Define.ItemTipsType.Fixed_EnableUse, extraParam)
    elseif itemCfg.Type == X3_CFG_CONST.ITEM_TYPE_GEMCORE and extraParam.gemCoreId then
        ---芯核实例
        UIMgr.Open(UIConf.CorePositionWnd, extraParam.gemCoreId, clickTrans, nil, nil, nil, extraParam.isShowLevelUpBtn)
    else
        UIMgr.Open(UIConf.FixedItemTipsWnd, itemCfg, itemId, tipsType, extraParam)
    end
end
--endregion

---@public 通用奖励提示
---@param RewardList table 奖励列表
---@param type int 1为飘字类型 2为奖励界面
---@param isMerge boolean 是否合并
---@param callback function 关闭的回调
---@param sourceType int sundryCfgId 主要用于不同来源需要合并的道具不同
---@param isSpilloverExp bool 是否是溢出经验的Reward
---@param params table { transDataList = pbcmessage.ItemTrans[] }
function UICommonUtil.ShowRewardPopTips(rewardList, type, isMerge, callback, sourceType, isSpilloverExp, params)
    local retReward = GameHelper.CheckRewardListIsShow(rewardList)
    if #retReward <= 0 then
        pcall(callback)
        return
    end
    if type == 1 then
        if(isMerge) then
            rewardList = UICommonUtil.SimpleMergeReward( rewardList)
        end
        if not UIMgr.IsOpened(UIConf.RewardTipsWnd) then
            UIMgr.Open(UIConf.RewardTipsWnd, rewardList)
        else
            EventMgr.Dispatch("EVENT_CHANGE_REWARDTEXT", rewardList)
        end
    else
        if isMerge == nil then
            isMerge = true
        end
        local transDataList = params and params.transDataList
        local showRewardList, transRewardDic = BllMgr.GetItemBLL():GetShowRewardAndTransReward(rewardList, transDataList)
        ErrandMgr.Add(X3_CFG_CONST.POPUP_COMMON_GETREWARD, { showRewardList, transRewardDic, isMerge, callback, sourceType, isSpilloverExp })
    end
end

---LYDJS-52468 对飘字奖励进行简单合并，无视星核，以及转化规则。无视的奖励不应该出现在此接口中
function UICommonUtil.SimpleMergeReward(rewardList)
    local retTab = PoolUtil.GetTable()
    if(rewardList) then
        for i = 1, #rewardList do
            local reward = rewardList[i]
            if table.containskey(retTab, reward.Id) then
                retTab[reward.Id].Num = retTab[reward.Id].Num + reward.Num
            else
                retTab[reward.Id] = reward
            end
        end
    end
    local arrayRet = table.dictoarray(retTab)
    PoolUtil.ReleaseTable(retTab)
    return arrayRet
end

---显示恭喜获得
---@param showRewardList pbcmessage.S3Int[] 转换前的所有道具
---@param transRewardDic table<string,pbcmessage.S3Int[]> 转换前对应 转换后的道具
function UICommonUtil.ShowRewardPopTipsByTransReward(showRewardList, transRewardDic, isMerge)
    if isMerge == nil then
        isMerge = true
    end
    ErrandMgr.Add(X3_CFG_CONST.POPUP_COMMON_GETREWARD, { showRewardList, transRewardDic, isMerge })
end

---@public 打开一个展示item的界面，有确认按钮可以执行回调
---@param RewardList table 奖励列表
---@param isMerge boolean 是否合并
---@param callback function 确认的回调
---@param sourceType int sundryCfgId 主要用于不同来源需要合并的道具不同 (暂时舍弃，用不到)
---@param desc string|nil 展示界面的描述 没有就是空字符串
---@param warnDescType int|nil 展示界面的警告描述枚举 没有就是空
function UICommonUtil.ShowRewardDisplayTips(rewardList, isMerge, callback, sourceType, desc, warnDescType)
    if isMerge == nil then
        isMerge = true
    end
    local retReward = {}
    for k, v in pairs(rewardList) do
        if v.Type == 0 then
            table.insert(retReward, v)
        else
            local itemTypeCfg = LuaCfgMgr.Get("ItemType", v.Type)
            if itemTypeCfg ~= nil then
                if itemTypeCfg.Display == 1 then
                    table.insert(retReward, v)
                end
            end
        end
    end
    if #retReward <= 0 then
        --pcall(callback)
        return
    end

    if not UIMgr.IsOpened(UIConf.CommonDisplayTips) then
        UIMgr.Open(UIConf.CommonDisplayTips, { rewardList, isMerge, callback, desc, warnDescType })
    else
        Debug.LogError("重复打开展示item的界面了")
    end
end
---@public 通用奖励提示
---@param rewardList table 奖励列表
function UICommonUtil.ShowFloatRewardTips(rewardList, targetTf)
    local retReward = {}
    for k, v in pairs(rewardList) do
        local itemTypeCfg = LuaCfgMgr.Get("ItemType", v.Type)
        if itemTypeCfg ~= nil then
            if itemTypeCfg.Display == 1 then
                table.insert(retReward, v)
            end
        end
    end
    if #retReward <= 0 then
        return
    end
    UIMgr.Open(UIConf.ComGiftTips, targetTf, retReward)
end

---@param OCX_Image UObject
---@param ID int
function UICommonUtil.SetItemIcon(OCX_Image, ID)
    local item = LuaCfgMgr.Get("Item", ID)
    if item then
        UIUtil.SetImage(OCX_Image, item.Icon)
    else
        Debug.LogError("找不到对应的Item, ID = ", ID)
    end
end

---显示体力购买
---@param isShowTips boolean
function UICommonUtil.ShowBuyPowerWnd(isShowTips)
    if isShowTips then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5318)
    end

    UIMgr.Open(UIConf.BuyPowerWnd, Define.BuyPowerWndType.BuyPower)
end

---显示浮窗
---@param content string
---@param target Transform
---@param isForward bool 是否可穿透
function UICommonUtil.ShowFloatTextTips(content, target, isForward)
    UIMgr.Open(UIConf.ComGiftTips, target, nil, content, isForward)
end

---打开通用选男主界面
---@class _roleListParam
---@field callback function
---@field selectId int
---@field roleList int[]
---@field tips int
---@field redPointId int
---@field redPointParamDic table<int,string|int>
---@param showType Define.CommonManListWndType
---@param param _roleListParam
function UICommonUtil.ShowCommonRoleList(showType, param)
    UIMgr.Open(UIConf.CommonManListWnd, nil, showType, param.callback, param.selectId, param.roleList, param.tips, param.redPointId,param.redPointParamDic)
end

--region Jump
local jump = require("Runtime.System.X3Game.Modules.Jump.Jump").new()
---设置Jump按钮回调或者执行jump
---@param jumpId int
---@param setting jumpSetting
---@return boolean 是否存在JumpId
---@return boolean 是否不可跳转
---@return int 失败类型 是否不可跳转
function UICommonUtil.SetOrDoJump(jumpId, setting)
    return jump:SetOrDoJump(jumpId, setting)
end

---检查是否可以跳转
---@param jumpId int jump表Id
---@param paras int[] 复写跳转参数
function UICommonUtil.CheckJump(jumpId, paras)
    return jump:CheckJump(jumpId, paras)
end

---检查跳转是否合法
---@param jumpId int jump表Id
function UICommonUtil.CheckJumpValid(jumpId)
    return jump:CheckJumpValid(jumpId)
end
--endregion
---打开通用规则界面
---@param groupId  int  ruleTypeId
function UICommonUtil.ShowCommonRuleWnd(groupId)
    local ruleTypeCfg = LuaCfgMgr.Get("RuleType", groupId)
    if ruleTypeCfg == nil then
        return
    end
    if ruleTypeCfg.Type == 1 then
        UIMgr.Open(UIConf.CommonRuleDetailPnl, groupId)
    elseif ruleTypeCfg.Type == 2 then
        UIMgr.Open(UIConf.NoviceGuideIntroduceWnd, groupId)
    elseif ruleTypeCfg.Type == 3 then
        --UIMgr.Open(UIConf.CommonRuleDetailPnl, groupId)
        UIMgr.Open(UIConf.NoviceGuideIntroduceWnd, groupId)
    end
end

---显示快捷购买界面
---@param costNum int
---@param followUpHandle function
---@param content string 文本内容
function UICommonUtil.BuyItemWithJewel(costNum, followUpHandle, content)
    if costNum > BllMgr.Get("PlayerBLL"):GetPlayerCoin().Jewel then
        ----if BllMgr.GetChargeBLL():ChargeIsUnlock(true) then
        --UIMgr.Open(UIConf.JewelShortcutConverWnd, costNum, followUpHandle, content)
        ----end
        local proportionNum = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.EXCHANGERATE))
        local curJewel = BllMgr.Get("PlayerBLL"):GetPlayerCoin().Jewel
        local convertNum = costNum - curJewel
        local starJewelNum = math.ceil(convertNum / proportionNum)
        local curStarJewelNum = BllMgr.Get("PlayerBLL"):GetPlayerCoin().StarJewel
        local contentTxt = content == nil and UITextHelper.GetUIText(UITextConst.UI_TEXT_5906, costNum, curJewel, convertNum, convertNum * proportionNum) or content
        local haveStarJewel = curStarJewelNum >= starJewelNum
        local goToShopMall = function()
            if BllMgr.GetChargeBLL():ChargeIsUnlock(true) then
                if GameStateMgr.GetCurStateName() == GameState.Battle then
                    UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_9113,
                            { { btn_type = GameConst.MessageBoxBtnType.CONFIRM,
                                btn_call = function()
                                    ChapterStageManager.SetJumpFunc(function()
                                        local ShopMallConst = require("Runtime.System.X3Game.GameConst.ShopMallConst")
                                        UIMgr.Open(UIConf.ShopMainWnd, ShopMallConst.TabType.CHARGE)
                                    end)
                                    EventMgr.Dispatch("OnJumpOutBattle")
                                end }, { btn_type = GameConst.MessageBoxBtnType.CANCEL } }, AutoCloseMode.None)
                else
                    local ShopMallConst = require("Runtime.System.X3Game.GameConst.ShopMallConst")
                    UIMgr.Open(UIConf.ShopMainWnd, ShopMallConst.TabType.CHARGE)
                end
            end
        end
        UICommonUtil.ShowMessageBox(contentTxt, {
            { btn_type = GameConst.MessageBoxBtnType.CONFIRM,
              btn_call = function()
                  if haveStarJewel then
                      local followUpHandle = followUpHandle
                      local req = {}
                      req.Fast = 1
                      req.SjNum = starJewelNum
                      GrpcMgr.SendRequest(RpcDefines.JewelExchangeRequest, req)
                      EventMgr.AddListenerOnce("StartJewel_ShortCut_ExChangeFinish", function()
                          if followUpHandle ~= nil then
                              followUpHandle()
                          end
                      end)
                  else
                      goToShopMall()
                  end
              end,
              btn_text = haveStarJewel and UITextConst.UI_TEXT_5911 or UITextConst.UI_TEXT_5928 }, {
                btn_type = GameConst.MessageBoxBtnType.CANCEL
            }
        })
    else
        followUpHandle()
    end
end

---打印当前debug信息
function UICommonUtil.DebugPrint()
    EventMgr.Dispatch(Const.Event.DEBUG_PRINT_CUR_STATE)
end

---@param id int
function UICommonUtil.SetMessageBoxId(id)
    messageBoxId = id
end

---晶钻不足二次确认弹窗
---@param needNum int 购买商品需要的晶钻数量
function UICommonUtil.ShowBuyStarDiamond(needNum)
    local curNum = BllMgr.GetPlayerBLL():GetPlayerCoin().StarJewel
    local needGet = needNum - curNum
    local contactStr = UITextHelper.GetUIText(UITextConst.UI_TEXT_5927, needNum, curNum, needGet)
    UICommonUtil.ShowMessageBox(contactStr, {
        { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_5928, btn_call = function()
            if BllMgr.GetChargeBLL():ChargeIsUnlock(true) then
                local ShopMallConst = require("Runtime.System.X3Game.GameConst.ShopMallConst")
                UIMgr.Open(UIConf.ShopMainWnd, ShopMallConst.TabType.CHARGE)
            end
        end },
        { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_text = UITextConst.UI_TEXT_5702 }
    })
end

---@public
---检查targetItem是否在商城可购买 如果是则跳转
---@param targetItemId number itemId
function UICommonUtil.CheckJump2ShopByItemId(targetItemId)
    -- 检查Item配置
    local itemCfg = LuaCfgMgr.Get("Item", targetItemId)
    if not itemCfg then
        Debug.LogError("itemCfg not found, itemId : " .. tostring(targetItemId))
        return false
    end

    -- 遍历商城配置尝试寻找对应ItemId的商品
    local function __getShopGroupIdList()
        local _shopGroupIdList = {}
        for _shopGroupId, _cfg in pairs(LuaCfgMgr.GetAll("ShopGroup")) do
            if _cfg.ItemID and _cfg.ItemID[1] and _cfg.ItemID[1].ID == targetItemId then
                -- 这里配置好像都是一种商品对应一种Item, 目前只取第一位 后续有需要再修改
                table.insert(_shopGroupIdList, _shopGroupId)
            end
        end
        return _shopGroupIdList
    end
    local targetShopGroupIdList = __getShopGroupIdList()
    if table.isnilorempty(targetShopGroupIdList) then
        return false
    end

    -- 检查商品逻辑, 如果这里返回false 可能会额外返回一个tip文本
    local flag, buyCondition, conditionTip
    for idx, targetShopGroupId in ipairs(targetShopGroupIdList) do
        local shopGroupCfg = LuaCfgMgr.Get("ShopGroup", targetShopGroupId)

        flag, buyCondition = BllMgr.GetShopMallBLL():CheckShopGoodsIsShow(shopGroupCfg, true)
        local function __getConditionTip()
            local conditionTxt = {
                [ShopMallConst.ShopGroupShowLimitType.ShowCondition] = UITextConst.UI_TEXT_9364,
                [ShopMallConst.ShopGroupShowLimitType.SellOut] = UITextConst.UI_TEXT_9362,
                [ShopMallConst.ShopGroupShowLimitType.CommodityOff] = UITextConst.UI_TEXT_9363,
                [ShopMallConst.ShopGroupShowLimitType.PreShopGoods] = UITextConst.UI_TEXT_9361,
            }
            if buyCondition and conditionTxt[buyCondition] then
                return conditionTxt[buyCondition]
            end
        end
        if flag then
            -- 商品可购买直接跳转
            local itemName = UITextHelper.GetUIText(itemCfg.Name)
            UICommonUtil.ShowMessageBox(UITextHelper.GetUIText(UITextConst.UI_TEXT_12010, itemName), {
                { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_call = function()
                    BllMgr.GetShopMallBLL():JumpToShop(X3_CFG_CONST.SHOP_DIAMOND, { ID = targetItemId, Type = itemCfg.Type, Num = 1 })
                end },
                { btn_type = GameConst.MessageBoxBtnType.CANCEL }
            })
            return true
        else
            conditionTip = conditionTip or __getConditionTip()
        end
    end

    return false, conditionTip
end

---@public 打开技能Tips
---@param skillId number 技能Id
---@param skillLevel number 技能等级
---@param skillType number 技能类型 枚举
---@param targetObj GameObject 参考对象 因为技能Tips要根据参考对象调整其位置
function UICommonUtil.ShowSkillTip(skillId, skillLevel, skillType, targetObj)
    if not skillId or not skillLevel or not skillType or not targetObj then
        Debug.LogError("ShowSkillTips param not found ")
        return
    end

    UIMgr.Open(UIConf.SkillTips, { skillId = skillId, skillLevel = skillLevel, skillType = skillType, targetObj = targetObj })
end

---@public 设置玩家头像 (通用预设版本)
---@param rootObj GameObject 通用头像预设根节点 (预设名: UIPrefab_HeadIcon_Normal)
---@param playerInfoProxy PlayerInfoProxy 玩家信息proxy
---@param headData pbcmessage.PersonalHead 头像数据 (可选传参 不传入会从proxy中拿)
---@param frameId number 头像框Id (可选传参 不传入会从proxy中拿)
---@param faceUrl string
---@param uid number
function UICommonUtil.SetPlayerIcon(rootObj, playerInfoProxy, headData, frameId, faceUrl, uid)
    playerInfoProxy = playerInfoProxy or SelfProxyFactory.GetPlayerInfoProxy()
    headData = headData or playerInfoProxy:GetHead()
    frameId = frameId or playerInfoProxy:GetFrame()
    faceUrl = faceUrl or playerInfoProxy:GetFaceUrl()
    uid = uid or playerInfoProxy:GetUid()
    local headType = headData and headData.Type or PlayerEnum.PlayerHeadType.Default

    -- set icon
    local commonIconObj = GameObjectUtil.GetComponent(rootObj, "OCX_HeadIcon")
    local miaoCardObj = GameObjectUtil.GetComponent(rootObj, "OCX_MiaoGacha")

    local styleEnumIdx = headType == PlayerEnum.PlayerHeadType.Miao and 1 or 0
    UIUtil.SetValue(GameObjectUtil.GetComponent(rootObj, "OCX_HeadIconMask"), styleEnumIdx)

    local targetHeadIconObj = headType == PlayerEnum.PlayerHeadType.Miao and miaoCardObj or commonIconObj
    PlayerUtil.SetHeadIcon(targetHeadIconObj, headData, faceUrl, uid)

    -- set frame
    local frameItemCfg = LuaCfgMgr.Get("Item", frameId)
    local frameObj = GameObjectUtil.GetComponent(rootObj, "OCX_Frame")
    GameObjectUtil.SetActive(frameObj, frameItemCfg ~= nil)
    if frameItemCfg then
        UIUtil.SetImage(frameObj, frameItemCfg.Icon)
    end
end

-- ScreenRect Padding
local SCREEN_PADDING_VERTICAL = 20
-- ScreenRect Padding
local SCREEN_PADDING_HORIZONTAL = 20
-- 两个Obj之间的像素间隔 (水平)
local SPACE_PIXEL_HORIZONTAL = 0
-- 两个Obj之间的像素间隔 (垂直)
local SPACE_PIXEL_VERTICAL = 0

---@private 获取CanvasScaler的缩放比例 (基于当前的CanvasScaler的MatchMode是Expand)
---@return number
local function __getCurrentCanvasScale()
    local canvasScaler = GameObjectUtil.GetComponent(UIMgr.GetRootCanvas(), nil, "CanvasScaler")
    local referenceResolutionWidth = canvasScaler.referenceResolution.x
    local referenceResolutionHeight = canvasScaler.referenceResolution.y

    local screenRect = RectTransformUtil.GetScreenRect()
    local screenWidth = screenRect.width
    local screenHeight = screenRect.height

    return math.min(screenWidth / referenceResolutionWidth, screenHeight / referenceResolutionHeight)
end

---@public 基于TargetObj位置设置Tip位置 (吸附TargetObj) (基于屏幕坐标计算) (考虑CanvasScaler的影响)
---@param tipObj GameObject Tip对象
---@param targetObj GameObject 目标对象
---@param posType GameConst.TipPosType 吸附规则
---后续参数可扩展比如space_x, space_y 可以计算吸附时的space pixel
function UICommonUtil.SetTipPosBasedOnTargetObj(tipObj, targetObj, posType)
    if GameObjectUtil.IsNull(tipObj) or GameObjectUtil.IsNull(targetObj) then
        Debug.LogError("SetTipPosBasedOnTargetObj Error !!")
        return
    end
    posType = posType or GameConst.TipPosType.BottomRight

    UIUtil.ForceLayoutRebuild(GameObjectUtil.GetComponent(tipObj, nil, "Transform"), true)

    -- 获取屏幕分辨率
    local canvasScale = __getCurrentCanvasScale()
    local screenRect = RectTransformUtil.GetScreenRect()
    local screen_width = screenRect.width / canvasScale
    local screen_height = screenRect.height / canvasScale

    -- 获取目标位置
    local target_pos_x, target_pos_y = GameObjectUtil.GetScreenPosXYWithCanvasAdjustment(targetObj)
    local target_width, target_height = GameObjectUtil.GetSizeDeltaXY(targetObj)

    -- 获取Tip位置
    local tip_pos_x, tip_pos_y = GameObjectUtil.GetScreenPosXYWithCanvasAdjustment(tipObj)
    local tip_width, tip_height = GameObjectUtil.GetSizeDeltaXY(tipObj)

    tipObj.transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)
    targetObj.transform.pivot = CS.UnityEngine.Vector2(0.5, 0.5)

    -- 相对位置计算 (不同规则) 规则多了以后后续可以拆分xy逻辑计算 不用一起算 省点代码
    local result_x, result_y
    if posType == GameConst.TipPosType.BottomRight then
        -- 往右 (tip左边和target左边对齐)
        result_x = target_pos_x - target_width / 2 + tip_width / 2

        -- 往下 (tip顶部和target底部对齐)
        result_y = target_pos_y - target_height / 2 - tip_height / 2
    elseif posType == GameConst.TipPosType.BottomFlex then
        -- 基于屏幕左右半部分 自适应左右
        if target_pos_x < screen_width / 2 then
            result_x = target_pos_x - target_width / 2 + tip_width / 2 + SPACE_PIXEL_HORIZONTAL
        else
            result_x = target_pos_x + target_width / 2 - tip_width / 2 - SPACE_PIXEL_HORIZONTAL
        end

        -- 往下 (tip顶部和target底部对齐)
        result_y = target_pos_y - target_height / 2 - tip_height / 2
    elseif posType == GameConst.TipPosType.FlexCenter then
        -- 中心点对齐
        result_x = target_pos_x

        -- 往下 (tip顶部和target底部对齐)
        if target_pos_y < screen_height / 2 then
            result_y = target_pos_y + target_height / 2 + tip_height / 2
        else
            result_y = target_pos_y - target_height / 2 - tip_height / 2
        end
    elseif posType == GameConst.TipPosType.BottomCenter then
        -- 中心点对齐
        result_x = target_pos_x

        -- 往下 (tip顶部和target底部对齐)
        result_y = target_pos_y - target_height / 2 - tip_height / 2
    end

    -- Tip的尺寸超过屏幕尺寸时的处理 通常不会走到这里
    local scaleSize = 1
    if tip_width > screen_width then
        scaleSize = math.min(scaleSize, screen_width / tip_width)
        result_x = 0
    end
    if tip_height > screen_height then
        scaleSize = math.min(scaleSize, screen_height / tip_height)
        result_y = 0
    end
    if scaleSize < 1 then
        GameObjectUtil.SetScreenPosXYWithCanvasAdjustment(tipObj, result_x, result_y)
        GameObjectUtil.SetScale(tipObj, scaleSize)
        return
    end

    -- 超框处理 通常不允许tipLayout的rect超过screen rect - padding
    result_x = math.min(result_x, screen_width - tip_width / 2 - SCREEN_PADDING_HORIZONTAL)                        -- 右边界
    result_x = math.max(result_x, tip_width / 2)                                                                -- 左边界	(左边界目前不处理, 处理的话就 + padding)
    result_y = math.min(result_y, screen_height - SCREEN_PADDING_VERTICAL - tip_height / 2)                        -- 上边界
    result_y = math.max(result_y, SCREEN_PADDING_VERTICAL + tip_height / 2)                                        -- 下边界

    -- set pos & scale
    GameObjectUtil.SetScale(tipObj, scaleSize)
    GameObjectUtil.SetScreenPosXYWithCanvasAdjustment(tipObj, result_x, result_y)
end

function UICommonUtil.Clear()
    UICommonUtil.SetIndicatorEnable(false)
    UICommonUtil.ForceCloseMessageBox(true)
end

return UICommonUtil