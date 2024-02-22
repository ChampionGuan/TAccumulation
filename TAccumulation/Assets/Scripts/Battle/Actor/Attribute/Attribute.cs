using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{

    public class Attribute:IReset
    {
        protected AttrType _type;
        protected float _basic;
        protected float _minValue;
        protected float _percent;
        protected float _additional;
        protected bool _isLock;
        protected float _lockPercent;
        protected AttributeOwner _attrOwner;
        protected List<IAttrModifier> _listModifier = new List<IAttrModifier>(1);
        private int _inheritPerthousand;//属性继承千分比

        protected List<Attribute> _inheritSummonAttributes = new List<Attribute>();

        private Attribute _masterAttribute = null;

        public virtual void Init(AttributeOwner attrOwner, AttrType type, float basic = 0, float minValue = 0)
        {
            _attrOwner = attrOwner;
            _type = type;
            _basic = basic;
            _percent = 0;
            _additional = 0;
            _isLock = false;
            _lockPercent = 0;
            _minValue = minValue;
        }

        public void AddModifier(IAttrModifier modifier)
        {
            _listModifier.Add(modifier);
        }

        public void RegisterInheritSummonAttr(Attribute summonAttribute,int inheritPerthousand)
        {
            if (summonAttribute == this)
            {
                LogProxy.LogError($"属性注册继承自己！！！ {_type} ");
                return;
            }

            if (!_inheritSummonAttributes.Contains(summonAttribute))
            { 
                _inheritSummonAttributes.Add(summonAttribute);
            }
            summonAttribute._inheritPerthousand = inheritPerthousand;
            summonAttribute._masterAttribute = this;
            //注册的时候赋初值
            summonAttribute._basic = GetValue() * inheritPerthousand * 0.001f;
        }
        
        public void OnDead()
        {
            if (_masterAttribute == null)
            {
                return;
            }
            if (_masterAttribute._inheritSummonAttributes.Remove(this))
            {
                LogProxy.LogError($"出现实时继承属性反注册失败，{_type} ");
            }
        }

        public void RemoveModifier(IAttrModifier modifier)
        {
            _listModifier.Remove(modifier);
        }
        
        public virtual AttrType GetAttrType()
        {
            return _type;
        }

        /// <summary>
        /// 计算加成后的属性.(目前：伤害公式里有用到.)
        /// </summary>
        /// <param name="percent"> 系数加成 </param>
        /// <param name="additional"> 加区加成 </param>
        /// <returns></returns>
        public virtual float CalculateAddedValue(float percent, float additional)
        {
            float tempPercent = _percent + percent;
            float tempAdditional = _additional + additional;
            float finalValue = _basic * (1 + tempPercent) + tempAdditional;
            finalValue = Mathf.Max(_minValue, finalValue);
            return finalValue;
        }

        public virtual float GetRawValue()
        {
            return _basic * (1 + _percent) + _additional;
        }

        public virtual float GetValue()
        {
            float value = AttributeOwner.ExecuteModify(_listModifier, GetRawValue(), this);
            return Mathf.Max(_minValue, value);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="additional"></param> 增加值
        /// <param name="percent"></param> 增加比例
        /// <param name="basic"></param> 增加基础值
        public virtual void Add(float additional, float percent, float basic = 0f)
        {
            float oldValue = GetRawValue();
            _additional += additional;
            _percent += percent;
            _basic += basic;
            _OnValueChange(oldValue,GetRawValue());
        }

        public virtual void Sub(float additional, float percent, float basic = 0f)
        {
            float oldValue = GetRawValue();
            _percent -= percent;
            _additional -= additional;
            _basic -= basic;
            _OnValueChange(oldValue,GetRawValue());
        }

        public virtual void SetPercent(float value)
        {
        }

        public virtual void AddPercent(float f)
        {
            Add(0, f);
        }
        
        public void SubPercent(float f)
        {
            Sub(0, f);
        }

        public (bool, float) GetLock()
        {
            return (_isLock, _lockPercent);
        }

        public void SetLock(bool b, float f)
        {
            _isLock = b;
            _lockPercent = f;
        }

        public virtual void Set(float value)
        {
            float oldValue = GetRawValue();
            _basic = value;
            _OnValueChange(oldValue,GetRawValue());
        }

        //调试器修改一个值，但是常规属性有3个值，百分比值会出问题,目前先反算后给出个能得到最终值的值
        public virtual void SetByDebugEditor(float value)
        {
            float oldValue = GetRawValue();
            if (_percent != -1f)
            {
                _basic = (value - _additional) / (1 + _percent);
            }
            _OnValueChange(oldValue,GetRawValue());
        }

        public void SetMinValue(float value)
        {
            _minValue = value;
            // _OnValueChange();
        }

        protected void _OnValueChange(float oldValue,float newValue)
        {
            _attrOwner.OnAttrChanged(this,oldValue,newValue);
            //创生物属性继承
            foreach (var summonAttr in _inheritSummonAttributes)
            {
                //异常情况
                if (summonAttr._masterAttribute != this)
                {
                    LogProxy.LogError($"实时继承属性异常！子属性监听多个夫属性 {_attrOwner.actor} attrType {_type}");
                }                                                                                             
                //子类也算属性变化，会发属性变化事件
                summonAttr.Set(newValue * summonAttr._inheritPerthousand * 0.001f);
            }
        }

        public void Reset()
        {
            _listModifier.Clear();
            _inheritSummonAttributes.Clear();
            _inheritPerthousand = 0;
        }
    }
}
