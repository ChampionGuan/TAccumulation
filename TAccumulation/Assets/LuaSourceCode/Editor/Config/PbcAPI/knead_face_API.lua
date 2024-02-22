--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DeleteKneadFaceTemplateReply 
---@field TemplateID number @ 模板id
local  DeleteKneadFaceTemplateReply  = {}
---@class pbcmessage.DeleteKneadFaceTemplateRequest @ 删除发型&妆容模板
---@field TemplateID number @ 模板id
local  DeleteKneadFaceTemplateRequest  = {}
---@class pbcmessage.GetKneadFaceDataReply 
---@field KneadFace pbcmessage.KneadFaceData 
local  GetKneadFaceDataReply  = {}
---@class pbcmessage.GetKneadFaceDataRequest @    rpc SetToneValue(SetToneValueRequest) returns (SetToneValueReply) {}                                    设置ToneValue
local  GetKneadFaceDataRequest  = {}
---@class pbcmessage.KneadFaceData @ 捏脸数据
---@field Current pbcmessage.KneadFaceFull 
---@field  Templates  table<number,pbcmessage.KneadFaceTemplate> 
---@field Kneaded number @ 是否捏过脸
local  KneadFaceData  = {}
---@class pbcmessage.KneadFaceFull @ 一套捏脸
---@field FaceUrl string @ 捏脸默认头像
---@field LastSetFaceUrlTime number @ 上一次设置头像时间
---@field  ToneValues         table<number,pbcmessage.Tone> @ k:语言, v:音色值
---@field  EditDataKneadface  table<number,number> @ 捏脸数据:客户端透传数据最多250, 新账号43, 服务器长度限制 600个元素 (化妆时 editData 和 delKeys 只用更新化妆数据，二次捏脸把化妆和捏脸的相关数据都替换成这)
---@field  EditDataMakeup     table<number,number> @ 化妆数据:客户端透传数据最多250, 新账号43, 服务器长度限制 600个元素
local  KneadFaceFull  = {}
---@class pbcmessage.KneadFaceReply 
local  KneadFaceReply  = {}
---@class pbcmessage.KneadFaceRequest @ 捏脸
---@field IsKneadFace boolean @ 是否是捏脸，true表示捏脸，false表示修改妆容
---@field  EditData  table<number,number> 
---@field DelKeys number[] @ 捏脸KV结构化后, 表删除逻辑
local  KneadFaceRequest  = {}
---@class pbcmessage.KneadFaceTemplate @ 模板
---@field TemplateName string @ 模板名称
---@field  EditData  table<number,number> @ 客户端透传数据最多250, 新账号43, 服务器长度限制 600个元素
local  KneadFaceTemplate  = {}
---@class pbcmessage.SetKneadFaceTemplateReply 
---@field TemplateID number @ 模板id
---@field Template pbcmessage.KneadFaceTemplate @ 模板数据
local  SetKneadFaceTemplateReply  = {}
---@class pbcmessage.SetKneadFaceTemplateRequest @ 增加设置发型&妆容模板
---@field TemplateID number @ 模板id
---@field Template pbcmessage.KneadFaceTemplate @ 模板数据
---@field IsCover boolean @ 是否覆盖
local  SetKneadFaceTemplateRequest  = {}
---@class pbcmessage.SetKneadFaceUrlReply 
local  SetKneadFaceUrlReply  = {}
---@class pbcmessage.SetKneadFaceUrlRequest 
---@field FaceUrl string 
local  SetKneadFaceUrlRequest  = {}
---@class pbcmessage.SetToneValueReply 
local  SetToneValueReply  = {}
---@class pbcmessage.SetToneValueRequest 
---@field LanguageID number 
---@field Tone pbcmessage.Tone @
local  SetToneValueRequest  = {}
---@class pbcmessage.Tone @    ToneKeyTypeMax    = 6;   最大值标记
---@field  KVs  table<number,number> @ k:四个维度(impact,nasal,sexy,warm) v:取值(不需要校验)
local  Tone  = {}
