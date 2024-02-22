using System.Collections.Generic;

namespace X3Battle
{
    //lua需要标注序号，这里先别删掉序号
    // 注意：如果新增Fx类型， 必须护对应的IsFxResType接口
    // 注意：如果新增UI类型， 必须护对应的IsUIResType接口
    // 注意：如果新增Audio类型， 必须护对应的IsBattleResAudio接口
    public enum BattleResType
    {
        Hero = 0,
        Monster = 1,
        Item = 2,
        FX = 3,//Battle
        Weapon = 4,
        Camera = 5,
        Texture = 6,
        Timeline = 7,
        TimelineFx = 8,
        TimelineAsset = 9,
        PhysicsWind = 10,
        ShakeBone = 11,
        CameraAsset = 12,
        CameraAnimatorController = 13,
        RoleAnimatorController = 14,
        DynamicUI = 15,
        SceneMapData = 16,
        UI = 17,
        NavMesh = 18,
        LevelMaker = 19,
        Machine = 20,
        ActorAudio = 21, // 音频
        TimelineAudio = 22, // timeline上的音频
        BulletAudio = 23, // 子弹的音频
        Fsm = 24,
        AITree = 25,
        Flow = 26,
        MessagePack = 27,
        MatCurveAsset = 29,
        Material = 30, // 材质
        Shadow = 31, // 残影prefab
        ShadowData = 32, // 残影数据
        HurtBackCurve = 33,
        ScenePathGraph = 34,
        Misc = 35,
        BGM = 36, // 背景音乐
        HurtFX = 37, // 受击特效
        UIAudio = 38, // UI音效
        BlendSpaceAsset = 39,
        LookAtCfgAsset = 40,
        TriggerGraph = 41, // 触发器蓝图(FlowCanvas)资源.
        TriggerBlackboard = 42, // 触发器黑板资源, 用来覆盖TriggerGraph资源里的黑板数据
        CameraImpulseAsset = 43, // 震屏
        Atlas = 44,
        Sprite = 45,//！！！分析出来，仅仅用于打图集。 动态引用的图标资源，技能图标和buff图标。需要进图集，不走统一预加载
        SystemDynamicUI = 46,
        PhysicsWindConfigAsset = 47, // 风场配置文件
        SceneSVC = 48, // 场景SVC，一个场景prefab 一个SVC
        MonsterSVC = 49, // 怪物SVC， 一个怪物prefab 一个SVC
        CharacterSVC = 50, // 角色SVC，一个部件一个SVC
        GlobalBlackboard = 51, // 全局黑板
        FxAudio = 52, // 特效的音频
        TagTexture = 53, //Tag贴图
        Test = 54, // 测试资源
        LocomotionAsset = 55,
 		PPV = 56,
        ActorSceneLight = 57,//角色场景灯
        ModelInfoCommonAsset = 58,//模型信息通用配置
		CameraCollider = 59,
		SceneAltitudeMap = 60, // 场景高度图
        VFXSVC = 61,
        HWVFXSVC = 62,
        InterActor = 63,
        AllFX = 64,//全路径特效
        DesignModel = 65, // 策划设计模型,目前用于在交互物表加载一些场景物件
        Num = 66, //这里需要确保Num是最大值，用于for遍历. 大于该值的type，对象池不会预加载的
        
        Lua = 10000,  // 从10000开始避免枚举增加导致版本异常，下面会自增
        Scene,
        DynamicCfgs, // 动态配置，例如技能，buff等由编辑器生成的配置数据
        CharacterParts, // 快速出包时,需要分析角色的部件，以及部件依赖的资产
        WeaponAsset, // 快速出包时，需要分析武器依赖的资产
        MonsterAsset, // 快速出包时，需要分析Monster依赖的资产
        
        // ！！！！ 类型新增请注意查看上面注意事项 ！！！！！//
    }

    public enum BattleResLoadType
    {
        Prefab = 1,
        Asset = 2,
        Hero = 3,
        Audio = 5,
        NavMesh = 6,
        Texture = 7,
        Music = 8,
        Atlas = 9,
        Sprite = 10,
        ShaderVariants = 11,
    }

