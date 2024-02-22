#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using MessagePack;
using MessagePack.Unity.Editor;
using Newtonsoft.Json;
using PapeGames.X3;
using UnityEditor;
using UnityEngine;
using System.Threading.Tasks;

namespace X3Battle
{
    public static partial class TbUtil
    {
        private static string _editorRootDir;
        public static string editorRootDir
        {
            get
            {
                if (string.IsNullOrEmpty(_editorRootDir))
                {
                    _editorRootDir = Application.dataPath.Replace("Assets", "MessagePack/Editor/");
                }

                return _editorRootDir;
            }
        }
        
        #region --动态配置Type定义--
        private static readonly Type _skillCfgType = typeof(SkillCfg);
        private static readonly Type _missileCfgType = typeof(MissileCfg);
        private static readonly Type _rogueEntryType = typeof(RogueEntryCfg);
        private static readonly Type _damageBoxCfgType = typeof(DamageBoxCfg);
        private static readonly Type _actionModuleCfgType = typeof(ActionModuleCfg);
        private static readonly Type _skinCfgType = typeof(SkinCfg);
        private static readonly Type _buffCfgType = typeof(BuffCfg);
        private static readonly Type _magicFieldCfgType = typeof(MagicFieldCfg);
        private static readonly Type _itemCfgType = typeof(ItemCfg);
        private static readonly Type _haloCfgType = typeof(HaloCfg);
        private static readonly Type _stageConfigType = typeof(StageConfig);
        private static readonly Type _triggerCfgType = typeof(TriggerCfg);
        private static readonly Type _modelInfoType = typeof(ModelInfo);
        #endregion

        // 设置buff配置
        public static void SetBuffCfg(BuffCfg buffCfg)
        {
            _proxy.GetCfgs<Dictionary<int, BuffCfg>>()[buffCfg.ID] = buffCfg;
        }

        public static bool RemoveCfg<T>(int id) where T : class
        {
            Type type = typeof(T);
            if (type == _skillCfgType) return skillCfgs.Remove(id);
            if (type == _missileCfgType) return missileCfgs.Remove(id);
            if (type == _rogueEntryType) return rogueEntryCfgs.Remove(id);
            if (type == _damageBoxCfgType) return damageBoxCfgs.Remove(id);
            if (type == _actionModuleCfgType) return actionModuleCfgs.Remove(id);
            if (type == _skinCfgType) return skinCfgs.Remove(id);
            if (type == _buffCfgType) return buffCfgs.Remove(id);
            if (type == _magicFieldCfgType) return magicFieldCfgs.Remove(id);
            if (type == _itemCfgType) return itemCfgs.Remove(id);
            if (type == _haloCfgType) return haloCfgs.Remove(id);
            if (type == _stageConfigType) return stageCfgs.Remove(id);
            if (type == _triggerCfgType) return triggerCfgs.Remove(id);
            return false;
        }

        public static bool RemoveCfg<T>(string id) where T : class
        {
            Type type = typeof(T);
            if (type == _modelInfoType) return modelInfos.Remove(id);
            return false;
        }
    }

    public static class MpCollector
    {
        [MenuItem("Build Tool/打包前处理/拷贝战斗bytes文件至MessagePack", false, 2)]
        public static void Collect()
        {
            AssetDatabase.StartAssetEditing();

            var fromDir = Application.dataPath.Replace("Assets", "MessagePack/");
            var toDir = Application.dataPath + BattleResConfig.Config[BattleResType.MessagePack].dir.Replace("Assets", "");
            try
            {
                _CopyTo(fromDir, toDir);
            }
            catch (Exception e)
            {
                LogProxy.LogError(e);
            }

            EditorUtility.ClearProgressBar();
            AssetDatabase.StopAssetEditing();
            AssetDatabase.Refresh(ImportAssetOptions.ForceUpdate);

            LogProxy.LogFormat("bytes文件已拷贝至：{0}", toDir);
        }

