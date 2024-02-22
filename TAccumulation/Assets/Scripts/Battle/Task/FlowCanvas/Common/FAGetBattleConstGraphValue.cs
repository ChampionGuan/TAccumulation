using System;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取配置在表中的常量信息\nGetBattleConstGraphValue")]
    public class FAGetBattleConstGraphValue: FlowAction
    {
        public enum ConstGrapValue
        {
            None = 0,
            GirlDodgeWeight = 1,
            QTEprobability = 2,
            BoyActiveprobability = 3,
            GirlActiveprobability = 4,
            GirlCooprobability = 5,
            ActiveMaxCount = 6,
            ActiveCDTimer = 7
        }
        
        private ValueInput<ConstGrapValue> _keyInput;

        protected override void _OnRegisterPorts()
        {
            _keyInput = AddValueInput<ConstGrapValue>("key");
            AddValueOutput<float>("value", _GetConstGraphValue);
        }

        private float _GetConstGraphValue()
        {
            switch (_keyInput.value)
            {
                case ConstGrapValue.None:
                    _LogError($"未指定枚举参数！");
                    break;
                case ConstGrapValue.GirlDodgeWeight:
                    return TbUtil.battleConsts.Girl_DodgeWeight;
                case ConstGrapValue.QTEprobability:
                    return TbUtil.battleConsts.QTEprobability;
                case ConstGrapValue.BoyActiveprobability:
                    return TbUtil.battleConsts.BoyActiveprobability;
                case ConstGrapValue.GirlActiveprobability:
                    return TbUtil.battleConsts.GirlActiveprobability;
                case ConstGrapValue.GirlCooprobability:
                    return TbUtil.battleConsts.GirlCooprobability;
                case ConstGrapValue.ActiveMaxCount:
                    return TbUtil.battleConsts.ActiveMaxCount;
                case ConstGrapValue.ActiveCDTimer:
                    return TbUtil.battleConsts.ActiveCDTimer;
                default:
                    _LogError($"错误的枚举参数 {_keyInput.value}");
                    return 0f;
            }

            return 0f;
        }
    }
}
