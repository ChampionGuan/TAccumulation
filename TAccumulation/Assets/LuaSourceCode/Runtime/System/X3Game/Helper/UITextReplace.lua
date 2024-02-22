﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/5/22 12:12
---@class UITextReplace
local UITextReplace = {}

---动态数据
function UITextReplace.Init()
    --region 动态相关或者和服务器数据相关的全部放在这里初始化

    local AddReplaceTag = UITextHelper.AddReplaceTag
    --region 玩家基础属性相关
    local playerProxy = SelfProxyFactory.GetPlayerInfoProxy()
    AddReplaceTag("{PlayerFullName}", playerProxy:GetName())
    AddReplaceTag("{PlayerFamilyName}", playerProxy:GetFamilyName())
    AddReplaceTag("{PlayerFirstName}", playerProxy:GetFirstName())
    AddReplaceTag("{PlayerID}", playerProxy:GetUid())
    AddReplaceTag("{PlayerShortID}", playerProxy:GetShortUid())
    AddReplaceTag("{PlayerNickName}", playerProxy:GetNickName(0))
    local roleCfgs = LuaCfgMgr.GetAll("RoleInfo")
    for _, v in pairs(roleCfgs) do
        AddReplaceTag(string.format("{PlayerNickNameFor%s}", v.ID), playerProxy:GetNickName(v.ID))
    end
    --endregion


    --region 娃娃机相关
    AddReplaceTag("{TargetDollName}", BllMgr.GetUFOCatcherBLL():GetTargetDollName())
    AddReplaceTag("{CatchDollName}", BllMgr.GetUFOCatcherBLL():GetCatchDollName())
    --endregion

    --region 电话相关
    local roleCfg = LuaCfgMgr.GetAll("RoleInfo")
    if roleCfg then
        local phoneCallTag = "{PhoneRole%d}"
        for k, v in pairs(roleCfg) do
            AddReplaceTag(string.format(phoneCallTag, k), BllMgr.GetMobileContactBLL():GetShowNameByRoleId(k))
        end
    end

    --endregion

    --region 角色喜好（今天吃什么）相关
    local playerFavorBll = BllMgr.GetPlayerFavoriteBLL()
    AddReplaceTag("{DailyRecipeFoodName}", playerFavorBll:GetRandomTagName("DailyRecipeFoodName"))
    for _, v in pairs(roleCfgs) do
        AddReplaceTag(string.format("{FavoriteFood%s}", v.ID), playerFavorBll:GetFavoriteName(v.ID, 20001))
        AddReplaceTag(string.format("{FavoriteFoodTaste%s}", v.ID), playerFavorBll:GetFavoriteName(v.ID, 10001))
        AddReplaceTag(string.format("{FavoriteSnack%s}", v.ID), playerFavorBll:GetFavoriteName(v.ID, 20002))
    end
    --endregion
end


---初始化带参数的动态数据
function UITextReplace.InitWithParam()
    local AddReplaceTag = UITextHelper.AddReplaceTag
    --region 娃娃机相关
    AddReplaceTag("{RepeatedDoll}", function(manType, dollType, count)
        return BllMgr.GetDailyDateBLL():GetRepeatedDollName(manType, dollType, count)
    end)
    AddReplaceTag("{ColorDoll}", function(manType, dollType)
        return BllMgr.GetDailyDateBLL():GetColorDollName(manType, dollType)
    end)
    --endregion
    --region playerTag
    AddReplaceTag("{FoodPick}", function(roleId)
        return BllMgr.GetPlayerFavoriteBLL():GetLastAcceptFood(roleId)
    end)

    AddReplaceTag("{WeeklyFavoriteFood}", function(roleId)
        return BllMgr.GetPlayerFavoriteBLL():GetWeeklyFavoriteFood(roleId)
    end)
    --endregion
    --region itemName
    AddReplaceTag("{ItemName}", function(itemId)
        local cfg = LuaCfgMgr.Get("Item", itemId)
        if cfg then
            return UITextHelper.GetUIText(cfg.Name)
        end

        Debug.LogError("Invalid item id for ItemNameDynamic")
        return ""
    end)

    AddReplaceTag("{ItemNameDynamic}", function(idx, paramStr)
        local param = string.split(paramStr, ",")
        if param and param[idx + 1] then
            local itemId = tonumber(param[idx + 1])
            if itemId then
                local cfg = LuaCfgMgr.Get("Item", itemId)
                if cfg then
                    return UITextHelper.GetUIText(cfg.Name)
                end
            end
        end

        Debug.LogError("Invalid item id for ItemNameDynamic tag")
        return ""
    end, true)
    --endregion
    --region 测试
    --AddReplaceTag("{Test}",function(a,b,c)
    --    Debug.LogError(...)
    --    return string.concat("Test:",a,b,c)
    --end)
    --endregion
end

---初始化静态的数据
function UITextReplace.InitStatic()
    --region 静态数据都放到这里
    local AddReplaceTag = UITextHelper.AddReplaceTag
    --region 全局url相关（跟地区）
    ---@type cfg.URLCN_R[]
    local urlCfg = LuaCfgMgr.GetAll("URL")
    if urlCfg then
        local tag = "{link=%s}"
        local tagRes = "link=%s"
        for k, v in pairs(urlCfg) do
            AddReplaceTag(string.format(tag, v.URLID), string.isnilorempty(v.URLJump) and "" or string.format(tagRes, v.URLJump))
        end
    end
    --endregion

    --region RoleInfo 为支持CMS填写，在这里初始化
    local roleCfg = LuaCfgMgr.GetAll("RoleInfo")

    if roleCfg then
        local tag = "{Role%s}"
        for _, v in pairs(roleCfg) do
            AddReplaceTag(string.format(tag, v.ID), UITextHelper.GetUIText(v.Name))
        end
    end
    --endregion
    --endregion
    
end

return UITextReplace