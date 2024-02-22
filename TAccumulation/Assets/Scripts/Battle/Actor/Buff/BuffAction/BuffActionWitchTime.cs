using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("开启魔女时间")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionWitchTime : BuffActionBase
    {
        [BuffLable("否先清除所有单位的魔女时间")]
        [Key(0)]
        public bool isRestoreActorsScale = true;

        [BuffLable("是否使用默认缩放倍率")]
        [Key(1)]
        [Tooltip("如果为true，值见BattleConst.ActorDefaultWitchScale")]
        public bool isUseDefaultScale = true;

        [BuffLable("缩放倍率")]
        [Key(2)]
        public float scale = 1;
        
        [BuffLable("下方所选单位是否为排除")]
        [Tooltip("勾选则为排除，表示不进入魔女时间")]
        [Key(3)]
        public bool isExclusion = true;
        
        [BuffLable("所选单位列表")] 
        [Key(4)]
        public List<WitchTimeIncludeData> excludeDatas;

        [BuffLable("暂停音频播放")] 
        [Key(5)]
        public bool isEnableSound = true;
        
        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionWitchTimePool.Get();
            action.isRestoreActorsScale = isRestoreActorsScale;
            action.isUseDefaultScale = isUseDefaultScale;
            action.scale = scale;
            action.isExclusion = isExclusion;
            action.isEnableSound = isEnableSound;
            action.excludeDatas = excludeDatas;
            return action;
        }

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.WitchTime;
        }

        public override void OnAdd(int layer)
        {
            var scaleParm = isUseDefaultScale ? TbUtil.battleConsts.ActorDefaultWitchScale : scale;
            _actor.battle.SetActorsWitchTime(_actor, isRestoreActorsScale, isExclusion, excludeDatas, scaleParm, -1, isEnableSound);
        }

        public override void OnDestroy()
        {
            //TODO,等策划确认冲突关系后处理。
            _actor.battle.ClearActorsWitchTime();
            base.OnDestroy();
            ObjectPoolUtility.BuffActionWitchTimePool.Release(this);
        }
    }
}