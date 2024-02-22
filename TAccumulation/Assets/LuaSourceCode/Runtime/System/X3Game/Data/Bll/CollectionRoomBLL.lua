---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-06-02 15:28:48
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File


local CollectionItemData = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.CollectionItemData"
local StyleItemData = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.StyleItemData"
local StyleGroupData = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.StyleGroupData"
local CollectionConst = require "Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.CollectionConst"
---@type ChangePrefabSlotData
local ChangePrefabSlotData = require("Runtime.System.X3Game.UI.UIView.CollectionRoomWnd.Data.ChangePrefabSlotData")
---@class CollectionRoomBLL
local CollectionRoomBLL = class("CollectionRoomBLL", BaseBll)

function CollectionRoomBLL:GetCollectionRP()
    return Define.CornerShowType.New, (SysUnLock.IsUnLock(CollectionConst.SYSTEM_COLLECTION)) and (self:IsRP(CollectionConst.State.CHANGE_STYLE) or self:IsRP(CollectionConst.State.CHANGE_COLLECTION))
end

---检测是否有该id藏品或者装修
---@param id number 道具表id
---@param roleId int 男主id
---@param is_style boolean
function CollectionRoomBLL:IsObtain(id, roleId, is_style)
    local roomData = self.proxy:GetCollectionData()
    if is_style then
        local data = self:GetStyleItemData(id)
        if data then
            return data:IsObtain()
        end
        return roomData:HasDecorationByID(id)
    else
        if roleId then
            local itemData = roomData:GetCollectionItemData(roleId, id)
            return itemData ~= nil
        else
            local itemCfg = LuaCfgMgr.Get("CollectionInfo", id)
            if itemCfg and itemCfg.Role > 0 then
                local itemData = roomData:GetCollectionItemData(itemCfg.Role, id)
                return itemData ~= nil
            end
        end
        return self:GetCollectionItemData(id) ~= nil
    end
end

---检测条件,为CommonCondition检测藏品相关条件
function CollectionRoomBLL:CheckCondition(id, ...)
    if id == X3_CFG_CONST.CONDITION_COLLECTION_PLACE then
        ---任务数据解析
        local params = select(1, ...)
        local min_count = 0
        local max_count = 0
        if params ~= nil then
            params = GameHelper.ToTable(params)
            min_count = tonumber(params[1] and params[1] or 0)
            max_count = tonumber(params[2] and params[2] or 0)
        end
        local in_view_count = self:GetInViewCollectionCount()
        return in_view_count >= min_count and in_view_count <= max_count, in_view_count
    elseif id == X3_CFG_CONST.CONDITION_UFO_COLLECTION_NUM then
        local datas = select(1, ...)
        local role_id = tonumber(datas[1])
        local amount = self:GetCollectDollAmount(role_id)
        return amount >= tonumber(datas[2]), amount
    end
    return false
end

function CollectionRoomBLL:GetInViewCollectionCount()
    local map = self:GetServerCollectionMap()
    local count = 0
    for k, v in pairs(map) do
        count = count + 1
    end
    return count
end

function CollectionRoomBLL:GetCollectionItemData(id)
    return self.collection_map[id]
end

function CollectionRoomBLL:GetAllCollectionItems()
    return self.collection_list
end

function CollectionRoomBLL:GetCollectionItemsByType(collection_type, role, is_sort)
    local list = {}
    local is_all = not role or role == -1
    for k, v in pairs(self.collection_list) do
        if v:GetType() == collection_type and (is_all or v:GetSource() == role) then
            table.insert(list, v)
        end
    end
    if is_sort then
        table.sort(list, handler(self, self.SortCollection))
    end

    return list
end

function CollectionRoomBLL:CheckCollectionShowRed(role_id)
    local count = 0
    for i, v in pairs(self.collection_list) do
        if v:GetRole() == role_id and v:IsNew() then
            count = count + 1
        end
    end
    for i, v in pairs(self.style_data_map) do
        if v:GetRole() == role_id and v:IsNew() then
            count = count + 1
        end
    end
    return count
end

function CollectionRoomBLL:CheckCollectionRed()
    if self.roleId == 0 then
        return
    end
    local countPendant = 0
    local countDecoration = 0
    for i, v in pairs(self.collection_list) do
        if v:GetRole() == self.roleId and v:IsNew() then
            if v:GetType() == CollectionConst.Type.DECORATION then
                countDecoration = countDecoration + 1
            elseif v:GetType() == CollectionConst.Type.PENDANT then
                countPendant = countPendant + 1
            end
        end
    end
    for k, v in pairs(CollectionConst.TypeConfig) do
        if k == CollectionConst.Type.DECORATION then
            RedPointMgr.Save(countDecoration, v.red_id, self.roleId)
        else
            RedPointMgr.Save(countPendant, v.red_id, self.roleId)
        end
        RedPointMgr.Check(v.red_id)
    end
end

function CollectionRoomBLL:CheckStyleRed()
    local count = 0
    local groupCount = 0
    for i, v in pairs(self.style_data_map) do
        if v:GetRole() == self.roleId and v:IsNew() then
            count = count + 1
            if v:GetGroup() > 0 then
                groupCount = groupCount + 1
            end
        end
    end
    for pos, v in pairs(self.style_type_map) do
        self:RefreshStyleRedByType(pos)
    end
    RedPointMgr.Save(count, X3_CFG_CONST.RED_COLLECTION_STYLE_ENTRANCE, self.roleId)
    RedPointMgr.Check(X3_CFG_CONST.RED_COLLECTION_STYLE_ENTRANCE)
    --TODO 处理套装红点
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_COLLECTIONSTYLE, groupCount, self.roleId)
end

---@param pos int
function CollectionRoomBLL:RefreshStyleRedByType(pos)
    local count = self:GetStyleRedCountByType(pos)
    RedPointMgr.UpdateCount(X3_CFG_CONST.RED_COLLECTION_STYLE_BY_TYPE, count, self:GetStyleTypeKey(pos))
end

---@return int
function CollectionRoomBLL:GetStyleRedCountByType(pos)
    if not self:IsStyleUnLock(pos) then
        return 0
    end
    local count = 0
    for i, v in pairs(self.style_data_map) do
        if v:GetRole() == self.roleId and v:IsNew() and v:GetType() == pos then
            count = count + 1
        end
    end
    return count
end

---@param pos int
function CollectionRoomBLL:GetStyleTypeKey(pos)
    return self:GetCurRole() * 10000 + pos
end

---判断是否是要检测红点
---@param red_id int 红点id
function CollectionRoomBLL:IsCheckRed(red_id)
    if red_id == X3_CFG_CONST.RED_COLLECTION_STYLE_ENTRANCE then
        return true
    end
    for i, v in pairs(CollectionConst.TypeConfig) do
        if v.red_id == red_id then
            return true
        end
    end
    return false
end

---红点刷新
---@param red_id int 红点id
function CollectionRoomBLL:OnRedPointCheck(red_id)
    if self:IsCheckRed(red_id) then
        local count = RedPointMgr.GetValue(red_id, self.roleId)
        RedPointMgr.UpdateCount(red_id, count, self.roleId)
    end
