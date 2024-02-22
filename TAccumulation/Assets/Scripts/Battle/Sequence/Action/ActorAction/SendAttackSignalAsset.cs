using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/向目标区域内的所有单位发送攻击信号")]
    [Serializable]
    public class SendAttackSignalAsset : BSActionAsset<ActionSendAttackSignal>
    {
        [LabelText("SignalKey", editorCondition: "false")]
        public string signalKey = "AttackWarning";

        [LabelText("形状数据")] 
        public ShapeInfo shapeInfo;
        
        [DrawCoorPoint("位置选点")]
        public CoorPoint coorPoint;

        [Header("阵营关系筛选")]
        public FactionRelationship[] factionRelationships = new FactionRelationship[] {FactionRelationship.Enemy};

        [LabelText("SignalValue")] public string signalValue = "";
    }

    public class ActionSendAttackSignal : BSAction<SendAttackSignalAsset>
    {
        private List<FactionRelationship> _relationships = new List<FactionRelationship>();

        private List<Actor> _reuseActors = new List<Actor>();

        protected override void _OnEnter()
        {
            var battle = context.battle;
            var actor = context.actor;
            
            // DONE: 阵营关系筛选List初始化.
            _relationships.Clear();
            if (clip.factionRelationships != null && clip.factionRelationships.Length > 0)
            {
                foreach (var factionRelationship in clip.factionRelationships)
                {
                    _relationships.Add(factionRelationship);
                }
            }
            else
            {
                _relationships.Add(FactionRelationship.Enemy);
            }

            Vector3 pos = clip.coorPoint.GetCoordinatePoint(actor, true);
            var shapeBoxInfo = new ShapeBoxInfo();
            shapeBoxInfo.ShapeInfo = clip.shapeInfo;
            shapeBoxInfo.ShapeInfo.SetDebugInfo("【Timeline/{0}/{1}/角色动作/向目标区域内的所有单位发送攻击信号】", this.track.sequencer.name, this.track.name);
            shapeBoxInfo.OffsetPos = Vector3.zero;
            shapeBoxInfo.OffsetEuler = Vector3.zero;
            shapeBoxInfo.ShapeBoxFollowMode = ShapeBoxFollowMode.None;
            var shapeBox = ObjectPoolUtility.ShapeBoxPool.Get();
            shapeBox.Init(shapeBoxInfo, null, null, null, pos, actor.transform.eulerAngles);
            shapeBox.Update();
            
            var targetPosition = shapeBox.GetCurWorldPos();
            var prevPosition = shapeBox.GetPrevWorldPos();
            var angleY = shapeBox.GetCurWorldEuler().y;
            var boundingShape = shapeBox.GetBoundingShape();

            ObjectPoolUtility.ShapeBoxPool.Release(shapeBox);
            shapeBox = null;

            var results = _reuseActors;
            BattleUtil.PickAOETargets(
                battle, 
                ref results,
                targetPosition,
                prevPosition,
                new Vector3(0f, angleY, 0f),
                boundingShape, // 这里的damageBoxConfig类型继承自BoundingShape，所以可以直接这样使用，不需要在创建新的shape，无GC
                actor,
                false,
                null,
                false, null, _relationships, false);

            if (results == null || results.Count <= 0)
            {
                return;
            }

            // DONE: 向筛选出来的目标们发送信号.
            foreach (Actor target in results)
            {
                if (target.signalOwner == null)
                {
                    continue;
                }

                target.signalOwner.Write(clip.signalKey, clip.signalValue, context.actor);
            }
        }  
    }
}