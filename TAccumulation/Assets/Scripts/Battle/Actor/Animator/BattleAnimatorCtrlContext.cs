using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using X3.PlayableAnimator;
using X3;
using UnityEngine.Animations;

namespace X3Battle
{
    public class BattleAnimatorCtrlContext : AnimatorControllerContext
    {
        public static List<AnimatorController> m_AnimatorCtrls = new List<AnimatorController>();
        protected Dictionary<string, float> _modifyOffsetTime;

        public BattleAnimatorCtrlContext(Transform[] transforms, Transform[] newParents)
        {
            _modifyOffsetTime = new Dictionary<string, float>();
            this.transforms = transforms;
            this.newParents = newParents;
        }

        public static AnimatorController LoadAnimatorCtrl(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return null;
            }

            var ctrl = BattleResMgr.Instance.Load<AnimatorController>(name, BattleResType.RoleAnimatorController);
            m_AnimatorCtrls.Add(ctrl);
            return ctrl;
        }

        public static void UnloadAnimatorCtrl(AnimatorController ctrl)
        {
            if (null == ctrl)
            {
                return;
            }

            m_AnimatorCtrls.Remove(ctrl);
            BattleResMgr.Instance.Unload(ctrl);
        }

        public static void UnloadAllAnimatorCtrl()
        {
            for (var i = m_AnimatorCtrls.Count - 1; i >= 0; i--)
            {
                BattleResMgr.Instance.Unload(m_AnimatorCtrls[i]);
            }

            m_AnimatorCtrls.Clear();
        }

        public override void Reset()
        {
            _modifyOffsetTime.Clear();
        }

        public override Playable CreateClipPlayable(AnimationClip clip)
        {
            Playable clipPlayable = Playable.Null;

            if (AnimationClipWithIK.IsValid(clip))
            {
                clipPlayable = AnimationClipWithIK.CreatePlayable(m_Owner.unityAnimator, m_Owner.playableGraph, clip);
            }
            else if (WeaponSwitchAnimPlayer.IsWeaponSwitchAnimation(clip))
            {
                clipPlayable = WeaponSwitchAnimPlayer.CreateWeaponSwitchAnimPlayable(m_Owner.unityAnimator, m_Owner.playableGraph, clip);
            }

            return !clipPlayable.IsValid() ? base.CreateClipPlayable(clip) : clipPlayable;
        }

        public override BoneLayerMixer.BoneLayerMixerPlayable CreateBoneLayerMixerPlayable(PlayableGraph graph, int layersCount)
        {
            return BoneLayerMixer.BoneLayerMixerPlayable.Create(graph, transforms, newParents, layersCount);
        }

        public override void ModifyTransition(int layerIndex, string destStateName, float destStateLength, ref float fixedOffsetTime)
        {
            var offset = GetModifyOffsetTime(destStateName);
            if (offset != null)
                fixedOffsetTime = offset.Value * destStateLength;
        }

        public void AddModifyOffsetTime(string name, float offset)
        {
            _modifyOffsetTime[name] = offset;
        }

        public float? GetModifyOffsetTime(string name)
        {
            if (_modifyOffsetTime.ContainsKey(name))
                return _modifyOffsetTime[name];
            else
                return null;
        }

        public void RemoveModefyOffsetTime(string name)
        {
            if (_modifyOffsetTime.ContainsKey(name))
                _modifyOffsetTime.Remove(name);
        }
    }
}