end

---男主是否解锁
function CollectionRoomBLL:IsRoleUnLock(id)
    return self.roleBLl:IsUnlocked(id)
end

function CollectionRoomBLL:IsRoleOpen(id)
    return self.roleBLl:IsOpend(id)
end

function CollectionRoomBLL:GetRoleList()
    if #self.collection_role_list == 0 then
        self.collection_role_list = {}

        for k, v in pairs(LuaCfgMgr.GetAll("RoleInfo")) do
            table.insert(self.collection_role_list, 1, { id = k, nameId = v.Name, icon = v.RoleMarkSmall, big_icon = v.RoleMarkSmall })
        end
    end
    return self.collection_role_list
end

function CollectionRoomBLL:GetRoleConf(id)
    for k, v in pairs(self:GetRoleList()) do
        if v.id == id then
            return v
        end
    end
end


---------------------预设相关--------------------

---获取slot列表 使用中-->已存-->已解锁-->未解锁
---@param is_sort boolean
---@return ChangePrefabSlotData[]
function CollectionRoomBLL:GetSlotList(is_sort)
    local data_list = {}
    for k, v in ipairs(self.slot_data_map) do
        if v:IsCanShow() then
            table.insert(data_list, v)
        else
            table.insert(data_list, v)
            break
        end
    end
    if is_sort then
        table.sort(data_list, function(a, b)
            local a_is_in_use = a:IsInUse()
            local b_is_in_use = b:IsInUse()
            if a_is_in_use or b_is_in_use then
                if a_is_in_use and b_is_in_use then
                else
                    if a_is_in_use then
                        return true
                    else
                        return false
                    end
                end

            else
                local a_is_has_save = a:HasSave()
                local b_is_has_save = b:HasSave()
                if a_is_has_save or b_is_has_save then
                    if a_is_has_save and b_is_has_save then
                    else
                        if a_is_has_save then
                            return true
                        else
                            return false
                        end
                    end
                else
                    local a_is_unlock = a:IsUnlock()
                    local b_is_unlock = b:IsUnlock()
                    if a_is_unlock or b_is_unlock then
                        if a_is_unlock and b_is_unlock then
                        else
                            if a_is_unlock then
                                return true
                            else
                                return false
                            end
                        end

                    end

                end
            end
            return a:GetId() < b:GetId()
        end)
    end
    return data_list
end

---@param id int
---@param is_create boolean
---@return ChangePrefabSlotData
function CollectionRoomBLL:GetSlot(id, is_create)
    if not id then
        return nil
    end
    ---@type ChangePrefabSlotData
    local data = self.slot_data_map[id]
    if not data and is_create then
        data = ChangePrefabSlotData.new()
        data:SetId(id)
        self.slot_data_map[id] = data
    end
    return data
end

---@param server_data pbcmessage.DecorationPrefabData
function CollectionRoomBLL:RefreshSlot(server_data)
    if not server_data or not server_data.Id then
        return
    end
    local data = self:GetSlot(server_data.Id, true)
    data:Refresh(server_data)
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_SLOT_DATA_UPDATE, data:GetId())
end

function CollectionRoomBLL:SetInUsePrefab(slot_id)
    self.cur_slot_id = slot_id
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_USE_PREFAB_CHANGE, slot_id)
end

---获取当前slot
function CollectionRoomBLL:GetCurUseSlotId()
    return self.cur_slot_id
end

function CollectionRoomBLL:SetCurSelectSlot(slot_id)
    self.cur_select_slot_id = slot_id
end

function CollectionRoomBLL:GetCurSelectSlot()
    return self.cur_select_slot_id
end

function CollectionRoomBLL:SetCheckPosList(list)
    self.check_pos_list = list
end

function CollectionRoomBLL:GetCheckPosList()
    return self.check_pos_list
end

---保存文件路径
---@param file_path string
---@param slot_id int
---@param is_delete boolean 是否要删除已存在的文件
function CollectionRoomBLL:SetSaveImgPath(file_path, slot_id, is_delete)
    self.img_save_map[slot_id] = file_path
    local slot_data = self:GetSlot(slot_id)
    if slot_data then
        slot_data:SetUrl(file_path, is_delete)
    end
end

function CollectionRoomBLL:GetSaveImgPath(slot_id)
    return self.img_save_map[slot_id]
end

function CollectionRoomBLL:ResetCapture()
    table.clear(self.img_save_map)
end

function CollectionRoomBLL:GetCaptureImgFilePath(slot_id)
    return string.format(CollectionConst.CAPTURE_PREFIX, BllMgr.Get("LoginBLL"):GetAccountId(), slot_id, math.floor(TimerMgr.GetCurTimeSeconds()))
end

---还原当前map
function CollectionRoomBLL:RestoreMap()
    if self.restore_collection_server_map then
        table.clear(self.collection_server_map)
        table.merge(self.collection_server_map, self.restore_collection_server_map)
    end
    if self.restore_style_map then
        table.clear(self.style_map)
        table.merge(self.style_map, self.restore_style_map)
    end
    self.restore_style_map = nil
    self.restore_collection_server_map = nil
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_ALL)
end

---保存当前map
function CollectionRoomBLL:SaveMap()
    self.restore_collection_server_map = table.clone(self.collection_server_map)
    self.restore_style_map = table.clone(self.style_map)
end

---根据slot刷新当前数据
function CollectionRoomBLL:RefeshDataBySlot(slot_id)
    local slot = self:GetSlot(slot_id)
    if slot then
        local server_data = slot:GetSeverData()
        table.clear(self.collection_server_map)
        self:RefreshServerCollectionMap(server_data and table.clone(server_data.CollectionDecorationList) or nil)
        self:RefreshServerCollectionMap(server_data and table.clone(server_data.CollectionPendantList) or nil)
        if not table.isnilorempty(server_data.DecorationMap) then
            table.clear(self.style_map)
            table.merge(self.style_map, server_data.DecorationMap)
        end
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_ALL)
    end
end

---@param data pbcmessage.CollectPrefabUpdateReply
function CollectionRoomBLL:CollectPrefabUpdateReply(data)
    self:RefreshSlot(data.PrefabData)
    self:SetInUsePrefab(data.InUsePrefab)
    if data.PushType == 2 then
        ---1代表保存， 2代表装备
        ---装备
        self:RefeshDataBySlot(self:GetCurUseSlotId())
    end
    if self.roleCollectMap[data.RoleID] then
        self.roleCollectMap[data.RoleID].InUsePrefab = data.InUsePrefab
        if data.PrefabData then
            local prefabMap = self.roleCollectMap[data.RoleID].DecorationPrefabMap
            if not prefabMap then
                prefabMap = {}
            end
            prefabMap[data.PrefabData.Id] = data.PrefabData
        end
    end
end

---@param slot_list pbcmessage.DecorationPrefabData[]
function CollectionRoomBLL:RefreshSlotList(slot_list)
    if not slot_list then
        return
    end
    for k, v in pairs(slot_list) do
        self:RefreshSlot(v)
    end
end

