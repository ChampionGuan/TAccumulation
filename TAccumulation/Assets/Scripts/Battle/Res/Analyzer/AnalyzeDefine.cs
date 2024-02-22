using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Serialization;

namespace X3Battle
{
    // 分析器执行的环境
    public enum AnalyzeRunEnv
    {
        /// <summary>
        /// 运行时逻辑实时分析， Editor下使战斗使用该种分析
        /// 该种分析分析耗时长，分析的资源准确(不缺)，且精确(会组合分析，分析出只需要的)
        /// 注意：精确分析的逻辑，数据+依赖需要支持能够记录下来
        /// 注意：前置条件需要battleArg的存在
        /// </summary>
        RunTimeLogic,

        /// <summary>
        /// 该方式耗时最短
        /// 运行时绝大部分的数据以读取离线数据的方式分析。 少部分以记录下的精确分析的数据，依赖进行运行时的精确分析
        /// 注意：前提需要生成准确的离线数据
        /// </summary>
        RunTimeOffline,

        /// <summary>
        /// 出包时分析,用于搜集战斗逻辑动态引用的资源(例如，通过字符串动态引用了一个prefab)
        /// 该种方式，每一个分析器都是独立启动，无法组合(精确)分析。所以遇到需要精确分析的逻辑，
        /// 该环境下常做冗余分析（简单粗暴的全部进包）
        /// </summary>
        BuildApp,

        /// <summary>
        /// 该种方式，每一个分析器都是独立启动，且要求能够记录精确分析依赖的条件，数据
        /// 和BuildApp方式的差别是，不能冗余分析
        /// </summary>
        BuildOfflineData,
        
        /// <summary>
        /// 分支合并模式，资源分析和BuildApp一致
        /// 特殊之处：需要分析出动态依赖的，由编辑器生成的配置，例如，技能，buff等
        /// </summary>
        BranchMerge,
    }
    
    public static class AnalyzeDefine
    {
        public static string ResultFullPath => ResultDirPath +"BattleResAnalyzerResult.csv";
        public static string DependFullPath => ResultDirPath +"BattleResAnalyzerDepend.csv";

        public static string ResultDetailInfoFileName = "BattleResAnalyzeDetailInfo";
        public static string ResultDirPath => Path.GetFullPath(Application.dataPath + "../../Library/ResourcesPacker/");

        public static bool ForceDirExist()
        {
            if (!Directory.Exists(AnalyzeDefine.ResultDirPath))
            {
                try
                {
                    Directory.CreateDirectory(AnalyzeDefine.ResultDirPath);
                    return true;
                }
                catch (Exception e)
                {
                    Debug.LogError("文件夹创建失败：" + ResultDirPath);
                    Debug.LogError(e);
                }
                return false;
            }
            else
            {
                return true;
            }
        }
        
        // 会离线生成配置的资源分析器类型
        public static HashSet<string> offlineAnalyzeTypes = new HashSet<string>()
        {
            typeof(SuitResAnalyzer).Name,
            typeof(BattleLevelResAnalyzer).Name,
            typeof(WeaponResAnalyzer).Name,
            typeof(HeroResAnalyzer).Name,
        };
    }

    [Serializable]
    public class BuildAppAnalyzePars
    {
        [SerializeField]private List<int> _levelIDs ;
        [SerializeField]private List<int> _girlSuitIDs;
        [SerializeField]private List<int> _boySuitIDs ;
        [SerializeField]private List<int> _weaponSkinIDs ;
        [SerializeField]private List<int> _sKillIDs ;
        [SerializeField]private List<int> _buffIDs ;
        [SerializeField]private List<int> _battleTags ;
        [SerializeField]private List<int> _suitIDs ;
        [SerializeField]private List<int> _girlCfgIDs ;
        [SerializeField]private List<int> _boyCfgIDs ;
        
        public List<int> levelIDs { get=>_levelIDs; set=>_levelIDs = value; }
        public List<int> girlSuitIDs{ get=>_girlSuitIDs; set=>_girlSuitIDs=value; }
        public List<int> boySuitIDs{ get=>_boySuitIDs; set=>_boySuitIDs=value; }
        public List<int> weaponSkinIDs{ get=>_weaponSkinIDs; set=>_weaponSkinIDs=value; }
        public List<int> sKillIDs{ get=>_sKillIDs; set=>_sKillIDs = value; }
        public List<int> buffIDs{ get=>_buffIDs; set=>_buffIDs=value; }
        public List<int> battleTags{ get=>_battleTags; set=>_battleTags=value; }
        public List<int> suitIDs { get=>_suitIDs; set=>_suitIDs = value; }
        public List<int> girlCfgIDs { get=>_girlCfgIDs; set=>_girlCfgIDs = value; }
        public List<int> boyCfgIDs { get=>_boyCfgIDs; set=>_boyCfgIDs = value; }
        
