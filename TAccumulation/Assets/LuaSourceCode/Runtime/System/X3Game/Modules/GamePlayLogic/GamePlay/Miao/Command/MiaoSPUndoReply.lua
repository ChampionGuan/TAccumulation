---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPUndoReply:PureLogic.ICommand
local Rec_MiaoSPUndoReply = class('MiaoSPUndoReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPUndoReply
function Rec_MiaoSPUndoReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPUNDO,reply)

end

return Rec_MiaoSPUndoReply