using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class CommandRecord
    {
        [Key(0)] public float time;
        [Key(1)] public int actorID;
        [Key(2)] public byte[] command;
        [Key(3)] public string cmdTypeName;
    }

    [MessagePackObject]
    public class GameRecord
    {
        [Key(0)]public BattleArg battleArg;
        [Key(1)]public Queue<CommandRecord> commandRecords = new Queue<CommandRecord>();

        public const string latestBattleRecord = "latestBattleRecord";

        public void SetBattleArg(BattleArg arg)
        {
            battleArg = arg;
        }
        public void EnqueueCmd(float time, int actorID, ActorCmd cmd)
        {
            if (cmd==null)
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

        public static void Serialize(GameRecord record)
        {
            string dirPath = BattleUtil.ForceGetReplayLogPath();
            string filePath = System.DateTime.Now.ToString(new CultureInfo("ja-JP"));
            filePath = filePath.Replace('/', '_');
            filePath = filePath.Replace(' ', '_');
            filePath = filePath.Replace(':', '_');
            string fullPath = dirPath + filePath + ".bytes";
            PlayerPrefs.SetString(latestBattleRecord, fullPath);
            MpUtil.Serialize(record, dirPath,filePath, false);
        }

        public static GameRecord Deserialize(string fullPath)
        {
            if (string.IsNullOrEmpty(fullPath))
            {
                PapeGames.X3.LogProxy.LogError("回放文件路径错误:" + fullPath);
                return null;
            }
            byte[] bytes = null;
            if (File.Exists(fullPath))
            {
                bytes = File.ReadAllBytes(fullPath);
            }
            return MpUtil.Deserialize<GameRecord>(bytes);
        }

        public static string GetLatestRecordPath()
        {
            return PlayerPrefs.GetString(latestBattleRecord);
        }
        
    }
}