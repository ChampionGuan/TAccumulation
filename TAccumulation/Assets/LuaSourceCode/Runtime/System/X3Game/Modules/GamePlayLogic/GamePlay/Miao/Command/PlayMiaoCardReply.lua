---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_PlayMiaoCardReply:PureLogic.ICommand
local Rec_PlayMiaoCardReply = class('PlayMiaoCardReply',ICommand)

---执行命令
---@param reply pbcmessage.PlayMiaoCardReply
function Rec_PlayMiaoCardReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.PLAYMIAOCARD,reply)
end

return Rec_PlayMiaoCardReply