---装备
function CollectionRoomBLL:SendRequestCollectionPrefabOn(id)
    local data = { Id = id, RoleID = self.roleId }
    GrpcMgr.SendRequest(RpcDefines.DecorationPrefabOnRequest, data, true)
end

---解锁
function CollectionRoomBLL:SendRequestCollectionPrefabUnlock(id, call)
    if not id then
        return
    end
    local data = { Id = id, RoleID = self.roleId }
    self.call = call
    GrpcMgr.SendRequest(RpcDefines.DecorationPrefabUnlockRequest, data)
end

---@param id int
---@param name string
function CollectionRoomBLL:SaveName(id, name, call)
    local data = self:GetSlot(id)
    data:SetName(name)
    self.saveNameCallBack = call
    GrpcMgr.SendRequest(RpcDefines.DecorationPrefabNameRequest, { Id = id, Name = name, RoleID = self.roleId }, true)
end

---修改名字結果返回
function CollectionRoomBLL:DecorationPrefabNameReply(is_success, cacheData)
    if self.saveNameCallBack then
        self.saveNameCallBack(is_success)
        self.saveNameCallBack = nil
    end
    if cacheData then
        local collectData = self:GetRoleCollectionData(cacheData.RoleID)
        local prefabMap = collectData.DecorationPrefabMap[cacheData.Id]
        prefabMap.Name = cacheData.Name
    end
end

---保存
function CollectionRoomBLL:SendRequestCollectionPrefabSave(id, call)
    if not id then
        return
    end
    local slot = self:GetSlot(id)
    local data = { Id = id, Url = slot:GetUrl(), RoleID = self.roleId }
    self.call = call
    GrpcMgr.SendRequest(RpcDefines.DecorationPrefabSaveRequest, data, true)
end

---解锁成功
function CollectionRoomBLL:DecorationPrefabUnlockReply(is_success)
    if self.call then
        self.call(is_success)
        self.call = nil
    end
end

---保存成功
function CollectionRoomBLL:DecorationPrefabSaveReply(data)
    if self.call then
        self.call()
        self.call = nil
    end
end

---装备成功
function CollectionRoomBLL:DecorationPrefabOnReply(data, cacheData)
    local collectData = BllMgr.GetCollectionRoomBLL():GetRoleCollectionData(cacheData.RoleID)
    local prefabMap = collectData.DecorationPrefabMap[cacheData.Id]
    local data = {
        Role = cacheData.RoleID,
        CollectionDecorationList = prefabMap.CollectionDecorationList,
        CollectionPendantList = prefabMap.CollectionPendantList
    }
    self:RefreshCollectMap(data)
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5987)
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_USE_PREFAB_CHANGE)
end

------风格和藏品通用接口--------

function CollectionRoomBLL:IsRP(st, _type, id)
    if st == CollectionConst.State.CHANGE_COLLECTION then
        for k, v in pairs(self:GetAllCollectionItems()) do
            if (not id or id == v:GetId()) and (not _type or _type == v:GetType()) and v:IsNew() then
                return true
            end
        end
    else
        for k, v in pairs(self.style_data_map) do
            if (not id or id == v:GetId()) and (not _type or _type == v:GetType()) and v:IsNew() then
                return true
            end
        end
    end
end

function CollectionRoomBLL:ClearCurRp(st, id)
    if not self.clear_red_point_map[st] then
        self.clear_red_point_map[st] = {}
    end
    self.clear_red_point_map[st][id] = true
end

function CollectionRoomBLL:ClearRpByRole(st)
    local id_map = {}
    if self.clear_red_point_map[st] then
        for id, v in pairs(self.clear_red_point_map[st]) do
            if v then
                local collectInfo = LuaCfgMgr.Get("CollectionInfo", id)
                if collectInfo.Role == 0 then
                    if not id_map[0] then
                        id_map[0] = { IDList = {} }
                    end
                    table.insert(id_map[0].IDList, id)
                else
                    if not id_map[self.roleId] then
                        id_map[self.roleId] = { IDList = {} }
                    end
                    table.insert(id_map[self.roleId].IDList, id)
                end
            end
        end
    end
    return id_map
end

function CollectionRoomBLL:GetClearRpList(st)
    local id_list = {}
    if self.clear_red_point_map[st] then
        for k, v in pairs(self.clear_red_point_map[st]) do
            if v then
                table.insert(id_list, k)
            end
        end
    end
    return id_list
end

function CollectionRoomBLL:ClearRpList(st)
    self.clear_red_point_map[st] = {}
end

---@param st CollectionConst.State
---@param _type int
function CollectionRoomBLL:ClearRp(st, _type)
    local is_success = false
    if st == CollectionConst.State.CHANGE_COLLECTION then

        for k, v in pairs(self:GetAllCollectionItems()) do
            if v:GetType() == _type and v:IsNew() then
                v:SetIsNew(false)
            end
        end
        local id_list = self:ClearRpByRole(st)
        if table.nums(id_list) > 0 then
            is_success = true
        end
    else
        for k, v in pairs(self.style_data_map) do
            if v:GetType() == _type and v:IsNew() then
                v:SetIsNew(false)
            end
        end
        local id_list = self:GetClearRpList(st)
        if #id_list > 0 then
            is_success = true
            self:CheckStyleRed()
        end
    end
    self:ClearRpList(st)
    if is_success then
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_RED_POINT, st)
    end
end

---@param value bool
function CollectionRoomBLL:SetIsShowTips(value)
    self.isShowTips = value == nil and true or value
end

function CollectionRoomBLL:GetIsShowTips()
    return self.isShowTips
end

---@param st  CollectionConst.State
---@param isForce bool
---@param isShowTips
function CollectionRoomBLL:Save(st, isForce, isShowTips)
    self:SetIsShowTips(isShowTips)
    local is_change = self:CheckChanged(st)
    if st == CollectionConst.State.CHANGE_STYLE or st == CollectionConst.State.CHANGE_STYLE_GROUP then
        if is_change then
            for k, v in pairs(self.cur_select_style_map) do
                self.style_map[k] = v
            end
            local list = {}
            for k, v in pairs(self.style_map) do
                table.insert(list, v)
            end
            GrpcMgr.SendRequest(RpcDefines.SetDecorationRequest, { IDList = list, RoleID = self.roleId }, true)
        end
        self:Reset(st)
    elseif st == CollectionConst.State.CHANGE_COLLECTION then
        if is_change or isForce then
            self.collection_server_map = {}
            local collectionDecorationList = {}
            local collectionPendantList = {}
            local item_data
            self:SetChange(true)
            for k, v in pairs(self:GetLocalCollectionMap()) do
                item_data = self:GetCollectionItemData(v.id)
                local item = { ID = v.id, X = math.decimaltonumber(v.pos.x, CollectionConst.DECIMAL), Y = math.decimaltonumber(v.pos.y, CollectionConst.DECIMAL), GUID = 0, InteractiveState = v.openState }
                if item_data:GetType() == CollectionConst.Type.PENDANT then
                    if v.r ~= nil and v.r ~= 0 then
                        item.R = math.decimaltonumber(v.r.eulerAngles.z, CollectionConst.DECIMAL)
                    else
                        item.R = 0
                    end
                    if not item.R then
                        item.R = 0
                    end
                    table.insert(collectionPendantList, item)
                else
                    table.insert(collectionDecorationList, item)
                end
            end
            GrpcMgr.SendRequestAsync(RpcDefines.SetCollectionRequest, { RoleID = self.roleId, CollectionDecorationList = collectionDecorationList, CollectionPendantList = collectionPendantList }, true)
            self:RefreshServerCollectionMap(collectionDecorationList)
            self:RefreshServerCollectionMap(collectionPendantList)
            for id, v in pairs(self.collection_map) do
                local posMap = v:GetPosMap()
                local re_k = {}
                for i, item in pairs(posMap) do
                    if not item:GetIsShow() then
                        table.insert(re_k, i)
                    end
                end
                for key = #re_k, 1, -1 do
                    table.remove(posMap, key)
                end
            end
        end
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_COLLECTION_EXIT_EDIT)
    end

