using FlowCanvas;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("获得单位血量百分比\nGetHpPercent")]
    public class FAGetHpPercent : FlowAction
    {
        private ValueInput<Actor> _viSourceActor;
        
        protected override void _OnRegisterPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
            AddValueOutput<float>("HPPercent", _GetHpPercent);
        }

        private float _GetHpPercent()
        {
            float result = -1;
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError("请联系策划【卡宝】,【获得单位血量百分比 GetHpPercent】SourceActor不允许为空. 返回错误-1");
                return result;
            }

            if (sourceActor.attributeOwner == null)
            {
                _LogError("请联系策划【卡宝】,【获得单位血量百分比 GetHpPercent】SourceActor身上没有AttributeOwner组件. 返回错误-1");
                return result;
            }

            var curHpAttr = sourceActor.attributeOwner.GetAttr(AttrType.HP);
            if (curHpAttr == null)
            {
                _LogError("请联系策划【卡宝】,【获得单位血量百分比 GetHpPercent】SourceActor身上AttributeOwner组件没有Hp属性. 返回错误-1");
                return result;
            }
            
            var maxHpAttr = sourceActor.attributeOwner.GetAttr(AttrType.MaxHP);
            if (maxHpAttr == null)
            {
                _LogError("请联系策划【卡宝】,【获得单位血量百分比 GetHpPercent】SourceActor身上AttributeOwner组件没有MaxHp属性. 返回错误-1");
                return result;
            }
            
            var curHp = curHpAttr.GetValue();
            var maxHp = maxHpAttr.GetValue();

            if (maxHp <= 0f)
            {
                _LogError("请联系策划【卡宝】,【获得单位血量百分比 GetHpPercent】SourceActor身上AttributeOwner组件的MaxHp属性<=0f, 除法错误. 返回错误-1");
                return result;
            }

            return curHp / maxHp;
        } 
    }
}
