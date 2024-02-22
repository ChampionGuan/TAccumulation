using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("杀死NPC Group\nKillNPCGroup")]
    public class FAKillNPCGroup : FlowAction
    {
        public BBParameter<int> targetGroupId = new BBParameter<int>();

        private List<Actor> _tempList = new List<Actor>(5);

        protected override void _Invoke()
        {
            var actorGroup = _battle.actorMgr.GetActorGroup(targetGroupId.GetValue());
            if (actorGroup == null)
            {
                _LogError($"【关卡】【杀死NPC Group】节点配置错误. targetGroupId={targetGroupId.GetValue()}");
                return;
            }

			_tempList.Clear();
			
            // DONE: 击杀该组所有的Actor.
            foreach (var actorId in actorGroup.actorIds)
            {
                var actor = _battle.actorMgr.GetActor(actorId);
                if (actor == null)
                    continue;
                _tempList.Add(actor);
            }
            
            for (var i = 0; i < _tempList.Count; i++)
            {
                _tempList[i].Dead();
            }
            
            _tempList.Clear();
        }
    }
}