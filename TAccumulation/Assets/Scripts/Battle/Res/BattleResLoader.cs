using System;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    /// <summary>
    /// 资源加载完成后的回调
    /// </summary>
    public delegate void EventOnLoadRes(Object obj, ResLoadArg arg, LoadedResInfo info = default(LoadedResInfo));

    /// <summary>
    /// 资源卸载载完成后的回调
    /// </summary>
    public delegate void EventOnUnLoadRes(Object obj, bool isUnLoadAsset);

    public interface IResLoader
    {
        Object Load(ResLoadArg arg);
        void Unload(BattleResLoadType loadType, Object obj, bool isUnLoadAsset = false); //卸载资源
        void UnInit(); // loader 卸载
        event EventOnLoadRes eventOnLoad;
        event EventOnUnLoadRes eventOnUnLoad;
    }

    // 加载资源时，参数
    public struct ResLoadArg
    {
        public string relativePath; // 相对路径（Asset为根目录）
        public BattleResType type;
        public int suitID; // Load 角色时，套装ID
        public int lod; // load角色时，指定load高模还是低模
        public string name;
        public bool isPreload; // 用于识别该次load是否是预加载
        private string _fullPath;
        public bool IsValidActorID()
        {
            return suitID != BattleConst.InvalidActorSuitID && suitID != 0;
        }

        public string GetFullPath()
        {
            if (string.IsNullOrEmpty(_fullPath))
            {
                _fullPath = BattleUtil.GetResPath(relativePath, type);
            }

            return _fullPath;
        }
    }

    // 加载出的资源信息
    public struct LoadedResInfo
    {
        public bool isFromAB; // 是否从ab中直接加载出来

        public LoadedResInfo(bool isFromAb)
        {
            this.isFromAB = isFromAb;
        }
    }
    
    public class BattleResLoader : IResLoader
    {
        private EventOnLoadRes _eventOnLoadRes;
        private EventOnUnLoadRes _eventOnUnLoadRes;

        public event EventOnLoadRes eventOnLoad
        {
            add { _eventOnLoadRes += value; }
            remove { _eventOnLoadRes -= value; }
        }

        public event EventOnUnLoadRes eventOnUnLoad
        {
            add { _eventOnUnLoadRes += value; }
            remove { _eventOnUnLoadRes -= value; }
        }

        /// <summary>
        /// 资源加载
        /// </summary>
        public virtual Object Load(ResLoadArg arg)
        {
            var obj = _Load(arg);
            OnLoad(obj, arg, new LoadedResInfo(true));
            return obj;
        }
        
        public void Unload(BattleResType resType, Object obj, bool isUnLoadAsset = false)
        {
            BattleResConfigItem cfg = BattleResConfig.GetResConfig(resType);
            if (cfg == null)
            {
                LogProxy.LogErrorFormat("资源卸载失败，缺少资源类型配置，资源类型：{0}", resType);
                return;
            }
            Unload(cfg.loadType, obj, isUnLoadAsset);
        }

        /// <summary>
        ///  资源卸载
        /// </summary>
        public virtual void Unload(BattleResLoadType loadType, Object obj, bool isUnLoadAsset = false)
        {
            _Unload(loadType, obj, isUnLoadAsset);
            OnUnLoad(obj, isUnLoadAsset);
        }
        
        /// <summary>
        /// loader 卸载
        /// </summary>
        public virtual void UnInit()
        {
        }
        
        protected Object _Load(ResLoadArg arg)
        {
            float startTime = Time.realtimeSinceStartup;
            var type = arg.type;
            Object obj = null;
            BattleResConfigItem cfg = BattleResConfig.GetResConfig(type);
            if (cfg == null)
            {
                LogProxy.LogError("缺少资源类型配置，资源类型：" + type);
                return obj;
            }

            BattleResLoadType loadType = cfg.loadType;
            string fullPath = arg.GetFullPath();
            switch (loadType)
            {
                case BattleResLoadType.Prefab:
                    obj = Res.Load<Object>(fullPath, Res.AutoReleaseMode.GameObject);
                    break;
                case BattleResLoadType.Asset:
                case BattleResLoadType.NavMesh:
                case BattleResLoadType.ShaderVariants:
                    obj = Res.Load<Object>(fullPath, Res.AutoReleaseMode.None);
                    break;
                case BattleResLoadType.Hero:
                    obj = BattleCharacterMgr.GetInsBySuitID(arg.suitID, arg.lod);
                    break;
                //不支持music音频
                case BattleResLoadType.Music:
                    break;
                default:
                    LogProxy.LogErrorFormat("load资源失败，未支持的资源类型：{0}", type);
                    break;
            }
            BattleCounterMgr.Instance.Add(CounterType.BattleLoad, Time.realtimeSinceStartup - startTime);
            if (obj == null && loadType != BattleResLoadType.Music)
                LogProxy.LogErrorFormat("资源类型：{0}, 不存在：{1}", type, fullPath);
            return obj;
        }

        protected void _Unload(BattleResLoadType loadType, Object obj, bool isUnLoadAsset = false)
        {
            if (obj == null)
                return;
            if (loadType == BattleResLoadType.Prefab)
            {
                BattleUtil.DestroyObj(obj as GameObject);
            }
            else if (loadType == BattleResLoadType.Asset 
                     || loadType == BattleResLoadType.NavMesh 
                     || loadType == BattleResLoadType.ShaderVariants)
            {
                // TODO 临时支持相机震屏资源，把asset 运行时Instantiate后当作prefab使用的的方式
                if (obj.GetInstanceID() > 0)
                    Res.Unload(obj);
                else
                    BattleUtil.DestroyObj(obj as GameObject);
            }
            else if (loadType == BattleResLoadType.Hero)
            {
                BattleCharacterMgr.ReleaseIns(obj as GameObject);
            }
            else
            {
                LogProxy.LogFatalFormat("【战斗】【严重错误】_Unload资源失败，未支持的LoadType：{0}, 资源名字：{1}，请检查！", loadType, obj.name);
            }
        }
        
        protected virtual void OnLoad(Object obj, ResLoadArg arg, LoadedResInfo resInfo)
        {
            _eventOnLoadRes?.Invoke(obj, arg, resInfo);
        }
        protected virtual void OnUnLoad(Object obj, bool isUnLoadAsset)
        {
            _eventOnUnLoadRes?.Invoke(obj, isUnLoadAsset);
        }
    }

    // 相同资源，只load一次，重复使用。 不支持 BattleResType.Hero
    // 可以通过强制卸载的方式，主动卸载掉
    // 对象池层面，get，recycle一直操作的都是同一个
    public class SameResLoadOnceLoader : BattleResLoader
    {
        private Dictionary<string, Object> _loadedRes = new Dictionary<string, Object>();
        public override Object Load(ResLoadArg arg)
        {
            if (string.IsNullOrEmpty(arg.relativePath))
            {
                var str = string.Format("SameResLoadOnceLoader不支持加载的资源相对路径为NUll, type:{0}", arg.type);
                LogProxy.LogFatalWithTag(LogTag.BattleRes, str);
                return null;
            }
            
            if (_loadedRes.TryGetValue(arg.relativePath, out var obj))
            {
                if (obj == null)
                {
                    LogProxy.LogErrorFormat("缓存的重复使用的对象被外部逻辑强制销毁,Type:{0}, relativePath:{1}"
                        ,arg.type, arg.relativePath);
                }
            }

            if (obj == null)
                obj = _Load(arg);
            
            if (obj == null)
                return null;
            _loadedRes[arg.relativePath] = obj;
            // 每次load都会增加引用计数
            OnLoad(obj, arg, new LoadedResInfo(true));
            return obj;
        }

        public override void Unload(BattleResLoadType loadType, Object obj, bool isUnLoadAsset = false)
        {
            if (isUnLoadAsset)
            {
                // 强制销毁一个对象时，这里把缓存也移除掉
                string removeKey = string.Empty;
                foreach (var item in _loadedRes)
                {
                    if (item.Value == obj)
                    {
                        removeKey = item.Key;
                        break;
                    }
                }
                if (!string.IsNullOrEmpty(removeKey))
                    _loadedRes.Remove(removeKey);
            }
            base.Unload(loadType, obj, isUnLoadAsset);
        }

        public override void UnInit()
        {
            // 这里只是个缓存，加载卸载走的是正常的机制load，unload。然后通过引用计数控制
            _loadedRes.Clear();
            base.UnInit();
        }
    }

    /// <summary>
    /// 特效专用Loader,fxAseet的vfx不初始化节省内存和消耗,asset load出来后go.active=false
    /// 特效播放时再active=true
    /// </summary>
    public class BattleFxLoaderPro : BattleResLoader
    {
        Dictionary<string, Object> fxAssets = new Dictionary<string, Object>();

        public override Object Load(ResLoadArg arg)
        {
            if (!fxAssets.TryGetValue(arg.relativePath, out var asset))
            {
                asset = base.Load(arg);
                fxAssets[arg.relativePath] = asset;
                if (asset == null)
                    return asset;
#if !UNITY_EDITOR
                UnityEngine.Profiling.Profiler.BeginSample("BattleFxLoaderPro.GetVFX.SetActive(False)");
                var vfxs = (asset as GameObject).GetComponentsInChildren<UnityEngine.VFX.VisualEffect>();
                foreach (var vfx in vfxs)
                    vfx.gameObject.SetActive(false);
                UnityEngine.Profiling.Profiler.EndSample();
#endif
            }
            if (asset == null)
                return asset;

            var inst = GameObject.Instantiate(asset) as GameObject;
            OnLoad(inst, arg, new LoadedResInfo(false));
            return inst;
        }
        public override void Unload(BattleResLoadType loadType, Object obj, bool isUnLoadAsset = false)
        {
            if (obj == null)
                return;
            //先卸载Asset
            //asset Unload
            if (isUnLoadAsset)
            {
                var resDesc = BattleResMgr.Instance.GetObjResDesc(obj);
                if (resDesc == null)
                {
                    LogProxy.LogErrorFormat("【战斗】_Unload资源失败，未找到实例的ResDesc ：{0}, 资源名字：{1}，请检查！", loadType, obj.name);
                    return;
                }
                // 先卸载实例
                base.Unload(loadType, obj, isUnLoadAsset);
                if (fxAssets.TryGetValue(resDesc.loadArg.relativePath, out var asset))
                {
                    // 后卸载asset
                    fxAssets.Remove(resDesc.loadArg.relativePath);
                    if (asset != obj) // obj有可能就是asset，此时不用卸载两次
                        base.Unload(loadType, asset, isUnLoadAsset);
                }
            }
            else
            {
                base.Unload(loadType, obj, isUnLoadAsset);
            }
        }
        public override void UnInit()
        {
            foreach (var item in fxAssets)
            {
                var resDesc = BattleResMgr.Instance.GetObjResDesc(item.Value);
                if (resDesc == null)
                {
                    LogProxy.LogErrorFormat("【战斗】_Unload资源失败，未找到实例的ResDesc,path：{0}", item.Key);
                    continue;
                }
                BattleResConfigItem cfg = BattleResConfig.GetResConfig(resDesc.type);
                if (cfg == null)
                {
                    LogProxy.LogError("缺少资源类型配置，资源类型：" + resDesc.type);
                    continue;
                }
                Unload(cfg.loadType, item.Value);
            }
            fxAssets.Clear();
            base.UnInit();
        }
    }
    public class BattleInstantiateAssetLoader : BattleResLoader
    {
        List<Object> assets = new List<Object>();

        public override Object Load(ResLoadArg arg)
        {
            var asset = _Load(arg);
            if (asset == null)
                return null;
            assets.Add(asset);
            OnLoad(asset, arg, new LoadedResInfo(true));
            var inst = GameObject.Instantiate(asset);
            OnLoad(inst, arg, new LoadedResInfo(false));
            return inst;
        }

        public override void UnInit()
        {
            base.UnInit();
            for (int i = 0; i < assets.Count; i++)
            {
                Unload(BattleResLoadType.Asset, assets[i]);
            }
            assets.Clear();
        }
    }
}