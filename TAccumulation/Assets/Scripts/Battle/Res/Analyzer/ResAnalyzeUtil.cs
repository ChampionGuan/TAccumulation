using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using NodeCanvas.Framework;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public static class ResAnalyzeUtil
    {
        // 解析动作模组，自己模块有调用动作模组的同学，资源解析时请调用一下这个接口
        public static void AnalyzeActionModule(ResModule resModule, int id, BattleResTag tag = BattleResTag.Default)
        {
            var cfg = TbUtil.GetCfg<ActionModuleCfg>(id);
            if (cfg == null)
            {
                return;
            }

            // 逻辑部分
            if (!string.IsNullOrEmpty(cfg.LogicTimelineAsset))
            {
                var analyzer = new TimelineResAnalyzer(resModule, cfg.LogicTimelineAsset, BattleResType.TimelineAsset, false, tag);
                analyzer.Analyze();
            }

            // 美术部分
            if (!string.IsNullOrEmpty(cfg.ArtTimeline))
            {
                var analyzer = new TimelineResAnalyzer(resModule, cfg.ArtTimeline, BattleResType.Timeline, false, tag);
                analyzer.Analyze();
            }
        }
        
        // 解析DamageBox
        public static void AnalyzeDamageBox(ResModule parent, int damageBoxId)
        {
            var damageBoxAnalyze = new DamageBoxAnalyzer(parent, damageBoxId);
            damageBoxAnalyze.Analyze();
        }

        // 解析Buff
        public static void AnalyzeBuff(ResModule parent, int buffID)
        {
            BuffResAnalyzer analyzer = new BuffResAnalyzer(buffID, parent:parent);
            analyzer.Analyze();
        }
        
        /// <summary>
        /// 分析动态引用的图标，只关注名称
        /// </summary>
        /// <param name="resModule"></param>
        /// <param name="spriteName">图片名称</param>
        public static void AnalyzeIcon(ResModule resModule, string spriteName)
        {
            if (string.IsNullOrEmpty(spriteName))
            {
                return;
            }
            resModule.AddResultByPath(spriteName, BattleResType.Sprite);
        }
        
        private static int _analyzerGraphDepth = 0;

        public static void AnalyzerGraph(ResModule resModule, Graph graph)
        {
            if (graph == null)
            {
                return;
            }

            _analyzerGraphDepth++;
            // Graph解析深度>10时，抛出异常（理论上不会有图套图非常深的情况，此处将值暂设为10，后续可视情况调整
            if (_analyzerGraphDepth > 10)
            {
                _analyzerGraphDepth = 0;
                LogProxy.LogFatal($"【战斗】【严重错误】【ResAnalyzeUtil.AnalyzerGraph()】Graph解析出现死循环，请检查!! Graph Name:{graph.agent?.name}");
                return;
            }
            
            // DONE: 解析黑板上的ModuleID
            AnalyzeBlackboard(resModule, graph.blackboard);

            // 关卡-显隐特效.
            var faShowHideEffects = graph.GetAllNodesOfType<FAShowHideEffect>();
            foreach (var faShowHideEffect in faShowHideEffects)
            {
                if (faShowHideEffect?.sfxId == null)
                {
                    continue;
                }
                var fxID = faShowHideEffect.sfxId.GetValue();
                resModule.AddResultByFxId(fxID);
            }

            // 解析关卡动作模组
            var faPlayStageActionModules = graph.GetAllNodesOfType<FAPlayStageActionModule>();
            foreach (var faPlayStageActionModule in faPlayStageActionModules)
            {
                var actionModuleID = faPlayStageActionModule.actionModuleID.GetValue();
                if (actionModuleID > 0)
                {
                    AnalyzeActionModule(resModule, actionModuleID);
                }
            }

            // DONE: 解析召唤物.
            var faSummonCreatures = graph.GetAllNodesOfType<FASummonCreature>();
            foreach (var faSummonCreature in faSummonCreatures)
            {
                var summonId = faSummonCreature.summonID.GetValue();
                if (summonId <= 0)
                {
                    continue;
                }

                // 解析召唤物
                var summonAnalyze = new SummonMonsterAnalyzer(resModule, summonId);
                summonAnalyze.Analyze();
            }

            // DONE: 解析法术场.
            var faCreateMagicFields = graph.GetAllNodesOfType<FACreateMagicField>();
            foreach (var faCreateMagicField in faCreateMagicFields)
            {
                var magicFieldID = faCreateMagicField.magicFieldID.GetValue();
                if (magicFieldID <= 0)
                {
                    continue;
                }

                var magicFieldAnalyze = new MagicFieldAnalyzer(resModule, magicFieldID);
                magicFieldAnalyze.Analyze();
            }

            // DONE: 解析子弹.
            var faCreateMissiles = graph.GetAllNodesOfType<FACreateMissile>();
            foreach (var faCreateMissile in faCreateMissiles)
            {
                var missileID = faCreateMissile.param.missileID;
                if (missileID <= 0)
                {
                    continue;
                }

                var missileAnalyze = new MissileAnalyzer(resModule, missileID, true);
                missileAnalyze.Analyze();
            }
            
            // DONE: 解析改子弹的FA
            var faModifyMissileCfgRicochets = graph.GetAllNodesOfType<FAModifyMissileCfgRicochet>();
            foreach (var modifyMissileCfgRicochet in faModifyMissileCfgRicochets)
            {
                if (modifyMissileCfgRicochet.ricochetActive && modifyMissileCfgRicochet.ricochetMissileID > 0)
                {
                    var missileAnalyze = new MissileAnalyzer(resModule, modifyMissileCfgRicochet.ricochetMissileID, true);
                    missileAnalyze.Analyze();   
                }
            }

            // DONE: 解析Buff.
            var faCastBuffs = graph.GetAllNodesOfType<FACastBuff>();
            foreach (var faCastBuff in faCastBuffs)
            {
                if (faCastBuff.NewBuffAddParam == null)
                {
                    continue;
                }

                foreach (var buffAddParam in faCastBuff.NewBuffAddParam)
                {
                    AnalyzeBuff(resModule, buffAddParam.buffId.value);
                }
            }

            var faAddBuffs = graph.GetAllNodesOfType<FAAddBuff>();
            foreach (var faAddBuff in faAddBuffs)
            {
                var buffId = faAddBuff.buffId.GetValue();
                if (buffId <= 0)
                {
                    continue;
                }

                AnalyzeBuff(resModule, buffId);
            }

            var faAddGroupBuffs = graph.GetAllNodesOfType<FAAddGroupBuff>();
            foreach (var faAddGroupBuff in faAddGroupBuffs)
            {
                var buffId = faAddGroupBuff.buffId.GetValue();
                if (buffId <= 0)
                {
                    continue;
                }

                AnalyzeBuff(resModule, buffId);
            }

            // DONE: 解析伤害包围盒.
            var faCastDamageBoxes = graph.GetAllNodesOfType<FACastDamageBox>();
            foreach (var faCastDamageBox in faCastDamageBoxes)
            {
                var boxID = faCastDamageBox.BoxID.GetValue();
                if (boxID <= 0)
                {
                    continue;
                }

                AnalyzeDamageBox(resModule, boxID);
            }

            var faCreateDirectDamageBoxes = graph.GetAllNodesOfType<FACreateDirectDamageBox>();
            foreach (var faCreateDirectDamageBox in faCreateDirectDamageBoxes)
            {
                var boxID = faCreateDirectDamageBox.damageBoxID.GetValue();
                if (boxID <= 0)
                {
                    continue;
                }

                AnalyzeDamageBox(resModule, boxID);
            }

            var fACastCoefficientDamageBoxs = graph.GetAllNodesOfType<FACastCoefficientDamageBox>();
            foreach (var fACastCoefficientDamageBox in fACastCoefficientDamageBoxs)
            {
                var boxID = fACastCoefficientDamageBox.damageBoxID.GetValue();
                if (boxID <= 0)
                {
                    continue;
                }

                AnalyzeDamageBox(resModule, boxID);
            }

            // DONE: 解析FX特效.
            var fAPlayFxes = graph.GetAllNodesOfType<FAPlayFx>();
            foreach (var faFx in fAPlayFxes)
            {
                if (faFx.fxID != null)
                    resModule.AddResultByFxId(faFx.fxID.value, 1);
            }

            var playBGMs = graph.GetAllNodesOfType<FAPlayBGM>();
            foreach (var playBgm in playBGMs)
            {
                if (playBgm.bgmName != null)
                    resModule.AddResultByPath(playBgm.bgmName.value, BattleResType.BGM);
            }

            // 解析Timeline
            var playTimelines = graph.GetAllNodesOfType<MPlayTimeline>();
            foreach (var playTimeline in playTimelines)
            {
                if (playTimeline.timelineName != null)
                {
                    var analyzer = new TimelineResAnalyzer(resModule, playTimeline.timelineName.value, BattleResType.Timeline, false);
                    analyzer.Analyze();
                }
            }
            
            var createItems = graph.GetAllNodesOfType<FACreateItem>();
            foreach (FACreateItem createItem in createItems)
            {
                AnalyzeItem(resModule, createItem.itemId);
            }

            var playDialogues = graph.GetAllNodesOfType<FAPlayDialogue>();
            foreach (FAPlayDialogue playDialogue in playDialogues)
            {
                if (playDialogue.keys == null || playDialogue.keys.isNoneOrNull)
                {
                    continue;
                }

                AnalyzeDialogSound(resModule, playDialogue.keys.value);
            }

            var nPlayDialogues = graph.AllTasks.OfType<PlayDialogue>();
            foreach (PlayDialogue nPlayDialogue in nPlayDialogues)
            {
                if (nPlayDialogue.keys == null || nPlayDialogue.keys.isNoneOrNull)
                {
                    continue;
                }

                AnalyzeDialogSound(resModule, nPlayDialogue.keys.value);
            }

            var allNestedGraphs = graph.GetAllNestedGraphs<Graph>(false);
            foreach (var allNestedGraph in allNestedGraphs)
            {
                AnalyzerGraph(resModule, allNestedGraph);
            }

            _analyzerGraphDepth--;
        }

        public static void AnalyzeBlackboard(ResModule resModule, IBlackboard blackboard)
        {
            if (blackboard == null)
            {
                return;
            }
            
            // DONE: 解析黑板上的ModuleID
            var variables = blackboard.variables;
            foreach (var kVariable in variables)
            {
                if (kVariable.Value is Variable<ModuleID> variableModuleID)
                {
                    AnalyzeByModuleID(variableModuleID.value, resModule);
                }
            }
            
            // DONE: 解析父黑板上的ModuleID
            var parentVariables = blackboard.parent?.variables;
            if (parentVariables != null && parentVariables.Count > 0)
            {
                foreach (var kVariable in parentVariables)
                {
                    if (kVariable.Value is Variable<ModuleID> variableModuleID)
                    {
                        AnalyzeByModuleID(variableModuleID.value, resModule);
                    }
                }
            }
        }

        public static void AnalyzeByModuleID(ModuleID moduleID, ResModule resModule = null)
        {
            if (resModule == null)
            {
                resModule = new ResModule();
            }

            var id = moduleID.id;
            switch (moduleID.moduleType)
            {
                case ModuleType.DamageBox:
                    AnalyzeDamageBox(resModule, id);
                    break;
                case ModuleType.Missile:
                    new MissileAnalyzer(resModule, id, false).Analyze();
                    break;
                case ModuleType.Buff:
                    AnalyzeBuff(resModule, id);
                    break;
                case ModuleType.MagicField:
                    new MagicFieldAnalyzer(resModule, id).Analyze();
                    break;
                case ModuleType.Halo:
                    new HaloAnalyzer(resModule, id).Analyze();
                    break;
                case ModuleType.Trigger:
                    new TriggerAnalyzer(resModule, id).Analyze();
                    break;
                case ModuleType.Item:
                    AnalyzeItem(resModule, id);
                    break;
                case ModuleType.Fx:
                    resModule.AddResultByFxId(id, type:BattleResType.FX);
                    break;
                case ModuleType.Summon:
                    new SummonMonsterAnalyzer(resModule, id).Analyze();
                    break;
                case ModuleType.ActionModule:
                    AnalyzeActionModule(resModule, id);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        public static void AnalyzeItem(ResModule resModule, int itemId)
        {
            ItemCfg itemCfg = TbUtil.GetCfg<ItemCfg>(itemId);
            if (itemCfg != null)
            {
                resModule.AddResultByFxId(itemCfg.ItemFxId, type:BattleResType.FX);
                resModule.AddResultByFxId(itemCfg.FlyFxId, type:BattleResType.FX);
                resModule.AddResultByFxId(itemCfg.PickUpFxId, type:BattleResType.FX);
                resModule.AddResultByFxId(itemCfg.PickUpFxId, type:BattleResType.FX);

                if (itemCfg.AddBuffDatas != null)
                {
                    foreach (AddItemBuffData addBuffData in itemCfg.AddBuffDatas)
                    {
                        AnalyzeBuff(resModule, addBuffData.ID);
                    }
                }

                if (itemCfg.AddDamageBoxDatas != null)
                {
                    foreach (AddDamageBoxData addDamageBoxData in itemCfg.AddDamageBoxDatas)
                    {
                        var damageBoxAnalyze = new DamageBoxAnalyzer(resModule, addDamageBoxData.ID);
                        damageBoxAnalyze.Analyze();
                    }
                }
            }
        }

        public static void AnalyzerGraphPrefab(GameObject go, ResModule resModule)
        {
            if (go == null)
            {
                return;
            }

            GraphOwner graphOwner = go.GetComponent<GraphOwner>();
            if (graphOwner == null)
            {
                return;
            }

            if (graphOwner.graph == null)
            {
                if (Application.isPlaying)
                {
                    return;
                }
                else
                {
#if UNITY_EDITOR
                    graphOwner.Validate();
#endif
                }
            }

            AnalyzerGraph(resModule, graphOwner.graph);
        }
        
        /// <summary>
        /// 该接口的封装来源于 @鳄鱼 生成SVC时用的接口，可以全局搜同名函数搜到
        /// 因他的接口属于Editor逻辑，这里copy了一下，用于支持运行时使用
        /// </summary>
        /// <param name="resFullPath"></param>
        /// <returns></returns>
        public static string GetShaderSVCPath(string resFullPath)
        {
            if (string.IsNullOrEmpty(resFullPath))
                return string.Empty;
            string shaderVariantCollectionPath = string.Intern("Assets/Build/Art/SVC/{0}.shadervariants");
            string assetPathPrefix = string.Intern("Assets/Build/Art/");
            string assetPathPrefix2 = string.Intern("Assets/Build/LocaleSound/zh-CN/Art/");
            var resPathReplaces = resFullPath.Replace(assetPathPrefix, "")
                .Replace(assetPathPrefix2, "")
                .Split('.');
            var savePath = string.Format(shaderVariantCollectionPath, resPathReplaces[0]);
            return savePath;
        }

        public static void GetResult(Dictionary<BattleResType, Dictionary<string, ResDesc>> result, ResModule resModule)
        {
            if (resModule == null)
            {
                return;
            }

            int resNum = resModule.resDescList == null ? 0 : resModule.resDescList.Count;
            for (int i = 0; i < resNum; i++)
            {
                AddResult(result, resModule.resDescList[i], resModule);
            }

            int childNum = resModule.children == null ? 0 : resModule.children.Count;
            for (int i = 0; i < childNum; i++)
            {
                GetResult(result, resModule.children[i]);
            }
        }

        private static void AddResult(Dictionary<BattleResType, Dictionary<string, ResDesc>> results, ResDesc resDesc, ResModule resModule)
        {
            // TODO: 编辑器时，存在path == null 的情况.
            if (string.IsNullOrEmpty(resDesc.path))
                return;

            //获取对应类型的所有结果集合
            results.TryGetValue(resDesc.type, out var typeResults);
            if (typeResults == null)
            {
                typeResults = new Dictionary<string, ResDesc>();
                results[resDesc.type] = typeResults;
            }

            //获取对应路径的资源描述
            int maxCount = 0;
            if (BattleResConfig.Config.TryGetValue(resDesc.type, out BattleResConfigItem configItem))
            {
                maxCount = configItem.maxPreloadCount;
            }

            resDesc.count = Mathf.Max(1, resDesc.count);
            // 统计数据
            if (typeResults.TryGetValue(resDesc.path, out ResDesc prevDesc))
            {
                //如果已经存在，则增加数量
                prevDesc.count = Mathf.Min(prevDesc.count + resDesc.count, maxCount);
                if (!Application.isPlaying)
                {
                    // 运行时无需拼接这个信息, 离线下拼接这个信息，用于写入本地，用于排查问题
                    string moduleInfo = string.Format("*{0}:{1}", resDesc.moduleName, resModule.id);
                    string preModuleName = prevDesc.moduleName ?? "";
                    if (!preModuleName.Contains(moduleInfo))
                    {
                        prevDesc.moduleName += moduleInfo;
                    }
                }
                prevDesc.AddTag(resModule.tags);
                prevDesc.AddTag(resDesc.tags);
            }
            else
            {
                resDesc.count = Mathf.Min(resDesc.count, maxCount);
                typeResults[resDesc.path] = resDesc;
                if (!Application.isPlaying)
                {
                    // 运行时无需拼接这个信息, 离线下拼接这个信息，用于写入本地，用于排查问题
                    string moduleInfo = string.Format("*{0}:{1}", resDesc.moduleName, resModule.id);
                    string moduleName = resDesc.moduleName ?? "";
                    if (!moduleName.Contains(moduleInfo))
                    {
                        resDesc.moduleName = moduleInfo;
                    }
                }
                resDesc.AddTag(resModule.tags);
            }
        }
        
        public static void AnalyzeDialogSound(ResModule resModule, List<string> keys)
        {
            if (keys == null)
            {
                return;
            }
            var analyze = new DialogSoundAnalyze(keys);
            resModule.AddConditionAnalyze(analyze);
        }

        public static bool TryAnalyzeDynamicCfgs(ResModule resModule)
        {
            if (TbUtil.dynamicCfgPaths == null)
                return false;
            
            foreach (var item in TbUtil.dynamicCfgPaths)
            {
                foreach (var path in item.Value)
                {
                    resModule.AddResultByPath(path, BattleResType.DynamicCfgs);
                }
            }
            return true;
        }
        
        public static void ConditionAnalyze(ResModule resModule)
        {
            if (resModule.conditions != null)
            {
                int notAnalyzeCount = resModule.conditions.Count;
                while (notAnalyzeCount > 0)
                {
                    for (int i = 0; i < resModule.conditions.Count; i++)
                    {
                        var conditionAnalyze = resModule.conditions[i];
                        if (conditionAnalyze.isAnalyzed)
                        {
                            continue;
                        }
                        conditionAnalyze.Analyze(resModule);
                    }
                    notAnalyzeCount = 0;
                    // 条件分析时，有概率生成新的条件分析
                    foreach (var conditionAnalyze in resModule.conditions)
                    {
                        if (!conditionAnalyze.isAnalyzed)
                        {
                            notAnalyzeCount = notAnalyzeCount + 1;
                        }
                    }
                }
            }
            
            foreach (var child in resModule.children)
            {
                ConditionAnalyze(child);
            }
        }
        
        /// <summary>
        /// 递归查询，resModule的parent，是否是归属一个指定类型的分析器
        /// 注意：运行时使用离线数据时， 返回值 resModule.owner 为空, 因为是byte文件中反序列化的
        /// </summary>
        /// <typeparam name="T">分析器类型</typeparam>
        /// <returns>归属的指定类型分析器持有的resModule</returns>
        public static ResModule FromAnalyzer<T>(ResModule resModule) where T : ResAnalyzer
        {
            if (resModule == null)
                return null;

            if (resModule.owner is T)
                return resModule; 
            
            if (resModule.ownerType == typeof(T).Name)
                return resModule;
            
            if (resModule.parent == null)
                return null;
            return FromAnalyzer<T>(resModule.parent);
        }
        
        [Obsolete("将会被删除，使用WriteAllAnalyzeResult代替")]
        public static void EditorWriteToLocalForBuild()
        {
        }
        
        /// <summary>
        /// 打包后战斗资源分析的全部结果，写到本地。且会自动上传的分发平台。 每一个包都会有一个对应的分析文件
        /// 如果真机上出现了资源丢失情况，如果资源在这个文件中，则证明分析逻辑没有问题，是分包逻辑的问题
        /// </summary>
        public static void WriteAllAnalyzeResult(ResModule resModule)
        {
            var results = new Dictionary<BattleResType, Dictionary<string, ResDesc>>();
            GetResult(results, resModule);
            string dirPath = AnalyzeDefine.ResultDirPath;
            if (!Directory.Exists(dirPath))
            {
                try
                {
                    Directory.CreateDirectory(dirPath);
                }
                catch (Exception e)
                {
                    LogProxy.LogError(e);
                    return;
                }
            }

            var owner = resModule.owner;
            // 序列化该次出包的分析参数
            if (owner is BattleResAnalyzerBuildApp buildApp)
            {
                buildApp.pars.WriteToLocal();
            }
            // 直接序列化ResModule， 用于支持分析ab信息
            try
            {
                string tempPath = dirPath.Replace("\\", "/");
                MpUtil.Serialize(resModule, tempPath,AnalyzeDefine.ResultDetailInfoFileName);
            }
            catch (Exception e)
            {
                LogProxy.LogError("资源分析细信息Serialize失败：" + e.ToString());
            }
           
            
            // csv文件，用于方便阅读
            string fullPath = AnalyzeDefine.ResultFullPath;
            try
            {
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
                using (StreamWriter writer = new StreamWriter(File.Open(fullPath, FileMode.OpenOrCreate), Encoding.Default))
                {
                    string title = "type,moduleName,path,fullPath,parts,count";
                    writer.WriteLine(title);
                    foreach (var resultItem in results)
                    {
                        foreach (var result in resultItem.Value)
                        {
                            ResDesc res = result.Value;
                            var cfgItem = BattleResConfig.GetResConfig(res.type);
                            string loadType = "";
                            if (cfgItem != null)
                            {
                                loadType = cfgItem.loadType.ToString();
                            }
        
                            string content = "{0},{1},{2},{3},{4},{5},{6}";
                            string str = string.Format(content, res.type, res.moduleName, res.path, res.fullPath,
                                res.suitID, res.count, loadType);
                            writer.WriteLine(str);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                return;
            }

            LogProxy.Log("资源分析日志输出成功，位置：" + fullPath);
        }

        public static void WriteStr(List<string> paths)
        {
            // csv文件，用于方便阅读
            string fullPath = AnalyzeDefine.DependFullPath;
            try
            {
                string dirPath = AnalyzeDefine.ResultDirPath;
                if (!Directory.Exists(dirPath))
                {
                    Directory.CreateDirectory(dirPath);
                }
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
                using (StreamWriter writer = new StreamWriter(File.Open(fullPath, FileMode.OpenOrCreate), Encoding.Default))
                {
                    foreach (var path in paths)
                    {
                        writer.WriteLine(path);
                    }
                }
            }
            catch (Exception e)
            {
                return;
            }
        }
        
        public static void WriteDicStr(Dictionary<string, List<string>> paths)
        {
            // csv文件，用于方便阅读
            string fullPath = AnalyzeDefine.DependFullPath;
            try
            {
                string dirPath = AnalyzeDefine.ResultDirPath;
                if (!Directory.Exists(dirPath))
                {
                    Directory.CreateDirectory(dirPath);
                }
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                }
                using (StreamWriter writer = new StreamWriter(File.Open(fullPath, FileMode.OpenOrCreate), Encoding.Default))
                {
                    foreach (var path in paths)
                    {
                        foreach (var info in path.Value)
                        {
                            var temp = info + "," + path.Key;
                            writer.WriteLine(temp);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                return;
            }
        }
        
        /// <summary>
        /// 获取战斗中所有的音频event
        /// 仅作editor下统计数据使用
        /// </summary>
        public static List<string> GetAudioEvents(ResModule resModule)
        {
            List<string> resultStrS = new List<string>();   
#if UNITY_EDITOR
            var results = new Dictionary<BattleResType, Dictionary<string, ResDesc>>();
            GetResult(results, resModule);
            
            foreach (var resultItem in results)
            {
                foreach (var result in resultItem.Value)
                {
                    ResDesc res = result.Value;
                    switch (res.type)
                    {
                        case BattleResType.ActorAudio:
                        case BattleResType.BulletAudio:
                        case BattleResType.TimelineAudio:
                        case BattleResType.UIAudio:
                        {
                            if (!resultStrS.Contains(res.name))
                            {
                                resultStrS.Add(res.name);
                            }
                        } break;
                    }
                }
            }
#endif
            return resultStrS;

        }

        public static void WriteOfflineData(Type analyzerType, int id, float progress=1)
        {
            ResAnalyzer analyzer = null;
            if (analyzerType == typeof(BattleLevelResAnalyzer))
            {
                analyzer = new BattleLevelResAnalyzer(id);
            }
            else if (analyzerType == typeof(HeroResAnalyzer))
            {
                analyzer = new HeroResAnalyzer(id);
            }
            else if (analyzerType == typeof(SuitResAnalyzer))
            {
                analyzer = new SuitResAnalyzer(id);
            }
            else if (analyzerType == typeof(WeaponResAnalyzer))
            {
                analyzer = new WeaponResAnalyzer(id);
            }
            else
            {
                Debug.LogError($"类型：{analyzerType} 不支持离线数据生成");
                return;
            }

            string typeName = analyzerType.Name;
            try
            {
                analyzer.Analyze();
                analyzer.WriteOfflineAnalyzeResult();
#if UNITY_EDITOR
                if (progress != 1)
                    UnityEditor.EditorUtility.DisplayProgressBar("生成离线数据", $"生成{typeName}离线数据...", progress);
                Debug.LogFormat("生成{0}离线数据, ID:{1}", typeName, id);
#endif
            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("{0}：{1}战斗资源分析离线数据生成失败，错误信息：{2}", typeName, id, e);
            }
        }
    }
}