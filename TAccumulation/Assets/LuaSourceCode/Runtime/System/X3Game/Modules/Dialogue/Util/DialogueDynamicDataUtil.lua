---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-27 20:11:52
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class DialogueDynamicDataUtil
local DialogueDynamicDataUtil = class("DialogueDynamicDataUtil")

---获取动态选项文本
---@param dialogueType DialogueEnum.ChoiceType
---@return table
function DialogueDynamicDataUtil.GetDialogueDataList(dialogueType)
    local dialogueDatas = nil
    if dialogueType == DialogueEnum.ChoiceType.ChooseDoll then
        dialogueDatas = GameHelper.ToTable(BllMgr.Get("UFOCatcherBLL"):GetChooseDollDialogue())
    end
    return dialogueDatas
end

return DialogueDynamicDataUtil