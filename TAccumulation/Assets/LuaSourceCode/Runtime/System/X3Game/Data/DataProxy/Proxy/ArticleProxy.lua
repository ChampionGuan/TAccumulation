﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2022/8/29 14:09
---
---@class ArticleProxy 背景音乐数据
local ArticleProxy = class("BGMDataProxy", BaseProxy)
MobileConst = require("Runtime.System.X3Game.GameConst.MobileConst")
---@class ArticleDataModel
---@field Id int 文章ID
---@field status int  状态  1 已读 0未读
---@field createTime int 公众号创建时间
---@field shareList  table<int> 分享人
---@field likeMap  table<int,boolean> 玩家点赞评论ID map K:评论id v:无意义
---@field like  boolean 点赞文章

local function CreateArticleData(serverData)
    local articleData = {}
    articleData.Id = serverData.ID
    articleData.status = serverData.Status
    articleData.createTime = serverData.CreateTime
    articleData.shareList = serverData.ShareList
    articleData.likeMap = serverData.LikeMap
    articleData.like = serverData.Like
    return articleData
end

---初始化
---@param owner ProxyFactory
function ArticleProxy:OnInit(owner)
    self.super.OnInit(self, owner)
    ---@type table<int,ArticleDataModel>   key articleId  value ArticleProxy
    self.articleDic = {}
end

---进入游戏初始化数据
function ArticleProxy:OnEnterGameReply(articleMap)
    self:InitArticleData(articleMap)
end
---初始化公众号数据
function ArticleProxy:InitArticleData(articleMap)
    for k, v in pairs(articleMap) do
        self:AddArticleData(v)
    end
    EventMgr.Dispatch(MobileConst.Event.MOBILE_ARTICLE_CHECK_RED_POINT)
end
---添加公众号数据
function ArticleProxy:AddArticleData(serverData)
    local tempArticleData = CreateArticleData(serverData)
    self.articleDic[tempArticleData.Id] = tempArticleData
end
---阅读公众号Reply
function ArticleProxy:OnReadArticleReply(articleId)
    self.articleDic[articleId].status = 1
    EventMgr.Dispatch(MobileConst.Event.MOBILE_ARTICLE_CHECK_RED_POINT, articleId)
end
---分享公众号Reply
function ArticleProxy:OnShareArticleReply(reply, request)
    local articleId = request.ID
    if self.articleDic[articleId].shareList == nil then
        self.articleDic[articleId].shareList = {}
    end
    table.insert(self.articleDic[articleId].shareList, request.ShareRoleID)
    EventMgr.Dispatch(MobileConst.Event.MOBILE_ARTICLE_CHECK_RED_POINT, articleId)
end
---点赞评论公众号Reply
function ArticleProxy:OnLikeArticleReplyReply(reply, articleId)
    self.articleDic[articleId].likeMap = reply.LikeMap
end
---点赞评论公众号Reply
function ArticleProxy:OnLikeArticleTextReply(reply, request)
    self.articleDic[request.ArticleID].like = request.OpType == 1 and true or false
end
---获取公众号数据
function ArticleProxy:GetArticleDataById(articleId)
    if table.containskey(self.articleDic, articleId) then
        return self.articleDic[articleId]
    end
    return nil
end
---更新公众号
function ArticleProxy:UpdateArticleReply(reply)
    if reply.OpType == 1 then
        for i = 1, #reply.ArticleList do
            local articleData=reply.ArticleList[i]
            self:AddArticleData(articleData)
        end
    end
    EventMgr.Dispatch(MobileConst.Event.MOBILE_ARTICLE_CHECK_RED_POINT)
end
---获取全部公众号数据
function ArticleProxy:GetArticleDataDic()
    return self.articleDic
end

return ArticleProxy