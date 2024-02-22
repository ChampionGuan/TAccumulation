using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("隐藏模型（全部隐藏，包括血条特效，包括仅同步位置但不挂载在目标上的特效）")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionUnVisibility : BuffActionBase
    {
        // [BuffLable("骨骼特效是否可见")] [Key(0)] public bool rootBoneVisible;
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.UnVisibility;
        }

        public override void OnAdd(int layer)
        {
            var insID = _actor.insID;
            foreach (var fxID in _actor.buffOwner.fxPlayedRefCounts.Keys)
            {
                var fxPlayer = _actor.battle.fxMgr.GetFx(insID, fxID);
                if (fxPlayer != null)
                {
                    fxPlayer.PlayFade(FxPlayer.FadeType.FadeOut, 0);
                }
            }
            _actor.transform.SetVisible(false);
        }

        public override void OnDestroy()
        {
            var insID = _actor.insID;
            foreach (var fxID in _actor.buffOwner.fxPlayedRefCounts.Keys)
            {
                var fxPlayer = _actor.battle.fxMgr.GetFx(insID, fxID);
                if (fxPlayer != null)
                {
                    fxPlayer.PlayFade(FxPlayer.FadeType.FadeIn,0);
                }
            }
            _actor.transform.SetVisible(true);
            ObjectPoolUtility.BuffActionUnVisibilityPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionUnVisibilityPool.Get();
            return action;
        }
    }
}