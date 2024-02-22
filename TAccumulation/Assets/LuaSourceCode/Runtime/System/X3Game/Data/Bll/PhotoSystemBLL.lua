---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-01-12 12:04:13
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class PhotoSystemBLL
local PhotoSystemBLL = class("PhotoSystemBLL", BaseBll)
local httpReq = require("Runtime.System.Framework.GameBase.Network.HttpRequest")
local localPhotoDB = require "Runtime.System.X3Game.Modules.Photo.LocalPhotoDB"
local temp_count = 0
local SDKDefine = require("Runtime.System.X3Game.Modules.SDK.SDKDefine")

local CS_ALBUM_UTIL = CS.X3Game.Platform.PFAlbumUtility
local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"
function PhotoSystemBLL:OnInit()
    localPhotoDB.Init()
	EventMgr.AddListener(SDKDefine.Event.SDK_WEB_VIEW_NOTIFICATION, self.OnGetWebCall, self)
    self.photoGroupConfigList = LuaCfgMgr.GetAll("PhotoGroup")
end

function PhotoSystemBLL:OnGetWebCall(data)
    ---这里需要判断网页传的参数，目前对应网页还没有正式流程
    local jsonObject = data.args
    if(jsonObject["action"] == "x3-web-activity-upload") then
        local params = jsonObject["params"]
        UIMgr.Open(UIConf.PhotoH5AlbumWnd, params)
    end
end
---获取照片剩余次数
---@return int
function PhotoSystemBLL:GetPhotoSurplusCount()
    return SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypePhotoInsertCount)
end

function PhotoSystemBLL:GetLocalPhoto(photoName)
    return localPhotoDB.SelectPhotoByName(photoName)
end

---获取拍照物品数据
---@param itemID int 物品ID
---@return int,bool 物品ID,状态
function PhotoSystemBLL:GetItemInfo(itemID)
    return SelfProxyFactory.GetPhotoProxy():GetItemInfo(itemID)
end

function PhotoSystemBLL:GetPhotoList()
    return SelfProxyFactory.GetPhotoProxy():GetPhotoList()
end

function PhotoSystemBLL:GetPhotoListAvaliableNum()
    return SelfProxyFactory.GetPhotoProxy():GetPhotoListAvaliableNum()
end

function PhotoSystemBLL:UpdateActionTabRedPoint(roleId)
    SelfProxyFactory.GetPhotoProxy():UpdateActionTabRedPoint(roleId)
end

function PhotoSystemBLL:CTS_ClearRedPoint(itemID)
    local state = SelfProxyFactory.GetPhotoProxy():GetItemState(itemID)
    if not state then
        return
    end

    self:CTS_ClearSomeRedPoint({ itemID })
end

function PhotoSystemBLL:CTS_ClearSomeRedPoint(list)
    if not list or #list == 0 then
        return
    end
    for i = 1, #list do
        local id = list[i]
        SelfProxyFactory.GetPhotoProxy():SetPhotoItem(id, false)
    end

    EventMgr.Dispatch("Photo_UpdateItem_RedPoint", list)
    --local messageBody = {}
    --messageBody.ComponentList = list
    --GrpcMgr.SendRequest(RpcDefines.PhotoComponentUpdateViewdRequest,messageBody)
end
--function PhotoSystemBLL:HandleARRedPoint()
--	local ARUnlockInfo = LuaCfgMgr.Get("SystemUnLock", X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT_AR)
--	if ARUnlockInfo == nil then
--		return
--	end
--	if BllMgr.GetUnLockBLL():CheckSystemUnlock(ARUnlockInfo) then
--		local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_PURIKURAAR_ENTER)
--		if value == 0 then
--			RedPointMgr.Save(1, X3_CFG_CONST.RED_PURIKURAAR_ENTER)
--		end
--	else
--		EventMgr.AddListener("UnLockSystem", self.OnUnlockSystem, self)
--	end
--	local value = RedPointMgr.GetValue(X3_CFG_CONST.RED_PURIKURAAR_ENTER)
--	if value == 1 then
--		RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PURIKURAAR_ENTER, 1)
--	end
--end

