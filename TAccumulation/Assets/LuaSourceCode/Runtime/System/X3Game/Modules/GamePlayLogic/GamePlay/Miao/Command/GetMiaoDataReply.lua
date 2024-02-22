---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_GetMiaoDataReply:PureLogic.ICommand
local Rec_GetMiaoDataReply = class('GetMiaoDataReply',ICommand)

---执行命令
---@param reply pbcmessage.GetMiaoDataReply
function Rec_GetMiaoDataReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.ENTER_GAME,reply)

end

return Rec_GetMiaoDataReply