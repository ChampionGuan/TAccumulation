using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class TbCfgProxyBase
    {
        /// <summary>
        /// 调试配置，如果Debug_GM的宏未开启，此列表下的配置不进包
        /// </summary>
        public static readonly List<string> debugCfgFiles = new List<string>
        {
            "AutoGen/BattleEditorConfig", // Editor下使用角色配置
            "AutoGen/BattleEditorScene", // Editor下使用场景信息  
            "AutoGen/BuffConflictTag", //Editor下使用Buff标签描述信息
            "AutoGen/BattleBuffMultipleTag", // Editor下使用buff信息
            "AutoGen/BattleSkillTag", // Editor下使用skill信息
            "AutoGen/DbgText", // Debug调试文本
            "AutoGen/BattleActorShowTag",
            "AutoGen/EntriesTag",
            "AutoGen/BattleActionTag",
        };
        
        /// <summary>
        /// 此类型对应的配置集获取函数
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<bool, object>> _typeToGetCfgsFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<ValueType, bool, object>> _typeToGetCfgByValueKeyFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Two Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<ValueType, ValueType, bool, object>> _typeToGetCfgByTwoValueKeyFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<string, bool, object>> _typeToGetCfgByStrKeyFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过双Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<string, string, bool, object>> _typeToGetCfgByTwoStrKeyFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Str、Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<string, ValueType, bool, object>> _typeToGetCfgByStrValueFunc { get; }
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value、Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected virtual Dictionary<Type, Func<ValueType, string, bool, object>> _typeToGetCfgByValueStrFunc { get; }
        
        /// <summary>
        /// 所有的配置，注意此字典不可以为静态字段
        /// </summary>
        private readonly Dictionary<Type, object> _allCfgMap = new Dictionary<Type, object>();
        
        /// <summary>
        /// Editor且非Playing模式下，记录load的动态配置信息，用于资源分析
        /// </summary>
        public Dictionary<Type, HashSet<string>> dynamicCfgPaths { get; private set; }

        /// <summary>
        /// 获取配置集
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public T GetCfgs<T>(bool onlyFromCache = false) where T : class
        {
            _typeToGetCfgsFunc.TryGetValue(typeof(T), out var func);
            return func?.Invoke(onlyFromCache) as T;
        }
        
        /// <summary>
        /// 获取配置(Value)
        /// </summary>
        /// <param name="id"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <returns></returns>
        public T2 GetCfg<T1, T2>(T1 id, bool onlyFromCache = false) where T1 : struct where T2 : class
        {
            _typeToGetCfgByValueKeyFunc.TryGetValue(typeof(T2), out var func);
            return func?.Invoke(id, onlyFromCache) as T2;
        }
        
        /// <summary>
        /// 获取配置(Value、Value)
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="id2"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <typeparam name="T3"></typeparam>
        /// <returns></returns>
        public T3 GetCfg<T1, T2, T3>(T1 id1, T2 id2, bool onlyFromCache = false) where T1 : struct where T2 : struct where T3 : class
        {
            _typeToGetCfgByTwoValueKeyFunc.TryGetValue(typeof(T3), out var func);
            return func?.Invoke(id1, id2, onlyFromCache) as T3;
        }
        
        /// <summary>
        /// 获取配置(String)
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public T GetCfg<T>(string id1, bool onlyFromCache = false) where T : class
        {
            _typeToGetCfgByStrKeyFunc.TryGetValue(typeof(T), out var func);
            return func?.Invoke(id1, onlyFromCache) as T;
        }
        
        /// <summary>
        /// 获取配置(String)
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="id2"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public T GetCfg<T>(string id1, string id2, bool onlyFromCache = false) where T : class
        {
            _typeToGetCfgByTwoStrKeyFunc.TryGetValue(typeof(T), out var func);
            return func?.Invoke(id1, id2, onlyFromCache) as T;
        }
        
        /// <summary>
        /// 获取配置(String、Value)
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="id2"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <returns></returns>
        public T2 GetCfg<T1, T2>(string id1, T1 id2, bool onlyFromCache = false) where T1 : struct where T2 : class
        {
            _typeToGetCfgByStrValueFunc.TryGetValue(typeof(T2), out var func);
            return func?.Invoke(id1, id2, onlyFromCache) as T2;
        }
        
        /// <summary>
        /// 获取配置(Value、String)
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="id2"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <returns></returns>
        public T2 GetCfg<T1, T2>(T1 id1, string id2, bool onlyFromCache = false) where T1 : struct where T2 : class
        {
            _typeToGetCfgByValueStrFunc.TryGetValue(typeof(T2), out var func);
            return func?.Invoke(id1, id2, onlyFromCache) as T2;
        }

        /// <summary>
        /// 加载所有非修改型配置集
        /// </summary>
        public void LoadAllCfgs()
        {
            foreach (var func in _typeToGetCfgsFunc.Values)
            {
                func?.Invoke(false);
            }
        }
        
        /// <summary>
        /// 获取Excel配置集
        /// </summary>
        /// <param name="path"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _GetExcelCfgs<T>(string path, bool onlyFromCache) where T : class
        {
            var type = typeof(T);
            if (_allCfgMap.TryGetValue(type, out var cfgs))
            {
                return cfgs as T;
            }
            if (onlyFromCache)
            {
                return null;
            }
            cfgs = MpUtil.Deserialize<T>(path);
            _allCfgMap.Add(type, cfgs);
            return cfgs as T;
        }
        
        /// <summary>
        /// 获取动态配置集，如果没有此配置且onlyFromCache为false，则创建配置集实例
        /// </summary>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _EnsureCfgs<T>(bool onlyFromCache) where T : class
        {
            var type = typeof(T);
            if (_allCfgMap.TryGetValue(type, out var cfgs))
            {
                return cfgs as T;
            }
            if (onlyFromCache)
            {
                return null;
            }
            cfgs = Activator.CreateInstance<T>();
            _allCfgMap.Add(type, cfgs);
            return cfgs as T;
        }
        
        /// <summary>
        /// 获取Excel配置
        /// </summary>
        /// <param name="id"></param>
        /// <param name="dict"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <returns></returns>
        protected T2 _GetExcelCfg<T1, T2>(T1 id, Dictionary<T1, T2> dict) where T2 : class
        {
            if (dict == null)
            {
                return null;
            }
            dict.TryGetValue(id, out T2 t);
            return t;
        }
        
        /// <summary>
        /// 获取Excel配置
        /// </summary>
        /// <param name="id1"></param>
        /// <param name="id2"></param>
        /// <param name="dict"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <typeparam name="T3"></typeparam>
        /// <returns></returns>
        protected T3 _GetExcelCfg<T1, T2, T3>(T1 id1, T2 id2, Dictionary<T1, Dictionary<T2, T3>> dict) where T3 : class
        {
            if (dict == null)
            {
                return null;
            }
            if (!dict.TryGetValue(id1, out Dictionary<T2, T3> d))
            {
                return null;
            }
            d.TryGetValue(id2, out T3 t);
            return t;
        }
        
        /// <summary>
        /// 获取动态配置
        /// </summary>
        /// <param name="id"></param>
        /// <param name="filePathPrefix"></param>
        /// <param name="name"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _GetDynamicCfg<T>(int id, bool onlyFromCache, string filePathPrefix, string name) where T : class
        {
            var cfg = default(T);
            if (id > 0)
            {
                cfg = _GetDynamicCfg<int, T>(id, onlyFromCache, filePathPrefix, name);
            }
            else
            {
                LogProxy.LogWarningFormat("【{0}】传入配置ID<=0，不合法！，请找策划【{2}】", typeof(T), id, name);
            }

            return cfg;
        }
        
        /// <summary>
        /// 获取动态配置
        /// </summary>
        /// <param name="key"></param>
        /// <param name="onlyFromCache"></param>
        /// <param name="filePathPrefix"></param>
        /// <param name="name"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _GetDynamicCfg<T>(string key, bool onlyFromCache, string filePathPrefix, string name) where T : class
        {
            var cfg = default(T);
            if (!string.IsNullOrEmpty(key))
            {
                cfg = _GetDynamicCfg<string, T>(key, onlyFromCache, filePathPrefix, name);
            }
            else
            {
                LogProxy.LogWarningFormat("【{0}】传入配置ID为空字符串，请找策划【{2}】", typeof(T), key, name);
            }

            return cfg;
        }
        
        /// <summary>
        /// 获取动态配置（内部）
        /// </summary>
        /// <param name="key"></param>
        /// <param name="onlyFromCache"></param>
        /// <param name="filePathPrefix"></param>
        /// <param name="name"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        /// <returns></returns>
        private T2 _GetDynamicCfg<T1, T2>(T1 key, bool onlyFromCache, string filePathPrefix, string name) where T2 : class
        {
            var dict = _EnsureCfgs<Dictionary<T1, T2>>(onlyFromCache);
            if (dict == null)
            {
                return null;
            }
            var result = dict.TryGetValue(key, out var cfg);
#if !UNITY_EDITOR
            if (result) return cfg;
#endif
            if (cfg == null && !onlyFromCache)
            {
                cfg = MpUtil.Deserialize<T2>($"{filePathPrefix}{key}");
                if (cfg != null)
                {
                    dict[key] = cfg;
                }
            }

            if (cfg == null)
            {
                LogProxy.LogWarningFormat("【{0}】配置ID：【{1}】为空，请找策划【{2}】", typeof(T2), key, name);
            }

            // 资源分析时，同时分析出依赖的动态配置
            if (!Application.isPlaying)
                _AddDynamicCfgPaths<T2>($"{filePathPrefix}{key}");
            return cfg;
        }
        
        /// <summary>
        /// 获取属性最小值
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public float GetAttrMinValue(AttrType type)
        {
            var cfg = GetCfgs<Dictionary<AttrType, float>>();
            if (cfg.TryGetValue(type, out var value))
            {
                return value;
            }

            return 0;
        }

        /// <summary>
        /// 获取后处理配置集
        /// </summary>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _GetPostProcessCfgs<T>(bool onlyFromCache) where T : class
        {
            var type = typeof(T);
            if (_allCfgMap.TryGetValue(type, out var cfgs))
            {
                return cfgs as T;
            }
            if (onlyFromCache)
            {
                return null;
            }
            if (type == typeof(Dictionary<int, ActorCfg>))
            {
                var excelCfgs = GetCfgs<ActorCfgs>();
                var actorCfgs = new Dictionary<int, ActorCfg>();
                BattleUtil.CombineDict(actorCfgs, excelCfgs.girlCfgs);
                BattleUtil.CombineDict(actorCfgs, excelCfgs.boyCfgs);
                BattleUtil.CombineDict(actorCfgs, excelCfgs.monsterCfgs);
                BattleUtil.CombineDict(actorCfgs, excelCfgs.machineCfgs);
                BattleUtil.CombineDict(actorCfgs, excelCfgs.interActorCfgs);
                _allCfgMap.Add(type, actorCfgs);
                cfgs = actorCfgs;
            }
            else if (type == typeof(Dictionary<int, ActorSuitCfg>))
            {
                var suitCfgs = new Dictionary<int, ActorSuitCfg>();
                BattleUtil.CombineDict(suitCfgs, GetCfgs<FemaleSuitConfigs>()?.femaleSuitConfigs);
                BattleUtil.CombineDict(suitCfgs, GetCfgs<MaleSuitConfigs>()?.maleSuitConfigs);
                _allCfgMap.Add(type, suitCfgs);
                cfgs = suitCfgs;
            }
            else if (type == typeof(Dictionary<AttrType, float>))
            {
                BattleEnv.LuaBridge.GetAttrMin(out var types, out var values);
                var attrCfgs = new Dictionary<AttrType, float>();
                for (var i = 0; i < types.Count; i++) attrCfgs.Add(types[i], values[i]);
                _allCfgMap.Add(type, attrCfgs);
                cfgs = attrCfgs;
            }
            else
            {
                _allCfgMap.Add(type, null);
            }

            return cfgs as T;
        }

        /// <summary>
        /// 获取调试配置集
        /// </summary>
        /// <param name="path"></param>
        /// <param name="onlyFromCache"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        protected T _GetDebugCfgs<T>(string path, bool onlyFromCache) where T : class
        {
            var type = typeof(T);
            if (_allCfgMap.TryGetValue(type, out var cfgs))
            {
                return cfgs as T;
            }
            if (onlyFromCache)
            {
                return null;
            }
#if DEBUG_GM
            cfgs = MpUtil.Deserialize<T>(path);
#else
            cfgs = default;
#endif
            _allCfgMap.Add(type, cfgs);
            return cfgs as T;
        }

        /// <summary>
        /// 缓存动态配置获取路径
        /// </summary>
        /// <param name="path"></param>
        /// <typeparam name="T"></typeparam>
        private void _AddDynamicCfgPaths<T>(string path)
        {
            if (dynamicCfgPaths == null)
                dynamicCfgPaths = new Dictionary<Type, HashSet<string>>();

            var fullPath = $"{TbUtil.rootDir}{path}.bytes";
            if (dynamicCfgPaths.TryGetValue(typeof(T), out var hashPaths))
            {
                hashPaths.Add(fullPath);
            }
            else
            {
                hashPaths = new HashSet<string>();
                hashPaths.Add(fullPath);
                dynamicCfgPaths[typeof(T)] = hashPaths;
            }
        }
    }
}