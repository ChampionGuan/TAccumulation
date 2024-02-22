using System;
using System.Collections.Generic;

namespace X3Battle
{
    public class TbCfgModifyProxy : TbCfgProxyBase
    {
        private static TbCfgModifyProxy _instance;
        public static TbCfgModifyProxy instance => _instance ?? (_instance = new TbCfgModifyProxy());
        
        /// <summary>
        /// 此类型对应的配置集获取函数
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<bool, object>> _typeToGetCfgsFunc { get;  } =  new Dictionary<Type, Func<bool, object>>
        {
            //Excel类型配置
            [typeof(BattleSummons)] = onlyFromCache => instance._GetExcelCfgs<BattleSummons>("AutoGen/BattleSummon", onlyFromCache),
            //动态类型配置
            [typeof(Dictionary<int, MissileCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, MissileCfg>>(onlyFromCache),
            [typeof(Dictionary<int, BuffCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, BuffCfg>>(onlyFromCache),
            [typeof(Dictionary<int, ItemCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, ItemCfg>>(onlyFromCache),
            [typeof(Dictionary<int, HaloCfg>)] = onlyFromCache => instance._EnsureCfgs<Dictionary<int, HaloCfg>>(onlyFromCache),
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, bool, object>> _typeToGetCfgByValueKeyFunc { get;  } = new Dictionary<Type, Func<ValueType, bool, object>>
        {
            //Excel类型配置
            [typeof(BattleSummon)] = (id,onlyFromCache) => instance._GetExcelCfg((int)id, instance.GetCfgs<BattleSummons>(onlyFromCache)?.battleSummons),
            //动态类型配置
            [typeof(MissileCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<MissileCfg>((int)id, onlyFromCache, "Missile/", "佚之喵"),
            [typeof(BuffCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<BuffCfg>((int)id, onlyFromCache, "Buff/", "卡宝宝"),
            [typeof(ItemCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<ItemCfg>((int)id, onlyFromCache, "Item/", "卡宝宝"),
            [typeof(HaloCfg)] = (id,onlyFromCache) => instance._GetDynamicCfg<HaloCfg>((int)id, onlyFromCache, "Halo/", "楚门"),
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Two Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, ValueType, bool, object>> _typeToGetCfgByTwoValueKeyFunc { get;  } = new Dictionary<Type, Func<ValueType, ValueType, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, bool, object>> _typeToGetCfgByStrKeyFunc { get;  } = new Dictionary<Type, Func<string, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过双Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, string, bool, object>> _typeToGetCfgByTwoStrKeyFunc { get;  } = new Dictionary<Type, Func<string, string, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Str、Value Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<string, ValueType, bool, object>> _typeToGetCfgByStrValueFunc { get;  } = new Dictionary<Type, Func<string, ValueType, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 此类型对应的具体配置项获取函数，通过Value、Str Key
        /// 后续如果有新增，请在此字典内填写类型对应的获取函数即可
        /// </summary>
        protected override Dictionary<Type, Func<ValueType, string, bool, object>> _typeToGetCfgByValueStrFunc { get;  } = new Dictionary<Type, Func<ValueType, string, bool, object>>
        {
            
        };
        
        /// <summary>
        /// 销毁
        /// </summary>
        public static void Dispose()
        {
            _instance = null;
        }
        
    }
}