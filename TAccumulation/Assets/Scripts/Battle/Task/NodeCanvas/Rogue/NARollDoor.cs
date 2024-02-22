using System;
using System.Collections.Generic;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue")]
    public class NARollDoor : BattleAction
    {
        private Action<List<RogueDoorData>> _rollDoorCallback;
        private Action<int> _selectDoorCallback;
        private Action<EventInterActorDone> _actionInterActorDone;

        public NARollDoor()
        {
            _rollDoorCallback = _RollDoorCallback;
            _selectDoorCallback = _SelectDoorCallback;
            _actionInterActorDone = _InterActorDone;
        }
        
        protected override void OnExecute()
        {
            // DONE: Roll门.
            if (_battle.rogue.doorDatas.Count <= 0)
            {
                _battle.rogue.RollDoor(_rollDoorCallback);
                return;
            }

            // DONE: 创建门.
            _CreateDoor(_battle.rogue.doorDatas);
        }

        private void _RollDoorCallback(List<RogueDoorData> doorDatas)
        {
            // DONE: 根据服务器返回的数据创建对应数量的门.
            _CreateDoor(doorDatas);
        }

        private void _CreateDoor(List<RogueDoorData> doorDatas)
        {
            BattleUtil.CreateDoor(doorDatas);
            Battle.Instance.eventMgr.AddListener<EventInterActorDone>(EventType.InterActorDone, _actionInterActorDone, "NARollDoor._InterActorDone");
        }

        private void _SelectDoor(int index)
        {
            _battle.rogue.SelectDoor(index, _selectDoorCallback);
        }

        private void _SelectDoorCallback(int index)
        {
            Battle.Instance.eventMgr.RemoveListener<EventInterActorDone>(EventType.InterActorDone, _actionInterActorDone);
            
            EndAction();
            ForceTick();
        }

        private void _InterActorDone(EventInterActorDone args)
        {
            int index = -1;
            for (var i = 0; i < Battle.Instance.rogue.doorConfigs.Count; i++)
            {
                var doorConfig = Battle.Instance.rogue.doorConfigs[i];
                if (doorConfig.ID == args.pointInsId)
                {
                    index = i;
                    break;
                }
            }

            if (index < 0)
            {
                return;
            }
            
            _SelectDoor(index);
        }
    }
}