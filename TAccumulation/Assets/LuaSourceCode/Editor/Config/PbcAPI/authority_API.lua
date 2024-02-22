--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BeKickedReply 
---@field ErrNo pbcmessage.Errno @ 被踢error code
local  BeKickedReply  = {}
---@class pbcmessage.HelloReply 
local  HelloReply  = {}
---@class pbcmessage.HelloRequest @    rpc Login(LoginRequest) returns (LoginReply) {}  登录协议
---@field AesKey number 
local  HelloRequest  = {}
---@class pbcmessage.LoginReply 
---@field StartSeq number @ 客户端起始的序列号
---@field LastRespond pbcmessage.Respond @ 服务端缓存的最后一个回包
---@field ServerTime number @ 服务器时间
---@field DelTime number @ 角色删除时间
---@field BanInfo pbcmessage.Ban @ 封禁原因
---@field SendServerSeq number @ 已发送服务器包序列号
---@field ProtoVersion number @ 协议版本号，仅GM开启时赋值
---@field CsvVersion string @ csv版本号，仅GM开启时赋值
local  LoginReply  = {}
---@class pbcmessage.LoginRequest 
---@field AccountID number 
---@field OpenID string 
---@field OpenKey string @ 平台token,如果游戏内账号则是密码
---@field Token string @ 游戏生成的token
---@field ZoneID number 
---@field HotFixVersion string 
---@field ApkVersion string 
---@field ExData string 
---@field ClientInfo pbcmessage.ClientInfo 
---@field ResetCalm boolean @ 是否重置冷静期标识
---@field Type number 
---@field LastRespondSeq number @ 请求最后一个回包的序列号
---@field Receipt string @ 登陆排队平台 Receipt JWT Token
---@field GameID number @ 登录指定gamesvr
---@field RecvServerSeq number @ 已接收服务器包序列号
local  LoginRequest  = {}
