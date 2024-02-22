﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2023/2/22 16:35
---

---@class DialogueConst
local DialogueConst = class("DialogueConst")

DialogueConst.PPVAnimPath = "Assets/Build/Art/Lightings/ppv_AniClip/"
DialogueConst.RainTexPath = "Assets/Build/Art/UIEffect/UITex/Normal/%s.png"

---@class DialogueConst.EventName
DialogueConst.EventName = {
    ---开启UI
    OpenUI = "OpenUI",
    ---关闭UI
    CloseUI = "CloseUI",
    ---开启UIPrefab
    OpenUIPrefab = "OpenUIPrefab",
    ---关闭UIPrefab
    CloseUIPrefab = "CloseUIPrefab",
    ---Cts事件
    CutScene_Event = "CutScene_Event",
    ---计数
    QuestCount = "QuestCount",
    ---挠痒痒
    CharacterInteraction = "CharacterInteraction",
    ---自由互动
    FreeMotionStart = "FreeMotionStart",
    ---戳兔尾巴
    PhysicsCloth = "PhysicsCloth",
    ---开启除退出按钮外的所有基础按钮（总控）
    OpenUIButton = "DialogueBaseUI_EexceptReturn_Open",
    ---关闭除退出按钮外的所有基础按钮
    HideUIButton = "DialogueBaseUI_EexceptReturn_Hide",
    ---开启基础按钮
    DialogueBaseUI_Open = "DialogueBaseUI_Open",
    ---关闭基础按钮
    DialogueBaseUI_Hide = "DialogueBaseUI_Hide",
}
return DialogueConst