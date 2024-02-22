--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AccompanyData 
---@field  RoleMap  table<number,pbcmessage.AccompanyRoleData> @ key:男主id value:男主陪伴数据
---@field Records pbcmessage.AccompanyRecords @ 陪伴记录数据
local  AccompanyData  = {}
---@class pbcmessage.AccompanyDayRecord 
---@field  Records  table<number,pbcmessage.AccompanyTypeRecord> @ key:陪伴类型 value:类型陪伴记录
local  AccompanyDayRecord  = {}
---@class pbcmessage.AccompanyRecords 
---@field  TLogRefreshTime  table<number,number> @ 类型刷新时间 key:类型 value:刷新时间
---@field TotalDays number @ 累计陪伴天数
---@field TotalMonths number @ 累计陪伴月数
---@field CurrentConsecutiveDays number @ 当前连续陪伴天数
---@field LongestConsecutiveDays number @ 最长连续陪伴天数
---@field  TypeTotalDays    table<number,number> @ 类型累计陪伴天数
---@field  TypeTotalMonths  table<number,number> @ 类型累计陪伴月数
---@field  TypeLatestTime   table<number,number> @ 类型最晚陪伴时间 此数字为那一时刻减单日5点的秒差
local  AccompanyRecords  = {}
---@class pbcmessage.AccompanyRoleData 
---@field Type number @ 陪伴类型
---@field StartTime number @ 开始时间
---@field ExpectDuration number @ 期待陪伴时长
---@field AccumulateTime number @ 累积陪伴时长
---@field OfflineDuration number @ 陪伴离线时间
---@field WaitDuration number @ 续期等待时长
---@field Records pbcmessage.AccompanyRoleRecords 
local  AccompanyRoleData  = {}
---@class pbcmessage.AccompanyRoleRecords 
---@field  CounterRefreshTime         table<number,number> @ 类型刷新时间 key:类型 value:刷新时间
---@field  WeekRecord                 table<number,number> @ 周陪伴记录 key：类型 value：天数
---@field  MonthRecord                table<number,number> @ 月陪伴记录 key：类型 value：天数
---@field  ConsecutiveWeekOne         table<number,number> @ 陪伴一次连续周数  key：类型 value：连续次数
---@field  ConsecutiveWeekThree       table<number,number> @ 陪伴三次连续周数  key：类型 value：连续次数
---@field  YearRecords  table<number,pbcmessage.AccompanyYearRecord> @ key：年份 value:每年陪伴记录 满一分钟计算(按配置，目前为一分钟)
---@field  WeekRecordCnt              table<number,number> @ 陪伴记录 key:类型 value：次数 每周刷新  客户端需要计算周任务
local  AccompanyRoleRecords  = {}
---@class pbcmessage.AccompanyTypeRecord @import "x3x3.proto";
---@field Cnt number @ 次数
---@field Duration number @ 时长 单位分钟
local  AccompanyTypeRecord  = {}
---@class pbcmessage.AccompanyYearRecord 
---@field  Records  table<number,pbcmessage.AccompanyDayRecord> @ key：天数 value：每日陪伴记录
local  AccompanyYearRecord  = {}
---@class pbcmessage.GetAccompanyDataReply 
---@field Data pbcmessage.AccompanyData 
local  GetAccompanyDataReply  = {}
---@class pbcmessage.GetAccompanyDataRequest 
local  GetAccompanyDataRequest  = {}
---@class pbcmessage.StartAccompanyReply 
---@field StartTime number @ 开始时间
---@field WaitDuration number @ 等待时长
local  StartAccompanyReply  = {}
---@class pbcmessage.StartAccompanyRequest @    rpc GetAccompanyData(GetAccompanyDataRequest) returns (GetAccompanyDataReply);   获取陪伴数据
---@field RoleID number 
---@field AccompanyType number @ 陪伴类型
---@field AccompanyDuration number 
local  StartAccompanyRequest  = {}
---@class pbcmessage.StopAccompanyReply 
---@field Duration number @ 陪伴时长
---@field  WeekRecordCnt              table<number,number> @ 陪伴记录 key:类型 value：次数 每周刷新
---@field  YearRecords  table<number,pbcmessage.AccompanyYearRecord> @ key：年份 value:每年陪伴记录(只给当天的记录）
local  StopAccompanyReply  = {}
---@class pbcmessage.StopAccompanyRequest 
---@field RoleID number 
---@field AccompanyType number @ 陪伴类型
local  StopAccompanyRequest  = {}