--处理子业务解锁红点
function PhotoSystemBLL:HandleUnlockItem(unlockKey, redKey)
    local ARUnlockInfo = LuaCfgMgr.Get("SystemUnLock", unlockKey)
    if ARUnlockInfo == nil then
        return
    end
    if BllMgr.GetUnLockBLL():CheckSystemUnlock(ARUnlockInfo) then
        local value = RedPointMgr.GetValue(redKey)
        if value == 0 then
            RedPointMgr.Save(1, redKey)
        end
    else
        EventMgr.AddListener("UnLockSystem", self.OnUnlockSystem, self)
    end
    local value = RedPointMgr.GetValue(redKey)
    if value == 1 then
        RedPointMgr.UpdateCount(redKey, 1)
    end
end

function PhotoSystemBLL:HandleUnlockRedP()
    self:HandleUnlockItem(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT_AR, X3_CFG_CONST.RED_PURIKURAAR_ENTER)
    self:HandleUnlockItem(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH, X3_CFG_CONST.RED_PURIKURA_ENTER)
end

---设置AR拍照解锁红点
function PhotoSystemBLL:OnUnlockSystem(sysId)
    if sysId == X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT_AR then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PURIKURAAR_ENTER)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PURIKURAAR_ENTER, 1)
    elseif sysId == X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH then
        RedPointMgr.Save(1, X3_CFG_CONST.RED_PURIKURA_ENTER)
        RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PURIKURA_ENTER, 1)
    end
end

function PhotoSystemBLL:CTS_SavePic(picName, mode, RoleID, puzzleMode, Num, PicList, localID, actionString, dressString)
    local struct = self:GenerateSavePicStruct(picName, mode, RoleID, puzzleMode, Num, actionString, dressString)
    --Debug.LogError("CTS_SavePic")
    --Debug.LogErrorTable(struct)
    localPhotoDB.BindingServerName(localID, picName)
    self:CTS_InsertPic({ struct })
end

function PhotoSystemBLL:GenerateSavePicStruct(picName, mode, RoleID, _puzzleMode, actorNum, actionString, dressString)
    local msgStruct = {}
    msgStruct.Url = picName
    msgStruct.RoleId = RoleID
    --local heads = {}
    --msgStruct.HeadUrl = heads
    msgStruct.GroupMode = actorNum -- GameConst.PhotoGroupMode
    msgStruct.TimeStamp = GrpcMgr.GetServerTime().Ticks
    msgStruct.Mode = mode
    msgStruct.ActionList = (string.isnilorempty(actionString) or actionString == "nil") and {} or string.split(actionString, "_")
    msgStruct.DecorationList = (string.isnilorempty(dressString) or dressString == "nil") and {} or string.split(dressString, "_")

    local puzzleMode = 1
    if mode == Define.PhotoEditMode.PhotoSticker and _puzzleMode == 4 then
        puzzleMode = 4
    end
    msgStruct.PuzzleMode = puzzleMode

    return msgStruct
end

---客户端数据结构与服务器Proto转换
---@param x3data X3Data.PhotoData
function PhotoSystemBLL:GetServerStructWithX3Data(x3data)

end

---@param serverData pbcmessage.Photo
function PhotoSystemBLL:GetX3DataDataWithServerData(serverData)
    ---@type X3Data.PhotoData
    local x3Data = X3DataMgr.Create(X3DataConst.X3Data.PhotoData)
    local serverFileName = UrlImgMgr.GetFileNameWithPath(serverData.Url)

    ---名称
    x3Data:SetPrimaryValue(serverFileName)
    x3Data:SetFullUrl(serverData.Url)
    x3Data:SetMode(serverData.Mode)
    x3Data:SetMaleID(serverData.RoleId ~= 0 and serverData.RoleId or -1)
    x3Data:SetFemaleID(serverData.RoleId == 0 and 0 or -1)
    x3Data:SetPictureNum(serverData.PuzzleMode)
    x3Data:SetNumOfPeople(serverData.GroupMode)
    x3Data:SetServerPhotoName(serverFileName)
    ---默认有服务器数据的都为已上传
    x3Data:SetUploadState(X3DataConst.UploadStateEnum.HasUpload)
    ---ParentID应该无用，
    x3Data:SetPlayerID(SelfProxyFactory.GetPlayerInfoProxy():GetUid())
    if(serverData.ActionList) then
        local actionString = ""
        for _, actionId in pairs(serverData.ActionList) do
            actionString = string.format("%s_%s", actionString, actionId)
        end
        x3Data:SetActionString(actionString)
    end
    if(serverData.DecorationList) then
        local dressString = ""
        for _, dressId in pairs(serverData.DecorationList) do
            dressString = string.format("%s_%s", dressString, dressId)
        end
        x3Data:SetDressString(dressString)
    end
    x3Data:SetTimeStamp(serverData.TimeStamp)
    --x3Data:SetServerPhotoName(serverData.Url)
    x3Data:SetFullUrl(serverData.Url)
    return x3Data
