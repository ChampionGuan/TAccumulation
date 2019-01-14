-----------------------------------------------------
-------------------定义layer--------------------------
-----------------------------------------------------
-- 渲染
local Layer = {}

-- cullingMask
local cameraCullingMask = {
    [Define.LevelType.MainCity] = bit.bor(
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Default")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("NPC"))
    ),
    [Define.LevelType.WorldMap] = bit.bor(
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Default")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("WorldmapGround"))
    ),
    [Define.LevelType.Battle] = bit.bor(
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Default")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Troops")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("FightMap"))
    ),
    [Define.LevelType.NewBattle] = bit.bor(
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Default")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Troops"))
    ),
    [Define.LevelType.Farm] = bit.bor(
        bit.lshift(1, CSharp.LayerMask.NameToLayer("Default")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("FarmGround")),
        bit.lshift(1, CSharp.LayerMask.NameToLayer("WorldmapTree"))
    )
}

function Layer:Mask(ctrl)
    -- 无主相机
    if nil == CSharp.Camera.main then
        return
    end
    -- 无渲染layer
    local cullingMask = cameraCullingMask[LevelManager.CurLevelType]
    if nil == cullingMask then
        return
    end
    -- 主相机的渲染layer
    local fsCtrl = UIManager.getTopFullScreenCtrl()
    if (nil ~= fsCtrl and fsCtrl.IsShow) or ctrl.Type == UIDefine.CtrlType.FullScreen then
        CSharp.Camera.main.cullingMask = 0
    elseif CSharp.Camera.main.cullingMask == 0 then
        CSharp.Camera.main.cullingMask = cullingMask
    end
end

return Layer
