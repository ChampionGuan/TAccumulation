using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/脱手动画骨骼覆盖")]
    [Serializable]
    public class OverwriteBoneAsset : BSActionAsset<ActionOverwriteBone>
    {
        [LabelText("覆盖动画clip")]
        public AnimationClip animClip;

        [LabelText("被覆盖动画名")]
        public List<SourceOverwriteAnim> prevStates;

        [LabelText("脱手帧(如果当前动画是换手动画才需配置)")]
        public float getOffHand;

        [LabelText("是否要播放武器消散效果")]
        public bool enableWeaponEffect = true;

        public string[] boneTranforms;

        public string[] newParents;
    }

    public class ActionOverwriteBone : BSAction<OverwriteBoneAsset>
    {
        private bool _showWeapon;
        private bool _enableOverwrite;
        private bool _enableNewParent;
        private List<Transform> _boneTranforms;
        private List<Transform> _newParents;

        protected override void _OnInit()
        {
            base._OnInit();
            _showWeapon = false;
            _enableOverwrite = false;
            _enableNewParent = false;
            context.actor.animator.AddOverwriteClip(clip.animClip);
            _boneTranforms = new List<Transform>();
            _newParents = new List<Transform>();

            if (clip.boneTranforms != null)
            {
                foreach (var bonePath in clip.boneTranforms)
                {
                    var bone = context.actor.GetDummy().Find(bonePath);
                    if (bone != null)
                        _boneTranforms.Add(bone);
                }
            }

            if (clip.newParents != null)
            {
                foreach (var parentPath in clip.newParents)
                {
                    var parent = context.actor.GetDummy().Find(parentPath);
                    if (parent != null)
                        _newParents.Add(parent);
                }
            }
            context.actor.animator.InitBoneOverwrite(_boneTranforms.ToArray(), _newParents.ToArray());
        }

        protected override void _OnEnter()
        {
            base._OnEnter();
            for(int i = 0; i < clip.prevStates.Count; i ++)
            {
                if (clip.prevStates[i].prevName == context.actor.animator.GetCurrentAnimatorStateInfo(0).name)
                {
                    var prevStateTime = context.actor.animator.GetCurrentAnimatorStateInfo(0).normalizedTime * context.actor.animator.GetCurrentAnimatorStateInfo(0).length;
                    if (prevStateTime / BattleConst.AnimFrameTime > clip.prevStates[i].range.x && prevStateTime / BattleConst.AnimFrameTime < clip.prevStates[i].range.y)
                    {
                        if(clip.enableWeaponEffect) 
                        {
                            context.actor.weapon.RequireCustomVisible(false, true);
                            _showWeapon = true;
                        }
                        
                        context.actor.animator.EnableOverwrite(clip.animClip.name, true);
                        _enableOverwrite = true;
                    }

                }
            }
        }

        protected override void _OnExit()
        {
            base._OnExit();
            context.actor.animator.EnableOverwrite(clip.animClip.name, false);
            context.actor.animator.EnableTransformToNewParent(false);
            context.actor.weapon.ReleaseCustomVisible(owner: GetHashCode());
            _showWeapon = false;
        }

        protected override void _OnUpdate()
        {
            base._OnUpdate();
            if (_showWeapon)
            {
                context.actor.weapon.RequireCustomVisible(true, owner:GetHashCode());
                _showWeapon = false;
            }
            if (context.actor.animator.GetBlendTick(0) <= 0 && _enableOverwrite)
            {
                context.actor.animator.EnableOverwrite(clip.animClip.name, false);
                context.actor.animator.EnableTransformToNewParent(false);
                _enableOverwrite = false;
                _enableNewParent = false;
                return;
            }

            if (track.curTime / BattleConst.AnimFrameTime > clip.getOffHand && !_enableNewParent)
            {
                context.actor.animator.EnableTransformToNewParent(true);
                _enableNewParent = true;
            }
        }
    }

    [Serializable]
    public class SourceOverwriteAnim
    {
        [LabelText("上一个动画名")]
        public string prevName;
        [LabelText("动画脱手区间")]
        public Vector2 range;   
    }
}