end

function PhotoSystemBLL:CTS_InsertPic(data)
    ---由于LOCALDB缘故，过滤掉0
    --Debug.LogError("CTS_InsertPic ")
    --Debug.LogErrorTable(data)

    for i = 1, #data do
        local item = data[i]
        item = BllMgr.GetPlayerBLL():RefillPhotoData(item)
    end

    if(data and #data > 0) then
        local messagebody = {}
        messagebody.PhotoList = data
        --Debug.LogError("CTS_InsertPic end ")
        --Debug.LogErrorTable(data)
        GrpcMgr.SendRequest(RpcDefines.PhotoInsertRequest, messagebody)
    else
        Debug.LogWarning("上传照片数量不正确 ")
    end
    --

end

function PhotoSystemBLL:CTS_DeletePic(PicList)
    local messagebody = {}

    messagebody.UrlList = PicList
    GrpcMgr.SendRequest(RpcDefines.PhotoDeleteRequest, messagebody)
end

function PhotoSystemBLL:GetDailyUploadCount(type)
    local id = 250
    if type == Define.PicType.Photos then
        id = X3_CFG_CONST.PHOTOUPLOADNUMDAILYLIMIT
    elseif type == Define.PicType.HeadIcon then
        id = X3_CFG_CONST.PHOTOHEADDAILYLIMIT
    elseif type == Define.PicType.Card then
        id = X3_CFG_CONST.PHOTOPLAYERCARDDAILYLIMIT
    end
    local sundryCfg = LuaCfgMgr.Get("SundryConfig", id)
    if sundryCfg == nil then
        return 10000
    end --无限制
    return tonumber(sundryCfg)
end

function PhotoSystemBLL:CheckPhotoTakeCount(_surplusCount)
    --local surplusCount = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypePhotoTakeCount)
    --local surplusCount = _surplusCount or 0
    --local totalCount = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHOTODAYLIMITFORSENDCOUNT)
    --
    --return surplusCount <= totalCount
    return true
end

-------动作库
function PhotoSystemBLL:CTS_AddMarkAction(id, isAdd)
    local messagebody = {}
    messagebody.ActionID = id
    messagebody.Mark = isAdd and 1 or 0
    GrpcMgr.SendRequest(RpcDefines.PhotoActionMarkRequest, messagebody, true)
    --Debug.LogError("CTS_AddMarkAction ", id, " isAdd ", isAdd and 1 or 0)
end

function PhotoSystemBLL:OnRecieveMarkReply(data, sendData)
    --Debug.LogWarning("OnRecieveMarkReply ", data.Timestamp, " sendData ", sendData.ActionID, " mark ", sendData.Mark)
    if (data.Timestamp) then
        SelfProxyFactory.GetPhotoProxy():UpdateMarkData(data, sendData)
    end
end

function PhotoSystemBLL:GetMarkData(id)
    return SelfProxyFactory.GetPhotoProxy():GetMarkData(id)
end

-------饰品加星
function PhotoSystemBLL:CTS_AddMarkFashion(id, roleID, isAdd)
    local message = {}
    message.FashionID = id
    message.RoleID = roleID
    message.Mark = isAdd and 1 or 0
    GrpcMgr.SendRequest(RpcDefines.PhotoFashionMarkRequest, message, true)
end

function PhotoSystemBLL:OnRecieveFashionMarkReply(data, sendData)
    if (data.Timestamp) then
        SelfProxyFactory.GetPhotoProxy():UpdateFashionMarkData(data, sendData)
    end
end

function PhotoSystemBLL:GetFashionMarkData(id, roleID)
    return SelfProxyFactory.GetPhotoProxy():GetFashionMarkData(id, roleID)
end

---每日清除的计数
function PhotoSystemBLL:CTS_TakePhotoForDaily(roleID, mode, type)
    local surplusCount = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypePhotoTakeCount)
    if not self:CheckPhotoTakeCount(surplusCount) then
        return
    end
    BllMgr.GetCounterBLL():SetCounterUpdateData(X3_CFG_CONST.COUNTER_TYPE_PHOTOTAKENDAILYNUM,1,{ roleID, mode, type })
end