end

function CollectionRoomBLL:Reset(st)
    if st == nil then
        self:Reset(CollectionConst.State.CHANGE_STYLE)
        self:Reset(CollectionConst.State.CHANGE_COLLECTION)
        self:ResetCapture()
        return
    end
    if st == CollectionConst.State.CHANGE_STYLE or st == CollectionConst.State.CHANGE_STYLE_GROUP then
        if st == CollectionConst.State.CHANGE_STYLE_GROUP then
            table.clear(self.cur_select_style_map)
            for k, v in pairs(self.style_map) do
                self:SetCurStyle(k, v, true)
            end
        else
            for k, v in pairs(self.cur_select_style_map) do
                self:SetCurStyle(k, self.style_map[k])
            end
        end
        self:SetCurStyle(nil)
        table.clear(self.cur_select_style_map)
    elseif st == CollectionConst.State.CHANGE_COLLECTION then
        self:ClearShowMap()
        self:SetChange(false)
        --self.cur_collection_type = nil
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_COLLECTION_VIEW, true)
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_COLLECTION_EXIT_EDIT)
    end
end

function CollectionRoomBLL:SetChange(value)
    for i, v in pairs(self.collection_map) do
        v:SetChange(value)
    end
end

function CollectionRoomBLL:IsCollectionPosChange(id, index)
    local item = self:GetCollectionItemData(id)
    if item then
        local posData = item:GetPosDatByIndex(index)
        if posData then
            return posData:IsChange()
        end
    end
    return false
end

function CollectionRoomBLL:IsCollectionChanged(id, local_data, server_data)
    local is_changed = false
    local pos = local_data.pos
    if math.abs(pos.x - server_data.X) > CollectionConst.CHECK_COLLECTION_POS_CHANGE_OFFSET or math.abs(pos.y - server_data.Y) > CollectionConst.CHECK_COLLECTION_POS_CHANGE_OFFSET then
        is_changed = true
    else
        local collection_data = self:GetCollectionItemData(id)
        local type = collection_data:GetType()
        if type == CollectionConst.Type.PENDANT then
            local r = local_data.r
            if r ~= nil and r ~= 0 then
                r = local_data.r.eulerAngles.z
            end
            if math.abs(server_data.R - r) > CollectionConst.CHECK_COLLECTION_POS_CHANGE_OFFSET then
                is_changed = true
            end
        end
    end
    return is_changed
end

function CollectionRoomBLL:CheckChanged(st)
    local is_changed = false
    if st == CollectionConst.State.CHANGE_STYLE or st == CollectionConst.State.CHANGE_STYLE_GROUP then
        local is_can_check = true
        if st == CollectionConst.State.CHANGE_STYLE_GROUP then
            local group = self:GetStyleGroup(self:GetCurGroup())
            if not group or not group:IsUnlock() then
                is_can_check = false
            end
        end
        if is_can_check then
            for k, v in pairs(self.cur_select_style_map) do
                if not self.style_map[k] or v ~= self.style_map[k] then
                    is_changed = true
                    break
                end
            end
        end
    elseif st == CollectionConst.State.CHANGE_COLLECTION then
        for k, v in pairs(self.collection_local_map) do
            local server = self.collection_server_map[v.id]
            if not server then
                is_changed = true
                break
            else
                --if self:IsCollectionChanged(k, v, server) then
                --    is_changed = true
                --    break
                --end
                if self:IsCollectionPosChange(v.id, v.index) then
                    is_changed = true
                    break
                end
            end
        end
        if not is_changed then
            for k, serverData in pairs(self.collection_server_map) do
                for i, v in pairs(serverData) do
                    local local_data = self.collection_local_map[k * 10000 + i]
                    if not local_data then
                        is_changed = true
                        break
                    else
                        --if self:IsCollectionChanged(k, local_data, server) then
                        --    is_changed = true
                        --    break
                        --end
                        if self:IsCollectionPosChange(k, i) then
                            is_changed = true
                            break
                        end
                    end
                end

            end
        end
    end
    return is_changed
end

function CollectionRoomBLL:RefreshStyleMap()
    for k, v in pairs(self.cur_select_style_map) do
        self.style_map[k] = v
    end
end

function CollectionRoomBLL:IsMax(_type, num, is_show_tips)
    local config = CollectionConst.TypeConfig[_type]
    if not config then
        return false
    end
    local max_count = self.max_count_map[_type]
    if max_count == nil then
        max_count = tonumber(LuaCfgMgr.Get("SundryConfig", config.max_count_id))
        self.max_count_map[_type] = max_count
    end
    local is_max = num >= max_count
    if is_max and is_show_tips then
        UICommonUtil.ShowMessage(config.max_count_tips_text_id)
    end

    return is_max
end

------------藏品摆件和装饰相关-----------------------------
function CollectionRoomBLL:SetCurCollection(id, index, pos, r, openState)
    if id ~= nil and index ~= nil then
        local key = id * 10000 + index
        r = r and r or 0
        if not self.collection_local_map[key] then
            self.collection_local_map[key] = {}
        end

        if pos == nil then
            self.collection_local_map[key] = nil
            EventMgr.Dispatch(CollectionConst.Event.COLLECTION_ITEM_UN_SELECT, key)
        else
            self.collection_local_map[key] = { pos = pos, r = r, id = id, index = index, openState = openState or 0 }
        end

    end
end

function CollectionRoomBLL:GetItemIdByKey(key)
    if self.collection_local_map[key] then
        return self.collection_local_map[key].id
    end
    return 0
end

function CollectionRoomBLL:IsCollectionInView(id, index)
    local key = id * 10000 + index
    return self.collection_local_map[key] ~= nil
end

function CollectionRoomBLL:GetCollectionPosById(id, index)
    local key = id * 10000 + index
    local data = self.collection_local_map[key]
    return data and data.pos or nil
end
function CollectionRoomBLL:GetCollectionAngelById(id, index)
    local key = id * 10000 + index
    local data = self.collection_local_map[key]
    return data and data.r or nil
end

function CollectionRoomBLL:GetAllShowCollection()
    return self.collection_local_map
end

