using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class BattleReplay : BattleComponent
    {
        private GameRecord _gameRecord;
        private bool _isReplayMode; // 是否是回放模式

        public BattleReplay() : base(BattleComponentType.BattleReplay)
        {
            requiredAnimationJobRunning = true;
        }
        
        protected override void OnAwake()
        {
            string recordPath = battle.arg.replayPath;
            _isReplayMode = !string.IsNullOrEmpty(recordPath); 
            if (_isReplayMode)// 回放路径不为空，则是回放录像
            {
                _gameRecord = GameRecord.Deserialize(recordPath);
                if (_gameRecord.commandRecords == null)
                    _gameRecord.commandRecords = new Queue<CommandRecord>();
            }
        }

        protected override void OnStart()
        {
            base.OnStart();
            if (!_isReplayMode)
            {
                // 如果是回放，会覆盖该次赋值
                StartRecord();
            }
        }

        public override void OnActorBorn(Actor actor)
        {
            // 回放时，女主的AI关掉
            if (actor.roleBornCfg != null && actor.roleBornCfg.IsPlayer && _isReplayMode)
            {
                actor.aiOwner?.DisableAI(true, AISwitchType.Player);
            }
        }

        protected override void OnAnimationJobRunning()
        {
            if (_isReplayMode)
            {
                UpdateReplay();
            }
        }

        private void StartRecord()
        {
            _gameRecord = new GameRecord();
            _gameRecord.SetBattleArg(battle.arg);
            battle.eventMgr.AddListener<EventActorCommand>(EventType.ActorCommand, OnActorCommand, "BattleReplay.OnActorCommand");
        }
        
        private void StopRecord()
        {
            GameRecord.Serialize(_gameRecord);
            battle.eventMgr.RemoveListener<EventActorCommand>(EventType.ActorCommand, OnActorCommand);
        }

        private void UpdateReplay()
        {
            if (_gameRecord.commandRecords.Count <= 0)
            {
                return;
            }
            float curTime = battle.time;
            CommandRecord cmdRecord = _gameRecord.commandRecords.Peek();
            while (cmdRecord != null)
            {
                if (cmdRecord.time > curTime)
                    break;
                Actor actor = battle.actorMgr.GetActor(cmdRecord.actorID);
                if (actor == null)
                {
                    LogProxy.LogErrorFormat("未找到actor， insID:{0}", cmdRecord.actorID);
                    break;
                }
                var cmd = MpUtil.Deserialize<ActorCmd>(cmdRecord.command);
                if (cmd == null)
                {
                    LogProxy.LogErrorFormat("回放时cmd:{0}反序列化失败", cmdRecord.cmdTypeName);
                    _gameRecord.commandRecords.Dequeue();
                    break;
                }
                actor.commander.TryExecute(cmd);
                _gameRecord.commandRecords.Dequeue();
                if (_gameRecord.commandRecords.Count <= 0)
                {
                    break;
                }
                cmdRecord = _gameRecord.commandRecords.Peek();
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            if (!_isReplayMode)
            {
                StopRecord();
            }
        }

        public void OnActorCommand(EventActorCommand eventArg)
        {
            _gameRecord.EnqueueCmd(battle.time, eventArg.owner.insID, eventArg.cmd);
        }
    }
}