---拍照计数
function PhotoSystemBLL:CTS_TakePhoto(roleID, mode, type)

    ---每日的计数
    self:CTS_TakePhotoForDaily(roleID, mode, type)

    local surplusCount = SelfProxyFactory.GetUserRecordProxy():GetUserRecordValue(DataSaveRecordType.DataSaveRecordTypePhotoTakeCount)
    if not self:CheckPhotoTakeCount(surplusCount) then
        return
    end
    BllMgr.GetCounterBLL():SetCounterUpdateData(X3_CFG_CONST.COUNTER_TYPE_PHOTOTAKENNUM,1,{ roleID, mode, type })
end

---没选过姿势+倒计时结束
function PhotoSystemBLL:CTS_TakePhotoNoAction(roleID)
    BllMgr.GetCounterBLL():SetCounterUpdateData(X3_CFG_CONST.COUNTER_TYPE_PHOTOACTIONFAILEDNUM,1, { roleID })
end

function PhotoSystemBLL:ShowPhotoAlbum()
    if not self:HasPhoto() then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7326)
        return
    end
    UIMgr.Open(UIConf.PhotoAlbumListWnd, GameConst.AlbumUiType.Album)
end

---打开相册界面，需要传入对应类型
function PhotoSystemBLL:OpenAlbum(type)

end

---是否有照片
function PhotoSystemBLL:HasPhoto()
    local localCount = localPhotoDB.GetLocalPhotoCount()
    local cloudCount = #self:GetPhotoList()
    if localCount == 0 and cloudCount == 0 then
        return false
    end

    return true
end

---此接口只允许触发服务器删除时使用
function PhotoSystemBLL:CheckRemoveLocal(serverFileName)
    serverFileName = UrlImgMgr.GetFileNameWithPath(serverFileName)
    local serverFileState = UrlImgMgr.Exists(serverFileName, UrlImgMgr.BizType.PhotoAlbum)
    --Debug.LogWarning("CheckRemoveLocal ", serverFileState, " serverFileName ", serverFileName)
    if(not serverFileState) then
        ---当本地文件已删除，又删除云端时，把本地也删除
        self:DeleteLocalPhoto(serverFileName)
    end
end

---@param isUpload bool 是上传还是删除，只有上传云端及删除云端需要调用 --
function PhotoSystemBLL:ChangeLocalUploadState(serverFileName, isUpload)
    serverFileName = UrlImgMgr.GetFileNameWithPath(serverFileName)
    ---上传成功后，将本地数据与云端图片名关联，需要本地的ID
    ---@type X3Data.PhotoData
    local x3Data = localPhotoDB.SetUpdateFlag(nil, serverFileName, isUpload)
    if (not isUpload) then
        ---换设备后，云端照片在本地只有一张图，所以云端删除时不应真正删除
        --Debug.LogError("ChangeLocalUploadState serverFileName ", serverFileName, " p ", x3Data and x3Data:GetPrimaryValue())
        if((not x3Data) or (serverFileName ~= x3Data:GetPrimaryValue())) then
            UrlImgMgr.DeleteImgFile(serverFileName, UrlImgMgr.BizType.PhotoAlbum)
        end
    end
end

function PhotoSystemBLL:DeleteLocalPhoto(serverFileName)
    local x3data = localPhotoDB.GetX3DataByServerName(serverFileName)
    if(x3data) then
        UrlImgMgr.DeleteImgFile(x3data:GetPrimaryValue(), UrlImgMgr.BizType.PhotoAlbum)
        localPhotoDB.DelPhoto(nil, serverFileName)
    else
        Debug.LogError("DeleteLocalPhoto Error serverFileName ", serverFileName)
    end
end

---批量上传
function PhotoSystemBLL:UploadLocalPhoto(dataList)
    local insertList = {}
    for i = 1, #dataList do
        local picName = dataList[i].Name
        local localName = dataList[i].ID

        local localData = localPhotoDB.SelectPhotoByName(localName)
        if localData then
            local roleID = localData.MaleID
            if localData.NoP == GameConst.PhotoMode.Single and localData.FemaleID ~= -1 then
                roleID = localData.FemaleID
            end

            local struct = self:GenerateSavePicStruct(picName, localData.modeID, roleID,
                     localData.Num, localData.NoP, localData.ActionString, localData.DressString)
            struct.TimeStamp = localData.Time
            table.insert(insertList, struct)
            localPhotoDB.BindingServerName(localName, picName)
        else
            Debug.LogError("UploadLocalPhoto localData is nil ", picName)
        end
    end

    self:CTS_InsertPic(insertList)