function CollectionRoomBLL:SetCurCollectionType(_type)
    if self.cur_collection_type and self.cur_collection_type == _type then
        return
    end
    if self.cur_collection_type then
        self:ClearRp(CollectionConst.State.CHANGE_COLLECTION, self.cur_collection_type)
    end
    self.cur_collection_type = _type
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_CHANGE_TYPE, _type)
end

function CollectionRoomBLL:GetCurCollectionType()
    return self.cur_collection_type
end

function CollectionRoomBLL:GetLocalCollectionMap()
    return self.collection_local_map
end

function CollectionRoomBLL:GetServerCollectionMap()
    return self.collection_server_map
end

function CollectionRoomBLL:ClearShowMap()
    self.collection_local_map = {}
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_ITEM_UN_SELECT)
end

function CollectionRoomBLL:GetCollectionPosFromServer(id)
    local pos = self.collection_server_map[id]
    return pos and CS.UnityEngine.Vector2(pos.X, pos.Y) or nil
end

function CollectionRoomBLL:GetCollectionAngleFromServer(id, index)
    local data = self.collection_server_map[id]
    if data then
        local rData = data[index]
        if rData then
            local rotation = CS.UnityEngine.Quaternion(0, 0, 0, 1)
            rotation.eulerAngles = CS.UnityEngine.Vector3(0, 0, rData.R)
            return rotation
        end
    end
    return nil
end

---@param a CollectionItemData
---@param b CollectionItemData
function CollectionRoomBLL:SortCollection(a, b)
    --检测是否是新获取的
    local a_is_new = a:IsNew()
    local b_is_new = b:IsNew()

    if a_is_new or b_is_new then
        if a_is_new and b_is_new then
        elseif a_is_new then
            return true
        else
            return false
        end
    end

    local a_left_count = a:GetSortNum()
    local b_left_count = b:GetSortNum()

    if a_left_count > b_left_count then
        return true
    elseif a_left_count < b_left_count then
        return false
    end
    --检测id
    return a:GetOrder() > b:GetOrder()
end


-----风格装修相关------------

function CollectionRoomBLL:IsStyleUnLock(_type)
    local condition_id = self.style_lock_condition[_type]
    if not condition_id then
        local data = LuaCfgMgr.Get("DecorationUnlock", _type)
        condition_id = data and data.Condition or 0
        self.style_lock_condition[_type] = condition_id
    end
    return condition_id == 0 or ConditionCheckUtil.CheckConditionByCommonConditionGroupId(condition_id, nil)
end

function CollectionRoomBLL:GetStyleList(cur_type, is_sort)
    local style_list = {}
    for k, v in pairs(self.style_data_map) do
        local is_valid = true
        if cur_type then
            is_valid = cur_type == v:GetType()
        end
        if is_valid and v:IsCanShow() then
            table.insert(style_list, v)
        end
    end
    if is_sort then
        table.sort(style_list, handler(self, self.SortStyle))
    end
    return style_list
end

function CollectionRoomBLL:SortStyle(a, b)
    local is_has_a = a:IsObtain()
    local is_has_b = b:IsObtain()

    --检测是否获得
    if is_has_a then
        if not is_has_b then
            return true
        end
    elseif is_has_b then
        return false
    end

    --检测是否是新获取的

    local a_is_new = a:IsNew()
    local b_is_new = b:IsNew()

    if a_is_new or b_is_new then
        if a_is_new and b_is_new then
        elseif a_is_new then
            return true
        else
            return false
        end
    end

    --检测是否在使用中
    local a_in_use = a:IsSelect()
    local b_in_use = b:IsSelect()
    if a_in_use or b_in_use then
        if a_in_use and b_in_use then
        elseif a_in_use then
            return true
        else
            return false
        end
    end

    --检测品质
    local a_quality = a:GetQuality()
    local b_quality = b:GetQuality()
    if a_quality ~= b_quality then
        return a_quality > b_quality
    end

    --检测id
    return a:GetId() > b:GetId()

end

function CollectionRoomBLL:SetCurSelectCollection(item_id)
    self.cur_select_item_id = item_id
end

function CollectionRoomBLL:GetCurSelectCollection()
    return self.cur_select_item_id
end

function CollectionRoomBLL:GetStyleMap()
    return self.style_map
end

function CollectionRoomBLL:GetStyleItemData(id)
    return self.style_data_map[id]
end

function CollectionRoomBLL:IsNewStyle(_type, id)
    if not _type or not id then
        return false
    end
    return not self.new_style_map[_type]
end

function CollectionRoomBLL:SetCurStyle(_type, id, no_clear_rp)
    if not no_clear_rp then
        if self.cur_style_id then
            self:ClearRp(CollectionConst.State.CHANGE_STYLE, self.cur_style_id)
        end
        self.cur_style_id = _type
    end
    local is_change = false
    if _type and id then
        if self.cur_select_style_map[_type] then
            if self.cur_select_style_map[_type] ~= id then
                is_change = true
            end
        else
            is_change = true
        end
        self.cur_select_style_map[_type] = id
        if is_change then
            EventMgr.Dispatch(CollectionConst.Event.COLLECTION_STYLE_CHANGE, _type, id)
        end
    end
end

function CollectionRoomBLL:GetCurStyle()
    return self.cur_style_id
end

function CollectionRoomBLL:RestStyleByType(_type)
    self.cur_select_style_map[_type] = nil
    self:SetCurStyle(_type, self:GetServerStyleByType(_type))
end

function CollectionRoomBLL:GetStyleByType(id)
    return id and self.cur_select_style_map[id] or nil
end

function CollectionRoomBLL:GetServerStyleByType(_type)
    return self.style_map[_type]
end

---初始化装修
function CollectionRoomBLL:InitStyleList()
    if self.is_init then
        return
    end
    local data = LuaCfgMgr.Get("SundryConfig", CollectionConst.DEFAULT_STYLE_UNLOCK_ID)
    self.default_style_id_map = {}
    if data then
        local value = data
        local id
        for k, v in pairs(value) do
            id = v
            self.default_style_id_map[id] = id
        end
    end

    local item_data
    for k, v in pairs(LuaCfgMgr.GetAll("DecorationInfo")) do
        if v.Role == 0 or self.roleId == v.Role then
            item_data = self:CreateStyleItemData(v.ID, self.default_style_id_map[v.ID] ~= nil)
            --item_data:SetIsDefault(self.default_style_id_map[v.ID] ~= nil)
        end
    end
    local style_type = LuaCfgMgr.GetAll("DecorationUnlock")
    for i, v in pairs(style_type) do
        self.style_type_map[v.Type] = v.Condition
    end
end

---@param id int
---@return bool
function CollectionRoomBLL:GetIsDefaultStyle(id)
    return self.default_style_id_map[id] ~= nil
end

--region 装修套装相关

---@param group_id int
---@param is_create boolean 如果没有是否需要创建
---@return StyleGroupData
function CollectionRoomBLL:GetStyleGroup(group_id, is_create)
    if not group_id or group_id < 0 then
        return nil
    end
    local data = self.style_group_list[group_id]
    if not data and is_create then
        data = StyleGroupData.new()
        self.style_group_list[group_id] = data
    end
    return data
