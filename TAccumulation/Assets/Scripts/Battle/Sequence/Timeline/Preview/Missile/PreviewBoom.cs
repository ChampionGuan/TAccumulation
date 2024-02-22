using System;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 预览爆炸特效
    /// </summary>
    [ExecuteInEditMode]
    public class PreviewBoom : MonoBehaviour
    {
        private FxPlayer _fxPlayer;//爆炸特效
        private float _time;
        private ShapeBox _shapeBox = null;//爆炸打击盒
        private ShapeUseType _shapeUseType = ShapeUseType.AttackBox;

        public void Init(FxPlayer fxPlayer, int damageBox)
        {
            _fxPlayer = fxPlayer;
            _time = 0;

            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBox);
            if (damageBoxCfg == null)
            {
                return;
            }

            _shapeBox = new ShapeBox();
            _shapeBox.Init(damageBoxCfg.ShapeBoxInfo, new VirtualTrans(_fxPlayer.transform));
        }

        public void Update()
        {
            if (_fxPlayer != null)
            {
                _time += Time.deltaTime;
                _fxPlayer.SetPlayTime(_time);
            }

            if (_fxPlayer.IsDestroy)
            {
                _HideShapeBox();
            }
            else
            {
                _ShowShapeBox();
            }
        }

        public void OnDestroy()
        {
            _HideShapeBox();
        }

        private void _ShowShapeBox()
        {
            if (_shapeBox == null)
                return;
            _shapeBox.Update();
            X3PhysicsDebug.Ins.autoRemove = false;
            if (X3PhysicsDebug.Ins.ShapeCfgs != null && !X3PhysicsDebug.Ins.ShapeCfgs[_shapeUseType].isClose)
            {
                X3PhysicsDebug.Ins.ShowShapeBox(_shapeBox, _shapeUseType);
            }
        }
    
        private void _HideShapeBox()
        {
            if (_shapeBox == null)
                return;
            X3PhysicsDebug.Ins.HideShapeBox(_shapeBox, _shapeUseType);
            _shapeBox = null; 
        }
    }
}