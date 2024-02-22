using System;
using System.Collections.Generic;
using System.IO;
using System.Security.AccessControl;
using System.Text;
using PapeGames.X3;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public static class ResAnalyzerExtension
    {
        #region MyRegion 运行时需要
        public static Dictionary<BattleResType, Dictionary<string, ResDesc>> GetResult(this ResAnalyzer analyzer)
        {
            var result = new Dictionary<BattleResType, Dictionary<string, ResDesc>>();
            ResAnalyzeUtil.GetResult(result, analyzer.resModule);
            return result;
        }
        #endregion
        
        #region MyRegion 生成离线数据时需要
        /// <summary>
        /// 部分分析器分析出的结果，写入本地，作为一个配置进包。 读取时优先读取该配置，节省时间
        /// 文件粒度：女主武器，男主，女主，关卡，四类
        /// 每一类，一个id生成一个文件
        /// </summary>
        public static void WriteOfflineAnalyzeResult(this ResAnalyzer analyzer)
        {
#if UNITY_EDITOR
            // 递归找到对应的ResModuld
            var modules = new List<ResModule>();
            GetResModuleByOwnerTypes(analyzer.resModule, ref AnalyzeDefine.offlineAnalyzeTypes, ref modules);
 
            // 开始写入本地, 写到messagePack文件夹下. 每次数据都是全量生成
            for (int i = 0; i < modules.Count; i++)
            {
                // 此处设计：支持id类型的分析器，也支持BattleCommonResAnalyzer类型的唯一分析器
                string fileName = modules[i].id.ToString();
                string ownerType = modules[i].ownerType;
                if (modules[i].id == 0)
                {
                    fileName = ownerType;
                }

                MpUtil.Serialize<ResModule>(modules[i], ownerType + "/" + fileName);
            }

            // string dir = System.Environment.CurrentDirectory + @"\MessagePack\";
            // LogProxy.LogFormat("分析器离线数据本地生成完成，数量：{0}位置：{1}", modules.Count, dir);
#endif
        }

        private static void GetResModuleByOwnerTypes(ResModule parentResModule, ref HashSet<string> types,
            ref List<ResModule> resModules)
        {
            if (types == null || parentResModule == null)
                return;
            string ownerType = parentResModule.ownerType;
            if (types.Contains(ownerType))
            {
                resModules.Add(parentResModule);
            }

            // 递归
            var modules = parentResModule.children;
            if (modules == null || modules.Count <= 0)
                return;
            foreach (var module in modules)
            {
                GetResModuleByOwnerTypes(module, ref types, ref resModules);
            }
        }
        
        /// <summary>
        /// 清理所有的离线分析生成的数据
        /// </summary>
        public static void ClearOfflineAnalyzeData(bool isClearSoundCfg = true)
        {
            // 先清理文件夹下的旧数据
            HashSet<string> offlineDatas = new HashSet<string>(AnalyzeDefine.offlineAnalyzeTypes);
            if (isClearSoundCfg)
            {
                offlineDatas.Add(FxCfg.OfflineDataDir);
            }
            foreach (var type in offlineDatas)
            {
                string parentDir = TbUtil.rootDir + type;
                if (!Directory.Exists(parentDir))
                {
                    continue;
                }

                try
                {
                    // 该代码，不适用于mac平台
#if UNITY_EDITOR_WIN                    
                    DirectorySecurity fsec = new DirectorySecurity();
                    fsec.AddAccessRule(new FileSystemAccessRule("Everyone", FileSystemRights.FullControl,
                        InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
                    Directory.SetAccessControl(parentDir, fsec);
#endif
                    Directory.Delete(parentDir, true);
                }
                catch (Exception e)
                {
                    LogProxy.LogError(e);
                }
            }
        }
        #endregion
        
        #region MyRegion 分包规则需要
        public static Dictionary<BattleResType, List<string>> GetResultInfos(this ResAnalyzer analyzer)
        {
            return GetResultInfos(analyzer.resModule);;
        }
        
        public static Dictionary<BattleResType, List<string>> GetResultInfos(ResModule resModule)
        {
            var notRepeatResult = new Dictionary<BattleResType, HashSet<string>>();
            GetResult(notRepeatResult, resModule);
            var result = new Dictionary<BattleResType, List<string>>();
            foreach (var item in notRepeatResult)
            {
                result[item.Key] = new List<string>(item.Value);
            }
            return result;
        }

        private static void GetResult(Dictionary<BattleResType, HashSet<string>> result, ResModule resModule)
        {
            if (resModule == null)
            {
                return;
            }
            int resNum = resModule.resDescList == null ? 0 : resModule.resDescList.Count;
            for (int i = 0; i < resNum; i++)
            {
                var res = resModule.resDescList[i];
                HashSet<string> list = null;
                if (!result.TryGetValue(res.type, out list))
                {
                    list = new HashSet<string>();
                    result[res.type] = list;
                }
                if (res.type == BattleResType.Scene)
                {
                    // 场景较为特殊， 分包规则要求必须是标签（相对路径）
                    list.Add(res.path);
                    continue;
                }
                if (string.IsNullOrEmpty(res.fullPath))
                {
                    list.Add(res.path);
                }
                else
                {
                    list.Add(res.fullPath);
                }
            }
            int childNum = resModule.children == null ? 0 : resModule.children.Count;
            for (int i = 0; i < childNum; i++)
            {
                GetResult(result, resModule.children[i]);
            }
        }
        #endregion

        public static BattleResLoadType GetResLoadType(BattleResType resType)
        {
            var cfgItem = BattleResConfig.GetResConfig(resType);
            if (cfgItem != null)
            {
                return cfgItem.loadType;
            }
            return default(BattleResLoadType);
        }

    }
}