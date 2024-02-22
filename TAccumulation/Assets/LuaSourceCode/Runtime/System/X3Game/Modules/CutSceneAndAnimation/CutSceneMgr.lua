--- X3@CutSceneMgr
--- CutScene综合管理类
--- Created by Tungway
--- Created Date: 2020/8/27
--- Updated by Tungway
--- Update Date: 2021/01/18

---@class CutSceneMgr
local CutSceneMgr = {}
local cts_mgr = CS.PapeGames.CutScene.CutSceneManager
local x3cts_mgr = CS.PapeGames.CutScene.X3CutSceneManager
local cts_ctrl = CS.PapeGames.CutScene.CutSceneCtrl
local cts_collector = CS.PapeGames.CutScene.CutSceneCollector
local cts_default_content = CS.PapeGames.CutScene.DefaultCutSceneContext
local cts_helper = CS.PapeGames.CutScene.CutSceneHelper
---配合getIns()使用，而非一开始即初始化
local INS = nil
local CS_CutScenePlayMode = CS.PapeGames.CutScene.CutScenePlayMode
local CS_DirectorWrapMode = CS.UnityEngine.Playables.DirectorWrapMode
local CLS_X3ASSETINSPROVIDER = CS.PapeGames.X3.X3AssetInsProvider
local CLS_CutSceneAssetInsProvider = CS.PapeGames.CutScene.CutSceneAssetInsProvider
local CLS_PrefabCtlInsPool = CS.PapeGames.Timeline.PrefabControlInstancePool
local call_map = {}

---获取CutSceneManager.Instance
local function getIns()
	if INS == nil then
		INS = cts_mgr.Instance
	end
	return INS
end

---播放CutScene
---@param cutScenePrefabOrName GameObject 或 CutScene名字（eg.:[CutScene_xxx_prefab].prefab 中括号中间的）
---@param playMode int CutScenePlayMode
---@param wrapMode int DirectorWrapMode
---@param initialTime float 起始时间（秒）
---@param endTime float 结束时间（秒）
---@param autoPause bool 遇到事件帧是否自动暂停
---@param parentNode Transform 将CutScene自动置于此节点下
---@param tag int
---@return PapeGames.CutScene.CtsHandle
function CutSceneMgr.Play(cutScenePrefabOrName, playMode, wrapMode, initialTime, endTime, autoPause, parentNode, tag, isMuteAudio, isMuteLipsync)
	playMode = playMode or CutScenePlayMode.Break
	-- cast to cs enum
	playMode = CS_CutScenePlayMode.__CastFrom(playMode)
	wrapMode = wrapMode or DirectorWrapMode.None
	-- cast to cs enum
	wrapMode = CS_DirectorWrapMode.__CastFrom(wrapMode)
	initialTime = initialTime or 0
	endTime = endTime or 0
	autoPause = autoPause or false
	tag = tag or 0
	local crossfadeDuration = -1
	local initiaPos = Vector3.zero
	local initialRot = Vector3.zero
	isMuteAudio = isMuteAudio or false
	isMuteLipsync = isMuteLipsync or false
	return x3cts_mgr.PlayX3(cutScenePrefabOrName, playMode, wrapMode, initialTime, endTime, autoPause, parentNode, tag, crossfadeDuration, initiaPos, initialRot, isMuteAudio, isMuteLipsync)
end

---暂停CutScene播放（CutSceneName或PlayId）
---@param ctsNameOrPlayId string | int CutSceneName或PlayId
---@param withIdle bool Pause时是否同时触发Idle动画
function CutSceneMgr.Pause(ctsNameOrPlayId, withIdle)
	withIdle = withIdle or false
	if string.isnilorempty(ctsNameOrPlayId) then
		cts_mgr.Pause(withIdle)
	else
		local paramType = type(ctsNameOrPlayId)
		if paramType == "string" then
			cts_mgr.PauseWithName(ctsNameOrPlayId, withIdle)
		elseif paramType == "number" then
			cts_mgr.PauseWithPlayId(ctsNameOrPlayId, withIdle)
		end
	end
end

---利用CutScene的CinemachineTrack机制Blend一个VirtualCamera
---@param virtualCamera Cinemachine.CinemachineVirtualCameraBase
---@param duration float
function CutSceneMgr.BlendVirtualCamera(virtualCamera, duration)
	getIns():BlendVirtualCamera(virtualCamera, duration)
end

---重置BlendTime
function CutSceneMgr.ResetBlendTime()
	getIns():ResetBlendTime()
end

---清理Blend虚拟相机
function CutSceneMgr.ClearBlendVirtualCamera()
	getIns():ClearBlendVirtualCamera()
end

