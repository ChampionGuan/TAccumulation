using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("创建子弹\nCreateMissile")]
    public class FACreateMissile : FlowAction
    {
        public CreateMissileParam param = new CreateMissileParam();
        private ValueInput<DamageExporter> _viDamageExporter;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            
            if(param.StartPos == null)
                param.StartPos = new CoorPoint();
            if(param.StartForward == null)
                param.StartForward = new CoorOrientation();
            
            this.DrawFlowNodePoint(param.StartPos);   
            this.DrawFlowNodeOrientation(param.StartForward);
            
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }

        protected override void _OnGraphStart()
        {
            base._OnGraphStart();

            var damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            {
                _LogError($"请联系策划【卡宝】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建子弹 CreateMissile】, graph.name:{_graphOwner.gameObject.name}, missileID:{param.missileID}");
                return;
            }
            
            param.IsTargetType = false;
            _battle.actorMgr.PreloadMissile(damageExporter, param);
        }

        protected override void _Invoke()
        {
            var damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;
            if (damageExporter == null)
            {
                _LogError($"请联系策划【卡宝】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建子弹 CreateMissile】, graph.name:{_graphOwner.gameObject.name}, missileID:{param.missileID}");
                return;
            }

            param.IsTargetType = false;
            _battle.actorMgr.CreateMissile(damageExporter, param);
        }
    }
}
