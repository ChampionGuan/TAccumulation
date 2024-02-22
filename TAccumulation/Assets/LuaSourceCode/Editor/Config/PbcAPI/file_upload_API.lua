--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.QueryFileUploadInfoReply 
---@field UploadFileName string 
---@field SignedURL string 
---@field  Header  table<string,string> 
---@field ClientFileName string 
local  QueryFileUploadInfoReply  = {}
---@class pbcmessage.QueryFileUploadInfoRequest @    rpc QueryFileUploadInfo(QueryFileUploadInfoRequest) returns (QueryFileUploadInfoReply) {}   获取文件上传信息
---@field ClientFileName string 
local  QueryFileUploadInfoRequest  = {}