        private static void _CopyTo(string fromDir, string toDir)
        {
            if (!Directory.Exists(toDir))
            {
                Directory.CreateDirectory(toDir);
                FileUtility.SetFileWritable(toDir);
            }
            else
            {
                Directory.Delete(toDir, true);
            }

            var filePaths = Directory.GetFiles(fromDir, "*.bytes", SearchOption.AllDirectories);
            var total = filePaths.Length;
            for (var i = 0; i < total; i++)
            {
                var sPath = filePaths[i];
                sPath = sPath.Replace("\\", "/");
                if (sPath.Contains("/Editor/"))
                {
                    continue;
                }
                var fName = Path.GetFileName(sPath);

                // note: 如果是宏DEBUG_GM为false，则debug配置筛除不进包！！
#if !DEBUG_GM
                var skip = false;
                var fPath = sPath.Substring(0, sPath.LastIndexOf("."));
                foreach (var value in TbCfgProxyBase.debugCfgFiles)
                {
                    if (!fPath.EndsWith(value)) continue;
                    skip = true;
                    break;
                }

                if (skip)
                {
                    continue;
                }
#endif

                var relativePath = sPath.Replace(fromDir, "");
                var relativeDir = relativePath.Replace(fName, "");
                var dir = $"{toDir}{relativeDir}";
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                    FileUtility.SetFileWritable(dir);
                }

                // note: 如果是宏DEBUG_GM为false，则中文字符串置空！
#if !DEBUG_GM
                string relativePathMp = relativePath.Replace(".bytes", "");
                if (relativeDir == "ActionModule/")
                {
                    ActionModuleCfg actionModuleCfg = MpUtil.Deserialize<ActionModuleCfg>(relativePathMp);
                    actionModuleCfg.Name = string.Empty;
                    actionModuleCfg.VirtualPath = string.Empty;
                    _Serialize(actionModuleCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Buff/")
                {
                    BuffCfg buffCfg = MpUtil.Deserialize<BuffCfg>(relativePathMp);
                    buffCfg.Name = string.Empty;
                    buffCfg.VirtualPath = string.Empty;
                    buffCfg.Description = string.Empty;
                    _Serialize(buffCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "DamageBox/")
                {
                    DamageBoxCfg damageBoxCfg = MpUtil.Deserialize<DamageBoxCfg>(relativePathMp);
                    damageBoxCfg.Name = string.Empty;
                    damageBoxCfg.VirtualPath = string.Empty;
                    _Serialize(damageBoxCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Halo/")
                {
                    HaloCfg haloCfg = MpUtil.Deserialize<HaloCfg>(relativePathMp);
                    haloCfg.Name = string.Empty;
                    haloCfg.VirtualPath = string.Empty;
                    _Serialize(haloCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Item/")
                {
                    ItemCfg itemCfg = MpUtil.Deserialize<ItemCfg>(relativePathMp);
                    itemCfg.Name = string.Empty;
                    itemCfg.VirtualPath = string.Empty;
                    _Serialize(itemCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "MagicField/")
                {
                    MagicFieldCfg magicFieldCfg = MpUtil.Deserialize<MagicFieldCfg>(relativePathMp);
                    magicFieldCfg.Name = string.Empty;
                    magicFieldCfg.VirtualPath = string.Empty;
                    _Serialize(magicFieldCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Missile/")
                {
                    MissileCfg missileCfg = MpUtil.Deserialize<MissileCfg>(relativePathMp);
                    missileCfg.Name = string.Empty;
                    missileCfg.VirtualPath = string.Empty;
                    missileCfg.Description = string.Empty;
                    _Serialize(missileCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Skill/")
                {
                    SkillCfg skillCfg = MpUtil.Deserialize<SkillCfg>(relativePathMp);
                    skillCfg.Name = string.Empty;
                    skillCfg.VirtualPath = string.Empty;
                    skillCfg.Description = string.Empty;
                    _Serialize(skillCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Skin/")
                {
                    SkinCfg skinCfg = MpUtil.Deserialize<SkinCfg>(relativePathMp);
                    skinCfg.Name = string.Empty;
                    skinCfg.VirtualPath = string.Empty;
                    skinCfg.DiffName = string.Empty;
                    _Serialize(skinCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Trigger/")
                {
                    TriggerCfg triggerCfg = MpUtil.Deserialize<TriggerCfg>(relativePathMp);
                    triggerCfg.Name = string.Empty;
                    triggerCfg.VirtualPath = string.Empty;
                    triggerCfg.Description = string.Empty;
                    _Serialize(triggerCfg, toDir, relativePathMp);
                    continue;
                }

                if (relativeDir == "Level/")
                {
                    StageConfig stageConfig = MpUtil.Deserialize<StageConfig>(relativePathMp);
                    if (stageConfig.Cameras != null)
                    {
                        foreach (var camera in stageConfig.Cameras)
                        {
                            camera.Name = string.Empty;
                        }
                    }

                    if (stageConfig.Points != null)
                    {
                        foreach (var point in stageConfig.Points)
                        {
                            point.Name = string.Empty;
                        }
                    }

                    if (stageConfig.SpawnPoints != null)
                    {
                        foreach (var spawnPoint in stageConfig.SpawnPoints)
                        {
                            spawnPoint.Name = string.Empty;
                        }
                    }

                    if (stageConfig.Machines != null)
                    {
                        foreach (var machine in stageConfig.Machines)
                        {
                            machine.Name = string.Empty;
                        }
                    }

                    if (stageConfig.Obstacles != null)
                    {
                        foreach (var obstacle in stageConfig.Obstacles)
                        {
                            obstacle.Name = string.Empty;
                        }
                    }

                    if (stageConfig.TriggerAreas != null)
                    {
                        foreach (var triggerArea in stageConfig.TriggerAreas)
                        {
                            triggerArea.Name = string.Empty;
                        }
                    }

                    _Serialize(stageConfig, toDir, relativePathMp);
                    continue;
                }
#endif

                var dPath = $"{dir}{fName}";
                File.Copy(sPath, dPath);
                fName = fName.Replace(".bytes", "");
                EditorUtility.DisplayProgressBar("拷贝bytes", fName, 1.0f * i / total);
            }

            EditorUtility.ClearProgressBar();
        }

        private static void _Serialize<T>(T t, string rootDir, string filePath)
        {
            byte[] bytes = MessagePackSerializer.SerializeX3(t);
            _Write(bytes, rootDir, filePath);
        }

        private static void _Write(byte[] bytes, string rootDir, string filePath)
        {
            string fullPath = string.Format("{0}{1}.bytes", rootDir, filePath);
            if (bytes == null)
            {
                PapeGames.X3.LogProxy.LogError($"【MpUtil._Write】{fullPath}为空！");
                return;
            }

            string dir = fullPath.Substring(0, fullPath.LastIndexOf('/'));
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            if (File.Exists(fullPath))
            {
                File.SetAttributes(fullPath, FileAttributes.Normal);
            }

            File.WriteAllBytes(fullPath, bytes);
        }
    }

    public static class MPTester
    {
        [MenuItem("Battle/配置,数据处理辅助工具/导表真机检查", false, 0)]
        public static void MenuCheck()
        {
            _Check();
        }

        /// <summary>
        /// 执行检查，并收集报错信息
        /// </summary>
        /// <returns></returns>
        public static Dictionary<string, List<string>> Check()
        {
            var files = new List<string>();
            MpUtil.ErrorHandler = (path, msg) => { files.Add(path); };
            _Check();
            MpUtil.ErrorHandler = null;
            var checkData = new Dictionary<string, List<string>>();
            if (files.Count > 0) checkData.Add("【沧澜】", files);
            return checkData;
        }

        /// <summary>
        /// 执行检查并输出检查报告（提交前验使用） -by 项天
        /// </summary>
        /// <param name="reportPath">报告保存路径</param>
        /// <param name="exitIfError">出错后退出</param>
        public static void RunCheck(string reportPath, bool exitIfError = false)
        {
            var logs = new ArrayList();
            var errors = 0;
            MpUtil.ErrorHandler = (path, msg) =>
            {
                logs.Add(new
                {
                    file = path,
                    message = msg,
                    type = "Error"
                });
                errors++;
            };

            _Check();
            MpUtil.ErrorHandler = null;

            if (errors == 0)
            {
                logs.Add(new
                {
                    message = "检查未发现问题",
                    type = "Normal"
                });
            }

            var report = new
            {
                logs = logs,
                errors = errors,
                warnings = 0,
                title = "战斗配置检查"
            };

            File.WriteAllText(reportPath, JsonConvert.SerializeObject(report));

            LogProxy.Log($"RunCheck exitIfError {exitIfError} errors: {errors}");
            if (errors > 0 && exitIfError)
            {
                EditorApplication.Exit(-1);
            }
        }

        private static void _Check()
        {
            try
            {
                MpUtil.TryRegister(true);
                TbUtil.UnInit();
                TbUtil.Init();
            }
            catch (Exception e)
            {
                LogProxy.LogError("战斗表格检查发生异常：" + e);
            }
        }
    }

    public static class MpCodeGen
    {
        private static string[] ScriptRootDir =
        {
            $"{Application.dataPath}/Scripts/Battle/",
            $"{Application.dataPath}/Scripts/MsgPack/",
            $"{Application.dataPath}/Scripts/Shared/TestbedCore/",
        };

        private static string TargetScriptDir => $"{Application.dataPath}/Scripts/MsgPack/Resolver/Formatters";

        [MenuItem("Battle/配置,数据处理辅助工具/MessagePack Code Generate", false, 0)]
        public static async void MenuCodeGen()
        {
            var ok = false;
            try
            {
                var dotnet = await ProcessHelper.FindDotnetAsync();
                ok = dotnet.found;
            }
            catch (Exception e)
            {
                LogProxy.LogError(e.Message);
            }

            if (!ok)
            {
                if (EditorUtility.DisplayDialog("Formatter CodeGen Error", "MessagePack CodeGen requires .NET Core Runtime. Please install first!", "download", "cancel"))
                {
                    // Application.OpenURL("https://dotnet.microsoft.com/en-us/download/dotnet/3.1");
                    Application.OpenURL("https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-3.1.424-windows-x64-installer");
                }

                LogProxy.LogError("MessagePack Formatter CodeGen Error, CodeGen requires .NET Core Runtime. Please install first!");
                return;
            }

            EditorUtility.DisplayProgressBar("Format文件生成中", "Format文件生成中, 请稍后...", 0);

            await CodeGen();

            EditorUtility.ClearProgressBar();

            AssetDatabase.Refresh();
            EditorUtility.DisplayDialog("完成", "Formatter已生成", "ok");
        }

        public static Task CodeGen()
        {
            var mpcArguments = new MpcArgument
            {
                Input = string.Join(",", ScriptRootDir),
                Output = TargetScriptDir
            };

            if (Directory.Exists(TargetScriptDir))
            {
                Directory.Delete(TargetScriptDir, true);
            }
            return MessagePackWindow.Generate(mpcArguments);
        }
    }
}

#endif