end

function CollectionRoomBLL:GetStyleGroupList(is_sort)
    if not self.style_group_list then
        self.style_group_list = {}
        local map = LuaCfgMgr.GetAll("DecorationGroup")
        for k, v in pairs(map) do
            if v.Role == 0 or v.Role == self.roleId then
                local data = self:GetStyleGroup(k, true)
                data:SetData(v)
            end
        end
        LuaCfgMgr.UnLoad("DecorationGroup")
    end
    local list = {}
    for k, v in pairs(self.style_group_list) do
        if v:IsCanShow() then
            table.insert(list, v)
        end
    end
    if is_sort then
        table.sort(list, self.SortStyleGroup)
    end
    return list
end

function CollectionRoomBLL.CheckSort(a_ok, b_ok)
    if a_ok or b_ok then
        if a_ok and b_ok then
        elseif a_ok then
            return true
        else
            return false
        end
    end
    return nil
end

function CollectionRoomBLL.SortStyleGroup(a, b)
    local a_ok, b_ok, res
    local check = CollectionRoomBLL.CheckSort
    a_ok = a:IsNew()
    b_ok = b:IsNew()
    res = check(a_ok, b_ok)
    if res ~= nil then
        return res
    end

    a_ok, b_ok = a:IsUnlock(), b:IsUnlock()
    res = check(a_ok, b_ok)
    if res ~= nil then
        return res
    end
    return a:GetOrder() > b:GetOrder()
end

---根据id替换
function CollectionRoomBLL:ChangeStyleByGroup(group_id, is_all)
    if not group_id or group_id < 0 then
        return
    end
    self:Reset(CollectionConst.State.CHANGE_STYLE_GROUP)
    local style_data_list = self:GetStyleListByGroup(group_id)
    for k, v in pairs(style_data_list) do
        if is_all or v:IsObtain() then
            self:SetCurStyle(v:GetType(), v:GetId(), true)
        end
        --if v:IsNew() then
        --    v:SetIsNew(false)
        --end
    end
    --self:ClearRp(CollectionConst.State.CHANGE_STYLE, -999)
end

function CollectionRoomBLL:CleaRpByGroup(group_id)
    if not group_id then
        for k, v in pairs(self.style_group_list) do
            self:CleaRpByGroup(v:GetId())
        end
        self:ClearRp(CollectionConst.State.CHANGE_STYLE, -999)
    else
        local style_data_list = self:GetStyleListByGroup(group_id)
        if style_data_list then
            for k, v in pairs(style_data_list) do
                if v:IsNew() then
                    v:SetIsNew(false)
                end
            end
        end
    end
end

---@return StyleItemData[]
function CollectionRoomBLL:GetStyleListByGroup(group_id)
    local style_list = {}
    for k, v in pairs(self.style_data_map) do
        if v:GetGroup() == group_id then
            table.insert(style_list, v)
        end
    end
    return style_list
end

function CollectionRoomBLL:SetCurGroup(group, is_all, is_force)
    self.group = group
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_SELECT_GROUP, group, is_all, is_force)
end

function CollectionRoomBLL:GetCurGroup()
    return self.group
end

---获取名称限制
function CollectionRoomBLL:GetNameLimit()
    if not self.name_limit then
        self.name_limit = tonumber(LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DECORATIONFORMWORKMAX))
    end
    return self.name_limit
end
--endregion



----------初始化数据相关---------------------
---初始化预设列表
function CollectionRoomBLL:InitSlotList()
    if self.is_init then
        return
    end
    local str = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DECORATIONFORMWORK)
    if str then
        for id, v in ipairs(str) do
            local slot = self:GetSlot(id, true)
            local sp2 = v
            slot:SetCost(sp2)
            local name = UITextHelper.GetUIText(UITextConst.UI_TEXT_5946, id)
            slot:SetName(name)
            slot:SetDefaultName(name)
        end
    end
end

function CollectionRoomBLL:OnInit()
    ---@type CollectionItemData[]
    self.collection_map = {}
    ---@type CollectionItemData[]
    self.collection_list = {}
    self.style_map = {}
    self.cur_select_style_map = {}
    ---@type StyleItemData[]
    self.style_data_map = {}
    self.cur_style_id = nil
    self.is_init = false
    self.collection_role_list = {}
    self.collection_server_map = {}
    self.collection_local_map = {}
    self.cur_collection_type = nil
    self.max_count_map = {}
    self.handle_item_size = {}
    self.clear_red_point_map = {}
    self.style_lock_condition = {}
    self.style_type_map = {}
    self.slot_data_map = {}
    self.img_save_map = {}
    self.state_ui_map = {}
    self.style_group_list = nil
    self.style_group_state = 0
    self.prefix_url = "PreGenerated_"
    self:SetContext()
    self:RegisterListener()
end

function CollectionRoomBLL:GetStateUIMap()
    return self.state_ui_map
end

---@param collection pbcmessage.CollectionData 藏品数据
---@param decoration pbcmessage.DecorationData 装修数据
function CollectionRoomBLL:Init(collection, decoration)
    self.loveData = BllMgr.GetLovePointBLL():GetLoveData()
    self.roleId = self.loveData:GetCurRole()
    self.proxy = SelfProxyFactory.GetCollectionRoomProxy()
    self.init_put_map = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.INITIALGETCOLLECTION)
    --self.proxy:InitData(map and map.RoleCollectionMap)
    self.proxy:InitCollectData(collection, decoration)
    ---@type CollectionRoomData
    self.collectionData = self.proxy:GetCollectionData()
    --self.collectionData:RefreshDecorationInfo(map.DecorationInfoMap)
    if UIMgr.IsOpened(UIConf.CollectionRoomWnd) then
        return
    end
    self:CheckRoleInfo()
end

function CollectionRoomBLL:GetRoleCollectionData(roleId)
    return self.collectionData:GetRoleCollectDataByRoleID(roleId)
end

function CollectionRoomBLL:CheckInInit(id)
    return table.containsvalue(self.init_put_map, id)
end

function CollectionRoomBLL:GetCollectDollAmount(role_id)
    local amount = 0
    if role_id == -1 then
        if not self.roleCollectMap then
            return 0
        end
        for i, v in pairs(self.roleCollectMap) do
            if i > 0 then
                local collectMap = v.CollectionMap
                if collectMap then
                    for _, item in pairs(collectMap) do
                        local itemInfo = LuaCfgMgr.Get("Item", item.ID)
                        if itemInfo and itemInfo.Type == X3_CFG_CONST.ITEM_TYPE_COLLECTION and itemInfo.SubType == 2 then
                            if item.Num > 0 then
                                amount = amount + 1
                            end
                        end
                    end
                end
            end
        end
        return amount
    else
        if self.roleCollectMap and self.roleCollectMap[role_id] then
            local collectMap = self.roleCollectMap[role_id].CollectionMap
            if collectMap then
                for i, v in pairs(collectMap) do
                    local itemInfo = LuaCfgMgr.Get("Item", v.ID)
                    if itemInfo and itemInfo.Type == X3_CFG_CONST.ITEM_TYPE_COLLECTION and itemInfo.SubType == 2 then
                        if v.Num > 0 then
                            amount = amount + 1
                        end
                    end
                end
            end
        end
    end
    return amount