---恢复CutScene播放（CutSceneName或PlayId）
---@param ctsNameOrPlayId string | int CutSceneName或PlayId
---@param withIdle boolean 是否从Idle中恢复
function CutSceneMgr.Resume(ctsNameOrPlayId, withIdle)
	withIdle = withIdle or false
	if string.isnilorempty(ctsNameOrPlayId) then
		cts_mgr.Resume(withIdle)
	else
		local paramType = type(ctsNameOrPlayId)
		if paramType == "string" then
			cts_mgr.ResumeWithName(ctsNameOrPlayId, withIdle)
		elseif paramType == "number" then
			cts_mgr.ResumeWithPlayId(ctsNameOrPlayId, withIdle)
		end
	end
end

---停止CutScene（CutSceneName或PlayId）
---@param ctsNameOrPlayId string | int CutSceneName或PlayId
---@param destroyImmediate bool 是否立即销毁
function CutSceneMgr.Stop(ctsNameOrPlayId, destroyImmediate)
	destroyImmediate = destroyImmediate or false
	if string.isnilorempty(ctsNameOrPlayId) then
		---todo:需要增加一个Stop不传任何参数的方法
		---cts_mgr.Stop(destroyImmediate)
	else
		local paramType = type(ctsNameOrPlayId)
		if paramType == "string" then
			cts_mgr.StopWithName(ctsNameOrPlayId, destroyImmediate)
		elseif paramType == "number" then
			cts_mgr.StopWithPlayId(ctsNameOrPlayId, destroyImmediate)
		end
	end
	CS.PapeGames.Timeline.ControlObjInstancePool.UnSpawnAllObject()
end

---停止所有的CutScene播放（请谨慎调用）
function CutSceneMgr.StopAll()
	Debug.LogError("Warning: CutSceneMgr.StopAll invoked.")
	cts_mgr.StopAll()
	CS.PapeGames.Timeline.ControlObjInstancePool.UnSpawnAllObject()
end

---根据Tag停止CutScene播放
---@param tag int
---@param destroyImmediate bool 是否立即销毁
function CutSceneMgr.StopWithTag(tag, destroyImmediate)
	destroyImmediate = destroyImmediate or false
	cts_mgr.StopWithTag(tag, destroyImmediate)
	CS.PapeGames.Timeline.ControlObjInstancePool.UnSpawnAllObject()
end

---插入资产实例（只应用于本次CutScene播放）
---@param assetId int
---@param ins GameObject
---@return bool 本次操作是否成功
function CutSceneMgr.InjectAssetIns(assetId, ins)
	local ret = CLS_X3ASSETINSPROVIDER.Instance:InjectAssetIns(assetId, ins)
	return ret
end

---永久插入资产实例（对后面的CutScene播放都有效）
---@param assetId int
---@param ins GameObject
---@return boolean 本次操作是否成功
function CutSceneMgr.InjectAssetInsPermanently(assetId, ins)
	local ret = CLS_X3ASSETINSPROVIDER.Instance:InjectAssetIns(assetId, ins)
	return ret
end

---永久移除资产实例（对后面的CutScene播放都有效）
---@param ins GameObject
---@return boolean 本次操作是否成功
function CutSceneMgr.RemoveAssetInsPermanently(ins)
	return CLS_X3ASSETINSPROVIDER.Instance:RemoveAssetIns(ins)
end

---永久移除所有资产实例（对后面的CutScene播放都有效）
function CutSceneMgr.RemoveAllAssetInsPermanently()
	return CLS_X3ASSETINSPROVIDER.Instance:RemoveAllAssetIns()
end

---是否有注入有效的资产实例
---@param assetId Int
---@return boolean
function CutSceneMgr.HasInjectedIns(assetId)
	---todo:
    local ret = CLS_X3ASSETINSPROVIDER.Instance:HasInjectedAssetIns(assetId)
	return ret
end

---根据AssetId返回一个资产实例
---@param assetId Int
---@return GameObject
function CutSceneMgr.GetIns(assetId)
	return CLS_X3ASSETINSPROVIDER.Instance:GetInjectedIns(assetId)
end

---还资产实例
---@param ins GameObject
function CutSceneMgr.ReleaseIns(ins)
	CLS_X3ASSETINSPROVIDER.Instance:ReleaseInjectedIns(ins)
end

---设置CutScene对象的世界坐标
---@param playId int
---@param worldPos Vector3 World Position
---@param worldRot Vector3 World Rotation
function CutSceneMgr.SetCutScenePosition(playId, worldPos, worldRot)
	local handle = getIns():GetHandle(playId)
	if not handle:IsValid() or handle.Ctrl == nil then return end
	local tf = handle.Ctrl.transform
	if worldPos ~= nil then
		tf.position = worldPos
	end
	if worldRot ~= nil then
		tf.rotation = CS.UnityEngine.Quaternion.Euler(worldRot)
	end
