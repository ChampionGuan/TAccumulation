using System;
using BattleCurveAnimator;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("播放材质动画")]
    [MessagePackObject]
    [Serializable]
    public class PlayMatAnim : BuffActionBase
    {
        [BuffLable("材质动画路径")]
        [Key(0)] public string matAnimPath;
        
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.PlayMatAnim;
        }
        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            if (string.IsNullOrEmpty(matAnimPath))
            {
                return;
            }
            if (_owner.actor.model.curveAnimator == null)
            {
                return;
            }
            
            // if (_owner.owner.MaterialPlayedRefCounts.TryGetValue(matAnimPath, out var refData))
            // {
            //     refData.RefCount += 1;
            // }
            // else
            // {
            //     refData = new matAnimPath();
            //     _owner.owner.MaterialPlayedRefCounts.Add(matAnimPath, 1);
            // }
            // _effectAsset = BattleResMgr.Instance.Load<CurveAnimAsset>(matAnimPath, BattleResType.MatCurveAsset);
            // _actor.model.curveAnimator.Play(_effectAsset);
            _owner.owner.MatAnimBegin(matAnimPath);
        }
        
        public override void OnDestroy()
        {
            if (string.IsNullOrEmpty(matAnimPath))
            {
                return;
            }
            if (_owner.actor.model.curveAnimator == null)
            {
                return;
            }
            _owner.owner.MatAnimEnd(matAnimPath);

            ObjectPoolUtility.PlayMatAnimPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.PlayMatAnimPool.Get();
            action.matAnimPath = matAnimPath;
            return action;
        }
    }
}