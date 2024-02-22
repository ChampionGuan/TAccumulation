---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_AddMiaoTurnReply:PureLogic.ICommand
local Rec_AddMiaoTurnReply = class('AddMiaoTurnReply',ICommand)

---执行命令
---@param reply pbcmessage.AddMiaoTurnReply
function Rec_AddMiaoTurnReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.ADDMIAOTURN,reply)
end

return Rec_AddMiaoTurnReply