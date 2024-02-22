---@class sqliteStatement
---@field bind fun(self:sqliteStatement, n, ...)
---@field bind_blob fun(self:sqliteStatement,n, blob)
---@field bind_names fun(self:sqliteStatement,nametable)
---@field bind_parameter_count fun(self:sqliteStatement,n:number)
---@field bind_parameter_name fun(n:number)
---@field bind_values fun(self:sqliteStatement,...)
---@field columns fun(self:sqliteStatement)
---@field finalize fun(self:sqliteStatement)
---@field get_name fun(self:sqliteStatement,n:number)
---@field get_named_types fun(self:sqliteStatement)
---@field get_named_values fun(self:sqliteStatement)
---@field get_names fun(self:sqliteStatement)
---@field get_type fun(self:sqliteStatement,n:number)
---@field get_types fun(self:sqliteStatement)
---@field get_utypes fun(self:sqliteStatement)
---@field get_uvalues fun(self:sqliteStatement)
---@field get_uvalue fun(self:sqliteStatement, n:number)
---@field isopen fun(self:sqliteStatement)
---@field nrows fun(self:sqliteStatement)
---@field reset fun(self:sqliteStatement)
---@field rows fun(self:sqliteStatement)
---@field urows fun(self:sqliteStatement)  @Returns an function that iterates over the values of the result set of statement stmt. Each iteration returns the values for the current row. This is the prepared statement equivalent of db:urows().
---@field step fun(self:sqliteStatement)
---@field last_insert_rowid fun(self:sqliteStatement)


---@class sqliteDB
---@field busy_handler fun(self:sqliteDB, func, udata)
---@field busy_timeout fun(self:sqliteDB, t)
---@field changes fun(self:sqliteDB, t)
---@field close fun(self:sqliteDB)
---@field close_vm fun(self:sqliteDB, temponly)
---@field get_ptr fun(self:sqliteDB)
---@field commit_hook fun(self:sqliteDB, func, udata)
---@field create_aggregate fun(self:sqliteDB, name,nargs,step,final,userdata)
---@field create_collation fun(self:sqliteDB, name,func)
---@field create_function fun(self:sqliteDB, name,func)
---@field load_extension fun(self:sqliteDB, name,nargs,func,userdata)
---@field errcode fun(self:sqliteDB)
---@field errmsg fun(self:sqliteDB)
---@field exec fun(self:sqliteDB, sql : string)
---@field interrupt fun(self:sqliteDB)
---@field db_filename fun(self:sqliteDB,name:string)
---@field isopen fun(self:sqliteDB)
---@field last_insert_rowid fun(self:sqliteDB)
---@field nrows fun(self:sqliteDB, sql : string)
---@field prepare fun(self:sqliteDB, sql : string) : sqliteStatement
---@field progress_handler fun(self:sqliteDB, n:number,func,udata)
---@field rollback_hook fun(self:sqliteDB,func,udata)
---@field rows fun(self:sqliteDB, sql : string)
---@field total_changes fun(self:sqliteDB)
---@field trace fun(self:sqliteDB,func,udata)
---@field update_hook fun(self:sqliteDB,func,udata)
---@field urows fun(self:sqliteDB, sql : string)
---@field urows fun(self:sqliteDB, sql : string)

---@class sqlite3Enum
---@field OPEN_READONLY number
---@field OPEN_READWRITE number
---@field OPEN_CREATE number
---@field OPEN_URI number
---@field OPEN_MEMORY number
---@field OPEN_NOMUTEX number
---@field OPEN_FULLMUTEX number
---@field OPEN_SHAREDCACHE number
---@field OPEN_PRIVATECACHE number
---@field OK number@ 0
---@field ERROR number@ 1
---@field INTERNAL number@ 2
---@field PERM number@ 3
---@field ABORT number@ 4
---@field BUSY number@  5
---@field LOCKED number@  6
---@field NOMEM number@  7
---@field READONLY number@  8
---@field INTERRUPT number@  9
---@field IOERR number@  10
---@field CORRUPT number@  11
---@field NOTFOUND number@  12
---@field FULL number@  13
---@field CANTOPEN number@  14
---@field PROTOCOL number@  15
---@field EMPTY number@  16
---@field SCHEMA number@  17
---@field TOOBIG number@  18
---@field CONSTRAINT number@  19
---@field MISMATCH number@  20
---@field MISUSE number@  21
---@field NOLFS number@  22
---@field FORMAT number@  24
---@field RANGE number@  25
---@field NOTADB number@  26
---@field ROW number@  100
---@field DONE number@  101


