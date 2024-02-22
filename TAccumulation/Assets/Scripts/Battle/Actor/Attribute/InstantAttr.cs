using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class InstantAttr : Attribute
    {
        private AttrType _maxAttrType;

        public override void Init(AttributeOwner attrOwner, AttrType type, float basic = 0, float minValue = 0)
        {
            base.Init(attrOwner, type, basic, minValue);
            //本属性最大值对应的属性
            _maxAttrType = AttrUtil.GetMaxValueType(type);
        }

        public float GetMaxValue()
        {
            return _attrOwner.GetAttrValue(_maxAttrType);
        }
        
        public override float CalculateAddedValue(float percent, float additional)
        {
            float finalValue = base.CalculateAddedValue(percent, additional); 
            if (_maxAttrType != AttrType.None)
            {
                // 如果该属性存在最大值, 则增加后结果不大于最大值
                float maxValue = _attrOwner.GetAttrValue(_maxAttrType);
                finalValue = Mathf.Min(finalValue, maxValue);
            }

            return finalValue;
        }
        
        public override float GetRawValue()
        {
            return _basic;
        }

        public override float GetValue()
        {
            float value = AttributeOwner.ExecuteModify(_listModifier, _basic, this);
            if (_maxAttrType != AttrType.None)
            {
                // 如果该属性存在最大值, 则增加后结果不大于最大值
                float maxValue = _attrOwner.GetAttrValue(_maxAttrType);
                return Mathf.Min(value, maxValue);
            }
            return value;
        }

        public override void Add(float additional, float percent, float basic)
        {
            float oldValue = GetRawValue();
            _basic += basic;
            _basic *= (1 + percent);
            _basic += additional;
            _basic = Mathf.Max(_minValue, _basic);
         
            if (_maxAttrType != AttrType.None)
            {
                // 如果该属性存在最大值, 则增加后结果不大于最大值
                float maxValue = _attrOwner.GetAttrValue(_maxAttrType);
                _basic = Mathf.Min(_basic, maxValue);
            }
            _OnValueChange(oldValue,GetRawValue());
        }
        private void _Sub(float additional, float percent, float basic)
        {
            _basic *= (1f - percent);
            _basic -= additional;
            _basic -= basic;
            _basic = Mathf.Max(_minValue, _basic);
        }

        public override void Sub(float additional, float percent, float basic)
        {
            float oldValue = GetRawValue();
            _Sub(additional,percent,basic);
            _OnValueChange(oldValue,GetRawValue());
        }
        
        public void Sub(float additional, float percent, float basic, bool hasLimit, float min)
        {
            float oldValue = GetRawValue();
            _Sub(additional,percent,basic);
            if (hasLimit) _basic = Mathf.Max(min, _basic);
            _OnValueChange(oldValue,GetRawValue());
        }

        public override void Set(float targetValue)
        {
            float oldValue = GetRawValue();
            _basic = Mathf.Max(_minValue, targetValue);
            _OnValueChange(oldValue,GetRawValue());
        }

        public override void SetPercent(float percent)
        {
            float oldValue = GetRawValue();
            _basic = Mathf.Max(_minValue, _basic * percent);
            _OnValueChange(oldValue,GetRawValue());
        }
        
        public override void SetByDebugEditor(float value)
        {
            float oldValue = GetRawValue();
            _basic = value;
            _OnValueChange(oldValue,GetRawValue());
        }
    }
}
