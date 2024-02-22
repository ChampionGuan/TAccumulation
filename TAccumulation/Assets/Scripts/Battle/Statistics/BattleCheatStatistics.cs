using System;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using PapeGames.X3;
using UnityEngine.Profiling;

namespace X3Battle
{
    /// <summary>
    /// 防作弊统计数据
    /// </summary>
    public class BattleCheatStatistics : BattleComponent
    {
        //事件信息
        private List<CheatEventBase> m_events;

        //技能信息
        private Dictionary<int, CheatSkillBase> m_skills = new Dictionary<int, CheatSkillBase>();

        //伤害信息
        private List<CheatHurtBase> m_hurts;
        
        //属性信息
        private List<CheatAttrBase> m_attrs;

        //伤害调试信息 只在unity下生效
        private List<CheatDebugBase> m_debugs = new List<CheatDebugBase>();

        private readonly float THOUSANDTH = 0.001f;
        private const string DebugDirPath = "../../../Tools/BattleDebug/";
        private const string DirPath = "/Battle/";
        private const string DebugName = "Battle.txt";
        private const string UpSceneID = "BattleLog";
        public static string PassWord = "!asfd=sadf`1354";
        private byte[] _keyBytes = null;
        private Dictionary<int, CheatHurtBase> m_cheatHurtDic = new Dictionary<int, CheatHurtBase>();
        private readonly int ATTR_CD = TbUtil.battleConsts.BattleCheatCd;
        private bool m_need = false;    //是否需要采集数据
        private bool m_levelBegin = false;    //战斗是否开始倒计时
        private float m_lastCd = 0;    //上一次采集数据的时间
        private int m_levelId = 0;
        private int m_girlId = 0;
        private int m_boyId = 0;
        private bool isWin = false;
        private List<int> m_tempList = new List<int>(12);
        private float beginTime = 0;//战斗开始时间
        private float battleTime = 0;//战斗持续时间
        private AutoSigleBattleData _autoSigleBattleData;
        public BattleCheatStatistics() : base(BattleComponentType.BattleCheatStatistics)
        {
            requiredAnimationJobRunning = true;
        }

