using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public partial class ActorMgr
    {
        private List<StageIdWeight> _cachedStageIdWeights = new List<StageIdWeight>(5);
        private HashSet<int> _groupTypes = new HashSet<int>();
        private int _groupType;
        
        public void Preload()
        {
            if (!battle.isPreloading) return;
            CreateHero();
            _RollGroupType();
            _ForEach(_stageConfig.SpawnPoints, config => _PreloadMonster(config.ID));
            _ForEach(_stageConfig.TriggerAreas, config => CreateTriggerArea(config.ID));
            _ForEach(_stageConfig.Obstacles, config => CreateObstacle(config.ID));
            _ForEach(_stageConfig.Machines, config => CreateMachine(config.ID));
        }

        public void PreloadFinished()
        {
            _ClearActorRefs();
            _CreateAllGroups();
        }
        
        private void _RollGroupType()
        {
            int totalWeight = 0;
            _cachedStageIdWeights.Clear();
            _groupTypes.Clear();
            if (_stageConfig.GroupTypeWeights == null)
            {
                _groupTypes.Add(0);
                return;
            }
            foreach (StageIdWeight stageIdWeight in _stageConfig.GroupTypeWeights)
            {
                if (stageIdWeight.Weight <= 0)
                {
                    if (stageIdWeight.Weight < 0)
                    {
                        _groupTypes.Add(stageIdWeight.ID);
                    }
                    continue;
                }
                totalWeight += stageIdWeight.Weight;
                stageIdWeight.TopWeight = totalWeight;
                _cachedStageIdWeights.Add(stageIdWeight);
            }
            int targetWeight = Random.Range(0, totalWeight + 1);
            foreach (StageIdWeight stageIdWeight in _cachedStageIdWeights)
            {
                if (targetWeight <= stageIdWeight.TopWeight)
                {
                    _groupTypes.Add(stageIdWeight.ID);
                    break;
                }
            }
        }

        private Actor _PreloadMonster(int spawnPointID)
        {
            var spawnPoint = _GetElement(_stageConfig.SpawnPoints, spawnPointID);
            if (spawnPoint == null)
            {
                LogProxy.LogError($"刷怪点(ID = {spawnPointID}) 没有找到，请找策划");
                return null;
            }

            var count = GetActors(ActorType.Monster, cfgId: spawnPoint.ConfigID);
            int maxNum = _GetMemoryLimitNum(TbUtil.battleConsts.BattlePreloadMonsterCount);
            if (count >= maxNum)
            {
                return null;
            }
            return CreateMonster(spawnPointID);
        }

        public void PreloadSummonCreature(ISkill masterSkill, int summonId, Vector3 pos, float angleY, bool useWorldForward = false, FactionType? factionType = null)
        {
            if (!battle.isPreloading) return;
            var battleSummon = TbUtil.GetCfg<BattleSummon>(summonId);
            if (battleSummon == null)
            {
                LogProxy.LogErrorFormat("请联系策划【卡宝】, BattleSummon配置获取失败, ID={0}", summonId);
                return;
            }
            
            // DONE: 是否超过该单位的召唤最大数量限制.
            int curNum = masterSkill.actor.GetCreatures(battleSummon.ID);
            int maxNum = Math.Min(battleSummon.MaxNum, _GetMemoryLimitNum(TbUtil.battleConsts.BattlePreloadSummonCreatureCount));
            if (curNum >= maxNum)
            {
                return;
            }

            for (int i = 0; i < maxNum - curNum; i++)
            {
                SummonMonster(masterSkill, summonId, pos, angleY, useWorldForward, factionType);
            }
        }

        public void PreloadSummonMagicField(DamageExporter master, int magicFieldID, Vector3 targetPos, Vector3 targetEuler, bool autoRelease = false)
        {
            if (!battle.isPreloading) return;

            // DONE: 法术场最大数量处理.
            int curNum = GetActors(ActorType.SkillAgent, (int)SkillAgentType.MagicField, cfgId: magicFieldID);
            if (curNum >= _GetMemoryLimitNum(TbUtil.battleConsts.BattlePreloadMagicFieldCount))
            {
                return;
            }

            CreateMagicField(master, magicFieldID, targetPos, targetEuler, autoRelease);
        }

        public void PreloadSummonFakebody(Actor master)
        {
            if (!battle.isPreloading) return;
            var actor = SummonFakebody(master);
            RecycleActor(actor);
            _TryRecycleActorToCache(actor);
        }

        public void PreloadItem(Actor master, DamageExporter damageExporter, int itemLevel, int itemId)
        {
            if (!battle.isPreloading) return;
            
            // DONE: 道具最大数量处理.
            int curNum = GetActors(ActorType.Item, cfgId: itemId);
            if (curNum >= _GetMemoryLimitNum(TbUtil.battleConsts.BattlePreloadItemCount))
            {
                return;
            }

            CreateItem(master, damageExporter, 1, itemId, Vector3.zero, 0);
        }

        /// <summary>
        /// 预加载交互物
        /// </summary>
        public void PreloadInterAction(int id)
        {
            if (!battle.isPreloading) return;
            
            var interActorPoint = _GetElement(_stageConfig.InterActors, id);
            if (interActorPoint == null)
            {
                LogProxy.LogErrorFormat("请联系策划【一只喵】, 关卡编辑器interActorCfg配置获取失败, ID={0}", id);
                return;
            }

            if (interActorPoint.CreateType == InterActorCreateType.MonsterInterActor)
            {
                return;//如果是怪物版本的交互物不需要预加载，已经提前加载过了
            }
            
            var interActor = CreateInterActor(id);
            interActor.interActorOwner.Enable(false);
        }
        public void PreloadMissile(DamageExporter master, CreateMissileParam createParam)
        {
            if (!battle.isPreloading) return;

            // DONE: 子弹最大数量处理.
            int curNum = GetActors(ActorType.SkillAgent, (int)SkillAgentType.Missile, cfgId: createParam.missileID);
            if (curNum >= _GetMemoryLimitNum(TbUtil.battleConsts.BattlePreloadMissileCount))
            {
                return;
            }

            CreateMissile(master, createParam);

            var missileCfg = TbUtil.GetCfg<MissileCfg>(createParam.missileID);
            if (missileCfg != null && missileCfg.ricochetActive && missileCfg.ricochetMissileID > 0)
            {
                var childIDs = new HashSet<int>();
                RicochetUtil.GatherRicochetMissile(missileCfg.ricochetMissileID, ref childIDs);
                foreach (var childID in childIDs)
                {
                    var data = new RicochetData();
                    data.createMissileID = childID;
                    CreateMissile(master, null, ricochetData: data);
                }
            }
        }

        private int _GetMemoryLimitNum(int[] array)
        {
            if (array == null)
            {
                LogProxy.LogError($"【战斗】【预加载】配置的预加载数组:null, 根据堆栈排查对应数组配置问题!");
                return 1;
            }

            int index = BattleEnv.memorySizeLevel;
            if (index < 0 || index >= array.Length)
            {
                LogProxy.LogError($"【战斗】【预加载】配置的预加载数组:null, 获取的内存等级:{index}, 根据堆栈排查对应数组配置问题!");
                return 1;
            }
            
            return array[index];
        }
    }
}