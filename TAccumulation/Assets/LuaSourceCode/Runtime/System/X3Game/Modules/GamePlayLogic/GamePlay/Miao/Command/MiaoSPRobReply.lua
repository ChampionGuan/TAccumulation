---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPRobReply:PureLogic.ICommand
local Rec_MiaoSPRobReply = class('MiaoSPRobReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPRobReply
function Rec_MiaoSPRobReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPROB,reply)

end

return Rec_MiaoSPRobReply