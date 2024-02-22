using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    /// <summary>Generated from BattleStageEditor.xlsx</summary>
    [X3MessagePackObject]
    public class EditorStageCfgs
    {
        public Dictionary<int, EditorStageCfg> editorStageCfgs { get; set; }
    }

    [X3MessagePackObject]
    public class EditorStageCfg
    {
        /// <summary>关卡ID</summary>
        public int ID { get; set; }
        /// <summary>此行配置是否生成脚本</summary>
        public int NoGenerate { get; set; }
        /// <summary>Base基础点位</summary>
        public int BaseID { get; set; }
        /// <summary>怪物生成位置预设ID</summary>
        public int MosterTransID { get; set; }
        /// <summary>各波次怪物分布</summary>
        public int[] MonsterGroupTypes { get; set; }
        /// <summary>Group1怪物模板ID&</summary>
        public int[] MonsterIDGroup1 { get; set; }
        /// <summary>Group2怪物模板ID&</summary>
        public int[] MonsterIDGroup2 { get; set; }
        /// <summary>Group3怪物模板ID&</summary>
        public int[] MonsterIDGroup3 { get; set; }
        /// <summary>Group4怪物模板ID&</summary>
        public int[] MonsterIDGroup4 { get; set; }
        /// <summary>Group5怪物模板ID&</summary>
        public int[] MonsterIDGroup5 { get; set; }
        /// <summary>Group6怪物模板ID&</summary>
        public int[] MonsterIDGroup6 { get; set; }
        /// <summary>Group7怪物模板ID&</summary>
        public int[] MonsterIDGroup7 { get; set; }
        /// <summary>Group8怪物模板ID&</summary>
        public int[] MonsterIDGroup8 { get; set; }
        /// <summary>Group9怪物模板ID&</summary>
        public int[] MonsterIDGroup9 { get; set; }
        /// <summary>Group10怪物模板ID&</summary>
        public int[] MonsterIDGroup10 { get; set; }
        [IgnoreMember]
        public int[][] MonsterIDGroups { get; set; }
    }
    
    
    [X3MessagePackObject]
    public class EditorStageBaseCfgs
    {
        public Dictionary<int, EditorStageBaseCfg> editorStageBaseCfgs { get; set; }
    }

    [X3MessagePackObject]
    public class EditorStageBaseCfg
    {
        /// <summary>Base信息ID</summary>
        public int ID { get; set; }
        /// <summary>Points信息来源关卡ID</summary>
        public int Point { get; set; }
        /// <summary>Obstacles信息来源关卡ID</summary>
        public int Obstacle { get; set; }
        /// <summary>TriggerAreas信息来源关卡ID</summary>
        public int TriggerArea { get; set; }
        /// <summary>SpawnPoints非Trans信息来源关卡ID</summary>
        public int PartSpawnPoint { get; set; }
    }
    
    [X3MessagePackObject]
    public class EditorStageMonsterCfgs
    {
        public Dictionary<int, EditorStageMonsterCfg> editorStageMonsterCfgs { get; set; }
    }

    [X3MessagePackObject]
    public class EditorStageMonsterCfg
    {
        /// <summary>怪物生成位置预设ID</summary>
        public int ID { get; set; }
        /// <summary>怪物数量1预设坐标</summary>
        public Vector2[] MonsterPosNum1 { get; set; }
        /// <summary>怪物数量2预设坐标</summary>
        public Vector2[] MonsterPosNum2 { get; set; }
        /// <summary>怪物数量3预设坐标</summary>
        public Vector2[] MonsterPosNum3 { get; set; }
        /// <summary>怪物数量4预设坐标</summary>
        public Vector2[] MonsterPosNum4 { get; set; }
        /// <summary>怪物数量5预设坐标</summary>
        public Vector2[] MonsterPosNum5 { get; set; }
        /// <summary>怪物数量6预设坐标</summary>
        public Vector2[] MonsterPosNum6 { get; set; }
        /// <summary>怪物数量7预设坐标</summary>
        public Vector2[] MonsterPosNum7 { get; set; }
        /// <summary>怪物数量8预设坐标</summary>
        public Vector2[] MonsterPosNum8 { get; set; }
        /// <summary>怪物数量9预设坐标</summary>
        public Vector2[] MonsterPosNum9 { get; set; }
        /// <summary>怪物数量10预设坐标</summary>
        public Vector2[] MonsterPosNum10 { get; set; }
        /// <summary>怪物数量11预设坐标</summary>
        public Vector2[] MonsterPosNum11 { get; set; }
        /// <summary>怪物数量12预设坐标</summary>
        public Vector2[] MonsterPosNum12 { get; set; }
        /// <summary>怪物数量13预设坐标</summary>
        public Vector2[] MonsterPosNum13 { get; set; }
        /// <summary>怪物数量14预设坐标</summary>
        public Vector2[] MonsterPosNum14 { get; set; }
        /// <summary>怪物数量15预设坐标</summary>
        public Vector2[] MonsterPosNum15 { get; set; }
        /// <summary>怪物数量16预设坐标</summary>
        public Vector2[] MonsterPosNum16 { get; set; }
        /// <summary>怪物数量17预设坐标</summary>
        public Vector2[] MonsterPosNum17 { get; set; }
        /// <summary>怪物数量18预设坐标</summary>
        public Vector2[] MonsterPosNum18 { get; set; }
        /// <summary>怪物数量19预设坐标</summary>
        public Vector2[] MonsterPosNum19 { get; set; }
        /// <summary>怪物数量20预设坐标</summary>
        public Vector2[] MonsterPosNum20 { get; set; }
		/// <summary>怪物数量1预设旋转</summary>
        public int[] MonsterRotNum1 { get; set; }
        /// <summary>怪物数量2预设旋转</summary>
        public int[] MonsterRotNum2 { get; set; }
        /// <summary>怪物数量3预设旋转</summary>
        public int[] MonsterRotNum3 { get; set; }
        /// <summary>怪物数量4预设旋转</summary>
        public int[] MonsterRotNum4 { get; set; }
        /// <summary>怪物数量5预设旋转</summary>
        public int[] MonsterRotNum5 { get; set; }
        /// <summary>怪物数量6预设旋转</summary>
        public int[] MonsterRotNum6 { get; set; }
        /// <summary>怪物数量7预设旋转</summary>
        public int[] MonsterRotNum7 { get; set; }
        /// <summary>怪物数量8预设旋转</summary>
        public int[] MonsterRotNum8 { get; set; }
        /// <summary>怪物数量9预设旋转</summary>
        public int[] MonsterRotNum9 { get; set; }
        /// <summary>怪物数量10预设旋转</summary>
        public int[] MonsterRotNum10 { get; set; }
        /// <summary>怪物数量11预设旋转</summary>
        public int[] MonsterRotNum11 { get; set; }
        /// <summary>怪物数量12预设旋转</summary>
        public int[] MonsterRotNum12 { get; set; }
        /// <summary>怪物数量13预设旋转</summary>
        public int[] MonsterRotNum13 { get; set; }
        /// <summary>怪物数量14预设旋转</summary>
        public int[] MonsterRotNum14 { get; set; }
        /// <summary>怪物数量15预设旋转</summary>
        public int[] MonsterRotNum15 { get; set; }
        /// <summary>怪物数量16预设旋转</summary>
        public int[] MonsterRotNum16 { get; set; }
        /// <summary>怪物数量17预设旋转</summary>
        public int[] MonsterRotNum17 { get; set; }
        /// <summary>怪物数量18预设旋转</summary>
        public int[] MonsterRotNum18 { get; set; }
        /// <summary>怪物数量19预设旋转</summary>
        public int[] MonsterRotNum19 { get; set; }
        /// <summary>怪物数量20预设旋转</summary>
        public int[] MonsterRotNum20 { get; set; }
        [IgnoreMember]
        public Vector2[][] MonsterPosNums { get; set; }
        [IgnoreMember]
        public int[][] MonsterRotNums { get; set; }
    }
}