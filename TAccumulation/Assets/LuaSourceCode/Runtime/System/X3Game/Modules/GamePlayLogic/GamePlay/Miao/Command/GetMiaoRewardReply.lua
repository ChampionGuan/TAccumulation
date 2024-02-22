---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_GetMiaoRewardReply:PureLogic.ICommand
local Rec_GetMiaoRewardReply = class('GetMiaoRewardReply', ICommand)

---执行命令
---@param reply pbcmessage.GetMiaoRewardReply
function Rec_GetMiaoRewardReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_GAME_END_EVENT, reply)
end

return Rec_GetMiaoRewardReply