---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_MiaoSPRobGetCardReply:PureLogic.ICommand
local Rec_MiaoSPRobGetCardReply = class('MiaoSPRobGetCardReply',ICommand)

---执行命令
---@param reply pbcmessage.MiaoSPRobGetCardReply
function Rec_MiaoSPRobGetCardReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.MIAOSPROBGETCARD,reply)
end

return Rec_MiaoSPRobGetCardReply