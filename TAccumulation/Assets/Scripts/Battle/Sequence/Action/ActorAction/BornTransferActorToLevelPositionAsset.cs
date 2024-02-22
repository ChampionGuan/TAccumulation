using System;
using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/出生将Actor传送至关卡位置")]
    [Serializable]
    public class BornTransferActorToLevelPositionAsset : BSActionAsset<ActionBornTransferActorToLevelPosition>
    {
        public enum TransferTargetType
        {
            Girl,
            Boy,
        }

        [Serializable]
        public class TransferConfig
        {
            [LabelText("目标枚举")]
            public TransferTargetType targetType;
            [LabelText("传送至关卡目标坐标ID")]
            public int pointID;
        }
        
        [LabelText("传送配置")] 
        public List<TransferConfig> configs = new List<TransferConfig>();
    }
    
    public class ActionBornTransferActorToLevelPosition : BSAction<BornTransferActorToLevelPositionAsset>
    {
        protected override void _OnEnter()
        {
            if (context.actor.bornCfg.ControlBornPerform)
            {
                foreach (var transferConfig in clip.configs)
                {
                    var target = _GetActorByTransferTargetType(transferConfig.targetType);
                    Battle.Instance.actorMgr.TransferActor(target, transferConfig.pointID);
                }
            }
        }

        private static Actor _GetActorByTransferTargetType(BornTransferActorToLevelPositionAsset.TransferTargetType targetType)
        {
            switch (targetType)
            {
                case BornTransferActorToLevelPositionAsset.TransferTargetType.Girl:
                    return Battle.Instance.actorMgr.girl;
                case BornTransferActorToLevelPositionAsset.TransferTargetType.Boy:
                    return Battle.Instance.actorMgr.boy;
            }

            return null;
        }
    }
}