using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using MessagePack;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Serialization;
using X3Battle;
using Debug = System.Diagnostics.Debug;
using EventType = X3Battle.EventType;
namespace X3Battle
{
    /// <summary>
    /// 自动战斗参数
    /// </summary>
    [Serializable]
    [MessagePackObject]
    public class BattleAutoRun
    {
        //自动战斗的数据
        [Key(1)]
        public int maxHp;
        [Key(2)]
        public int PhyAtk;
        [Key(3)]
        public int PhyDef;
        [Key(4)]
        public int CritVal;
        [Key(5)]
        public int CritHurtAdd;
        [Key(6)] public List<int> boyBuffs;
        [Key(7)] public List<int> girlBuffs;
        [Key(8)] public List<int> monsterBuffs;
        [Key(9)] public List<int> attrKeys;
        [Key(10)] public List<int> attrValue;
        public BattleAutoRun()
        {
            boyBuffs = new List<int>();
            girlBuffs = new List<int>();
            monsterBuffs = new List<int>();
            attrKeys = new List<int>();
            attrValue = new List<int>();
        }
    }
    public class ActorBase
    {
        public int battleNum;
        public int boyID;
        public int girlID;
        public int levelID;
        public float BattleTime;
        public int girlWeaponID;

        public ActorBase(int battleNum, int boyID, int girlID, int levelID, int girlWeaponID)
        {
            this.battleNum = battleNum;
            this.boyID = boyID;
            this.girlID = girlID;
            this.levelID = levelID;
            this.girlWeaponID = girlWeaponID;
        }
    }
    
    public class ActorSkill : ActorBase
    {
        public int skillID;
        public SkillType skillType;
        public int belongActorID;
        public int SkillNum;
        public float DamageNum;
        public float HealNum;

        public ActorSkill(int battleNum, int skillID, SkillType skillType, int boyID, int girlID, int levelID,
            int belongActorID, int girlWeaponID)
            : base(battleNum, boyID, girlID, levelID, girlWeaponID)
        {
            this.skillID = skillID;
            this.skillType = skillType;
            this.belongActorID = belongActorID;
        }
    }

    public class ActorTime : ActorBase
    {
        public int belongActorID;
        public Dictionary<int, float> Damages = new Dictionary<int, float>();

        public ActorTime(int battleNum, int boyID, int girlID, int levelID, int belongActorID, int girlWeaponID)
            : base(battleNum, boyID, girlID, levelID, girlWeaponID)
        {
            this.belongActorID = belongActorID;
        }
    }


    public class ActorBuff : ActorBase
    {
        public int buffID;
        public int targetID;
        public int casterID;
        public int BuffNum;

        public ActorBuff(int battleNum, int boyID, int girlID, int levelID, int buffID, int casterID, int targetID,
            int girlWeaponID)
            : base(battleNum, boyID, girlID, levelID, girlWeaponID)
        {
            this.buffID = buffID;
            this.targetID = targetID;
            this.casterID = casterID;
        }
    }

    public class DamageItem
    {
        public float damageTotal;
        public float dps;
    }
    public class ActorStatistic : ActorBase
    {
        public float boyEndHP;
        public float girlEndHp;
        public float boyHurtTotal;
        public float girlHurtTotal;
        public float boyHealTotal;
        public float girlHealTotal;
        public bool result;
        public Dictionary<int, Dictionary<SkillType, DamageItem>> actorDamages = new Dictionary<int, Dictionary<SkillType, DamageItem>>(); //key：configid, value:伤害
        public Dictionary<string, float> actorLifes = new Dictionary<string, float>();//key 是 insID + configID  value: 生存时间

        public ActorStatistic(int battleNum, int boyID, int girlID, int levelID, int girlWeaponID)
            : base(battleNum, boyID, girlID, levelID, girlWeaponID)
        {
        }

        public void DoDps(float battleTime)
        {
            foreach (var info in actorDamages)
            {
                foreach (var damage in info.Value)
                {
                    damage.Value.dps = damage.Value.damageTotal / battleTime;
                }
            }
        }
    }
    
    /// <summary>
    /// 一场战斗数据 同一时间只能存在一场战斗数据
    /// </summary>
    public class AutoSigleBattleData
    {
        public static bool IS_AUTORUN = false;//是否开启自动战斗工具
        public static int BATTLE_NUM;//当前战斗场次