end

---设置AssetIns在CutScene播放完后是否需要保持世界坐标的位置
---@param ins GameObject
---@param isStay boolean 是否保持世界坐标
function CutSceneMgr.SetStayWorldPosition(ins, isStay)
	local ret = x3cts_mgr.SetStayWorldPosition(ins, isStay)
	return ret
end

---获取当前正在播放的CTS剩余时间
---@return float 剩余时间（秒）
function CutSceneMgr.GetCurCutSceneLeftTime()
	return cts_mgr.GetCurCutSceneLeftTime()
end

---注册事件回调
---@param cb fun(data:CutSceneEventData)
---@param dontClear boolean
function CutSceneMgr.RegisterEventCallback(cb , dontClear)
	if cb ~= nil then
		if not dontClear then
			table.insert(call_map,cb)
		end
		cts_mgr.RegisterEventCallback(cb)
	end
end

---反注册事件回调
---@param cb fun(data:CutSceneEventData)
function CutSceneMgr.UnregisterEventCallback(cb)
	if cb ~= nil then
		table.removebyvalue(call_map,cb)
		cts_mgr.UnregisterEventCallback(cb)
	end
end

---设置是否开启CachePPVMode
---@param cacheMode bool
---@return void
function CutSceneMgr.SetCachePPVMode(cacheMode)
	cts_mgr.CachePPVMode = cacheMode or false
end

---销毁Cached PPV
---@return void
function CutSceneMgr.DestroyCachedPPV()
	cts_mgr.DestroyCachedPPV()
end

---播放CTS快照
---@param snapShotPrefab GameObject
function CutSceneMgr.PlaySnapshot(snapShotPrefab)
	getIns():PlaySnapshot(snapShotPrefab)
end

---设置HypeSpeed
---@param value float
function CutSceneMgr.SetHypeSpeed(value)
	cts_mgr.HypeSpeed = value
end

---获取HypeSpeed
---@return float
function CutSceneMgr.GetHypeSpeed()
	return cts_mgr.HypeSpeed
end

---@param value float
function CutSceneMgr.SetCutSceneSoundSpeed(value)
	x3cts_mgr.SetCutSceneSoundSpeed(value)
end

---设置权重
---@param slot EStaticSlot
---@param weight float
function CutSceneMgr.SetBlendingGroupWeight(slot, weight)
	getIns():SetBlendingGroupWeight(slot, weight)
end

---给CutScene发事件
---@param eventType string
---@param value any
function CutSceneMgr.SendEvent(eventType, value)
	cts_ctrl.SendEvent(eventType, value)
end

---@param eventType string
---@param value float | number
function CutSceneMgr.SendEventWithFloat(eventType,value)
	x3cts_mgr.SendEvent(eventType,value)
end

---给CutScene发事件
---@param eventType string
---@param param string
---@param value any
function CutSceneMgr.SendEventWithParam(eventType, param, value)
	cts_ctrl.SendEvent(eventType, param, value)
end

---设置是否关闭“exclude from blur”
---true时播放Cts时对角色和NPC的RendererAttModifier.ExcludeFromBlur执行false
---false时不做处理
---@param enable bool
function CutSceneMgr.SetDisableExcludeFromDOF(enable)
	CLS_CutSceneAssetInsProvider.SetDisableExcludeFromDOF(enable)
end

---返回CTS长度
function CutSceneMgr.GetCTSLength(ctsName)
	return cts_collector.GetLength(ctsName)
end

---返回CTS路径
function CutSceneMgr.GetCTSPath(ctsName)
	return cts_collector.GetPath(ctsName)
end

---返回CTS创建出来的对象
---@return List<GameObject>
function CutSceneMgr.GetCTSInsPool()
	return CLS_PrefabCtlInsPool.pool
end

function CutSceneMgr.Init()
	cts_default_content.UIPrefab = Res.LoadWithAssetPath("Assets/Build/Res/GameObjectRes/BasicWidget/CutSceneUI.prefab", AutoReleaseMode.None)
	cts_ctrl.context:SetUICamera(UIMgr.GetUICamera())
	cts_helper.MainCamera = CS.X3Game.CameraUtility.MainCamera
end

function CutSceneMgr.Clear()
	for k,v in pairs(call_map) do
		CutSceneMgr.UnregisterEventCallback(v)
	end
	table.clear(call_map)
	CLS_CutSceneAssetInsProvider.Clear()
	INS = nil
end

function CutSceneMgr.Destroy()
	CutSceneMgr.Clear()
end

return CutSceneMgr