end

function CollectionRoomBLL:InitCollectionData(data)
    self:InitStyleList()
    self:InitSlotList()
    self.style_map = data and data.DecorationMap or {}
    if not next(self.style_map) then
        self:InitStyleMap()
    end
    table.merge(data and data.CollectionMap or {}, self.roleCollectMap[0] and self.roleCollectMap[0].CollectionMap or {})
    self:RefreshCollectionList(data and data.CollectionMap or nil)
    self:RefreshServerCollectionMap(data and data.CollectionDecorationList or nil)
    self:RefreshServerCollectionMap(data and data.CollectionPendantList or nil)
    self:RefreshNewStyleMap()
    self:SetInUsePrefab(data and data.InUsePrefab)
    self:RefreshSlotList(data and data.DecorationPrefabMap)
    self.loveData:RefreshCollectRed(self.roleId)
    self.is_init = true
end

function CollectionRoomBLL:CheckRoleId(uid)
    self:CheckRoleInfo()
end

---查看男主的藏品数据
function CollectionRoomBLL:CheckRoleInfo(role_id)
    self:OnInit()
    local data = nil
    if role_id then
        self.roleId = role_id
    end
    self.roleCollectMap = self.collectionData:GetRoleCollectMap()
    data = self.collectionData:GetRoleCollectDataByRoleID(self.roleId)
    self:InitCollectionData(data)
end

---查看好友男主id
function CollectionRoomBLL:GetFriendCheckRoleId()
    return self.check_role_id
end

---获取好友亲密度最高的男主
function CollectionRoomBLL:GetFriendMaxPoint()
    local roleList = BllMgr.GetRoleBLL():GetRoleCfgList()
    local loveSort = {}
    for i, v in pairs(roleList) do
        local roleData = BllMgr.GetRoleBLL():GetRole(v.ID)
        if roleData then
            table.insert(loveSort, { ID = v.ID, Point = roleData and roleData.LovePoint or 0 })
        end
    end
    table.sort(loveSort, function(a, b)
        return a.Point > b.Point
    end)
    return loveSort[1] and loveSort[1].ID or 1
end

function CollectionRoomBLL:InitStyleMap()
    for i, v in pairs(self.style_data_map) do
        if v:GetIsDefault() then
            self.style_map[v:GetType()] = v:GetId()
        end
    end
end

function CollectionRoomBLL:GetCurRole()
    return self.roleId
end

function CollectionRoomBLL:ResetCurRole()
    self.roleId = self.loveData:GetCurRole()
end

function CollectionRoomBLL:ChangeRole(role_id)
    if role_id and role_id == self.roleId then
        return
    end
    self.is_init = false
    self:CheckRoleInfo(role_id)
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_ALL)
end

---@class Collection
---@field ID int  --藏品ID
---@field Num int -- 数量
---@field CreateTime int --创建时间
---@field IsNew int -- 是否新物品 1为新的
---@field GalleryNew int--图鉴界面里的是否新物品 1为新的
---@return Collection
--根据道具id获得指定角色的获得数据信息
function CollectionRoomBLL:GetCollectionDataByRole(itemID, roleId)
    if not roleId then
        roleId = self.roleId
    end
    local collData = self.roleCollectMap[roleId]
    if collData then
        return collData.CollectionMap[itemID]
    end
end

-------服务器数据刷新相关---------------------------


function CollectionRoomBLL:RefreshNewStyleMap()
    if self.is_init then
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_RED_POINT, CollectionConst.State.CHANGE_STYLE)
    end
    self:CheckStyleRed()
end

---解析藏品坐标数据
function CollectionRoomBLL:RefreshServerCollectionMap(map_list)
    if not map_list then
        return
    end
    for k, v in pairs(map_list) do
        local x = math.numbertodecimal(v.X, CollectionConst.DECIMAL)
        local y = math.numbertodecimal(v.Y, CollectionConst.DECIMAL)
        local r
        if v.R then
            r = math.numbertodecimal(v.R, CollectionConst.DECIMAL)
        end
        if not self.collection_server_map[v.ID] then
            self.collection_server_map[v.ID] = {}
        end
        local pos = { ID = v.ID, X = x, Y = y, R = r, InteractiveState = v.InteractiveState or 0 }
        table.insert(self.collection_server_map[v.ID], pos)
    end
    for k, list in pairs(self.collection_server_map) do
        ---@type CollectionItemData
        local item = self:GetCollectionItemData(k)
        if item then
            item:SetPosMap(list)
        end
    end
end

function CollectionRoomBLL:RefreshCollectionList(collection_item_data_list)
    if collection_item_data_list ~= nil then
        for k, v in pairs(collection_item_data_list) do
            local item = self:GetCollectionItemData(v.ID)
            if not item then
                self:CreateCollectionItemData(v)
            else
                item:Refresh(v)
            end
        end
        self:RefreshCollectionList2()
        self:CheckCollectionRed()
        if self.is_init then
            EventMgr.Dispatch(CollectionConst.Event.COLLECTION_DATA_UPDATE)
            EventMgr.Dispatch(CollectionConst.Event.COLLECTION_REFRESH_RED_POINT, CollectionConst.State.CHANGE_COLLECTION)
        end
    end
end

function CollectionRoomBLL:RefreshCollectionList2()
    self.collection_list = self.collection_list and self.collection_list or {}
    table.clear(self.collection_list)
    for k, v in pairs(self.collection_map) do
        table.insert(self.collection_list, v)
    end
end

function CollectionRoomBLL:NewDecorationUpdateReply(data)
    if not data.DecorationList then
        return
    end

    local infoMap = PoolUtil.GetTable()
    for _, v in pairs(data.DecorationList) do
        local decInfo = LuaCfgMgr.Get("DecorationInfo", v.ID)
        if decInfo then
            infoMap[v.ID] = v
        end
    end
    self.collectionData:RefreshDecorationInfo(infoMap)
    for k, v in pairs(infoMap) do
        self:CreateStyleItemData(k, self.default_style_id_map[k] ~= nil)
    end
    PoolUtil.ReleaseTable(infoMap)
    self:RefreshNewStyleMap()
end

function CollectionRoomBLL:HasDecorationItem(id)
    if self.default_style_id_map[id] then
        return true
    end
    return self.collectionData:HasDecorationByID(id)
end

function CollectionRoomBLL:CollectionUpdateReply(data)
    self:UpdateCollectionMapByRole(data.Role, data.CollectionList)
    if data.Role == 0 or data.Role == self.roleId then
        self:RefreshCollectionList(data and data.CollectionList or nil)
        self.loveData:RefreshCollectRed(self.roleId)
    end
end

function CollectionRoomBLL:DecorationUpdateReply(data)
    self:UpdateDecorationMapByRole(data.Role, data.DecorationMap)
    if data.Role == self.roleId then
        self.loveData:RefreshCollectRed(self.roleId)
    end
end

