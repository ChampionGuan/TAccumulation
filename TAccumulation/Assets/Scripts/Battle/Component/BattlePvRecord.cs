using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 编辑器下PV录制相关的录制功能
    /// </summary>
    public class BattlePvRecord : BattleComponent
    {
        public BattlePvData Data;
        private bool m_isPlay = false;
        private float m_beginTime = 0.0f;
        private float m_beginRecordTime = 0.0f;
        private bool m_isRecord = false;
        private List<int> m_setActorDic = new List<int>();

        public BattlePvRecord() : base(BattleComponentType.BattlePvRecord)
        {
        }

        protected override void OnAwake()
        {
        }

        protected override void OnStart()
        {
            base.OnStart();
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            if (m_isPlay)
            {
                UpdatePlay();
            }
        }

        /// <summary>
        /// 是否还在播放
        /// </summary>
        public bool IsPlay()
        {
            return m_isPlay;
        }

        /// <summary>
        /// 获取正在播放的录制文件的总时间
        /// </summary>
        /// <returns></returns>
        public float GetCountPlayTime()
        {
            if (!m_isPlay || Data == null)
                return 0;
            return Data.time;
        }

        /// <summary>
        /// 获取播放的进度 没有播放返回0
        /// </summary>
        /// <returns></returns>
        public float GetPlayTime()
        {
            if (!m_isPlay || battle == null)
                return 0;

            return battle.time - m_beginTime;
        }

        /// <summary>
        /// 开始播放
        /// </summary>
        /// <param name="path"></param>录制文件
        public void BeginPlay(string path)
        {
            LogProxy.Log("开始播放");
            InitPlay(path);
        }

        /// <summary>
        /// 停止播放
        /// </summary>
        public void EndPlay()
        {
            LogProxy.Log("停止播放");
            m_isPlay = false;
        }

        /// <summary>
        /// 开始录制
        /// </summary>
        public void BeginRecord()
        {
            if (Battle.Instance == null)
            {
                LogProxy.LogError("开始录制失败，战斗没有开始");
            }

            LogProxy.Log("开始录制");
            Data = new BattlePvData();
            Data.InitNodes = new List<InitNode>();
            Data.battleArg = Battle.Instance.arg;
            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                var node = new InitNode();
                node.cfgID = actor.cfgID;
                node.actorType = actor.type;
                node.pos = actor.transform.position;
                node.rotation = actor.transform.rotation;
                Data.InitNodes.Add(node);
            }

            m_beginRecordTime = battle.time;
            m_isPlay = false; //开始录制要停止播放 不然会死循环
            battle.eventMgr.RemoveListener<EventActorCommand>(EventType.ActorCommand, OnActorCommand);
            battle.eventMgr.AddListener<EventActorCommand>(EventType.ActorCommand, OnActorCommand, "BattlePvRecord.OnActorCommand");
        }

        /// <summary>
        /// 结束录制
        /// </summary>
        public void EndRecord(string dirPath, string filePath)
        {
            battle.eventMgr.RemoveListener<EventActorCommand>(EventType.ActorCommand, OnActorCommand);
            if (dirPath == "" || Data == null || filePath == "")
            {
                LogProxy.LogError("结束录制保存文件失败");
                return;
            }

            Data.SetTime(battle.time - m_beginRecordTime);
            BattlePvData.Serialize(Data, dirPath, filePath);
            LogProxy.Log("结束录制");
        }

        /// <summary>
        /// 初始化播放
        /// </summary>
        /// <param name="path"></param>
        private void InitPlay(string path)
        {
            Data = BattlePvData.Deserialize(path);
            if (Data == null || Battle.Instance == null)
            {
                return;
            }

            //恢复男女住初始化配置
            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                foreach (var node in Data.InitNodes)
                {
                    if (actor.cfgID == node.cfgID && actor.type == node.actorType && (actor.aiOwner?.isActive ?? true) && !actor.isDead)
                    {
                        actor.transform.SetPosition(node.pos);
                        actor.transform.SetRotation(node.rotation);
                        if (actor.skillOwner != null)
                        {
                            Battle.Instance.ClearSkillsCd(actor.insID);
                        }
                    }
                }
            }

            //恢复怪物初始化设置
            m_setActorDic.Clear();
            foreach (var node in Data.InitNodes)
            {
                bool isInit = false;
                foreach (var actor in Battle.Instance.actorMgr.actors)
                {
                    if (m_setActorDic.Contains(actor.insID))
                        continue;
                    if (actor.cfgID == node.cfgID && actor.type == node.actorType && (actor.aiOwner?.isActive ?? true) && !actor.isDead)
                    {
                        actor.transform.SetPosition(node.pos);
                        actor.transform.SetRotation(node.rotation);
                        if (actor.skillOwner != null)
                        {
                            Battle.Instance.ClearSkillsCd(actor.insID);
                        }

                        m_setActorDic.Add(actor.insID);
                        isInit = true;
                        break;
                    }
                }

                if (!isInit)
                {
                    var actor = battle.actorMgr.CreateMonster(node.cfgID);
                    if (actor != null)
                    {
                        actor.transform.SetPosition(node.pos);
                        actor.transform.SetRotation(node.rotation);
                        m_setActorDic.Add(actor.insID);
                    }
                }
            }

            m_isPlay = true;
            m_beginTime = battle.time;
        }

        private void UpdatePlay()
        {
            if (!m_isPlay)
                return;

            if (Data.commandRecords.Count <= 0)
            {
                return;
            }

            float curTime = battle.time - m_beginTime;
            CommandRecord cmdRecord = Data.commandRecords.Peek();
            while (cmdRecord != null)
            {
                if (cmdRecord.time > curTime)
                    break;
                Actor actor = battle.actorMgr.GetActor(cmdRecord.actorID);
                if (actor == null)
                {
                    LogProxy.LogErrorFormat("播放过程中 未找到actor， insID:{0}", cmdRecord.actorID);
                    break;
                }

                var cmd = MpUtil.Deserialize<ActorCmd>(cmdRecord.command);
                if (cmd == null)
                {
                    LogProxy.LogErrorFormat("播放时cmd:{0}反序列化失败", cmdRecord.cmdTypeName);
                    continue;
                }

                actor.commander.TryExecute(cmd);
                Data.commandRecords.Dequeue();
                if (Data.commandRecords.Count <= 0)
                {
                    break;
                }

                cmdRecord = Data.commandRecords.Peek();
            }

            if (battle.time - m_beginTime > Data.time)
            {
                m_isPlay = false;
                return;
            }
        }

        public void OnActorCommand(EventActorCommand eventArg)
        {
            if (Data == null)
            {
                LogProxy.LogError("录制过程中指令录制失败");
                return;
            }

            Data.EnqueueCmd(battle.time - m_beginRecordTime, eventArg.owner.insID, eventArg.cmd);
        }
    }
}