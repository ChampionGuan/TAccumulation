---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_RollMiaoReply:PureLogic.ICommand
local Rec_RollMiaoReply = class('RollMiaoReply',ICommand)

---执行命令
---@param reply pbcmessage.RollMiaoReply
function Rec_RollMiaoReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.ROLLMIAO,reply)

end

return Rec_RollMiaoReply