---获得拿到CMS前缀拼接后的url
---@param url string
---@param finishCallBack fun
function CollectionRoomBLL:GetUrlWithCMS(url, finishCallBack)
    if string.isnilorempty(url) then
        if finishCallBack then
            finishCallBack()
        end
        return
    end
    if self.prefix_connect_url then
        if finishCallBack then
            finishCallBack(string.concat(self.prefix_connect_url, url))
        end
    else
        local reqData
        local regionId = Locale.GetRegion()
        if Locale.GetRegion() == Locale.Region.EuropeAmericaAsia then
            local zoneId = BllMgr.GetLoginBLL():GetServerId()
            reqData = { key = string.concat(self.prefix_url, regionId, "_", zoneId) }
        else
            reqData = { key = string.concat(self.prefix_url, regionId) }
        end
        GameHttpRequest:Get(ServerUrl.UrlType.CMS, ServerUrl.UrlOp.GameConfig, reqData, nil, function(str)
            local data = JsonUtil.Decode(str)
            local is_success = true
            if not data then
                Debug.LogErrorFormat("request url={%s} is error", url)
                is_success = false
            end
            if tonumber(data["ret"]) ~= 0 then
                Debug.LogErrorFormat("request url={%s} is error,ret={%s}", url, data["ret"])
                is_success = false
            end
            if not data.gameConfigParameter then
                Debug.LogErrorFormat("request url={%s} gameConfigParameter is nil", url)
                is_success = false
            end
            if is_success then
                self.prefix_connect_url = data.gameConfigParameter.value
                if finishCallBack then
                    finishCallBack(string.concat(self.prefix_connect_url, url))
                end
            else
                if finishCallBack then
                    finishCallBack()
                end
            end
        end, function()
            if finishCallBack then
                finishCallBack()
            end
        end)
    end
end

function CollectionRoomBLL:UpdateCollectionMapByRole(role_id, collectionList)
    role_id = role_id == nil and 0 or role_id
    if role_id > 0 then
        if self.roleCollectMap[role_id] then
            for i, v in pairs(collectionList) do
                local data = self.roleCollectMap[role_id].CollectionMap[v.ID]
                if data then
                    v.LastNum = data.Num
                else
                    v.LastNum = 0
                end
                self.roleCollectMap[role_id].CollectionMap[v.ID] = v
            end
        end
    else
        for _, v in pairs(self.roleCollectMap) do
            for _, collect in pairs(collectionList) do
                v.CollectionMap[collect.ID] = collect
            end
        end
    end
end

function CollectionRoomBLL:UpdateDecorationMapByRole(role_id, decorationList)
    role_id = role_id == nil and 0 or role_id
    if role_id > 0 then
        if self.roleCollectMap[role_id] then
            for i, v in pairs(decorationList) do
                self.roleCollectMap[role_id].DecorationMap[i] = v
            end
        end
    else
        for _, v in pairs(self.roleCollectMap) do
            for k, decoration in pairs(decorationList) do
                v.DecorationMap[k] = decoration
            end
        end
    end
end

function CollectionRoomBLL:SaveSuccess(data, is_show_tips)
    EventMgr.Dispatch(CollectionConst.Event.COLLECTION_SAVE_SUCCESS, is_show_tips)
    self:SetIsShowTips()
    if data then
        if self.roleCollectMap[data.RoleID] then
            self.roleCollectMap[data.RoleID].CollectionDecorationList = data.CollectionDecorationList
            self.roleCollectMap[data.RoleID].CollectionPendantList = data.CollectionPendantList
        end
    end
end

function CollectionRoomBLL:RefreshCollectMap(data)
    if not data then
        return
    end
    if self.roleCollectMap[data.Role] then
        self.roleCollectMap[data.Role].CollectionDecorationList = data.CollectionDecorationList
        self.roleCollectMap[data.Role].CollectionPendantList = data.CollectionPendantList
    end
    if data.Role == self.roleId then
        self.collection_server_map = {}
        for i, v in pairs(self.collection_map) do
            v:ClearPosMap()
        end
        self:RefreshServerCollectionMap(data and data.CollectionDecorationList or nil)
        self:RefreshServerCollectionMap(data and data.CollectionPendantList or nil)
    end
end

function CollectionRoomBLL:CreateCollectionItemData(server_data)
    local item_data = CollectionItemData.new()
    item_data:SetRole(self.roleId)
    item_data:SetInInit(self:CheckInInit(server_data.ID))
    local is_ok = item_data:Refresh(server_data)
    if not is_ok then
        return
    end
    self.collection_map[item_data:GetId()] = item_data
    return item_data
end

---@param itemData: CollectionItemData
function CollectionRoomBLL:ChangeCollectionMap(itemData)
    self.collection_map[itemData:GetId()] = itemData
end

function CollectionRoomBLL:CreateStyleItemData(id, is_default)
    local item_data = StyleItemData.new()
    item_data:RefreshData(id, self.collectionData:GetDecorationItem(id), is_default)
    self.style_data_map[id] = item_data
    return item_data
end

function CollectionRoomBLL:ChangeRedPoint(changeType)
    if changeType == CollectionConst.State.CHANGE_COLLECTION then
        self:CheckCollectionRed()
    end
end

---@param state
function CollectionRoomBLL:ChangeStyleGroupState(state)
    self.style_group_state = state
end

function CollectionRoomBLL:GetStyleGroupState()
    return self.style_group_state
end

function CollectionRoomBLL:GetFirstCollectionItem(roleId)
    return self.collectionData:GetFirstCollectionItem(roleId)
end

function CollectionRoomBLL:RegisterListener()
    X3DataMgr.Subscribe(X3DataConst.X3Data.Item, self.OnEventBagItemUpdate, self)
    EventMgr.AddListener(CollectionConst.Event.COLLECTION_REFRESH_RED_POINT, self.ChangeRedPoint, self)
end

function CollectionRoomBLL:UnRegisterEventListener()
    EventMgr.RemoveListenerByTarget(self)
    X3DataMgr.UnsubscribeWithTarget(self)
end

function CollectionRoomBLL:OnEventBagItemUpdate(item_data)
    if item_data and item_data.Type == CollectionConst.STYLE_TYPE then
        EventMgr.Dispatch(CollectionConst.Event.COLLECTION_STYLE_DATA_UPDATE)
    end
end

---@param state CollectionConst.State
function CollectionRoomBLL:SetCurState(state)
    self.cur_change_stage = state
end

---@return CollectionConst.State
function CollectionRoomBLL:GetCurState()
    return self.cur_change_stage
end

function CollectionRoomBLL:OnClear()
    self:UnRegisterEventListener()
end

------------------------------------------------------------------------------------------------------------------------
---暂时只是需要RoleBLL，ItemBLL
function CollectionRoomBLL:SetContext()
    self.roleBLl = BllMgr.GetRoleBLL()
    self.itemBLL = BllMgr.Get("ItemBLL")
end

---藏品跳转相关
---跳转到装修套装界面
function CollectionRoomBLL:JumpToStyleGroup()
    UIMgr.Open(UIConf.CollectionRoomWnd, CollectionConst.State.CHANGE_STYLE_GROUP, true)
end

return CollectionRoomBLL
