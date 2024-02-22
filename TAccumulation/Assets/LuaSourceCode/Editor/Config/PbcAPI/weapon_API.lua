--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Weapon @ 女主武器 文档地址:depotx3策划文档女主武器女主武器系统.xlsx
---@field Id number @ 武器id
---@field FashionId number @ 穿着的皮肤
local  Weapon  = {}
---@class pbcmessage.WeaponData 
---@field  WeaponFashionMap  table<number,boolean> @ key:皮肤id
---@field  WeaponMap       table<number,pbcmessage.Weapon> @ key:武器id
---@field IsInit boolean 
local  WeaponData  = {}
---@class pbcmessage.WeaponFashionUpdateReply @ 主动推送(只需要Reply)
---@field WeaponFashionList number[] 
local  WeaponFashionUpdateReply  = {}
---@class pbcmessage.WeaponUpdateReply @ 主动推送(只需要Reply)
---@field WeaponList pbcmessage.Weapon[] 
local  WeaponUpdateReply  = {}
