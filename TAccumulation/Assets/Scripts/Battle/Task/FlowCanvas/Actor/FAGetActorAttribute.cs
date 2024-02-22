using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("属性值获取\nGetActorAttribute")]
    public class FAGetActorAttribute : FlowAction
    {
        private ValueInput<Actor> _viSourceActor;
        public BBParameter<int> _attrType;
        
        protected override void _OnRegisterPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
            AddValueOutput<float>("Value", _GetAttribute);
        }

        private float _GetAttribute()
        {
            float result = -1;
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null || sourceActor.attributeOwner == null)
            {
                _LogError("FAGetActorAttribute, SourceActor不允许为空. 返回错误-1");
                return result;
            }

            AttrType type = (AttrType)_attrType.GetValue();
            return sourceActor.attributeOwner.GetAttrValue(type);
        } 
    }
}
