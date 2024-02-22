using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("计算Actor身上的Debuff层数\nFAGetActorTotalDebuffLayer")]
    public class FAGetActorTotalDebuffLayer : FlowAction
    {
        private ValueInput<Actor> _targetActor;
        
        protected override void _OnRegisterPorts()
        {
            _targetActor = AddValueInput<Actor>(nameof(Actor));
            AddValueOutput("Debuff总层数", _GetBuffLayer);
        }
        
        private int _GetBuffLayer()
        {
            var actor = _targetActor?.GetValue();
            if (actor == null)
            {
                _LogError("获取Buff层数节点，传入的Actor为空！请联系【楚门】");
                return 0;
            }

            var allBuffs = actor.buffOwner?.GetBuffs();
            if (allBuffs != null && allBuffs.Count > 0)
            {
                var totalLayer = 0;
                foreach (var buff in allBuffs)
                {
                    if (buff.config.BuffTag == BuffTag.Debuff)
                    {
                        totalLayer += buff.layer;
                    }
                }
                return totalLayer;
            }
            else
            {
                return 0;
            }
        }
    }
}