using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("创建系数修正直接命中打击盒\nCastCoefficientDamageBox")]
    public class FACastCoefficientDamageBox : FlowAction
    {
        public BBParameter<int> damageBoxID = new BBParameter<int>();
        public BBParameter<float> damageMultiplier = new BBParameter<float>(1f);
        public BBParameter<HitParamRatioType> hitParamRatioType = new BBParameter<HitParamRatioType>(HitParamRatioType.AttackRatio);

        private ValueInput<HitInfo> _viHitInfo;
        private ValueInput<Actor> _viSourceActor;
        private ValueInput<DamageExporter> _viDamageExporter;
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viHitInfo = AddValueInput<HitInfo>("HitInfo");
            _viSourceActor = AddValueInput<Actor>("SourceActor");
            _viDamageExporter = AddValueInput<DamageExporter>(nameof(DamageExporter));
        }

        protected override void _Invoke()
        {
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
            {
                _LogError("请联系策划【蜗牛君】,【创建系数修正直接命中打击盒 CastCoefficientDamageBox】节点配置错误. 引脚【HitInfo】没有正确赋值.");
                return;
            }

            var target = _viSourceActor.GetValue();
            if (target == null)
            {
                _LogError("请联系策划【蜗牛君】,【创建系数修正直接命中打击盒 CastCoefficientDamageBox】节点配置错误. 引脚【SourceActor】没有正确赋值.");
                return;
            }

            var damageBoxId = damageBoxID.GetValue();
            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxId);
            if (damageBoxCfg == null)
            {
                _LogError("请联系策划【蜗牛君】,【创建系数修正直接命中打击盒 CastCoefficientDamageBox】节点配置错误. 配置得DamageBoxId不存在.");
                return;
            }

            // DONE: 强制将配置改为直接命中类型的, 策划约定强制修改.
            damageBoxCfg.CheckTargetType = CheckTargetType.Direct;
            damageBoxCfg.DirectSelectType = DirectSelectType.SpecifyTarget;
            
            DamageExporter damageExporter = _viDamageExporter?.GetValue() ?? _source as DamageExporter;

            if (damageExporter == null)
            {
                _LogError($"请联系策划【蜗牛君】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建系数修正直接命中打击盒 CastCoefficientDamageBox】, graph.name:{_graphOwner.gameObject.name}, boxId:{damageBoxId}");
                return;
            }

            var hitParamConfig = hitInfo.hitParamConfig;
            if (hitParamConfig == null)
            {
                _LogError($"请联系策划【蜗牛君】, 该蓝图非技能orBuff图, 请在正确的蓝图里使用这个节点【创建系数修正直接命中打击盒 CastCoefficientDamageBox】, graph.name:{_graphOwner.gameObject.name}, boxId:{damageBoxId}");
                return;
            }

            var hitParamRatio = BattleUtil.GetHitParamRatio(hitParamConfig, hitParamRatioType.GetValue());

            // DONE: 策划计算规则: 前一个伤害包围盒得伤害系数 * 策划该节点配置的系数 * HitParamConfig表里配置的系数.
            float damageProportion = hitInfo.damageProportion * damageMultiplier.GetValue() * hitParamRatio;
            
            LogProxy.LogFormat("【创建系数修正直接命中打击盒】HitInfo系数{0}, damageMultiplier系数{1}, hitParamRatio系数{2}, hitParam的唯一ID={3}, 继承图的level={4}, hitParamRatioType={5}", hitInfo.damageProportion, damageMultiplier.GetValue(), hitParamRatio, hitParamConfig.ID, _level, hitParamRatioType.GetValue());
            
            damageExporter.CastDamageBox(null, damageBoxCfg, target, _level, out _, null, null, damageProportion: damageProportion);
        }
    }
}