---@class sqlite3 : sqlite3Enum
---@field complete fun(sql : string) : boolean
---@field open fun(filename : string) : sqliteDB
---@field open_memory fun() : sqliteDB
---@field open_ptr fun(db_ptr : string) : sqliteDB
---@field backup_init fun(target_db, target_name, source_db, source_name)

---@class UseArgString1

--region local

---@type sqlite3
local sqlite3 = require("lsqlite3")
local pool = {}

local function GetTable()
    local res = table.remove(pool)
    if res then
        return res
    end
    return {}
end

local function ReleaseTable(t)
    if not t then return end
    table.clear(t)
    table.insert(pool,t)
end


---@return string
local function GetSqlKeyType(kName, v)
    local result = "TEXT"
    if type(v) == "number" then
        result = "INT"
    elseif type(v) == "bool" then
        result = "INT"
    elseif type(v) == "string" then
        result = "TEXT"
    else
        result = "BLOB"
    end

    if string.lower(kName) == "id" then
        result = string.concat(result, " PRIMARY KEY")
    end

    return string.concat(kName, " ", result)
end

---@param db sqliteDB
---@param sql string
---@param noLog boolean
local function stmtExe(db, sql, noLog)
    local stmt = db:prepare(sql)
    local result
    if stmt then
        result = stmt:step()
        stmt:finalize()
    end
    if not noLog and (not result or (result ~= sqlite3.DONE and result ~= sqlite3.ROW)) then
        Debug.LogErrorFormat("stmtExe  sql=[%s] errorMsg=[%s]", sql, db:errmsg())
    end
    return result
end

local function GetSqlTableCreateInfo(tableName, head, id)
    local typeNameList = GetTable()
    local insertNameList = GetTable()
    local updateNameList = GetTable()
    local colNameList = GetTable()

    table.insert(typeNameList, 1, GetSqlKeyType("id", id))
    table.insert(insertNameList, 1, ":id")
    table.insert(colNameList, 1, "id")

    for k, v in pairs(head) do
        table.insert(typeNameList, GetSqlKeyType(k, v))
        table.insert(insertNameList, string.concat(":", k))
        table.insert(colNameList, k)
        table.insert(updateNameList, string.concat(k, " =:", k))
    end

    local createSql = string.format("CREATE TABLE %s (%s)", tableName, table.concat(typeNameList, ","))
    local insertSql = string.format("INSERT INTO %s (%s) VALUES (%s)", tableName, table.concat(colNameList, ","), table.concat(insertNameList, ","))
    local updateSql = string.format("UPDATE %s SET %s WHERE id=:id", tableName, table.concat(updateNameList, ","))
    ReleaseTable(typeNameList)
    ReleaseTable(insertNameList)
    ReleaseTable(updateNameList)
    ReleaseTable(colNameList)
    return createSql, insertSql, updateSql, colNameList
end

---@param stmt sqliteStatement
local function DoInsertValue(stmt, k, v)
    assert(type(v) == "table")
    local isSet = false
    if not rawget(v, "id") then
        rawset(v, "id", k)
        isSet = true
    end
    stmt:bind_names(v)
    stmt:step()
    stmt:reset()
    if isSet then
        rawset(v, "id", nil)
    end
end

---@param self DBHelper
---@param tableName string
---@return SqlStmtCache
local function GetTableStmtDict(self, tableName)
    local result = self.stmtDict[tableName]
    local db = self.db
    if not result then
        local common = db:prepare(string.format("SELECT * FROM %s", tableName))
        if not common then
            return nil
        end
        local names = common:get_names()
        local insertNameList = GetTable()
        local updateNameList = GetTable()
        local colNameList = GetTable()
        local fieldNameList = GetTable()
        for k, v in ipairs(names) do
            table.insert(insertNameList, string.concat(":", v))
            table.insert(updateNameList, string.concat(v, " =:", v))
            table.insert(colNameList, v)
            fieldNameList[v] = k - 1
        end
        local insertSql = string.format("INSERT INTO %s (%s) VALUES (%s)", tableName, table.concat(colNameList, ","), table.concat(insertNameList, ","))
        local updateSql = string.format("UPDATE %s SET %s WHERE id=:id", tableName, table.concat(updateNameList, ","))

        result = {}
        self.stmtDict[tableName] = result
        result.select = db:prepare(string.format("SELECT * FROM %s WHERE id = ?", tableName))
        result.update = db:prepare(updateSql)
        result.delete = db:prepare(string.format("DELETE FROM %s WHERE id = ?", tableName))
        result.insert = db:prepare(insertSql)
        result.selectAll = common
        result.fieldIndexTb = fieldNameList
        ReleaseTable(insertNameList)
        ReleaseTable(updateNameList)
        ReleaseTable(colNameList)

    end
    return result