        protected override void OnStart()
        {
            base.OnStart();
            using (var sha256 = new SHA256CryptoServiceProvider())
            {
                _keyBytes = sha256.ComputeHash(Encoding.Unicode.GetBytes(PassWord));
            }
            m_need = GetIsMarkLevel();
            m_levelId = battle.arg.levelID;
            m_girlId = battle.arg.girlID;
            m_boyId = battle.arg.boyID;
            isWin = false;
            beginTime = battle.time;
            //editor 策划要求打印日志
            if (Application.isEditor && !AutoSigleBattleData.IS_AUTORUN)
            {
                _autoSigleBattleData = new AutoSigleBattleData();
                _autoSigleBattleData.Init(battle.arg, X3Battle.Battle.Instance, 1, null);
            }
            
            if (!m_need && !Application.isEditor)
                return;
            
            m_events = new List<CheatEventBase>(200);
            m_hurts = new List<CheatHurtBase>(100);
            m_attrs = new List<CheatAttrBase>(200);
            battle.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _OnBuffChange, "BattleCheatStatistics._OnBuffChange");
            battle.eventMgr.AddListener<EventAttrChange>(EventType.AttrChange, _OnAttrChange, "BattleCheatStatistics._OnAttrChange");
            battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill, "BattleCheatStatistics._OnCastSkill");
            battle.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _OnSkillEnd, "BattleCheatStatistics._OnSkillEnd");
            battle.eventMgr.AddListener<EventOnKillTarget>(EventType.OnKillTarget, _OnKillTarget, "BattleCheatStatistics._OnKillTarget");
            battle.eventMgr.AddListener<EventActor>(EventType.Actor, _OnActor, "BattleCheatStatistics._OnActor");
            battle.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _OnExportDamage, "BattleCheatStatistics._OnExportDamage");
            battle.eventMgr.AddListener<EventLockHp>(EventType.OnLockHp, _OnLockHp, "BattleCheatStatistics._OnLockHp");
            battle.eventMgr.AddListener<EventBattleEnd>(EventType.OnBattleEnd, OnBattleEnd, "BattleCheatStatistics._OnBattleEnd");
            battle.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelStart, _OnLevelBegin, "BattleCheatStatistics._OnLevelBegin");
            battle.eventMgr.AddListener<EventCoreChange>(EventType.CoreChange, _OnCoreChange, "BattleCheatStatistics._OnCoreChange");
            battle.eventMgr.AddListener<EventTauntActor>(EventType.TauntActorChange, _OnTauntTargetChange, "BattleCheatStatistics._OnTauntTargetChange");
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            if (_autoSigleBattleData != null)
            {
                _autoSigleBattleData.OnDeatroy();
                _autoSigleBattleData = null;  
            }
            battle.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _OnBuffChange);
            battle.eventMgr.RemoveListener<EventAttrChange>(EventType.AttrChange, _OnAttrChange);
            battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill);
            battle.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _OnSkillEnd);
            battle.eventMgr.RemoveListener<EventOnKillTarget>(EventType.OnKillTarget, _OnKillTarget);
            battle.eventMgr.RemoveListener<EventActor>(EventType.Actor, _OnActor);
            battle.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _OnExportDamage);
            battle.eventMgr.RemoveListener<EventLockHp>(EventType.OnLockHp, _OnLockHp);
            battle.eventMgr.RemoveListener<EventBattleEnd>(EventType.OnBattleEnd, OnBattleEnd);
            battle.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelStart, _OnLevelBegin);
            battle.eventMgr.RemoveListener<EventCoreChange>(EventType.CoreChange, _OnCoreChange);
            battle.eventMgr.RemoveListener<EventTauntActor>(EventType.TauntActorChange, _OnTauntTargetChange);
        }

        protected override void OnAnimationJobRunning()
        {
            if (!m_need || battle == null || !m_levelBegin)
            {
                return;
            }

            if (battle.time - m_lastCd > ATTR_CD)
            {
                m_lastCd = battle.time;
                _CollectAttr();
            }
        }

        private void _CollectAttr()
        {
            foreach (var actor in battle.actorMgr.actors)
            {
                if (!actor.isDead && 
                    (actor.type == ActorType.Hero || actor.type == ActorType.Monster))
                {
                    CheatAttrBase attrBase = ObjectPoolUtility.CheatAttrPool.Get();
                    attrBase.Init(actor);
                    m_attrs.Add(attrBase);
                }
            }
        }
        
        private void _OnLockHp(EventLockHp arg)
        {
            CheatLockHp lockHp = ObjectPoolUtility.CheatLockHpPool.Get();
            lockHp.Init(arg.actor.cfgID, arg.lockHpBuffId, arg.lockHpValue);
            m_events.Add(lockHp);
        }

        private void _OnExportDamage(EventExportDamage arg)
        {
            var atker = arg.exporter.GetCaster();
            var hurter = arg.hurtActor;
            int skillType = 0;
            int skillID = arg.exporter.GetCfgID();
            using (ProfilerDefine.BattleCheatStatisticsOnExportDamagePMarker.Auto())
            {
                //如果是法术场照成的伤害 取用masterexporter的cfgID
                if (arg.exporter is SkillMagicField && arg.exporter.masterExporter != null)
                {
                    skillID = arg.exporter.masterExporter.GetCfgID();
                }
                //伤害统计
                CheatHurtBase hurtBase = ObjectPoolUtility.CheatHurtPool.Get();

                hurtBase.InitAtk(_GetPropertyID(atker), _GetCheatType(atker), _GetSummonLevel(atker),
                    _GetBelongPropertyID(atker),
                    _GetBelongType(atker), _GetCfgID(atker));

                hurtBase.InitHurt(_GetPropertyID(hurter), _GetCheatType(hurter), _GetSummonLevel(hurter),
                    _GetBelongPropertyID(hurter),
                    _GetBelongType(hurter), _GetCfgID(hurter));

                hurtBase.InitBuff(atker, hurter);
                
                if (arg.exporter is ISkill)
                {
                    ISkill skill = arg.exporter as ISkill;
                    skillType = (int)skill.config.Type;
                }

                //破核计算
                bool isWeak = hurter.actorWeak != null && hurter.actorWeak.weak;
                hurtBase.InitSkill(skillID, skillType, arg.hitParamConfig.HitParamID,
                    arg.hitInfo.damageProportion, arg.hurtCritical, (int)arg.totalDamage, isWeak, battle.time,
                    arg.hitInfo.hitParamConfig.ID);
                m_hurts.Add(hurtBase);
                //技能统计
                if (m_skills.ContainsKey(skillID))
                {
                    if (arg.damageType == DamageType.Sub)
                    {
                        m_skills[skillID].AddData(0, arg.totalDamage);
                    }
                }
            }

            //debug 伤害信息
#if UNITY_EDITOR
            CheatDebugBase debugBase = new CheatDebugBase();

            debugBase.InitAtk(skillID, atker.cfgID,
                atker.attributeOwner.GetAttrValue(AttrType.PhyAttack), atker.level,
                atker.attributeOwner.GetAttrValue(AttrType.HurtAdd) * THOUSANDTH,
                atker.attributeOwner.GetAttrValue(AttrType.FinalDamageAdd) * THOUSANDTH,
                _GetSkillDamage((SkillSlotType) skillType, atker),
                atker.attributeOwner.GetAttrValue(AttrType.CritVal) * THOUSANDTH,
                atker.attributeOwner.GetAttrValue(AttrType.CritHurtAdd) * THOUSANDTH,
                hurter.attributeOwner.GetAttrValue(AttrType.FinalDamageDec) * THOUSANDTH);

            debugBase.InitHurt(hurter.attributeOwner.GetAttrValue(AttrType.PhyDefence),
                hurter.attributeOwner.GetAttrValue(AttrType.HurtDec),
                hurter.attributeOwner.GetAttrValue(AttrType.FinalDamageDec) * THOUSANDTH,
                arg.totalDamage);

            m_debugs.Add(debugBase);
#endif
        }

        private float _GetSkillDamage(SkillSlotType skillType, Actor actor)
        {
            float skillDamage = 0.0f;
            if (skillType == SkillSlotType.Attack)
            {
                skillDamage = actor.attributeOwner.GetAttrValue(AttrType.AttackSkillAdd) * THOUSANDTH;
            }
            else if (skillType == SkillSlotType.Active)
            {
                skillDamage = actor.attributeOwner.GetAttrValue(AttrType.ActiveSkillAdd) * THOUSANDTH;
            }
            else if (skillType == SkillSlotType.Combo)
            {
                skillDamage = actor.attributeOwner.GetAttrValue(AttrType.CoopSkillAdd) * THOUSANDTH;
            }
            else if (skillType == SkillSlotType.Ultra)
            {
                skillDamage = actor.attributeOwner.GetAttrValue(AttrType.UltraSkillAdd) * THOUSANDTH;
            }

            return skillDamage;
        }

        private void _OnActor(EventActor arg)
        {
            if (arg.actor == null)
            {
                return;
            }

            if (arg.actor.type != ActorType.Hero && arg.actor.type != ActorType.Monster)
            {
                return;
            }
            
            CheatActor cheatActor = ObjectPoolUtility.CheatActorPool.Get();
            cheatActor.Init(arg.actor.cfgID, arg.state);
            m_events.Add(cheatActor);
        }

        private void _OnKillTarget(EventOnKillTarget arg)
        {
            CheatOnKillTarget onKillTarget = ObjectPoolUtility.CheatOnKillPool.Get();
            onKillTarget.Init(arg.killer.cfgID, arg.deader.cfgID);
            m_events.Add(onKillTarget);
        }

        private void _OnCastSkill(EventCastSkill arg)
        {
            //子弹类技能 法术场技能 物体类 不统计
            if (arg.skill?.GetCaster() == null || arg.skill?.GetCaster().type == ActorType.Item || arg.skill is SkillMissile || arg.skill is SkillMagicField)
                return;

            int skillTargetID = arg.skillTarget == null ? 0 : arg.skillTarget.cfgID;
            CheatCastSkill castSkill = ObjectPoolUtility.CheatCastSkillPool.Get();
            castSkill.Init(arg.skill.GetID(), skillTargetID, arg.skill.GetCaster().config.ID);
            m_events.Add(castSkill);

            //怪物释放技能不统计
            if (arg.skill.GetCaster().type == ActorType.Monster)
                return;
            
            if (!m_skills.ContainsKey(arg.skill.GetID()))
            {
                CheatSkillBase skillBase = ObjectPoolUtility.CheatSkillPool.Get();
                skillBase.Init(arg.skill.GetID(), 1, 0);
                m_skills.Add(arg.skill.GetID(), skillBase);
            }
            else
            {
                m_skills[arg.skill.GetID()].AddData(1, 0);
            }
        }

        private void _OnBuffChange(EventBuffChange arg)
        {
            if (arg.buff == null || arg.caster == null || arg.target == null)
                return;
            CheatBuffEvent buffEvent = ObjectPoolUtility.CheatBuffEventPool.Get();
            buffEvent.Init(arg.buff.ID, arg.caster.cfgID, arg.target.cfgID, arg.type);
            m_events.Add(buffEvent);
        }

        private void _OnAttrChange(EventAttrChange arg)
        {
            // type >=1000不统计
            if (arg.actor == null || (int)arg.type >=1000)
                return;
            CheatAttrChangeEvent attrChangeEvent = ObjectPoolUtility.CheatAttrChangePool.Get();
            attrChangeEvent.Init(arg.actor.cfgID, arg.type, arg.oldValue, arg.newValue);
            m_events.Add(attrChangeEvent);
        }

        private void _OnSkillEnd(EventEndSkill arg)
        {
            if (arg.skill == null || arg.skill.GetCaster() == null)
                return;

            CheatEndSkill endSkill = ObjectPoolUtility.CheatEndSkillPool.Get();
            endSkill.Init(arg.skill.GetID(), arg.endType, arg.skill.GetCaster().config.ID);
            m_events.Add(endSkill);
        }

        private bool IsCreature(Actor actor)
        {
            var cacheActor = battle.statistics?.GetActorInfo(actor.spawnID);
            if (cacheActor != null)
            {
                return cacheActor.bornCfgType != CreatureType.None;
            }

            return false;
        }
        
        private CheatActorType _GetCheatType(Actor actor)
        {
            if (actor.type == ActorType.Monster)
            {
                if (actor.IsCreature() || IsCreature(actor))
                {
                    return CheatActorType.Summon;
                }
                else
                {
                    return CheatActorType.Monster;
                }
            }
            else if (actor.IsGirl())
            {
                return CheatActorType.Girl;
            }
            else if(actor.IsBoy())
            {
                return CheatActorType.Boy;
            }

            return CheatActorType.Max;
        }
        
        private int _GetSummonLevel(Actor actor)
        {
            if (_GetCheatType(actor) == CheatActorType.Summon && actor.master != null)
            {
                return actor.master.level;
            }

            return 0;
        }

        private int _GetBelongPropertyID(Actor actor)
        {
            if (_GetCheatType(actor) == CheatActorType.Summon && actor.master?.bornCfg != null)
            {
                return actor.master.bornCfg.PropertyID;
            }

            return 0;
        }

        private int _GetCfgID(Actor actor)
        {
            if (actor != null)
            {
                return actor.config.ID;
            }

            return 0;
        }
        
        private int _GetPropertyID(Actor actor)
        {
            if (_GetCheatType(actor) == CheatActorType.Summon)
            {
                return actor.config.ID;
            }
            else if (_GetCheatType(actor) == CheatActorType.Monster)
            {
                if (actor.bornCfg != null)
                    return actor.bornCfg.PropertyID;
            }
            
            return 0;
        }

        private CheatActorType _GetBelongType(Actor actor)
        {
            if (_GetCheatType(actor) == CheatActorType.Summon && actor.master != null)
            {
                return _GetCheatType(actor.master);
            }

            return 0;
        }

        private void OnBattleEnd(EventBattleEnd arg)
        {
            CheatBattleEnd cheatBattleEnd = ObjectPoolUtility.CheatBattleEndPool.Get();
            cheatBattleEnd.Init();
            m_events.Add(cheatBattleEnd);
            isWin = arg.isWin;
            battleTime = battle.time - beginTime;
            _WriteToLocalEditor();
        }
        private void _OnLevelBegin(ECEventDataBase arg)
        {
            m_levelBegin = true;
        }
        
        private void _OnCoreChange(EventCoreChange arg)
        {
            if (arg.actor == null || arg.actor.attributeOwner == null)
                return;
            CheatCoreChange coreEvent = ObjectPoolUtility.CheatCoreChangePool.Get();
            coreEvent.Init(arg.actor.config.ID, (int)arg.actor.attributeOwner.GetAttr(AttrType.WeakPoint).GetValue());
            m_events.Add(coreEvent);
        }

        private void _OnTauntTargetChange(EventTauntActor arg)
        {
            if (arg.actor == null || arg.tauntTarget == null)
                return;
            CheatTauntChange tauntChange = ObjectPoolUtility.CheatTauntChangePool.Get();
            tauntChange.Init(arg.actor.cfgID, arg.tauntTarget.cfgID);
            m_events.Add(tauntChange);
        }
        
        private void _WriteToLocalEditor()
        {
            if (!Application.isEditor)
                return;

            string fullPath = Path.GetFullPath(Application.dataPath + DebugDirPath);
            Directory.CreateDirectory(fullPath);
            fullPath = fullPath + DateTime.Now.Year + "-" + DateTime.Now.Month + "-" + DateTime.Now.Day + "-" +
                       DateTime.Now.Hour + "-" + DateTime.Now.Minute + DebugName;
            StringBuilder builder = new StringBuilder(2048);
            using (StreamWriter writer = new StreamWriter(File.Open(fullPath, FileMode.OpenOrCreate)))
            {
                foreach (var debug in m_debugs)
                {
                    builder.AppendFormat(
                        "攻击者-ID{0},攻击者-攻击力{1},攻击者-等级{2},攻击者-伤害加成{3},攻击者-最终伤害加成{4},攻击者-最终伤害加成系数{5},攻击者-技能伤害加成{6}," +
                        "攻击者-暴击率{7},攻击者-暴击伤害{8}",
                        debug.atkID, debug.atkAtk, debug.atkLevel, debug.atkDamage, debug.atkFinalDamage,
                        debug.atkFinalDamageAdd,
                        debug.atkSkillDamage, debug.atkCritVal, debug.atkCritHurt);
                    builder.AppendFormat(
                        "防守方-防御力{0},防守方-伤害减免{1},防守方-最终伤害减免{2}, ----- 本次伤害值={3} ",
                        debug.hurtDefend, debug.hurtDamage, debug.hurtFinalDamage, debug.damage);
                    writer.WriteLine(builder.ToString());
                    builder.Clear();
                }

                int CheatBuffEventCount = 0;
                int CheatAttrChangeEventCount = 0;
                int CheatCastSkillCount = 0;
                int CheatEndSkillCount = 0;
                int CheatOnKillTargetCount = 0;
                int CheatActorCount = 0;
                int CheatLockHpCount = 0;
                int CheatTauntChangeCount = 0;
                int CheatCoreChangeCount = 0;
                
                foreach (var eventBase in m_events)
                {
                    if (eventBase is CheatBuffEvent)
                    {
                        CheatBuffEventCount++;
                    }
                    else if(eventBase is CheatAttrChangeEvent)
                    {
                        CheatAttrChangeEventCount++;
                    }
                    else if (eventBase is CheatCastSkill)
                    {
                        CheatCastSkillCount++;
                    }
                    else if (eventBase is CheatEndSkill)
                    {
                        CheatEndSkillCount++;
                    }
                    else if (eventBase is CheatOnKillTarget)
                    {
                        CheatOnKillTargetCount++;
                    }
                    else if (eventBase is CheatActor)
                    {
                        CheatActorCount++;
                    }
                    else if (eventBase is CheatLockHp)
                    {
                        CheatLockHpCount++;
                    }
                    else if(eventBase is CheatTauntChange)
                    {
                        CheatTauntChangeCount++;
                    }
                    else if (eventBase is CheatCoreChange)
                    {
                        CheatCoreChangeCount++;
                    }
                }
                
                builder.Clear();
                builder.AppendFormat(
                    "CheatBuffEventCount:{0}  CheatAttrChangeEventCount:{1}" +
                    "CheatCastSkillCount:{2}  CheatEndSkillCount:{3} CheatOnKillTargetCount:{4}" +
                    "CheatActorCount:{5} CheatLockHpCount:{6}" +
                    "skillEventCount:{7}, HurtCount{8}, CheatTauntChangeCount{9}, CheatCoreChangeCount{10}", CheatBuffEventCount, CheatAttrChangeEventCount,
                    CheatCastSkillCount, CheatEndSkillCount, CheatOnKillTargetCount,
                    CheatActorCount, CheatLockHpCount, m_skills.Count, m_hurts.Count, CheatTauntChangeCount, CheatCoreChangeCount);
                writer.WriteLine(builder.ToString());
                builder.Clear();
                writer.Flush();
                writer.Close();
            }
        }

        /// <summary>
        /// 写入OSS上传日志文件
        /// </summary>
        /// <param name="path"></param>
        public void WriteOssFile(string formation)
        {
            string editorFullPath = Path.GetFullPath(Application.dataPath + DebugDirPath);
            string fullPath = Path.GetFullPath(Application.persistentDataPath + DirPath);
            LogProxy.Log("OSS: createdir");
            if (!Directory.Exists(fullPath))
            {
                Directory.CreateDirectory(fullPath);
            }
            
            //清除文件夹
            FileUtility.DirectoryDelChildren(fullPath);
            LogProxy.Log("OSS: cleardir");
            
            //对局时长
            string battleTimeStr = "BattleInfo_BattleTime:" + battleTime + "\n";
            
            //女主武器ID
            string weaponIDStr = "BattleInfo_WeaponID:" + battle.arg.girlWeaponID + "\n";
            
            //写入文件
            string curTime = DateTime.Now.Year + "." + DateTime.Now.Month + "." + DateTime.Now.Day + "." +
                             DateTime.Now.Hour + "." + DateTime.Now.Minute + "." + DateTime.Now.Millisecond;
            string dayTime = DateTime.Now.Year + "." + DateTime.Now.Month + "." + DateTime.Now.Day;
            string id = BattleEnv.LuaBridge.GetZoneID() + "+" + BattleEnv.LuaBridge.GePlayerID();
            string name = id + "-" + curTime + "-" + (int)battleTime + "-" + m_boyId + "-" + m_girlId + "-" + battle.arg.girlWeaponID + "-"+ m_levelId;
            string editorName = curTime + "-" + (AutoSigleBattleData.BATTLE_NUM + 1) + "-" + (int)battleTime + "-" + m_boyId + "-" + m_girlId + "-" + battle.arg.girlWeaponID + "-"+ m_levelId;
            
            fullPath = fullPath + name + ".txt";
            string editorPath = editorFullPath + editorName + ".txt";
            string realPath = Application.isEditor ? editorPath : fullPath;

            string txt = "";
            txt += formation;
            txt += battleTimeStr;
            txt += weaponIDStr;
            //editor下加入胜负结论
            if (Application.isEditor)
            {
                txt += "BattleInfo_Victory:" + isWin + "\n";
            }
            //写入属性数据
            foreach (var attr in m_attrs)
            {
                txt += attr.GetString() + "\n";
            }
                
            //写入伤害数据
            foreach (var hurt in m_hurts)
            {
                txt += hurt.GetString() + "\n";
            }
                
            //写入事件信息
            foreach (var eventBase in m_events)
            {
                txt += eventBase.GetString() + "\n";
            }
            
            //editor下不加密文件
            if (!Application.isEditor)
            {
                txt = BattleUtil.EncryptString(txt, _keyBytes);
            }
            
            StringBuilder builder = new StringBuilder(2048);
            using (StreamWriter writer = new StreamWriter(File.Open(realPath, FileMode.OpenOrCreate)))
            {
                writer.Write(txt);
                writer.Flush();
                writer.Close();
            }
            
            LogProxy.Log("OSS: upFile");
            
            if (!m_need || !isWin || Application.isEditor)
                return;

            //上传文件
            BattleEnv.LuaBridge.UpOssFile(UpSceneID, fullPath, "txt", id + "/" + dayTime, name);
            
            //文件上传之后删除
            FileUtility.DirectoryDelChildren(fullPath);
        }

        //获取相同ID中的最大伤害 
        //只获取怪物受到的伤害
        public List<CheatHurtBase> GetCheatHurtMax()
        {
            m_cheatHurtDic.Clear();
            foreach (var hurt in m_hurts)
            {
                if (m_cheatHurtDic.ContainsKey(hurt.skillID))
                {
                    if (m_cheatHurtDic[hurt.skillID].damageNum < hurt.damageNum)
                    {
                        m_cheatHurtDic[hurt.skillID] = hurt;
                    }
                }
                else
                {
                    m_cheatHurtDic.Add(hurt.skillID, hurt);
                }
            }

            m_tempList.Clear();
            foreach (var cheatHurtBase in m_cheatHurtDic)
            {
                if (cheatHurtBase.Value.hurtType != (int) CheatActorType.Monster)
                {
                    m_tempList.Add(cheatHurtBase.Key);
                }
            }

            foreach (var info in m_tempList)
            {
                m_cheatHurtDic.Remove(info);
            }
            
            return m_cheatHurtDic.Values.ToList();
        }

        //获取统计的技能信息
        public List<CheatSkillBase> GetCheatSkillInfo()
        {
            return m_skills.Values.ToList();
        }

        //获取当前关卡是否需要校验
        public bool GetIsMarkLevel()
        {
            if (battle.arg == null)
                return false;

            if (battle.arg.levelID <= 0)
                return false;
            
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(battle.arg.levelID);
            if (levelConfig == null)
            {
                return false;
            }

            switch (levelConfig.BattleReviewMark)
            {
                case 0:
                    return false;
                case 1:
                    return !BattleEnv.LuaBridge.GetStageIsWin(battle.arg.levelID);
                case 2:
                    return true;
            }

            return false;
        }

        /// <summary>
        /// 是否需要上传
        /// </summary>
        /// <returns></returns>
        public bool GetIsUp()
        {
#if UNITY_EDITOR
            //编辑器下都写入文件
            return true;
#endif
            //需要采集数据 并且胜利了才上传文件
            if (m_need && isWin)
            {
                return true;
            }

            return false;
        }
    }
}