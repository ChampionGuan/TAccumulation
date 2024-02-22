---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_ReduceMiaoCountReply:PureLogic.ICommand
local Rec_ReduceMiaoCountReply = class('ReduceMiaoCountReply',ICommand)

---执行命令
---@param reply pbcmessage.ReduceMiaoCountReply
function Rec_ReduceMiaoCountReply:OnCommand(reply)
    ---@type CatCardConst
    local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_RECEIVE_SERVER_MSG,CatCardConst.NetworkType.REDUCEMIAOCOUNT,reply)
end

return Rec_ReduceMiaoCountReply