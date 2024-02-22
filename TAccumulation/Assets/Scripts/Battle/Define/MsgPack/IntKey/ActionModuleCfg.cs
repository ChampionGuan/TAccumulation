using System;
using MessagePack;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class ActionModuleCfg
    {
        [Key(0)] public int ID;
        [Key(1)] public string Name;
        // 策划逻辑timeline
        [Key(2)] public string LogicTimelineAsset;
        // 美术表现timeline
        [Key(3)] public string ArtTimeline;

        /// <summary>
        /// 编辑器用的虚拟目录字段
        /// </summary>
        [Key(4)] public string VirtualPath;

        // 默认时长（当动作模组没有策划logicTimeline时，使用这个字段作为默认时长）
        [Key(5)] public float defaultDuration;

        // 序列化黑板数据
        [Key(6)] public string blackboardData;
    }
}