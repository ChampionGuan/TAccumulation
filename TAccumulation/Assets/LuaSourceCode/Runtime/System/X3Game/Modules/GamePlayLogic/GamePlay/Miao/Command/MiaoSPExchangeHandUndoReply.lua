---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPExchangeHandUndoReply:PureLogic.ICommand
local Rec_MiaoSPExchangeHandUndoReply = class('MiaoSPExchangeHandUndoReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPExchangeHandUndoReply
function Rec_MiaoSPExchangeHandUndoReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPEXCHANGEHANDUNDO,reply)
end

return Rec_MiaoSPExchangeHandUndoReply