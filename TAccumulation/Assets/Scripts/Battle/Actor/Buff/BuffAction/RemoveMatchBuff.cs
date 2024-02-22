using System;
using MessagePack;
using PapeGames.X3;

namespace X3Battle
{
    [BuffAction("移除指定类型的buff")]
    [MessagePackObject]
    [Serializable]
    public class RemoveMatchBuff : BuffActionBase,IBuffAddSection
    {
        [BuffLable("buff类别1")] [Key(0)] public BuffTag buffTypeTag = BuffTag.Buff;
        [BuffLable("无视类别1")] [Key(1)] public bool ignoreBuffTag = false;
        [BuffLable("buff类别2")] [Key(2)] public BuffType buffType = BuffType.Attribute;
        [BuffLable("无视类别2")] [Key(3)] public bool ignoreBuffType = false;
        [BuffLable("buff类别3")] [Key(4)] public int buffMultipleTags = 0;
        [BuffLable("无视类别3")] [Key(5)] public bool ignoreBuffMultipleTags = true;
        [BuffLable("状态标签")] [Key(6)] public int buffConflictTag = 0;
        [BuffLable("是否持续生效")] [Key(7)] public bool isContinueEffect = false;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.RemoveMatchBuff;
        }

        public override void OnAdd(int layer)
        {
            _actor.buffOwner.RemoveAllMatchBuff(buffType, buffTypeTag, buffMultipleTags, buffConflictTag, ignoreBuffType,
                ignoreBuffTag, ignoreBuffMultipleTags);
            if (isContinueEffect)
            {
                _actor.buffOwner.AddBuffAddSection(this);
            }
        }

        public override void OnDestroy()
        {
            if (isContinueEffect)
            {
                _actor.buffOwner.RemoveBuffAddSection(this);
            }
            ObjectPoolUtility.BuffActionRemoveMatchBuffPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionRemoveMatchBuffPool.Get();
            action.buffTypeTag = buffTypeTag;
            action.ignoreBuffTag = ignoreBuffTag;
            action.buffType = buffType;
            action.ignoreBuffType = ignoreBuffType;
            action.buffMultipleTags = buffMultipleTags;
            action.ignoreBuffMultipleTags = ignoreBuffMultipleTags;
            action.buffConflictTag = buffConflictTag;
            action.isContinueEffect = isContinueEffect;
            return action;
        }

        public override void OnReset()
        {
            _actor.buffOwner.RemoveAllMatchBuff(buffType, buffTypeTag, buffMultipleTags, buffConflictTag, ignoreBuffType,
                ignoreBuffTag, ignoreBuffMultipleTags);
        }

        public bool InterceptBuffAdd(BuffCfg config)
        {
            if ((ignoreBuffType || config.BuffType == buffType) &&
                (ignoreBuffTag || config.BuffTag == buffTypeTag) &&
                (ignoreBuffMultipleTags || (config.BuffMultipleTags != null &&
                                            config.BuffMultipleTags.Contains(buffMultipleTags))))
            {
                if (buffConflictTag == 0 || buffConflictTag == config.BuffConflictTag)
                {
                    LogProxy.Log($"RemoveMatchBuff :{_owner.ID} 阻止了buff: {config.ID} 的添加");
                    return true;
                }
            }
            return false;
        }
    }
}