using System;
using MessagePack;

namespace X3Battle
{
    [BuffAction("播放指定特效,(不在buff的管理下，播放无限时长的特效会停不下来)")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionPlayFx : BuffActionBase
    {
        [BuffLable("指定的特效ID")] [Key(0)]  public int fxID = 0;
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.PlayFx;
        }

        public override void OnAdd(int layer)
        {
            _actor.effectPlayer.PlayFx(fxID, creator: _owner.caster,isOnly:true);
        }
        
        public override void OnAddRepeatedly(int layer)
        {
            _actor.effectPlayer.PlayFx(fxID, creator: _owner.caster,isOnly:true);
        }

        public override void OnDestroy()
        {
            ObjectPoolUtility.BuffActionPlayFxPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionPlayFxPool.Get();
            action.fxID = fxID;
            return action;
        }

        public override void OnReset()
        {
            _actor.effectPlayer.PlayFx(fxID, creator: _owner.caster,isOnly:true);
        }
    }
}