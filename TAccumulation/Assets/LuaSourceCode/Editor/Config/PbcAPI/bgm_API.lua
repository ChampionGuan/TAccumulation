--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BGMActiveSwitchReply 
local  BGMActiveSwitchReply  = {}
---@class pbcmessage.BGMActiveSwitchRequest 
---@field SwitchOff boolean @ 活动开关，默认开启
local  BGMActiveSwitchRequest  = {}
---@class pbcmessage.BGMCreateListReply 
---@field ListID number @ 列表ID
local  BGMCreateListReply  = {}
---@class pbcmessage.BGMCreateListRequest 
---@field Name string 
---@field SongIDs number[] 
local  BGMCreateListRequest  = {}
---@class pbcmessage.BGMData @ 背景音乐数据
---@field SongID number @ 当前设置的背景音乐单曲ID
---@field ListID number @ 当前设置的背景音乐列表ID
---@field  BGMMap  table<number,pbcmessage.BGMListNode> @ key: 列表ID value：列表信息
---@field SwitchOff boolean @ 活动开关，默认开启
---@field  UnlockSongs   table<number,number> @ 解锁的歌曲 key:歌曲ID value:数量
---@field Mode pbcmessage.BGMPlayMode @ ListID的播放模式
local  BGMData  = {}
---@class pbcmessage.BGMDeleteListReply 
---@field SongID number @ 当前设置的背景音乐单曲ID
---@field ListID number @ 当前设置的背景音乐列表ID
local  BGMDeleteListReply  = {}
---@class pbcmessage.BGMDeleteListRequest 
---@field ListID number 
local  BGMDeleteListRequest  = {}
---@class pbcmessage.BGMListNode @    Single   = 2;   单曲循环
---@field ListID number @ 列表ID
---@field Name string @ 列表名字
---@field SongIDs number[] @ 歌曲ID列表
---@field LastRenameTime number @ 上次改名时间，用于CD
local  BGMListNode  = {}
---@class pbcmessage.BGMModifyListReply 
---@field SongID number @ 当前设置的背景音乐单曲ID
---@field ListID number @ 当前设置的背景音乐列表ID
---@field LastRenameTime number @ 上次改名时间，用于CD
local  BGMModifyListReply  = {}
---@class pbcmessage.BGMModifyListRequest 
---@field ListID number 
---@field Name string 
---@field SongIDs number[] 
local  BGMModifyListRequest  = {}
---@class pbcmessage.BGMSetModeReply 
local  BGMSetModeReply  = {}
---@class pbcmessage.BGMSetModeRequest 
---@field Mode pbcmessage.BGMPlayMode @ 设置播放模式
local  BGMSetModeRequest  = {}
---@class pbcmessage.BGMUnlockSongUpdateReply @ 主动推送(只需要Reply) 数据更新
---@field  UnlockSongs  table<number,number> @ 解锁的歌曲 key:歌曲ID
local  BGMUnlockSongUpdateReply  = {}
---@class pbcmessage.GetBGMDataReply 
---@field BGM pbcmessage.BGMData 
local  GetBGMDataReply  = {}
---@class pbcmessage.GetBGMDataRequest @    rpc BGMActiveSwitch(BGMActiveSwitchRequest) returns (BGMActiveSwitchReply) {}   设置活动开关
local  GetBGMDataRequest  = {}
---@class pbcmessage.SetBGMReply 
local  SetBGMReply  = {}
---@class pbcmessage.SetBGMRequest @ ListID 或者 SongID 为0不设置
---@field SongID number 
---@field ListID number 
local  SetBGMRequest  = {}