        private BattleArg _arg;
        private X3Battle.Battle _battle;
        private List<int> _boyBuffs;
        private float _battleTime;//战斗帧数
        private Dictionary<int, ActorSkill> _behavers = new Dictionary<int, ActorSkill>();//技能动作
        private Dictionary<int, ActorTime> _damageTimes = new  Dictionary<int, ActorTime>();//伤害时间轴
        private Dictionary<int, ActorBuff> _buffs = new Dictionary<int, ActorBuff>();//BUff统计
        private ActorStatistic _statistic;//战斗全局数据
        private BattleAutoRun _auto;
        private bool _isWin;
        
        private const string DirPath = "../../../Tools/Battle/BattleAuto/Result/";
        private const string BehaversDirPath = "BehaversDirPath.txt";
        private const string DamageTimesDirPath = "DamageTimesDirPath.txt";
        private const string BuffsDirPath = "BuffsDirPath.txt";
        private const string StatisticDirPath = "StatisticDirPath.txt";

        public BattleArg arg => _arg;

        public void Init(BattleArg arg, X3Battle.Battle battle,int battleNum, BattleAutoRun battleAutoRun)
        {
            _arg = arg;
            _battle = battle;
            BATTLE_NUM = battleNum;
            _auto = battleAutoRun;
            if (_battle == null || _arg == null)
            {
                return;
            }
            _battle.eventMgr.AddListener<EventActor>(EventType.Actor, _OnActor, "AutoSigleBattleData._OnActor");
            _battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill, "AutoSigleBattleData._OnCastSkill");
            _battle.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _OnExportDamage, "AutoSigleBattleData._OnExportDamage");
            _battle.eventMgr.AddListener<EventBuffChange>(EventType.BuffChange, _OnBuffChange, "AutoSigleBattleData._OnBuffChange");
            _battle.eventMgr.AddListener<ECEventDataBase>(EventType.OnLevelStart, _OnLevelStart, "AutoSigleBattleData._OnLevelStart");
            _battle.eventMgr.AddListener<EventBattleEnd>(EventType.OnBattleEnd, _OnLevelEnd, "AutoSigleBattleData._OnLevelEnd");

