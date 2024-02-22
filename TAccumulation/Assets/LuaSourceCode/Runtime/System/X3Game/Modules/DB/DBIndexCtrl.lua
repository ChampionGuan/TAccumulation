---
--- Key-Value形式的存储
--- Created by zhanbo.
--- DateTime: 2022/11/9 15:14
---
---@class DBIndexCtrl
local DBIndexCtrl = class("DBIndexCtrl")

---构造函数
function DBIndexCtrl:ctor()
    ---@type string
    self.dbPath = nil
    ---@type string
    self.tableName = nil
    ---@type DBHelper
    self.helper = nil
    ---@type int
    self.tableMaxId = nil
    self.sharedValue = {}
end



---设置表名
---@param tableName string
function DBIndexCtrl:SetTableName(tableName)
    self.tableName = tableName
end

---@param dbHelper DBHelper
function DBIndexCtrl:SetDBHelper(dbHelper)
    self.helper = dbHelper
end

---表是否存在
---@return bool
function DBIndexCtrl:ExistTable()
    if string.isnilorempty(self.tableName) then
        Debug.LogError("[DBIndexCtrl:ExistTable] tableName is nil.")
        return false
    end
    if self:_GetHelper():ExistTable(self.tableName) then
        return true
    end
    return false
end

---添加单个数据
---@param index int
---@param data table
function DBIndexCtrl:Add(index, data)
    table.clear(self.sharedValue)
    self.sharedValue.value = data
    self:_GetHelper():Add(self.tableName, index, self.sharedValue)
end

---删除单个数据
---@param index int
function DBIndexCtrl:DeleteValue(index)
    self:_GetHelper():Delete(self.tableName, index)
end

---添加或者更新单个数据
---@param index int
---@param data table
function DBIndexCtrl:AddOrUpdate(index, data)
    local dbData = self:Get(index)
    if not dbData then
        self:Add(index, data)
    else
        table.clear(self.sharedValue)
        self.sharedValue.value = data
        self:_GetHelper():Update(self.tableName, index, self.sharedValue)
    end
end

---获取单个数据
---@param index int
---@return table
function DBIndexCtrl:Get(index)
    return self:_GetHelper():GetOneFieldByIndex(self.tableName, index, 1)
end

---获取全部数据(不传参数就内部new一个table,参数用来存储所有数据)
---@param result {}
---@return table
function DBIndexCtrl:GetAll(result)
    local exists = self:ExistTable()
    if not exists then
        return nil
    end
    local all = self:_GetHelper():GetAll(self.tableName)
    if not result then
        result = {}
    else
        table.clear(result)
    end
    for i, v in pairs(all) do
        table.insert(result, v.value)
    end
    return result
end

---自动从1开始填充index添加数据
---@param dataList table[]
function DBIndexCtrl:FillValues(dataList)
    table.clear(self.sharedValue)
    for i = 1, #dataList do
        table.insert(self.sharedValue, { id = i, value = dataList[i] })
    end
    self:_GetHelper():AddValues(self.tableName, self.sharedValue)
end

---删除表
function DBIndexCtrl:DeleteTable()
    if string.isnilorempty(self.tableName) then
        Debug.LogError("[DBIndexCtrl:DeleteTable] tableName is nil.")
        return
    end
    self:_GetHelper():DropTable(self.tableName)
end

---清空表格数据(注意表格仍然存在)
function DBIndexCtrl:ClearTable()
    if string.isnilorempty(self.tableName) then
        Debug.LogError("[DBIndexCtrl:ClearTable] tableName is nil.")
        return
    end
    self:_GetHelper():ClearTable(self.tableName)
end

---执行Sql语句
---@param sql string
function DBIndexCtrl:_ExeSql(sql)
    self:_GetHelper():ExeSql(sql)
end

---@return DBHelper
function DBIndexCtrl:_GetHelper()
    if not self.helper then
        Debug.LogError("[DBIndexCtrl:_GetHelper] helper is nil.")
        return
    end
    return self.helper
end

---创建表
---@param defaultValue table<number, table> @ [101]={field1=1,field2=2}
function DBIndexCtrl:_CreateTable(tableName, defaultValue)
    self:_GetHelper():CreateTable(tableName, defaultValue)
end

---供外部调用,清理内部数据
function DBIndexCtrl:Clear()
    self.dbPath = nil
    self.tableName = nil
    self.helper = nil
    self.tableMaxId = nil
end

return DBIndexCtrl