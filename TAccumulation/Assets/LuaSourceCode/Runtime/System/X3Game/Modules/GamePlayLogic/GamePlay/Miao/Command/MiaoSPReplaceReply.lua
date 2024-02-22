---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPReplaceReply:PureLogic.ICommand
local Rec_MiaoSPReplaceReply = class('MiaoSPReplaceReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPReplaceReply
function Rec_MiaoSPReplaceReply:OnCommand(reply)
    --@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPREPLACE,reply)

end

return Rec_MiaoSPReplaceReply