using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("隐身")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionGhost:BuffActionBase
    {
        [NonSerialized]
        protected PapeGames.Rendering.RendererAttModifier _actroRenderttr;
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.Ghost;
        }
        
        public override void OnAdd(int layer)
        {
            //TODO 临时逻辑: 由于曲线动画的转换尚未完成 存在BattleEffect无法使用 所以先如此写死
            var model = _actor.GetDummy(ActorDummyType.Model);
            if (model == null)
                return;
            _actroRenderttr = _actor.EnsureComponent<PapeGames.Rendering.RendererAttModifier>(model.gameObject);
            if (_actroRenderttr == null)
                return;

            _actroRenderttr.Ghost = true;
            _actroRenderttr.GhostAlpha = 0.5f;
        }

        public override void OnDestroy()
        {
            if (_actroRenderttr == null)
                return;

            _actroRenderttr.Ghost = false;
            _actroRenderttr.GhostAlpha = 1f;
            ObjectPoolUtility.BuffActionGhostPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionGhostPool.Get();
            return action;
        }
    }
}