        public void Init()
        {
            if (levelIDs == null)
                levelIDs = new List<int>();
            if (girlSuitIDs == null)
                girlSuitIDs = new List<int>();
            if (boySuitIDs == null)
                boySuitIDs = new List<int>();
            if (weaponSkinIDs == null)
                weaponSkinIDs = new List<int>();
            if (sKillIDs == null)
                sKillIDs = new List<int>();
            if (buffIDs == null)
                buffIDs = new List<int>();
            if (battleTags == null)
                battleTags = new List<int>();
            if (suitIDs == null)
                suitIDs = new List<int>();
            if (girlCfgIDs == null)
                girlCfgIDs = new List<int>();
            if (boyCfgIDs == null)
                boyCfgIDs = new List<int>();
        }
        public void NotNull()
        {
            Init();

            if (boySuitIDs.Count <= 0 && TbUtil.boySuitCfgs != null)
            {
                foreach (var id in suitIDs)
                {
                    if (TbUtil.HasCfg<MaleSuitConfig>(id))
                    {
                        boySuitIDs.Add(id);
                    }
                }
            }

            if (girlSuitIDs.Count <= 0 && TbUtil.girlSuitCfgs != null)
            {
                foreach (var id in suitIDs)
                {
                    if (TbUtil.HasCfg<FemaleSuitConfig>(id))
                    {
                        girlSuitIDs.Add(id);
                    }
                }
            }

            //打包时，只传入suitID. 通过现有的规则匹配出所有的cfgID
            // 规则是：
            //1.根据进包的SuitID去battleActor表的MaleSuitConfig子表中拿到对应的ScoreID, 这个ScoreID 一般默认是等于CfgID
            //  可以在 MaleActorConfig 子表中看到
            //2.根据//X3Streams/dev-cbt3/Program/Binaries/Tables/OriginTable/Team.xlsx. team表的ScoreSet子表中的ActorConfigID列中拿到所有的CfgID
            //  此时 可以配置出ScoreID 不等于 CfgID 的情况
            //综上：这里取了个巧， 通过SuitID取到 ScoreID。 然后遍历MaleActorConfig表，找到所有 ScoreID相等的行数据，统计其CfgID
            // TODO 这里有个隐患， MaleActorConfig表中可能配置的有测试数据，该测试数据对应的资源也会进包   
            if (girlCfgIDs.Count <= 0)
            {
                foreach (var suitID in girlSuitIDs)
                {
                    List<int> ids = new List<int>();
                    TbUtil.GetActorCfgIDsBySuitID(suitID, ids);
                    girlCfgIDs.AddRange(ids);
                }
            }
            
            if (boyCfgIDs.Count <= 0)
            {
                foreach (var suitID in boySuitIDs)
                {
                    List<int> ids = new List<int>();
                    TbUtil.GetActorCfgIDsBySuitID(suitID, ids);
                    boyCfgIDs.AddRange(ids);
                }
            }

            _levelIDs = NotRepeat(_levelIDs);
            _girlSuitIDs = NotRepeat(_girlSuitIDs);
            _boySuitIDs = NotRepeat(_boySuitIDs);
            _weaponSkinIDs = NotRepeat(_weaponSkinIDs);
            _buffIDs = NotRepeat(_buffIDs);
            _battleTags = NotRepeat(_battleTags);
            _suitIDs = NotRepeat(_suitIDs);
            _girlCfgIDs = NotRepeat(_girlCfgIDs);
            _boyCfgIDs = NotRepeat(_boyCfgIDs);
        }

        public void Sort()
        {
            _levelIDs?.Sort();
            _girlSuitIDs?.Sort();
            _boySuitIDs?.Sort();
            _weaponSkinIDs?.Sort();
            _buffIDs?.Sort();
            _battleTags?.Sort();
            _suitIDs?.Sort();
            _girlCfgIDs?.Sort();
            _boyCfgIDs?.Sort();
        }
        
        private List<int> NotRepeat(List<int> repeatData)
        {
            HashSet<int> data = new HashSet<int>(repeatData);
            return new List<int>(data);
        }

        public void WriteToLocal()
        {
            if (!Application.isEditor)
            {
                return;
            }
            if (!AnalyzeDefine.ForceDirExist())
            {
                Debug.LogErrorFormat("打包参数写入本地失败，文件夹不存在");
                return;
            }
            var fullPath = Path.Combine(AnalyzeDefine.ResultDirPath, "BuildAppAnalyzePars.json");
            using (StreamWriter writer = new StreamWriter(fullPath, false))
            {
                var jsonStr = JsonUtility.ToJson(this, true);
                writer.Write(jsonStr);
                Debug.Log("打包参数写入成功本地成功：" + fullPath);
            }
        }

        public static BuildAppAnalyzePars ReadFromLocal()
        {
            if (!Application.isEditor)
            {
                return null;
            }
            var fullPath = Path.Combine(AnalyzeDefine.ResultDirPath, "BuildAppAnalyzePars.json");
            try
            {
                string text = File.ReadAllText(fullPath);
                return JsonUtility.FromJson<BuildAppAnalyzePars>(text);
            }
            catch (Exception e)
            {
                Debug.LogError("BuildAppAnalyzePars 打包参数不存在：" + fullPath);
                return null;
            }
        }
        
    }
    
}