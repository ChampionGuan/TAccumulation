--- X3@PapeGames
--- BaseLoginState
--- Created by fusu
--- Created Date: 2023/5/9
local BaseGameState = require("Runtime.System.X3Game.Modules.GameStateMgr.BaseGameState")
---@class BaseLoginState
local BaseLoginState = class("BaseLoginState", BaseGameState)

---@type GameDataBridge
local GameDataBridge = require("Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge")

function BaseLoginState:OnEnter(prevStateName)
	BaseGameState.OnEnter(self)
	---需要等待资源加载完成才能设置Unload(true)
	GameMgr.WaitAssetLoadFinished(function()
		---设置资源加载为正常模式
		---Unload(false)=>Unload(true)前，强制卸载一次，防止Unload(true)误卸载
		if Res.ABUnloadParameter == false then
			Res.ForceUnloadAllLoaders()
		end
		Res.SetABUnloadParameter(true)
		Res.SetFileLoaderMaxReleaseCount(1000000)

		if GameDataBridge.GetCacheData ~= nil and GameDataBridge.CacheType ~= nil then
			if GameDataBridge.GetCacheData(GameDataBridge.CacheType.SrpResChanged) then
				CS.PapeGames.Rendering.PapegameRenderPipelineAsset.IResourceProvider:UnloadAsset()
				Res.UnloadUnusedLoaders()
			end
		else
			CS.PapeGames.Rendering.PapegameRenderPipelineAsset.IResourceProvider:UnloadAsset()
			Res.UnloadUnusedLoaders()
		end
		
		---设置字体的Fallback关系
		local fontUtil = require("Runtime.System.X3Game.Modules.InputFieldAndFont.FontUtil")
		fontUtil.ForceReloadFontAsset(Locale.GetLang())

		---游戏内常量初始化
		require("Runtime.System.X3Game.X3GameInit")

		WwiseMgr.SetBankWhiteList({ "UI_Common", "Music_Interface", "Function", "Music_Playlist" })
		--BllMgr.Get("SystemSettingBLL"):InitGraphicsSetting()

		---设置GameObject池的释放时间
		local x3AssetInsProvider = CS.PapeGames.X3.X3AssetInsProvider.Instance
		x3AssetInsProvider.TickCondReleaseTime = 5
		x3AssetInsProvider.TickCondReleaseCount = 1000
		
		self:InternalEnter()
	end)
end


return  BaseLoginState