end

---跳转到拍照玩法选择界面
---@param roleID int 男主ID 如果为0选择一个最高好感度的男主
function PhotoSystemBLL:JumpPhotoMode(roleID)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT) then
        UICommonUtil.ShowMessage(SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT))
        return
    end

    if not roleID or roleID == 0 then
        roleID = BllMgr.Get("LovePointBLL"):GetMaxPointRole()
    end
    --UIMgr.Open(UIConf.PhotoTypeWnd, roleID)  --临时屏蔽，直接跳转到大头贴
    PurikuraMgrNew.Enter(roleID, PurikuraConstNew.PhotoMode.Sticker)
end

---跳转到大头贴玩法
---@param roleID int 男主ID 如果为0选择一个最高好感度的男主
function PhotoSystemBLL:JumpPhotoSticker(roleID)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT) then
        UICommonUtil.ShowMessage(SysUnLock.LockTips(X3_CFG_CONST.SYSTEM_UNLOCK_PHOTOGRAPH_HEADSHOT))
        return
    end
    if not roleID or roleID == 0 then
        roleID = BllMgr.Get("LovePointBLL"):GetMaxPointRole()
    end
    PurikuraMgrNew.Enter(roleID, PurikuraConstNew.PhotoMode.Sticker)
end

---今日次数已用尽
function PhotoSystemBLL:TodayCanUpload(amount)
    amount = amount or 0
    local totalCount = self:GetDailyUploadCount(Define.PicType.Photos)
    local todayUploadCount = self:GetPhotoSurplusCount()
    if (todayUploadCount >= totalCount) then
        return false
    end
    if amount + todayUploadCount > totalCount then
        return false
    end

    return true
end

function PhotoSystemBLL:AlbumIsFull(amount)
    amount = amount or 0
    local limitCount = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHOTOUPLOADNUMLIMIT)
    ---8.16 dl 策划表示本地没有数量限制
    local localCount = 0--localPhotoDB.GetLocalPhotoCount()
    local cloudCount = #self:GetPhotoList()
    return (localCount + cloudCount) + amount >= limitCount
end

---保存快照照片到本地
---@param texture Texture2D 快照截屏照片
---@param roleID int 角色ID
---@param photoMode GameConst.PhotoMode
---@return string 本地文件名
function PhotoSystemBLL:SaveSnapshotPicToLocal(texture, roleID, photoMode)
    local localFileName = "fileName__" .. os.time() .. "_" .. temp_count
    local result, md5String = UrlImgMgr.SaveTextureToPngFile(texture, localFileName, UrlImgMgr.BizType.PhotoAlbum, UrlImgMgr.EFileSaveCategory.All)
    if(not result) then
        return
    end
    local baseData = PoolUtil.GetTable()
    baseData.name = localFileName
    baseData.mode = Define.PhotoEditMode.Snapshot
    baseData.maleID = roleID
    baseData.femaleID = -1
    baseData.pictureNum = 1
    baseData.numOfPeople = photoMode or GameConst.PhotoMode.Single
    baseData.md5String = md5String
    localPhotoDB.AddPhoto(baseData)
    temp_count = temp_count + 1
    PoolUtil.ReleaseTable(baseData)

    return localFileName
end

---换设备后，云端照片的数据，需要加入到本地数据库处理（这样删除云端照片时，本地仍有数据备份）
function PhotoSystemBLL:AddCloudPhoto2DB()

end

local tempCount = 0
---存到用户设备的相册---这里一定要转化么，已经有本地文件的能不能处理下--加了一个 SaveFileToAlbum
---@param texture Texture2D 需要存到本地的数据
function PhotoSystemBLL:SaveAsToAlbum(texture, cb)
    --local bytes = CS.UnityEngine.ImageConversion.EncodeToPNG(texture)
    local result = UrlImgMgr.CheckSafeSize()
    if not result then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7219)
        return
    end

    tempCount = tempCount + 1
    CS_ALBUM_UTIL.AddPhotoToAlbum(texture, "Paper" .. os.time() .. tempCount, "des", function(success)
        if(cb) then
            cb(success)
        end
        if success then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7218)
        else
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7219)
        end
    end)
end