    public enum BattleResPoolType
    {
        BattleResPool = 0,
        EmptyPool,
        GameObjectPool,
        GameObjectVisiblePool,
        GraphAssetPool,
        FxResPool,
        FxResVisiblePool,
    }

    public enum BattleResLoaderType
    {
        CommonLoader, // 默认类型
        InstAssetLoader,
        BattleFxLoader,
        SameResLoadOnceLoader,
    }

    public class BattleResConfigItem
    {
        public string dir; // 资源文件夹路径
        public string ext; // 资源后缀名
        public BattleResLoadType loadType;
        public int maxPreloadCount; // 单个资源的最大预加载（预创建）数量
        public int maxCacheCount; // 单个资源的最大缓存数量
        public bool disableLoadError; // 是否禁止动态加载的错误提示
        public BattleResPoolType poolType; //使用的缓存池类型
        public BattleResLoaderType loaderType; //使用的资源加载器类型
        public bool enableStreaming; // 是否开启pool 的streaming机制
    }

    public static class BattleResConfig
    {
        public static Dictionary<BattleResType, BattleResConfigItem> Config { get; }

        static BattleResConfig()
        {
            Config = new Dictionary<BattleResType, BattleResConfigItem>();
            Config[BattleResType.Hero] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Hero,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Monster] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/Prefabs/Monster/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Item] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/Prefabs/Item/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Machine] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/Prefabs/Monster/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Shadow] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/Battle/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.ShadowData] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.Weapon] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Camera] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Camera/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Texture] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Texture/",
                ext = BattleConst.ExtTga,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.AllFX] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.FxResVisiblePool,
                loaderType = BattleResLoaderType.BattleFxLoader,
                maxPreloadCount = 5,
                enableStreaming = true,
            };
            Config[BattleResType.FX] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/Battle/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.FxResVisiblePool,
                loaderType = BattleResLoaderType.BattleFxLoader,
                maxPreloadCount = 5,
                enableStreaming = true,
            };
            Config[BattleResType.HurtFX] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/Battle/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.FxResVisiblePool,
                loaderType = BattleResLoaderType.BattleFxLoader,
                maxPreloadCount = 10,
                maxCacheCount = 10,
                enableStreaming = true,
            };
            Config[BattleResType.TimelineFx] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/",
                ext = string.Empty,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.FxResVisiblePool,
                loaderType = BattleResLoaderType.BattleFxLoader,
                enableStreaming = true,
            };
            Config[BattleResType.Timeline] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Timeline/Prefabs/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectVisiblePool,
            };
            Config[BattleResType.TimelineAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Timeline/PlayableAssets/",
                ext = BattleConst.ExtPlayable,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.PhysicsWind] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Physics/WindField/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.Misc] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Misc/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.ShakeBone] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Misc/ShakeBones/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.CameraAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Camera/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.CameraImpulseAsset] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/CameraImpulse/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
                loaderType = BattleResLoaderType.InstAssetLoader,
            };
            Config[BattleResType.CameraAnimatorController] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Camera/",
                ext = BattleConst.ExtController,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.RoleAnimatorController] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Animations/AnimatorController/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.DynamicUI] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/DynamicUIPrefab/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.SystemDynamicUI] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/GameObjectRes/UI/DynamicUIPrefab/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.Atlas] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/GameObjectRes/UI/SpriteAtlas/",
                ext = BattleConst.ExtAtlas,
                loadType = BattleResLoadType.Atlas,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.Sprite] = new BattleResConfigItem
            {
                //使用全路径配置，自带后缀
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Sprite,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.SceneMapData] = new BattleResConfigItem
            {
                //dir = "Assets/Build/Art/Scene/map/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.UI] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/GameObjectRes/UI/UIView/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
                maxPreloadCount = 1,
            };
            Config[BattleResType.NavMesh] = new BattleResConfigItem
            {
                // Navmesh使用全路径配置，自带后缀
                // dir = "Assets/Build/Art/Scene/NavMeshes/",
                // ext = BattleConst.ExtAsset,  
                loadType = BattleResLoadType.NavMesh,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.LevelMaker] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/LevelMaker/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.ActorAudio] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Audio,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.TimelineAudio] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Audio,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.BulletAudio] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Audio,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.UIAudio] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Audio,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.FxAudio] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Audio,
                poolType = BattleResPoolType.EmptyPool,
            };
            Config[BattleResType.BGM] = new BattleResConfigItem
            {
                dir = string.Empty,
                ext = string.Empty,
                loadType = BattleResLoadType.Music,
            };
            Config[BattleResType.Fsm] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/FSM/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GraphAssetPool,
                loaderType = BattleResLoaderType.CommonLoader,
            };
            Config[BattleResType.AITree] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/BattleAI/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GraphAssetPool,
                loaderType = BattleResLoaderType.CommonLoader,
            };
            Config[BattleResType.Flow] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/FlowCanvas/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GraphAssetPool,
                loaderType = BattleResLoaderType.CommonLoader,
            };
            Config[BattleResType.TriggerGraph] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/FlowCanvas/Trigger/Graph/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GraphAssetPool,
                loaderType = BattleResLoaderType.CommonLoader,
            };
            Config[BattleResType.MessagePack] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/MessagePack/",
                ext = BattleConst.ExtBytes,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.TriggerBlackboard] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/FlowCanvas/Trigger/Config/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.MatCurveAsset] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Art/Fx/MaterialAniAssets/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.Material] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Res/Battle/Material/",
                ext = BattleConst.ExtMat,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.TagTexture] = new BattleResConfigItem()
            {
                dir = "Assets/Build/Art/Fx/Texture/BattleTag/",
                ext = BattleConst.ExtPng,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.HurtBackCurve] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/HurtBack/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.ScenePathGraph] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/NavMeshes/Battle/",
                ext = BattleConst.ExtBytes,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.SceneAltitudeMap] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/NavMeshes/Battle/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.BlendSpaceAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/LookAt/MonsterBlendSpaces/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.LookAtCfgAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/LookAt/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.PhysicsWindConfigAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Physics/WindField/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.SceneSVC] = new BattleResConfigItem
            {
                dir = "", // SVC 的路径有一套自己的路径处理规则，这里不在配置(下同)
                ext = "",
                loadType = BattleResLoadType.ShaderVariants,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.MonsterSVC] = new BattleResConfigItem
            {
                dir = "",
                ext = "",
                loadType = BattleResLoadType.ShaderVariants,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.CharacterSVC] = new BattleResConfigItem
            {
                dir = "",
                ext = "",
                loadType = BattleResLoadType.ShaderVariants,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.VFXSVC] = new BattleResConfigItem
            {
                dir = "",
                ext = "",
                loadType = BattleResLoadType.ShaderVariants,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.GlobalBlackboard] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Misc/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
                loaderType = BattleResLoaderType.SameResLoadOnceLoader,
            };
            Config[BattleResType.Test] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Test/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.LocomotionAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/Locomotion/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.PPV] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Fx/Prefab/Battle/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
			Config[BattleResType.ActorSceneLight] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Lightings/Prefab/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
			Config[BattleResType.ModelInfoCommonAsset] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/ModelInfo/",
                ext = BattleConst.ExtAsset,
                loadType = BattleResLoadType.Asset,
                poolType = BattleResPoolType.BattleResPool,
            };
            Config[BattleResType.CameraCollider] = new BattleResConfigItem
			{
                dir = "Assets/Build/Res/Battle/CameraCollider/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };            
            Config[BattleResType.InterActor] = new BattleResConfigItem
            {
                dir = "Assets/Build/Art/Character/Prefabs/Monster/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };
            Config[BattleResType.DesignModel] = new BattleResConfigItem
            {
                dir = "Assets/Build/Res/Battle/ModelPrefabs/",
                ext = BattleConst.ExtPrefab,
                loadType = BattleResLoadType.Prefab,
                poolType = BattleResPoolType.GameObjectPool,
            };

            //资源配置预处理, 避免每个使用的地方都进行一次判断
            foreach (var item in Config)
            {
                int num = item.Value.maxCacheCount;
                item.Value.maxCacheCount = num == 0 ? BattleConst.MaxCacheCount : num;
                num = item.Value.maxPreloadCount;
                item.Value.maxPreloadCount = num == 0 ? BattleConst.MaxPreloadCount : num;
            }
        }

        public static BattleResConfigItem GetResConfig(BattleResType type)
        {
            Config.TryGetValue(type, out var cfg);
            return cfg;
        }
    }
}