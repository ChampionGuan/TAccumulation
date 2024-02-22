using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("添加道具\nCreateItem")]
    public class FACreateItem : FlowAction
    {
        [Name("道具ID")]
        public int itemId;
        [Name("是否启用验证")]
        public bool enableValidation;
        public CoorPoint pointData = new CoorPoint();
        public CoorOrientation forwardData = new CoorOrientation();
        [ShowIf("enableValidation", 1)]
        public CoorPoint pointData2 = new CoorPoint();
        [ShowIf("enableValidation", 1)]
        public CoorOrientation forwardData2 = new CoorOrientation();
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
            _battle.actorMgr.PreloadItem(_actor, null, 1, itemId);
        }

        protected override void _Invoke()
        {
            int level = _level;
            CoorPoint coorPoint = pointData;
            CoorOrientation coorOrientation = forwardData;
            if (enableValidation)
            {
                if (!CoorHelper.IsValidCoorConfig(_actor, pointData, coorOrientation, false))
                {
                    coorPoint = pointData2;
                    coorOrientation = forwardData2;
                }
            }

            DamageExporter damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            _battle.CreateItem(_actor, damageExporter, level, itemId, coorPoint, coorOrientation, false);
        }
    }
}