---将本地文件存到用户设备的相册
---@param textureFilePath string 图片路径
---@param cb fun(success:bool) 回调
function PhotoSystemBLL:SaveFileToAlbum(textureFilePath, needShowTips, cb)
    local result = UrlImgMgr.CheckSafeSize()
    if not result then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7219)
        if cb then
            cb(false)
        end
        return
    end

    CS_ALBUM_UTIL.AddPhotoToAlbumWithPath(textureFilePath, "Paper" .. os.time() .. temp_count, "des", function(success)
        temp_count = temp_count + 1
        if(needShowTips) then
            if success then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7218)
            else
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7219)
            end
        end

        if cb then
            cb(success)
        end
    end)
end


--todo，结构体应该统一下，
---@param photoName string 图片名字
---@return table 图片相关数据
function PhotoSystemBLL:GetPhotoData(photoName)
    local serverPhoto = SelfProxyFactory.GetPhotoProxy():GetPhoto(photoName)
    if serverPhoto then
        return serverPhoto
    end

    local localPhoto = self:GetLocalPhoto(photoName)
    if (not localPhoto) then
        ------其他业务系统未生成对应图片数据
    else
        local roleID = localPhoto.MaleID
        if localPhoto.NoP == 1 and localPhoto.FemaleID ~= -1 then
            roleID = localPhoto.FemaleID
        end

        local actionList = (string.isnilorempty(localPhoto.ActionString) or localPhoto.ActionString == "nil") and {} or string.split(localPhoto.ActionString, "_")
        local decorationList = (string.isnilorempty(localPhoto.DressString) or localPhoto.DressString == "nil") and {} or string.split(localPhoto.DressString, "_")

        return { Url = photoName, TimeStamp = localPhoto.Time, RoleId = roleID,
                 GroupMode = localPhoto.NoP, Mode = localPhoto.modeID,
                 PuzzleMode = localPhoto.Num, ActionList = actionList, DecorationList = decorationList }
    end

end

---使用老照片的数据，换上新的图片名字
function PhotoSystemBLL:GetPhotoDataWithNewName(baseDataName, newName)
    local _newName = newName or baseDataName
    local baseData = self:GetPhotoData(baseDataName)

    if (baseData) then
        --临时处理下，后面从数据储存中处理 -- todo
        local sourcePhoto = table.clone(baseData)
        BllMgr.GetPlayerBLL():RefillPhotoData(sourcePhoto)
        baseData.SourcePhoto = sourcePhoto
        baseData.Url = _newName
        return baseData
    else
        return { Url = _newName }
    end
end

---使用已有的照片信息，填充刚刚上传的照片
function PhotoSystemBLL:GetAppendPhotoData(newPhotoName, orginPhotoName)
    local baseData = self:GetPhotoDataWithNewName(orginPhotoName)
    baseData.Status = GameConst.PhotoStatus.Audit_Default
    baseData.Url = newPhotoName
    return baseData
end

---获取符合条件的动作数量
---@param mode int 模式
---@param role int 角色
---@param roleNum int 人数
---@return int
function PhotoSystemBLL:GetActionNumByCondition(mode, role, roleNum)
    local curActionList = SelfProxyFactory.GetPhotoProxy():GetActionList()
    local cnt = 0
    for index, _ in pairs(curActionList) do
        local actionInfo = LuaCfgMgr.Get("PhotoAction", index)
        if (actionInfo) then
            if ((table.containsvalue(actionInfo.ModelGroups, mode)) or mode == -1)
                    and ((role == actionInfo.Role) or role == -1) and ((roleNum == actionInfo.Type) or roleNum == -1) then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

---条件检查
function PhotoSystemBLL:CheckCondition(id, datas, ...)
    local result = false
    local resultNum = 0
    if id == X3_CFG_CONST.CONDITION_TASK_PHOTOACTIONNUM then
        resultNum = self:GetActionNumByCondition(tonumber(datas[1]), tonumber(datas[2]), tonumber(datas[3]))
        result = ConditionCheckUtil.IsInRange(resultNum, tonumber(datas[4]), tonumber(datas[5]))
    end
    return result, resultNum
end

----------本地及远端状态
function PhotoSystemBLL:SetPhotoLocalState(fileName, state)
    SelfProxyFactory.GetPhotoProxy():SetPhotoLocalState(fileName, state)
end

function PhotoSystemBLL:GetPhotoLocalState(fileName)
    return SelfProxyFactory.GetPhotoProxy():SetPhotoLocalState(fileName)
end

function PhotoSystemBLL:SetPhotoRemoteState(fileName, serverFileName)
    SelfProxyFactory.GetPhotoProxy():SetPhotoRemoteState(fileName, serverFileName)
