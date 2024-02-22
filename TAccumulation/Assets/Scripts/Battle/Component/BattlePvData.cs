using System.Collections.Generic;
using System.IO;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class InitNode
    {
        [Key(1)] public int cfgID;
        [Key(2)] public ActorType actorType;
        [Key(3)] public Vector3 pos;
        [Key(4)] public Quaternion rotation;
    }
    
    [MessagePackObject]
    public class BattlePvData
    {
        [Key(0)]public BattleArg battleArg;
        [Key(1)]public List<InitNode> InitNodes;
        [Key(2)]public Queue<CommandRecord> commandRecords = new Queue<CommandRecord>();
        [Key(3)]public float time;//录制的总时间

        public void InitData(BattleArg arg)
        {
            if (Battle.Instance == null)
            {
                LogProxy.LogError("初始化录制数据失败");
                return;
            }
            battleArg = arg;

            foreach (var actor in Battle.Instance.actorMgr.actors)
            {
                InitNode node = new InitNode();
                node.cfgID = actor.cfgID;
                node.pos = actor.transform.position;
                node.rotation = actor.transform.rotation;
            }
        }

        public void SetTime(float time)
        {
            this.time = time;
        }
        public void EnqueueCmd(float time, int actorID, ActorCmd cmd)
        {
            if (cmd == null)
            {
                return;
            }
            var bytes = MessagePackSerializer.Serialize(cmd);
            CommandRecord record = new CommandRecord()
            {
                time = time,
                actorID = actorID,
                command = bytes,
                cmdTypeName = cmd.GetType().Name
            };
            commandRecords.Enqueue(record);
        }

        public static void Serialize(BattlePvData record, string dirPath, string filePath)
        {
            MpUtil.Serialize(record, dirPath, filePath, false);
        }

        public static BattlePvData Deserialize(string fullPath)
        {
            if (string.IsNullOrEmpty(fullPath))
            {
                PapeGames.X3.LogProxy.LogError("录制文件路径错误");
                return null;
            }
            byte[] bytes = null;
            if (File.Exists(fullPath))
            {
                bytes = File.ReadAllBytes(fullPath);
            }
            return MpUtil.Deserialize<BattlePvData>(bytes);
        }
        
    }
}