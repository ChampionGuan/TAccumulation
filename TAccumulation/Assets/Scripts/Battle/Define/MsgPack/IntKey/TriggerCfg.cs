using System;
using MessagePack;

namespace X3Battle
{
    [Serializable]
    [MessagePackObject]
    public class TriggerCfg
    {
        // 基本属性
        [Key(0)] public int ID;
        [Key(1)] public string Name;
        [Key(2)] public string Description;
        [Key(3)] public string VirtualPath;

        [Key(4)] public string GraphPath; // (FlowCanvas)图文件的相对路径.
        [Key(5)] public string ConfigPath; // 配置文件(黑板)的相对路径.
    }
}