end

function PhotoSystemBLL:ResetPhotoRemoteState(serverFileName)
    SelfProxyFactory.GetPhotoProxy():ResetPhotoRemoteState(serverFileName)
end

function PhotoSystemBLL:GetPhotoRemoteState(fileName)
    return SelfProxyFactory.GetPhotoProxy():GetPhotoRemoteState(fileName)
end

--重新从服务器获取照片数据
function PhotoSystemBLL:RefreshPhotoData()
    local messagebody = {}
    GrpcMgr.SendRequest(RpcDefines.GetPhotoDataRequest, messagebody)
end

---检查是否特殊的限制 --必须包含或必须没有
function PhotoSystemBLL:CheckGroupLimit(checkList, ownerList)
    if(checkList) then
        local firstLimit = checkList[1]
        if(firstLimit == 0 and next(ownerList) ~= nil) then
            return false
        elseif(firstLimit ~= -1 and firstLimit ~= 0) then
            for j = 1, #checkList do
                local checkId = checkList[j]
                if(not ownerList[checkId]) then
                    return false
                end
            end
        end
        return true
    else
        return true
    end
end

--比如包含
function PhotoSystemBLL:CheckGroupLimitContains(checkList, ownerList)
    if(checkList) then
        local firstLimit = checkList[1]
        if(firstLimit ~= -1) then
            for j = 1, #checkList do
                local checkId = checkList[j]
                if(not ownerList[checkId]) then
                    return false
                end
            end
        end
    end
    return true
end

--必须包含特定数量
function PhotoSystemBLL:CheckGroupLimitContainsNum(checkList, ownerList, matchNum)
    if(checkList) then
        local firstLimit = checkList[1]
        if(firstLimit ~= -1) then
            local cnt = 0
            for j = 1, #checkList do
                local checkId = checkList[j]
                if(ownerList[checkId]) then
                    cnt = cnt + 1
                end
            end
            return cnt == matchNum
        end
    end
    return true
end