end

-- 添加表还有删除表因为是一次性操作所以不做
-- 改的操作因为每一次传入的对象可能会有缺省，所以会动态生成语句执行
---@class SqlStmtCache
---@field insert sqliteStatement
---@field delete sqliteStatement
---@field select sqliteStatement
---@field update sqliteStatement
---@field selectAll sqliteStatement
---@field fieldIndexTb table<string, number>

--endregion

---@class DBHelper
---@field db sqliteDB
---@field stmtDict table<string, SqlStmtCache>
local DBHelper = class("DBHelper")

function DBHelper:ctor(path)
    self.db = sqlite3.open(path, sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE + sqlite3.OPEN_PRIVATECACHE)
    self.stmtDict = {}
    if not self:DBIntegrityTest(path) then
        --重新创建数据库
        self.db = sqlite3.open(path, sqlite3.OPEN_READWRITE + sqlite3.OPEN_CREATE + sqlite3.OPEN_PRIVATECACHE)
    end
end

function DBHelper:ExistTable(tableName)
    local stmtCache = GetTableStmtDict(self, tableName)
    return stmtCache
end

---@param defaultValue table<number, table> @ [101]={field1=1,field2=2}
function DBHelper:CreateTable(tableName, defaultValue)
    local id, head = next(defaultValue)
    local db = self.db
    local createSql, insertSql, updateSql = GetSqlTableCreateInfo(tableName, head, id)
    local dropSql = string.format("DROP TABLE %s", tableName)
    stmtExe(db, "BEGIN TRANSACTION")
    stmtExe(db, dropSql, true)
    stmtExe(db, createSql)
    stmtExe(db, "COMMIT")

    local stmtCache = GetTableStmtDict(self, tableName)
    if stmtCache then
        stmtCache.insert = db:prepare(insertSql)
        stmtCache.update = db:prepare(updateSql)
    else
        Debug.LogErrorFormat("[CreateTable failed]tableName=[%s],dropSql=[%s],createSql=[%s]", tableName, dropSql, createSql)
    end

end

---删除表，数据和表结构一起删除，快速
---@param tableName string
function DBHelper:DropTable(tableName)
    local dropSql = string.format("DROP TABLE %s", tableName)
    stmtExe(self.db, dropSql, true)
    self.stmtDict[tableName] = nil
end

---清空表格数据(注意表格仍然存在)
---@param tableName
function DBHelper:ClearTable(tableName)
    local delSql = string.format("DELETE FROM %s", tableName)
    stmtExe(self.db, delSql)
end

function DBHelper:Add(tableName, id, value)
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.insert
    DoInsertValue(stmt, id, value)
end

function DBHelper:AddValues(tableName, valueList)
    local stmtCache = GetTableStmtDict(self, tableName)
    if stmtCache then
        local db = self.db
        local stmt = stmtCache.insert
        if not stmt then
            Debug.LogErrorFormat("[AddValues failed] tbl not exist tableName=[%s]", tableName)
            return
        end
        stmtExe(db, "BEGIN TRANSACTION")
        for k, v in pairs(valueList) do
            DoInsertValue(stmt, k, v)
        end
        stmtExe(db, "COMMIT")
    else
        Debug.LogErrorFormat("[AddValues failed] tbl not exist or broken tableName=[%s]", tableName)
    end
end

---@data必须要有id字段
---@param tableName string
---@param id int
---@param data table
---@return boolean
function DBHelper:AddOrUpdate(tableName, id, data)
    assert(type(data) == "table")
    if self:Get(tableName, id) then
        self:Update(tableName, id, data)
    else
        self:Add(tableName, id, data)
    end
end

---@param tableName string
---@param id int
---@param data table
function DBHelper:Update(tableName, id, data)
    assert(type(data) == "table")
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.update
    local isSet = false
    if not rawget(data, "id") then
        rawset(data, "id", id)
        isSet = true
    end
    stmt:bind_names(data)
    if isSet then
        rawset(data, "id", nil)
    end

    local v = stmt:step()
    stmt:reset()

    return v
end

---@param tableName string
---@param id int
---@return sqlite3Enum
function DBHelper:Delete(tableName, id)
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.delete
    stmt:bind_values(id)

    local v = stmt:step()
    stmt:reset()
    return v
end