            _statistic = new ActorStatistic(BATTLE_NUM, _arg.boyID, _arg.girlID, _arg.levelID, _arg.girlWeaponID);
        }

        public void OnDeatroy()
        {
            if (_battle == null || _arg == null || _battle.actorMgr == null 
                || _battle.actorMgr.boy == null || _battle.actorMgr.girl == null
                ||_battle.actorMgr.boy.attributeOwner == null)
            {
                return;
            }

            _battleTime = _battle.time;
            foreach (var info in _behavers)
            {
                info.Value.BattleTime = _battleTime;
            }
            
            foreach (var info in _damageTimes)
            {
                info.Value.BattleTime = _battleTime;
            }
            
            foreach (var info in _buffs)
            {
                info.Value.BattleTime = _battleTime;
            }

            _statistic.BattleTime = _battleTime; 

            var boyHpAttr = _battle.actorMgr.boy.attributeOwner.GetAttr(AttrType.HP);
            var girlHpAttr = _battle.actorMgr.girl.attributeOwner.GetAttr(AttrType.HP);
            _statistic.boyEndHP = boyHpAttr.GetValue();
            _statistic.girlEndHp = girlHpAttr.GetValue();
            _statistic.result = _isWin;
            _statistic.DoDps(_battleTime);
            _Write();
            _battle.eventMgr.RemoveListener<EventActor>(EventType.Actor, _OnActor);
            _battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _OnCastSkill);
            _battle.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _OnExportDamage);
            _battle.eventMgr.RemoveListener<EventBuffChange>(EventType.BuffChange, _OnBuffChange);
            _battle.eventMgr.RemoveListener<ECEventDataBase>(EventType.OnLevelStart, _OnLevelStart);
            _battle.eventMgr.RemoveListener<EventBattleEnd>(EventType.OnBattleEnd, _OnLevelEnd);
            
            _arg = null;
            _battle = null;
        }

        private void _OnLevelEnd(EventBattleEnd arg)
        {
            _isWin = arg.isWin;
        }
        
        private void _OnLevelStart(ECEventDataBase arg)
        {
            //开启自动战斗
            if (_auto != null)
            {
                BattleClient.Instance.battle.input.TrySwitchAuto(true);
            }
            
            if(_auto == null)
                return;
            float critHurtAdd = 0.0f;
            if (_battle.actorMgr.boy != null && !_battle.actorMgr.boy.isDead)
            {
                var boy = _battle.actorMgr.boy;
                critHurtAdd = BattleEnv.LuaBridge.GetCritHurtAdd(boy.cfgID);
                foreach (var buff in _auto.boyBuffs)
                {
                    LogProxy.Log("actor name = " + boy.name + " add buff =" + buff);
                    boy.buffOwner.Add(buff, layer: 1, time: -1, 1,null);
                }

                boy.attributeOwner.SetAttrValue(AttrType.MaxHP, _auto.maxHp);
                boy.attributeOwner.SetAttrValue(AttrType.HP, _auto.maxHp);
                boy.attributeOwner.SetAttrValue(AttrType.PhyAttack, _auto.PhyAtk);
                boy.attributeOwner.SetAttrValue(AttrType.PhyDefence, _auto.PhyDef);
                boy.attributeOwner.SetAttrValue(AttrType.CritVal, _auto.CritVal);
                boy.attributeOwner.SetAttrValue(AttrType.CritHurtAdd, _auto.CritHurtAdd + critHurtAdd);

                for (int i = 0; i < _auto.attrKeys.Count; i++)
                {
                    boy.attributeOwner.SetAttrValue((AttrType) _auto.attrKeys[i], _auto.attrValue[i]);
                }
            }
            
            if(_battle.actorMgr.girl != null && !_battle.actorMgr.girl.isDead)
            {
                var girl = _battle.actorMgr.girl;
                foreach (var buff in _auto.girlBuffs)
                {
                    LogProxy.Log("actor name = " + girl.name + " add buff =" + buff);
                    girl.buffOwner.Add(buff, layer: 1, time: -1, 1,null);
                }
                girl.attributeOwner.SetAttrValue(AttrType.MaxHP, _auto.maxHp);
                girl.attributeOwner.SetAttrValue(AttrType.HP, _auto.maxHp);
                girl.attributeOwner.SetAttrValue(AttrType.PhyAttack, _auto.PhyAtk);
                girl.attributeOwner.SetAttrValue(AttrType.PhyDefence, _auto.PhyDef);
                girl.attributeOwner.SetAttrValue(AttrType.CritVal, _auto.CritVal);
                girl.attributeOwner.SetAttrValue(AttrType.CritHurtAdd, _auto.CritHurtAdd + critHurtAdd);
                
                for (int i = 0; i < _auto.attrKeys.Count; i++)
                {
                    girl.attributeOwner.SetAttrValue((AttrType) _auto.attrKeys[i], _auto.attrValue[i]);
                }
            }
        }

        private void _OnBuffChange(EventBuffChange arg)
        {
            if (arg.buff == null || arg.caster == null || arg.target == null)
                return;
            var buffID = arg.buff.ID;
            if (arg.type != BuffChangeType.Add)
            {
                return;
            }
            if (_buffs.ContainsKey(buffID))
            {
                _buffs[buffID].BuffNum += 1;
            }
            else
            {
                int casterID = arg.caster.config.ID;
                int targetID = arg.target.config.ID;
                ActorBuff buff = new ActorBuff(BATTLE_NUM, _arg.boyID, _arg.girlID, _arg.levelID, buffID, casterID, targetID, _arg.girlWeaponID);
                _buffs.Add(buffID, buff);
            }
        }
        private void _OnExportDamage(EventExportDamage arg)
        {
            var skillID = arg.exporter.GetCfgID();
            var damage = arg.totalDamage;
            var attackID = arg.exporter.GetCaster().config.ID;
            var hurt = arg.hurtActor;
            var attack = arg.exporter.GetCaster();
            SkillType skillType = 0;
            if (arg.exporter is ISkill)
            {
                ISkill skill = arg.exporter as ISkill;
                skillType =  skill.config.Type;
            }
            
            //伤害统计
            if (_behavers.ContainsKey(skillID))
            {
                if (arg.damageType == DamageType.Sub)
                {
                    _behavers[skillID].DamageNum += damage;
                }
                else
                {
                    _behavers[skillID].HealNum += damage;
                }
            }
            
            //伤害时间统计
            if (!_damageTimes.ContainsKey(attackID))
            {
                ActorTime time = new ActorTime(BATTLE_NUM, _arg.boyID, _arg.girlID, _arg.levelID, attackID, _arg.girlWeaponID);
                _damageTimes.Add(attackID, time);
            }

            if (arg.damageType == DamageType.Sub)
            {
                int time = (int)_battle.time;
                if (_damageTimes[attackID].Damages.ContainsKey(time))
                {
                    _damageTimes[attackID].Damages[time] += damage;
                }
                else
                {
                    _damageTimes[attackID].Damages.Add(time, damage);
                }
            }
            
            if (arg.damageType == DamageType.Sub)
            {
                if (hurt.IsBoy())
                {
                    _statistic.boyHurtTotal += damage;
                }

                if (hurt.IsGirl())
                {
                    _statistic.girlHurtTotal += damage; 
                }

                if (attack.IsBoy() || attack.IsGirl())
                {
                    if (!_statistic.actorDamages.ContainsKey(attackID))
                    {
                        _statistic.actorDamages.Add(attackID, new Dictionary<SkillType, DamageItem>());
                    }

                    if (!_statistic.actorDamages[attackID].ContainsKey(skillType))
                    {
                        _statistic.actorDamages[attackID].Add(skillType, new DamageItem());
                    }

                    _statistic.actorDamages[attackID][skillType].damageTotal += damage;
                }
            }

            if (arg.damageType == DamageType.Add)
            {
                if (hurt.IsBoy())
                {
                    _statistic.boyHealTotal += damage;
                }

                if (hurt.IsGirl())
                {
                    _statistic.girlHealTotal += damage; 
                }
            }
        }
        private void _OnActor(EventActor arg)
        {
            var actor = arg.actor;
            var key = + actor.insID + "+" + actor.config.ID ;
            if (!_statistic.actorLifes.ContainsKey(key))
            {
                _statistic.actorLifes.Add(key, 0);
            }

            if (arg.state == ActorLifeStateType.Born)
            {
                _statistic.actorLifes[key] = _battle.time;
            }

            if (arg.state == ActorLifeStateType.Dead)
            {
                _statistic.actorLifes[key] = _battle.time - _statistic.actorLifes[key];
            }
            
            if (arg.state != ActorLifeStateType.Born)
            {
                return;
            }

            if(actor.IsMonster() && _auto != null)
            {
                foreach (var buff in _auto.monsterBuffs)
                {
                    LogProxy.Log("actor name = " + actor.name + " add buff =" + buff);
                    actor.buffOwner.Add(buff, layer: 1, time: -1, 1,null);
                }
            }
        }

        private void _OnCastSkill(EventCastSkill arg)
        {
            if (arg.skill == null || arg.skill.GetCaster() == null)
                return;

            var skillId = arg.skill.GetID();
            var skillType = arg.skill.config.Type;
            var casterID = arg.skill.GetCaster().config.ID;
            
            if (!_behavers.ContainsKey(skillId))
            {
                var actorSkill = new ActorSkill(BATTLE_NUM, skillId, skillType, _arg.boyID, _arg.girlID, _arg.levelID, casterID, _arg.girlWeaponID);
                _behavers.Add(skillId, actorSkill);
            }

            _behavers[skillId].SkillNum += 1;
        }
        private void _Write()
        {
            string fullPath = Path.GetFullPath(Application.dataPath + DirPath);
            Directory.CreateDirectory(fullPath);
            
            string behaverPath = fullPath + BehaversDirPath;
            StringBuilder builder = new StringBuilder(2048);
            FileStream fs = new FileStream(behaverPath, FileMode.OpenOrCreate);
            fs.Close();
            StreamWriter writer = new StreamWriter(behaverPath, true);
            foreach (var debug in _behavers.Values)
            {
                builder.AppendFormat(
                    "战斗场次:{0},战斗时长:{1},男主ID:{2},女主武器ID:{3},关卡ID:{4},技能ID:{5},技能类型:{6}," +
                    "隶属ActorID:{7},技能次数:{8},伤害统计:{9},治疗统计:{10}",
                    debug.battleNum, debug.BattleTime, debug.boyID, debug.girlWeaponID, debug.levelID,
                    debug.skillID, debug.skillType, debug.belongActorID, debug.SkillNum, debug.DamageNum, debug.HealNum);
                writer.WriteLine(builder.ToString());
                builder.Clear();
            }
            writer.Flush();
            writer.Close();
            
            string DamagePath = fullPath + DamageTimesDirPath;
            builder = new StringBuilder(2048);
            fs = new FileStream(DamagePath, FileMode.OpenOrCreate);
            fs.Close();
            writer = new StreamWriter(DamagePath, true);
            foreach (var debug in _damageTimes.Values)
            {
                string damagelist = "";
                for (int i = 1; i < _battleTime; i++)
                {
                    float damageTotal = 0;
                    foreach (var info in debug.Damages)
                    {
                        if (info.Key <= i)
                        {
                            damageTotal += info.Value;
                        }
                    }

                    damagelist += damageTotal + "|";
                }

                builder.AppendFormat(
                    "战斗场次:{0},战斗时长:{1},男主ID:{2},女主武器ID:{3},关卡ID:{4},隶属ActorID:{5},累计伤害数组:{6},",
                    debug.battleNum, debug.BattleTime, debug.boyID, debug.girlWeaponID, debug.levelID,
                    debug.belongActorID, damagelist);
                writer.WriteLine(builder.ToString());
                builder.Clear();
            }
            writer.Flush();
            writer.Close();
            
            string BuffPath = fullPath + BuffsDirPath;
            builder = new StringBuilder(2048);
            fs = new FileStream(BuffPath, FileMode.OpenOrCreate);
            fs.Close();
            writer = new StreamWriter(BuffPath, true);
            foreach (var debug in _buffs.Values)
            {
                builder.AppendFormat(
                    "战斗场次:{0},战斗时长:{1},男主ID:{2},女主武器ID:{3},关卡ID:{4},BUffId:{5},发起者:{6},承受者:{7},次数:{8},",
                    debug.battleNum, debug.BattleTime, debug.boyID, debug.girlWeaponID, debug.levelID,
                    debug.buffID, debug.casterID, debug.targetID, debug.BuffNum);
                writer.WriteLine(builder.ToString());
                builder.Clear();
            }
            writer.Flush();
            writer.Close();
            
            string StatisticPath = fullPath + StatisticDirPath;
            builder = new StringBuilder(2048);
            fs = new FileStream(StatisticPath, FileMode.OpenOrCreate);
            fs.Close();
            writer = new StreamWriter(StatisticPath, true);
            builder.AppendFormat(
                "战斗场次:{0},战斗时长:{1},男主ID:{2},女主武器ID:{3},关卡ID:{4},男主结束血量:{5},女主结束血量:{6},男主总承伤:{7},女主总承伤 :{8}," +
                "男主有效获得治疗:{9},女主有效获得治疗:{10}," +
                "战斗结果:{11},",
                _statistic.battleNum, _statistic.BattleTime, _statistic.boyID, _statistic.girlWeaponID, _statistic.levelID,
                _statistic.boyEndHP,_statistic.girlEndHp, 
                _statistic.boyHurtTotal,_statistic.girlHurtTotal,
                _statistic.boyHealTotal,_statistic.girlHealTotal,
                _statistic.result);

            string tempHead = builder.ToString();
            builder.Clear();
            foreach (var info in _statistic.actorDamages)
            {
                foreach (var damage in info.Value)
                {
                    builder.Append(tempHead);
                    builder.AppendFormat("actorConfigID: {0}, skillType: {1},TotalDamage: {2}, DPs: {3}", info.Key, damage.Key,
                        damage.Value.damageTotal, damage.Value.dps);
                    writer.WriteLine(builder.ToString());
                    builder.Clear();
                }
            }
            builder.Clear();
            writer.Flush();
            writer.Close();
            
            UnityEngine.Debug.Log("日志存放路径 = " + fullPath);
        }
    }
}