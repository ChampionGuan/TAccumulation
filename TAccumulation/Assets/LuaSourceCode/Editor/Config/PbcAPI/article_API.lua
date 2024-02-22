--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Article @import "x3x3.proto";
---@field ID number @ 文章ID
---@field Status number @ 状态
---@field CreateTime number @ 通话创建时间
---@field ShareList number[] @ 分享人
---@field  LikeMap  table<number,boolean> @ 玩家点赞评论ID map K:评论id v:无意义
---@field Like boolean @ 点赞文章
local  Article  = {}
---@class pbcmessage.ArticleData 
---@field  ArticleMap  table<number,pbcmessage.Article> @ 文章列表
local  ArticleData  = {}
---@class pbcmessage.ArticleUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field ArticleList pbcmessage.Article[] @ 通话列表
local  ArticleUpdateReply  = {}
---@class pbcmessage.GetArticleDataReply 
---@field Article pbcmessage.ArticleData @ 公众号信息
local  GetArticleDataReply  = {}
---@class pbcmessage.GetArticleDataRequest @    rpc LikeArticleText(LikeArticleTextRequest) returns (LikeArticleTextReply) {}          点赞文章
local  GetArticleDataRequest  = {}
---@class pbcmessage.LikeArticleCommentReply 
---@field  LikeMap  table<number,boolean> 
local  LikeArticleCommentReply  = {}
---@class pbcmessage.LikeArticleCommentRequest 
---@field ArticleID number 
---@field ReplyID number @ 回复ID
---@field OpType number 
local  LikeArticleCommentRequest  = {}
---@class pbcmessage.LikeArticleTextReply 
local  LikeArticleTextReply  = {}
---@class pbcmessage.LikeArticleTextRequest 
---@field ArticleID number 
---@field OpType number 
local  LikeArticleTextRequest  = {}
---@class pbcmessage.ReadArticleReply 
local  ReadArticleReply  = {}
---@class pbcmessage.ReadArticleRequest 
---@field ID number 
local  ReadArticleRequest  = {}
---@class pbcmessage.ShareArticleReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  ShareArticleReply  = {}
---@class pbcmessage.ShareArticleRequest 
---@field ID number 
---@field ShareRoleID number 
local  ShareArticleRequest  = {}
