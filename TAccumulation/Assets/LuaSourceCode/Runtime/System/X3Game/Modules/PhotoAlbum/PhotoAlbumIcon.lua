﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by kan.
--- DateTime: 2022/4/11 10:53
---

---@class PhotoAlbumIcon
local PhotoAlbumIcon = class("PhotoAlbumIcon", UICtrl)

local DownloadUIState ={
    Click = 0,
    OnlyShow = 1,
    Error = 2.
}

function PhotoAlbumIcon:Init()
    self.isExists = false
    self.itemData = nil
    ---非相册业务不能操作
    self.canHandle = false
    self.needDownload = false
    ---图片可用状态
    self.errorState = false

    self.downloadSlider = self:GetComponent("OCX_Slider", "X3Image")
    EventMgr.AddListener("PhotoAlbum_PhotoDownload", self.OnDownloadCB, self)
    self:AddButtonListener("OCX_PhotoItem", handler(self, self.OnItemClick))
    self:ChangeDownloadStatus(false)
    self:SetActive("OCX_Downloading", false)
    self.itemButton = self:GetComponent("OCX_PhotoItem", "PapeGames.X3UI.X3Button")
end

---界面关闭
function PhotoAlbumIcon:OnClose()
    EventMgr.RemoveListenerByTarget(self)
end

function PhotoAlbumIcon:SetData(data, onClick, onClickTarget, canHandle)
    self.canHandle = canHandle
    self.itemData = data
    self.onClick = onClick
    self.itemButton.enabled = (onClickTarget == nil)
    ---暂时还不能修改这个怪异上古代码（点击回调加来加去），会被不同界面复用，先保留吧，择机修改为列表直接调用 12.11 by dl
    if onClickTarget then
        UIUtil.RemoveButtonListener(onClickTarget, nil)
        UIUtil.AddButtonListener(onClickTarget, handler(self, self.OnItemClick))
    end

    self:SetPhoto()
    self:SetDownLoadState()
end

function PhotoAlbumIcon:SetPhoto()
    self:UpdateExistState()
    --Debug.LogError("SetPhoto ", self.itemData.Source, " name ", self.itemData.Name, " self.isExists ", self.isExists)

    if self.isExists  then
        self:SetUrlImage()
    else
        ---和UE沟通，已默认处理
        --local defaultRes = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHOTOALBUMDEFAULTIMG)
        --self:SetImage("OCX_Icon", defaultRes)
        self:ChangeErrorStatus(self.itemData.Source == 0)
    end
end

function PhotoAlbumIcon:SetUrlImage()
    local imgIcon = self:GetComponent("OCX_Icon", "X3Image")
    local picRect = self:GetComponent("OCX_Icon", "RectTransform")
    self:ChangeDownloadStatus(false)

    --Debug.LogError("self.itemData.Name ", self.itemData.Name)
    UrlImgMgr.SetUrlImage(imgIcon, self.itemData.Name, function(isSuccess, fileName)
        --Debug.LogError("DOWNLOAD ", isSuccess)
        if isSuccess then
            ImageCropUtil.OnSetImageCallBack(242, 322, imgIcon)
            ---11.5 - dl 怎么还有神秘数字，我服了啊 mark
            picRect.anchoredPosition3D = Vector3(0, 0, 0)
            self.isExists = true--UrlImgMgr.Exists(self.itemData.Name, UrlImgMgr.BizType.PhotoAlbum)
            EventMgr.Dispatch("PhotoAlbum_PhotoDownload", self.itemData.Name)
            self:ChangeErrorStatus(false)

        else
            ---手动处理下
            if(UrlImgMgr.Exists(fileName, UrlImgMgr.BizType.PhotoAlbum)) then
                UrlImgMgr.DeleteImgFile(fileName, UrlImgMgr.BizType.PhotoAlbum)
            end
            --local defaultRes = LuaCfgMgr.Get("SundryConfig", "PhotoAlbumDefaultImg")
            --self:SetImage("OCX_Icon", defaultRes)
            self:ChangeDownloadStatus(true)
            UrlImgMgr.RemoveLoadingCom(imgIcon)
            --self:ChangeErrorStatus(true)
        end

    end, true, UrlImgMgr.BizType.PhotoAlbum, self.itemData.FullUrl)
end

function PhotoAlbumIcon:ChangeErrorStatus(isError)
    self:SetActive("OCX_Error", isError)
    self.errorState = isError
end

function PhotoAlbumIcon:ChangeDownloadStatus(needDownload)
    self.needDownload = needDownload
    self:SetActive("OCX_NoDownload", needDownload and self.canHandle)
    self:SetActive("OCX_Icon", not (needDownload and self.canHandle))
end

function PhotoAlbumIcon:SetDownLoadState()
    self:SetValue("OCX_NoDownload", self.canHandle and self.owner:GetEditState() and DownloadUIState.OnlyShow or DownloadUIState.Click)
    if self.itemData.Source == 0 then
        self:SetActive("OCX_NoDownload", false)
        self:SetActive("OCX_Icon", true)
        return
    end
    self:UpdateExistState()
    self:ChangeDownloadStatus((not (self.isExists)))
end

function PhotoAlbumIcon:SetDownLoadStateOnList()
    self:UpdateExistState()
    if(self.isExists) then
        self:SetActive("OCX_NoDownload", false)
        self:SetActive("OCX_Icon", true)
    else
        self:SetValue("OCX_NoDownload", self.itemData.Source == 0 and DownloadUIState.Error or DownloadUIState.OnlyShow)
    end
end

function PhotoAlbumIcon:UpdateExistState()
    self.isExists = UrlImgMgr.CheckFile(self.itemData.Name, UrlImgMgr.BizType.PhotoAlbum)
end

function PhotoAlbumIcon:GetExistStateCache()
    return self.isExists
end

---列表操作时，部分表现不一样
function PhotoAlbumIcon:OnListHandleStateChange(multiHandle)
    if(multiHandle) then
        self:SetDownLoadStateOnList()
    else
        self:SetDownLoadState()
    end
end

function PhotoAlbumIcon:SetDownloadInfo(progress)
    if not progress then
        --完成
        self:SetActive("OCX_Downloading", false)
        return
    end
    self:SetActive("OCX_Downloading", true)
    self:ChangeDownloadStatus(false)
    self.downloadSlider.fillAmount = progress
    self:SetText("OCX_SliderText", math.floor(progress) .. "%")
end

function PhotoAlbumIcon:OnItemClick()
    if(self.needDownload and not self.canHandle) then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7425)
        return
    elseif(self.errorState and not self.canHandle) then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7426)
        return
    end
    if self.onClick then
        self.onClick(self.itemData.Name)
    end
end

function PhotoAlbumIcon:OnDownloadCB(fileName, progress)
    if fileName ~= self.itemData.Name then
        return
    end
    if not progress then
        --完成
        --self:SetPhoto()
        self:SetDownLoadState()
    end

    self:SetDownloadInfo(progress)
end

return PhotoAlbumIcon