using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("创建法术场\nFACreateMagicField")]
    public class FACreateMagicField : FlowAction
    {
        public BBParameter<int> magicFieldID = new BBParameter<int>();

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

        public CreateMagicFieldParam CreateMagicFieldParam = new CreateMagicFieldParam();
        
        private ValueInput<DamageExporter> _viDamageExporter;

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
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }
        
        protected override void _OnGraphStart()
        {
            base._OnGraphStart();
            
            var damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            { 
                _LogError($"请联系策划【路浩】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建法术场 FACreateMagicField】, graph.name:{_graphOwner.gameObject.name}");
                return;  
            }
            
            _battle.actorMgr.PreloadSummonMagicField(damageExporter, magicFieldID.GetValue(), Vector3.zero, Vector3.zero);
        }

        protected override void _Invoke()
        {
            var damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            { 
                _LogError($"请联系策划【路浩】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建法术场 FACreateMagicField】, graph.name:{_graphOwner.gameObject.name}");
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

            _battle.CreateMagicField(_actor, damageExporter, magicFieldID.GetValue(), coorPoint, coorOrientation, false, CreateMagicFieldParam, factionType: faction);
        }
    }
}
