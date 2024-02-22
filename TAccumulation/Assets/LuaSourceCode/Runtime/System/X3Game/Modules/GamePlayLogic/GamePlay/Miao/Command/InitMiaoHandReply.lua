---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_InitMiaoHandReply:PureLogic.ICommand
local Rec_InitMiaoHandReply = class('InitMiaoHandReply',ICommand)

---执行命令
---@param reply pbcmessage.InitMiaoHandReply
function Rec_InitMiaoHandReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.INITMIAOHAND,reply)

end

return Rec_InitMiaoHandReply