---检验photoGroup是否满足
function PhotoSystemBLL:CheckPhotoGroup(picInfo, actionDic, dressDic, texture)

    if(self.photoGroupConfigList) then
        for index, config in pairs(self.photoGroupConfigList) do
            if not SelfProxyFactory.GetPhotoProxy():CheckPhotoGroup(config.ID) then
                Debug.LogWarning(" CheckPhotoGroup Start", config.ID)
                --模式匹配
                if(config.Model ~= -1 and picInfo.Mode ~= config.Model) then
                    Debug.LogWarning(" CheckPhotoGroup Mode 不匹配 id: ", config.ID, " cur ", picInfo.Mode, "config ", config.Model)
                    goto continue
                end
                --角色匹配
                if(config.Role ~= -1 and picInfo.RoleID ~= config.Role) then
                    Debug.LogWarning(" CheckPhotoGroup Role 不匹配 id: ", config.ID, " cur ", picInfo.RoleID, "config ", config.Role)
                    goto continue
                end
                ---人数匹配
                if(config.Type ~= -1) then
                    if(config.Type ~= picInfo.NumOfPeople) then
                        Debug.LogWarning(" CheckPhotoGroup Type 不匹配 id: ", config.ID, " cur ", picInfo.NumOfPeople, "config ", config.Type)
                        goto continue
                    end
                end
                ---判断男主动作
                if(config.HisPhotoAction) then
                    if(not self:CheckGroupLimit(config.HisPhotoAction, actionDic)) then
                        Debug.LogWarning(" CheckPhotoGroup HisPhotoAction 不匹配 id: ", config.ID)
                        goto continue
                    end
                end

                ---判断女主动作
                if(config.MyPhotoAction) then
                    if(not self:CheckGroupLimit(config.MyPhotoAction, actionDic)) then
                        Debug.LogWarning(" CheckPhotoGroup MyPhotoAction 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                --判断背景--优先处理
                if(config.PhotoBackground) then
                    if(not self:CheckGroupLimitContains(config.PhotoBackground, picInfo.Background)) then
                        Debug.LogWarning(" CheckPhotoGroup PhotoBackground 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                --判断贴纸
                if config.PhotoSticker then
                    if (not self:CheckGroupLimitContains(config.PhotoSticker, picInfo.StickerInfo))then
                        Debug.LogWarning(" CheckPhotoGroup PhotoSticker 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                --判断边框
                if config.PhotoFrame ~= -1 then
                    if (config.PhotoFrame ~= picInfo.FrameId)then
                        Debug.LogWarning(" CheckPhotoGroup PhotoFrame 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                --判断男服装 --优先处理
                if config.HisFashionMust then
                    if (not self:CheckGroupLimitContains(config.HisFashionMust, dressDic))then
                        Debug.LogWarning(" CheckPhotoGroup HisFashionMust 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                ---判断可选男服装
                if config.HisFashionOptional then
                    if(not self:CheckGroupLimitContainsNum(config.HisFashionOptional, dressDic, config.HisFashionOptionalNum)) then
                        Debug.LogWarning(" CheckPhotoGroup HisFashionOptional 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                --判断女服装
                if config.MyFashionMust then
                    if(not self:CheckGroupLimitContains(config.MyFashionMust, dressDic)) then
                        Debug.LogWarning(" CheckPhotoGroup MyFashionMust 不匹配 id: ", config.ID)
                        goto continue
                    end
                end
                ---判断可选女服装
                if config.MyFashionOptional then
                    if(not self:CheckGroupLimitContainsNum(config.MyFashionOptional, dressDic, config.MyFashionOptionalNum)) then
                        Debug.LogWarning(" CheckPhotoGroup MyFashionOptional 不匹配 id: ", config.ID)
                        goto continue
                    end
                end

                --判断图片数量
                if(config.IsGrid ~= -1) then
                    if(not (picInfo.PuzzleMode == config.IsGrid )) then
                        Debug.LogWarning(" CheckPhotoGroup IsGroup & IsGrid 不匹配 id: ", config.ID, " picInfo.PuzzleMode ", picInfo.PuzzleMode)
                        break
                    end
                end
                --判断是否需要上传照片
                if(config.IsSave == 1) then
                    Debug.LogWarning("准备上传图片 ", config.ID)
                    UrlImgMgr.UploadTexture(texture, function(fileName)
                        Debug.LogWarning("photoGroup向服务器发送上传照片请求 ", config.ID, " fileName ", fileName)
                        local messagebody = {}
                        messagebody.PhotoGroupID = config.ID
                        messagebody.PhotoUrl = fileName
                        GrpcMgr.SendRequest(RpcDefines.PhotoGroupCheckRequest, messagebody, true)
                    end, function()
                        Debug.LogError("photoGroup上传照片失败")
                    end, nil, UrlImgMgr.OssChannel.PhotoAlbum)
                else
                    Debug.LogWarning("photoGroup发送counter  ", config.ID)
                    BllMgr.GetCounterBLL():SetCounterUpdateData(X3_CFG_CONST.COUNTER_TYPE_PHOTOGROUP,1, {config.ID})
                end
            else
                Debug.LogWarning("已经拥有该photoGroup ", config.ID)
            end
            ::continue::
        end
    end
end

---@param mode PurikuraConstNew.StickerEditType
function PhotoSystemBLL:CheckStickerMode(mode)
    return PurikuraConstNew.StickerItemDic[mode] and true or false
end

function PhotoSystemBLL:GetStickerOrder(mode)
    return PurikuraConstNew.StickerItemDic[mode]
end

function PhotoSystemBLL:GetStickerMode(order)
    local mode = nil
    for _mode, _order in pairs(PurikuraConstNew.StickerItemDic) do
        if(_order == order) then
            return _mode
        end
    end
    return mode
end

---逻辑有问题
--function PhotoSystemBLL:GetRolePartRedState(roleId, partId)
--	return SelfProxyFactory.GetPhotoProxy():GetRolePartRedState(roleId, partId)
--end

function PhotoSystemBLL:RequestH5ActivityUrl(callback)
    if not self.h5ActivityUrl then
        local parms = {
            key = "H5URL"
        }
        local url = ServerUrl:GetUrlWithType(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GameConfig, parms)
        httpReq.GetDeferred(url, nil, nil):next(
            function(respTxt)
                return GameHttpRequest:ParseRespDataAndDeferred(respTxt, function(data)
                    self.h5ActivityUrl = data.gameConfigParameter.value
                    if callback then
                        callback()
                    end
                end)
            end
        ):next(nil, function()
            ---失败
            Debug.LogError("H5 URL Get Failed")
        end)
    else
        if callback then
            callback()
        end
    end
end

function PhotoSystemBLL:GetH5ActivityUrl()
    return self.h5ActivityUrl
end

return PhotoSystemBLL
