using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("显示隐藏特效\nPlayFX")]
    public class FAShowHideEffect : FlowAction
    {
        public enum StagePointType
        {
            Point = 0,
            Trigger = 1,
        }
        
        public BBParameter<bool> isShow = new BBParameter<bool>();
        public BBParameter<bool> isStopAndClear = new BBParameter<bool>(false);
        public BBParameter<int> sfxId = new BBParameter<int>();

        public StagePointType stagePointType = 0;
        [ShowIf(nameof(stagePointType), 0)]
        [Name("SpawnID")]
        public BBParameter<int> pointId = new BBParameter<int>();
        
        [ShowIf(nameof(stagePointType), 1)]
        public BBParameter<int> triggerId = new BBParameter<int>();

        protected override void _Invoke()
        {
            var configId = sfxId.GetValue();
            int? spawnId = null;
            Vector3? position = null;
            Vector3? rotation = null;
            if (stagePointType == StagePointType.Point)
            {
                spawnId = this.pointId.GetValue();
                if (spawnId > 0)
                {
                    var point = Battle.Instance.actorMgr.GetPointConfig(spawnId.Value);
                    if (point == null)
                    {
                        _LogError($"【策划配置错误】【关卡节点】显示隐藏特效 spawnId={spawnId}配置错误.");
                        return;
                    }

                    position = point.Position;
                    rotation = point.Rotation;
                }
            }
            else
            {
                spawnId = triggerId.GetValue();

                if (spawnId > 0)
                {
                    var trigger = Battle.Instance.actorMgr.GetTriggerAreaConfig(spawnId.Value);
                    if (trigger == null)
                    {
                        _LogError($"【策划配置错误】【关卡节点】显示隐藏特效 triggerId={spawnId}配置错误.");
                        return;
                    }

                    position = trigger.Position;
                    rotation = trigger.Rotation;
                }
            }

            if (isShow.GetValue())
            {
                if (spawnId > 0)
                {
                    var insID = _battle.actorMgr.GetActorInsID(spawnId.Value);
                    Battle.Instance.fxMgr.PlayBattleFx(configId, insID, offsetPos: position, angle: rotation);
                }
                else
                {
                    Battle.Instance.fxMgr.PlayBattleFx(configId);
                }
            }
            else
            {
                if (spawnId > 0)
                {
                    var insID = _battle.actorMgr.GetActorInsID(spawnId.Value);
                    Battle.Instance.fxMgr.StopFx(configId, insID, isStopAndClear.GetValue());
                }
                else
                {
                    Battle.Instance.fxMgr.StopFx(configId, 0, isStopAndClear.GetValue());
                }
            }
        }
    }
}
