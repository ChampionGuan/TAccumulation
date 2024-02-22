using UnityEngine;
using X3Battle.Timeline.Extension;

namespace X3Battle.Timeline.Preview
{
    // 预览ShapeBox的action (最好能搞成通用的DamageBox, 法术场, 光环都能用)
    public class PreviewShapeBoxAction : PreviewActionBase
    { 
#if UNITY_EDITOR
        private ShapeBox _shapeBox = null;
        private ShapeUseType _shapeUseType = ShapeUseType.AttackBox;
        protected override void OnInit()
        {
            TbUtil.Init();
        }

        protected override void OnEnter()
        {
            ShapeBox shapeBox = null; 
            var damageBoxAction = GetRunTimeAction<CastDamageBoxAsset>();
            var magicFieldAction = GetRunTimeAction<CreateMagicFieldAsset>();
            if (magicFieldAction != null)
            {
                var magicFieldID = magicFieldAction.magicFieldID;
                if (magicFieldID > 0)
                {
                    var targetPos = CoorHelper.GetCoordinatePoint(magicFieldAction.pointData, null, true);
                    var forward = CoorHelper.GetCoordinateOrientation(magicFieldAction.forwardData, null, true);
                    var euler = Quaternion.LookRotation(forward).eulerAngles;
                    
                    var magicFieldCfg = TbUtil.GetCfg<MagicFieldCfg>(magicFieldID);
                    var shapeBoxInfo = magicFieldCfg.ShapeBoxInfo;
                    var root = TimelinePreviewTool.instance.GetDummy("");
                    if (root == null)
                        return;
                    shapeBox = new ShapeBox();
                    shapeBox.Init(shapeBoxInfo, new VirtualTrans(root), terminalPos: targetPos, terminalEuler: euler);
                    _shapeUseType = ShapeUseType.Magic;
                }
            }

            if (damageBoxAction != null)
            {
                var damageBoxId = damageBoxAction.boxId;
                var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxId);
                if (damageBoxCfg == null)
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("[PreviewShapeBoxAction] 渲染ShapeBox错误, DamageBox配置中不存在该Id: {0}", damageBoxId);
                    return;
                }
                var shapeBoxInfo = damageBoxCfg.ShapeBoxInfo;
                var offsetPos = damageBoxAction.offsetPos;
                var offsetAngle = damageBoxAction.offsetAngle;

                VirtualTrans? virtualTrans = null;
                if (damageBoxCfg.MountType == MountType.World || damageBoxCfg.MountType == MountType.CastingActorTrans)
                {
                    virtualTrans = new VirtualTrans(Vector3.zero, Quaternion.identity);
                }
                else
                {
                    var root = TimelinePreviewTool.instance.GetDummy(damageBoxCfg.DummyName);
                    if (root == null)
                    {
                        PapeGames.X3.LogProxy.LogErrorFormat("[PreviewShapeBoxAction] 渲染ShapeBox错误, 骨骼点路径不存在: {0}", damageBoxCfg.DummyName);
                    }
                    else
                    {
                        virtualTrans = new VirtualTrans(root);
                    }
                }

                if (virtualTrans == null)
                {
                    return;
                }
                
                shapeBox = new ShapeBox();
                shapeBox.Init(shapeBoxInfo, virtualTrans.Value, offsetPos, offsetAngle);
                _shapeUseType = ShapeUseType.AttackBox;
            }

            _shapeBox = shapeBox;
            _ShowShapeBox();
        }

        protected override void OnUpdate(float deltaTime)
        {
            _ShowShapeBox();
        }

        protected override void OnExit()
        {
            _HideShapeBox();
        }
        
        private void _ShowShapeBox()
        {
            if (_shapeBox == null)
                return;
            _shapeBox.Update();
            X3PhysicsDebug.Ins.autoRemove = false;
            X3PhysicsDebug.Ins.ShowShapeBox(_shapeBox, _shapeUseType);
        }

        private void _HideShapeBox()
        {
            if (_shapeBox == null)
                return;
            X3PhysicsDebug.Ins.HideShapeBox(_shapeBox, _shapeUseType);
            _shapeBox = null; 
        }
        
#endif
    }
}