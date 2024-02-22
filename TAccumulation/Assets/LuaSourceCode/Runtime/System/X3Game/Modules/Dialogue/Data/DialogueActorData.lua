---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-08-18 19:32:34
---------------------------------------------------------------------

---@class DialogueActorData
---@field name string Actor数据的Key
---@field gameObject GameObject 实际使用到的GameObject
---@field isCreatedByDialogueSystem boolean 标记是剧情系统创建的GameObject还是外部注入的
---@field gameObjectID int 换装Id
local DialogueActorData = class("DialogueActorData")

function DialogueActorData:ctor()
	self.name = nil
	self.gameObject = nil
	self.isCreatedByDialogueSystem = false
	self.gameObjectID = 0
end

return DialogueActorData