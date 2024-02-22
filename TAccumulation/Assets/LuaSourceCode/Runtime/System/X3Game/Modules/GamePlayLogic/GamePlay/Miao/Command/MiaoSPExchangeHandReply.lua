---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPExchangeHandReply:PureLogic.ICommand
local Rec_MiaoSPExchangeHandReply = class('MiaoSPExchangeHandReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPExchangeHandReply
function Rec_MiaoSPExchangeHandReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPEXCHANGEHAND,reply)

end

return Rec_MiaoSPExchangeHandReply