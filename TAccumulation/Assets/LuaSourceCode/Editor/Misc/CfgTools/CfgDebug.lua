﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2021/3/18 11:49
---

print("---------开始导表后处理调试-----")
local asset_path = CS.UnityEngine.Application.dataPath
LUA_BINARY_PATH =  string.gsub(asset_path,"Client/Assets","Binaries/Tables")
IS_CFG_DEBUG = true
os.remove = CS.System.IO.File.Delete
io.writefile = CS.System.IO.File.WriteAllText
require("Editor.Misc.CfgTools.CfgMain")
print("----------导表后处理结束----------------")