---@param tableName string
---@param condition table
function DBHelper:DeleteByCondition(tableName, condition)
    assert(type(condition) == "table")

    local nameList = GetTable()
    for k, _ in pairs(condition) do
        table.insert(nameList, string.concat(k, " = :", k))
    end
    local sql = string.format("DELETE FROM %s WHERE %s", tableName, table.concat(nameList, " AND "))
    local stmt = self.db:prepare(sql)
    stmt:bind_names(condition)
    local ret = stmt:step()
    stmt:finalize()
    
    ReleaseTable(nameList)

    return ret
end

---@param id number
---@return UseArgString1
function DBHelper:Get(tableName, id, emptyTb)
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.select
    stmt:bind_values(id)
    local errorCode = stmt:step()
    if errorCode == 100 then
        -- 枚举为 sqlite3.ROW，单纯为了速度
        if not emptyTb then
            local row = stmt:get_named_values()
            stmt:reset()
            return row
        else
            stmt:get_named_values(emptyTb)
            stmt:reset()
            return emptyTb
        end
    else
        stmt:reset()
        return nil, errorCode
    end
end

---@param tableName string
---@param id number
---@param fieldIndex number
function DBHelper:GetOneFieldByIndex(tableName, id, fieldIndex)
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.select
    stmt:bind_values(id)
    local errorCode = stmt:step()
    if errorCode == 100 then
        -- 枚举为 sqlite3.ROW，单纯为了速度
        local v = stmt:get_value(fieldIndex)
        stmt:reset()
        return v
    else
        stmt:reset()
        return nil, errorCode
    end
end

---@param tableName string
---@param id number
---@param fieldName string
function DBHelper:GetOneField(tableName, id, fieldName)
    local stmtCache = GetTableStmtDict(self, tableName)
    local tb = stmtCache.fieldIndexTb
    local index = tb[fieldName]
    assert(index, string.format("%s hash no %s col", tableName, fieldName))
    return self:GetOneFieldByIndex(tableName, id, index)
end

---@param tableName string
function DBHelper:GetAll(tableName)
    local stmtCache = GetTableStmtDict(self, tableName)
    local stmt = stmtCache.selectAll
    local rows = GetTable()
    for row in stmt:nrows() do
        local id = row.id
        rows[id] = row
        row.id = nil
    end
    stmt:reset()
    return rows
end

---@param tableName string
---@param condition table
function DBHelper:GetByCondition(tableName, condition)
    assert(type(condition) == "table")
    local nameList = GetTable()
    for k, _ in pairs(condition) do
        table.insert(nameList, string.concat(k, " = :", k))
    end
    local sql = string.format("SELECT * FROM %s WHERE %s", tableName, table.concat(nameList, " AND "))
    local stmt = self.db:prepare(sql)
    stmt:bind_names(condition)
    ReleaseTable(nameList)
    local rows = GetTable()
    for row in stmt:nrows() do
        table.insert(rows, row)
    end
    stmt:finalize()
    return rows
end

---@param sql string
---@return table[]|nil
function DBHelper:ExeSql(sql)
    self.db:exec(sql)
end

function DBHelper:GetLastInsertId(tableName)
    local stmtCache = GetTableStmtDict(self, tableName)
    if not stmtCache then
        return 0
    end

    local common = stmtCache.selectAll
    local id = common:last_insert_rowid()
    common:reset()

    return id
end

---关闭数据库
function DBHelper:Close()
    self.db:close()
end

---@private
---数据库完整性检测
---@param dbFilePath string
---@return boolean
function DBHelper:DBIntegrityTest(dbFilePath)
    if self.db == nil then
        return false
    end
    
    local tableName = "___IntegrityTestTable___"
    local isError = false
    if self:ExistTable(tableName) then
        self:DropTable(tableName)
        if self:RemoveErrorDB(dbFilePath) then
            return false
        end
    else
        self:CreateTable(tableName, { [1] = { value = 0 } })
        if self:RemoveErrorDB(dbFilePath) then
            return false
        end
        self:DropTable(tableName)
    end

    return true
end

---@private
---删除出现了NOTADB错误的DB
---@param dbFilePath string
---@return boolean 是否进行DB删除（Editor下会失败）
function DBHelper:RemoveErrorDB(dbFilePath)
    if self.db:errcode() == 26 then --NOTADB 当前DB不是数据库
        self.db:close_vm()
        self.db:close()
        local res, des = os.remove(dbFilePath)
        if des ~= nil then
            Debug.LogError("DBError: 损坏的DB删除失败!!!")
        end
        return true
    end

    return false
end

return DBHelper