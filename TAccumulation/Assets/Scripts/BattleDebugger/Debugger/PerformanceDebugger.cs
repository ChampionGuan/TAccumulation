#if DEBUG_GM || UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle.Debugger
{
    public class PerformanceDebugger : IDebugger
    {
        public const int Version = 0;
        public const string KeyDebugVersion = "__BattleDebugger___KeyDebugVersion";
        public const string DisableBoy = "__BattleDebugger___DisableBoy";
        public const string DisableGirl = "__BattleDebugger___DisableGirl";
        public const string DisableBoss = "__BattleDebugger___DisableBoss";
        public const string DisableScene = "__BattleDebugger___DisableScene";
        public const string DisableTimelineFX = "__BattleDebugger___DisableTimelineFX";
        public const string DisableNotTimelineFX = "__BattleDebugger___DisableNotTimelineFX";
        public const string RecordeReplayFile = "__BattleDebugger___RecordeReplayFile";
        public const string DisableBattleWorld = "__BattleDebugger___DisableBattleWorld";
        public const string OverallSkipLevel = "__BattleDebugger___OverallSkipLevel"; // 跳过所有关卡，赢或输，使用下面的key值
        public const string OverallSkipLevelToWin = "__BattleDebugger___OverallSkipLevelToWin"; // 赢的方式，跳过所有关卡

        public static StoragePrefs Prefs = new StoragePrefs(new Dictionary<string, object>
        {
            { KeyDebugVersion, 0 },
            { DisableBoy, false },
            { DisableGirl, false },
            { DisableBoss, false },
            { DisableScene, false },
            { DisableTimelineFX, false },
            { DisableNotTimelineFX, false },
            { RecordeReplayFile, false },
            { DisableBattleWorld, false },
            { OverallSkipLevel, false },
            { OverallSkipLevelToWin, true },
        });

        private static List<string> DebugKey = Prefs.dict.Keys.ToList();

        // 用于：一局战斗内的设置不会影响到下一场战斗
        private static List<string> NoCacheKeys = new List<string> { DisableBattleWorld };

        // 角色隐藏数据
        private static Dictionary<int, int> actorVisible = new Dictionary<int, int>();

        private static Battle battle => Battle.Instance;
        public string name => "性能测试";

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Init()
        {
            BattleClient.OnStartup.RemoveListener(_OnBattleStartup);
            BattleClient.OnStartup.AddListener(_OnBattleStartup);
            
            BattleClient.OnBegin.RemoveListener(_OnBattleBegin);
            BattleClient.OnBegin.AddListener(_OnBattleBegin);
            
            BattleClient.OnShutdown.RemoveListener(_OnBattleShutdown);
            BattleClient.OnShutdown.AddListener(_OnBattleShutdown);
        }

        private static void _OnBattleStartup()
        {
            // 清除数据
            actorVisible.Clear();

            // 当前版本,版本变更删除本地的缓存
            if ((int)Prefs.Get(KeyDebugVersion) != Version)
            {
                foreach (var key in DebugKey)
                {
                    Prefs.Delete(key);
                }

                Prefs.Set(KeyDebugVersion, Version);
            }

            // 不需要缓存的，每场战斗都重置缓存为默认值
            foreach (var key in NoCacheKeys)
            {
                Prefs.Restore(key);
            }

            // 初始化的生命周期最早阶段
            foreach (var key in DebugKey)
            {
                switch (key)
                {
                    case DisableTimelineFX:
                    case DisableNotTimelineFX:
                        _UpdateDebugKey(key);
                        break;
                }
            }

            battle.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, _OnActorBorn, "PerformanceDebugger._OnActorBorn");
            battle.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelStart, _OnLevelStart, "PerformanceDebugger._OnLevelStart");
        }

        private static void _OnBattleBegin()
        {
            foreach (var key in DebugKey)
            {
                switch (key)
                {
                    // 初始化的生命周期最晚阶段
                    case KeyDebugVersion:
                    case DisableTimelineFX:
                    case DisableNotTimelineFX:
                    case OverallSkipLevel:
                        continue;
                }

                _UpdateDebugKey(key);
            }
        }

        private static void _OnBattleShutdown()
        {
            actorVisible.Clear();
        }

        private static void _OnLevelStart(ECEventDataBase _)
        {
            var value = (bool)Prefs.Get(OverallSkipLevel);
            if (!value) return;
            CoroutineProxy.StartCoroutine(_ToFinishBattle());
        }

        private static IEnumerator _ToFinishBattle()
        {
            yield return new WaitForSeconds(0.5f);
            _UpdateDebugKey(OverallSkipLevel);
        }

        private static void _OnActorBorn(EventActorBase par)
        {
            var key = _TryGetActorKey(par.actor);
            if (string.IsNullOrEmpty(key) || !Prefs.Has(key)) return;
            // 隐藏单位
            if ((bool)Prefs.Get(key))
            {
                _EnableActorModel(par.actor, false);
            }
        }

        private static string _TryGetActorKey(Actor actor)
        {
            string key = null;
            switch (actor.type)
            {
                case ActorType.Hero:
                    if (actor.IsGirl())
                        key = DisableGirl;
                    else if (actor.IsBoy())
                        key = DisableBoy;
                    break;
                case ActorType.Monster:
                    key = DisableBoss;
                    break;
            }

            return key;
        }

        private static void _UpdateDebugKey(string key)
        {
            if (null == battle || string.IsNullOrEmpty(key) || !Prefs.Has(key)) return;
            var isDisable = (bool)Prefs.Get(key);
            var isVisible = !isDisable;
            switch (key)
            {
                case DisableBoy:
                    _EnableActorModel(battle.actorMgr.boy, isVisible);
                    break;
                case DisableGirl:
                    _EnableActorModel(battle.actorMgr.girl, isVisible);
                    break;
                case DisableBoss:
                    var actors = ObjectPoolUtility.CommonActorList.Get();
                    battle.actorMgr.GetActors(ActorType.Monster, outResults: actors);
                    foreach (var actor in actors)
                    {
                        _EnableActorModel(actor, isVisible);
                    }

                    ObjectPoolUtility.CommonActorList.Release(actors);
                    break;
                case DisableScene:
                    var obj = Res.GetSceneRoot();
                    if (obj && obj.activeSelf != isVisible)
                        obj.SetActive(isVisible);
                    break;
                case DisableTimelineFX:
                    if (Battle.Instance != null && Battle.Instance.isBegin)
                    {
                        LogProxy.LogError("战斗中，特效调试GM，不支持实时打开关闭。下一场战斗生效");
                        return;
                    }

                    var resMgr = BattleResMgr.Instance;
                    resMgr.poolMgr.EnablePool(BattleResType.TimelineFx, isVisible);
                    break;
                case DisableNotTimelineFX:
                    if (Battle.Instance != null && Battle.Instance.isBegin)
                    {
                        LogProxy.LogError("战斗中，特效调试GM，不支持实时打开关闭。下一场战斗生效");
                        return;
                    }

                    resMgr = BattleResMgr.Instance;
                    resMgr.poolMgr.EnablePool(BattleResType.FX, isVisible);
                    resMgr.poolMgr.EnablePool(BattleResType.HurtFX, isVisible);
                    break;
                case DisableBattleWorld:
                    Battle.Instance.SetWorldEnable(isVisible, BattleEnabledMask.Debugger);
                    break;
                case OverallSkipLevel:
                    if (isDisable)
                    {
                        var isWin = (bool)Prefs.Get(OverallSkipLevelToWin);
                        if (BattleClient.Instance != null) BattleClient.Instance.End(isWin);
                    }

                    break;
                case RecordeReplayFile:
                case OverallSkipLevelToWin:
                    break;
                default:
                    LogProxy.LogErrorFormat("不支持的BattleDebugKey:{0}", key);
                    break;
            }

            LogProxy.LogErrorFormat("【战斗性能调试】设置key：{0} 对应逻辑，请注意！！", key);
        }

        private static void _EnableActorModel(Actor actor, bool isVisible)
        {
            if (actor == null)
            {
                return;
            }

            var model = actor.GetDummy(ActorDummyType.Model)?.gameObject;
            if (null == model) return;

            var insID = actor.insID;
            if (actorVisible.TryGetValue(insID, out var uuid))
            {
                model.RemoveVisible(uuid);
                actorVisible.Remove(insID);
            }

            uuid = model.AddVisible(isVisible);
            actorVisible.Add(insID, uuid);
        }

        public static void SetDebugKey(string key, bool isDisable)
        {
            if (!DebugKey.Contains(key)) return;
            Prefs.Set(key, isDisable);
            _UpdateDebugKey(key);
        }

        public static bool GetDebugKey(string key)
        {
            if (!DebugKey.Contains(key)) return false;
            return (bool)Prefs.Get(key);
        }

        public void OnEnter()
        {
        }

        public void OnExit()
        {
        }

        public void OnGUI()
        {
            using (new GUILayout.AreaScope(new Rect(Screen.width * 0.3f, 0, Screen.width, Screen.height)))
            {
                _DrawToggle(DisableBoy, "隐藏男主");
                _DrawToggle(DisableGirl, "隐藏女主");
                _DrawToggle(DisableBoss, "隐藏怪物");
                _DrawToggle(DisableScene, "隐藏场景");
                _DrawToggle(DisableTimelineFX, "关闭战斗Timeline特效");
                _DrawToggle(DisableNotTimelineFX, "关闭战斗非Timeline特效");
                _DrawToggle(RecordeReplayFile, "记录回放文件");
                _DrawToggle(DisableBattleWorld, "暂停游戏逻辑");
                _DrawToggle(OverallSkipLevel, "全局战斗关卡跳过");
                _DrawToggle(OverallSkipLevelToWin, "若全局跳过结果为胜利（不勾选则失败）");
                if (GUILayout.Button("清除数据", GUILayout.Width(100)))
                {
                    Prefs.DeleteAll();
                }
            }
        }

        private void _DrawToggle(string key, string desc)
        {
            var result = GUILayout.Toggle((bool)Prefs.Get(key), desc);
            if (GUI.changed)
            {
                SetDebugKey(key, result);
            }
        }
    }
}
#endif