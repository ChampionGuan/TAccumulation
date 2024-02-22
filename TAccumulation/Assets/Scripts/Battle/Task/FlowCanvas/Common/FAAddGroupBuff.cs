using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("给对象组添加buff\nAddGroupBuff")]
    public class FAAddGroupBuff : FlowAction
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        public BBParameter<int> buffId = new BBParameter<int>();
        public BBParameter<int> buffLayer = new BBParameter<int>();
        public BBParameter<int> buffLevel = new BBParameter<int>();

        protected override void _Invoke()
        {
            var actorGroup = this._battle.actorMgr.GetActorGroup(groupId.GetValue());
            if (actorGroup == null)
            {
                _LogError($"[AddGroupBuff节点配置错误]: 找不到目标组, 参数为GroupId={groupId}");
                return;
            }

            for (int i = 0; i < actorGroup.actorIds.Count; i++)
            {
                var actorId = actorGroup.actorIds[i];
                var actor = this._battle.actorMgr.GetActor(actorId);
                if (actor == null)
                {
                    _LogError($"目标组存在空Actor, ActorId为{actorId}");
                    continue;
                }

                if (actor.buffOwner == null)
                {
                    continue;
                }
                
                int level = buffLevel.GetValue();
                if (level <= 0)
                {
                    var triggerLevel = (IGraphLevel) _context;
                    if (triggerLevel != null)
                    {
                        level = triggerLevel.level;
                    }
                }

                actor.buffOwner.Add(buffId.GetValue(), buffLayer.GetValue(), null, level, _actor);
            }
        }
    }
}
