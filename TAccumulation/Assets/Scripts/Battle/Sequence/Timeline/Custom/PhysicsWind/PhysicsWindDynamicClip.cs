using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Playables;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class PhysicsWindDynamicClip : InterruptClip
    {
        [SerializeField]
        public int ID;

        public PhysicsWindParamAsset physicsWindParamAsset { get; private set; }
        
        public PhysicsWindDynamicBehaviour behaviour { get; private set; }
        public GameObject bindObj { get; set; }

        public float duration { get; set; }
        
        [NonSerialized] 
        public ActionDynamicWind Wind;
        
        private List<string> partNames = new List<string>();

        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<PhysicsWindDynamicBehaviour>.Create(graph);
            behaviour = playable.GetBehaviour();
            interruptBehaviourParam = behaviour;
            LoadPhysicsWindParamAsset(ID);
            return playable; 
        }

        public void LoadPhysicsWindParamAsset(int id)
        {
            LoadAsset();
            _SetBehaviourParam();
            UnloadAsset();
        }

        public void LoadAsset()
        {
            if (bindObj == null)
            {
                return;
            }

            physicsWindParamAsset = null;
            // DONE: 加载逻辑.
            partNames.Clear();
            CharacterMgr.GetPartNamesWithPartType(bindObj, (int)PartType.Body, partNames);
            var physicsWindConfig = _LoadPhysicsWindConfig();
            string assetName = FindPhysicsWindName(ID, partNames, physicsWindConfig);
            if (string.IsNullOrEmpty(assetName))
            {
                return;
            }

            physicsWindParamAsset = _LoadPhysicsWindParamAsset(assetName);
        }

        private void _SetBehaviourParam()
        {
            if (physicsWindParamAsset == null)
            {
                return;
            }
            var needLerp = false;
            if (physicsWindParamAsset.isLerp)
            {
                if (physicsWindParamAsset.physicsWindParam != null && physicsWindParamAsset.physicsWindParam2 != null)
                {
                    if (physicsWindParamAsset.physicsWindParam.volumeParams?.Count == physicsWindParamAsset.physicsWindParam2.volumeParams?.Count)
                    {
                        needLerp = true;
                    }
                }
            }
            
            if (needLerp)
            {
                behaviour.SetPhysicsWindParam(physicsWindParamAsset.physicsWindParam, physicsWindParamAsset.physicsWindParam2);
                behaviour.SetDuration(duration);
            }
            else
            {
                behaviour.SetPhysicsWindParam(physicsWindParamAsset.physicsWindParam, null);
            }
        }

        public void UnloadAsset()
        {
            if (Application.isPlaying)
            {
                if (physicsWindParamAsset != null)
                {
                    BattleResMgr.Instance.Unload(physicsWindParamAsset);
                }
            }
        }

        private static PhysicsWindParamAsset _LoadPhysicsWindParamAsset(string paramName)
        {
            PhysicsWindParamAsset result = null;
            if (Application.isPlaying)
            { 
                result = BattleResMgr.Instance.Load<PhysicsWindParamAsset>(paramName, BattleResType.PhysicsWind);
            }
            else
            {
#if UNITY_EDITOR
                var config = BattleResConfig.GetResConfig(BattleResType.PhysicsWind);
                string path = config.dir + paramName + config.ext;
                result = UnityEditor.AssetDatabase.LoadAssetAtPath<PhysicsWindParamAsset>(path);
#endif
            }

            return result;
        }

        private static PhysicsWindConfigAsset _physicsWindConfig;

        private static PhysicsWindConfigAsset _LoadPhysicsWindConfig()
        {
            if (_physicsWindConfig == null)
            {
                if (Application.isPlaying)
                {
                    _physicsWindConfig = X3Battle.Battle.Instance.misc.physicsWindConfigAsset;
                }
                else
                {
#if UNITY_EDITOR
                    var config = BattleResConfig.GetResConfig(BattleResType.PhysicsWind);
                    string path = config.dir + BattleConst.PhysicsWindConfigName + config.ext;
                    _physicsWindConfig = UnityEditor.AssetDatabase.LoadAssetAtPath<PhysicsWindConfigAsset>(path);
#endif
                }
            }

            return _physicsWindConfig;
        }
        
        /// <summary>
        /// 查找风场资源的名字
        /// </summary>
        /// <param name="id"> 配置ID </param>
        /// <param name="partNames"> 部件名字列表 </param>
        /// <returns> 查到的风场资源名字 </returns>
        public static string FindPhysicsWindName(int id, List<string> partNames, PhysicsWindConfigAsset physicsWindConfigAsset)
        {
            if (physicsWindConfigAsset == null)
            {
                return null;
            }
            
            var configs = physicsWindConfigAsset.configs?.Dictionary;
            if (configs == null)
            {
                return null;
            }

            configs.TryGetValue(id, out var physicsWindConfig);
            if (physicsWindConfig == null)
            {
                return null;
            }

            PhysicWindConfigData data1 = null;
            PhysicWindConfigData data2 = null;
            for (int i = 0; i < physicsWindConfig.Datas.Count; i++)
            {
                if (partNames != null)
                {
                    // 如果多个部件在组内找到了匹配的风场，那么使用第一个（配错了的情况）
                    for (int j = 0; j < partNames.Count; j++)
                    {
                        // 如果一个部件找到了匹配的风场，那么就用找到的风场字符串
                        if (physicsWindConfig.Datas[i].PartName == partNames[j])
                        {
                            data1 = physicsWindConfig.Datas[i];
                            break;
                        }
                    }
                }
                
                if (data1 != null)
                {
                    break;
                }

                // 如果没有部件找到匹配的风场，那么使用Default对应的风场（部件填Default代表默认）
                if (data2 == null && physicsWindConfig.Datas[i].PartName == "Default")
                {
                    data2 = physicsWindConfig.Datas[i]; 
                }
            }

            var result = data1 ?? data2;
            
            // 如果默认的也没有，那么没有风场
            if (result == null)
            {
                string partNameLog = "";
                if (partNames != null)
                {
                    foreach (var partName in partNames)
                    {
                        partNameLog += partName + "; ";
                    }
                }
                LogProxy.LogError($"动态风场配置错误: PhysicsWindConfig id={id}, 没有配置部件数据, 部件名={partNameLog}");
                return null;
            }
            
            // 若找到的风场字符串为空，那么就是没有（大概率也是配错了）
            if (string.IsNullOrEmpty(result.PhysicsWindName))
            {
                LogProxy.LogError($"动态风场配置错误: PhysicsWindConfig id={id}, PartName={result.PartName}, Description={result.Description} 风场名字配置为空!");
                return null;
            }

            return result.PhysicsWindName;
        }
    }
}