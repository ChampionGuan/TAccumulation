using System;
using MessagePack;

namespace X3Battle
{
    [BuffAction("播放PPV")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionPlayPPV: BuffActionBase
    {
        [Key(0)]
        public string path;
        [Key(1)]
        public PlayPPVAsset.StopType stopType = PlayPPVAsset.StopType.EnterPlay;
        [Key(2)]
        public bool isStopAndClear = false;
        [Key(3)]
        public float time = 1f;
        public override BuffActionBase DeepCopy() 
        {
            var action = ObjectPoolUtility.BuffActionPlayPPVPool.Get();
            action.path = path;
            action.stopType = stopType;
            action.isStopAndClear = isStopAndClear;
            action.time = time;
            return action;
        }

        public override void OnAdd(int layer)
        {
            if (string.IsNullOrEmpty(path))
                return;

            if (stopType == PlayPPVAsset.StopType.EnterPlay ||
                stopType == PlayPPVAsset.StopType.ClipDutaion)
                _actor.battle.ppvMgr.Play(path);
            else if (stopType == PlayPPVAsset.StopType.PeriodTime)
                _actor.battle.ppvMgr.Play(path, time);
            else if (stopType == PlayPPVAsset.StopType.EnterStop)
                _actor.battle.ppvMgr.Stop(path, isStopAndClear);
        }

        public override void OnDestroy()
        {
            if (stopType == PlayPPVAsset.StopType.ClipDutaion)
                _actor.battle.ppvMgr.Stop(path, isStopAndClear);
        }
    }
}

