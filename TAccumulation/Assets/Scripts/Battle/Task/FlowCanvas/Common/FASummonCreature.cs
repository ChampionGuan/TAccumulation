using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("创建创生物\nSummonCreature")]
    public class FASummonCreature : FlowAction
    {
        public BBParameter<int> summonID = new BBParameter<int>();
        
        public bool isOverrideFaction = false;

        [ShowIf(nameof(isOverrideFaction), 1)]
        public BBParameter<FactionType> factionType = new BBParameter<FactionType>(FactionType.Neutral);

        [GatherPortsCallback]
        [Name("是否启用验证")]
        public bool enableValidation;
        
        public CoorPoint pointData = new CoorPoint();
        public CoorOrientation forwardData = new CoorOrientation();

        [ShowIf("enableValidation", 1)]
        public CoorPoint pointData2 = new CoorPoint();
        [ShowIf("enableValidation", 1)]
        public CoorOrientation forwardData2 = new CoorOrientation();

        private ValueInput<ISkill> _viSkill;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            this.DrawFlowNodePoint(pointData);
            this.DrawFlowNodeOrientation(forwardData);

            if (enableValidation)
            {
                this.DrawFlowNodePoint(pointData2, true);
                this.DrawFlowNodeOrientation(forwardData2, true);
            }
            
            _viSkill = AddValueInput<ISkill>(nameof(ISkill));
        }

        protected override void _OnGraphStart()
        {
            base._OnGraphStart();
            var skill = _viSkill?.GetValue() ?? _source as ISkill;
            if (skill == null)
            {
                return;
            }

            _battle.actorMgr.PreloadSummonCreature(skill, summonID.GetValue(), Vector3.zero, 0);
        }
        protected override void _Invoke()
        {
            var skill = _viSkill?.GetValue() ?? _source as ISkill;
            if (skill == null)
            {
                return;
            }
            
            CoorPoint coorPoint = pointData;
            CoorOrientation coorOrientation = forwardData;
            if (enableValidation)
            {
                if (!CoorHelper.IsValidCoorConfig(_actor, coorPoint, coorOrientation, false))
                {
                    coorPoint = pointData2;
                    coorOrientation = forwardData2;
                }
            }

            // DONE: 覆盖阵营逻辑.
            FactionType? faction = null;
            if (isOverrideFaction)
            {
                faction = factionType.GetValue();
            }
            _battle.SummonCreature(skill.actor, skill, summonID.GetValue(), faction, coorPoint, coorOrientation, false);
        }
    }
}
