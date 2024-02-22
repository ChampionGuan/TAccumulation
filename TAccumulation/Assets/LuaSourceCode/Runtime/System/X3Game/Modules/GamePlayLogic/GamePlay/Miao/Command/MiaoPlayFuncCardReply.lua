---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoPlayFuncCardReply:PureLogic.ICommand
local Rec_MiaoPlayFuncCardReply = class('MiaoPlayFuncCardReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoPlayFuncCardReply
function Rec_MiaoPlayFuncCardReply:OnCommand(reply)
    ---Insert Your Code Here!
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.PLAYFUNCCARD,reply)

end

return Rec_MiaoPlayFuncCardReply