---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPStealReply:PureLogic.ICommand
local Rec_MiaoSPStealReply = class('MiaoSPStealReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPStealReply
function Rec_MiaoSPStealReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPSTEAL,reply)

end

return Rec_MiaoSPStealReply