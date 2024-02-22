using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("增长召唤物生命周期\nExtendCreatureLifeTime")]
    public class FAExtendCreatureLifeTime : FlowAction
    {
        [GatherPortsCallback]
        public BBParameter<int> monsterTemplateId = new BBParameter<int>(0);
        public BBParameter<float> addLifeTime = new BBParameter<float>(0.1f);
        
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            if (monsterTemplateId.value <= 0)
            {
                _viSourceActor = AddValueInput<Actor>("SourceActor");   
            }
        }

        protected override void _Invoke()
        {
            var templateID = monsterTemplateId.GetValue();
            if (templateID > 0)
            {
                var actors = ObjectPoolUtility.CommonActorList.Get();
                _battle.actorMgr.GetActors(outResults: actors, cfgId: monsterTemplateId.GetValue());
                for (var i = 0; i < actors.Count; i++)
                {
                    var actor = actors[i];
                    if (!actor.IsCreature())
                    {
                        continue;
                    }
                    
                    var addValue = addLifeTime.GetValue();
                    actor.ModifyLifetime(addValue);
                }

                ObjectPoolUtility.CommonActorList.Release(actors);
            }
            else
            {
                var actor = _viSourceActor?.GetValue();
                if (actor == null)
                {
                    _LogError("请联系策划【卡宝】,【增长召唤物生命周期 ExtendCreatureLifeTime】节点配置错误. 引脚[SourceActor]没有赋值.");
                    return;
                }

                if (!actor.IsCreature())
                {
                    _LogError($"请联系策划【卡宝】,【增长召唤物生命周期 ExtendCreatureLifeTime】节点配置错误. 引脚[SourceActor]不是创生物 name={actor.name}.");
                    return;
                }

                var addValue = addLifeTime.GetValue();
                actor.ModifyLifetime(addValue);
            }
        }
    }
}
