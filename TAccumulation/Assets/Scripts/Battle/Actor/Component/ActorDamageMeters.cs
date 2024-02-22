using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActorDamageMeters : ActorComponent
    {
        private Dictionary<DamageExporter, DamageExportMeters> _dictionary = new Dictionary<DamageExporter, DamageExportMeters>(20);
        private Action<EventCastSkill> _actionCastSkill;
        private Action<EventEndSkill> _actionEndSkill;
        private Action<EventExportDamage> _actionEndExportDamage;

        public ActorDamageMeters() : base(ActorComponentType.DamageMeters)
        {
            _actionCastSkill = _OnCastSkill;
            _actionEndSkill = _OnEndSkill;
            _actionEndExportDamage = _OnExportDamage;
        }

        public override void OnBorn()
        {
            _dictionary.Clear();
            
            battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _actionCastSkill, "ActorDamageMeters._OnCastSkill");
            battle.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _actionEndSkill, "ActorDamageMeters._OnEndSkill");
            battle.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _actionEndExportDamage, "ActorDamageMeters._OnExportDamage");
        }

        public override void OnRecycle()
        {
            battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill, _actionCastSkill);
            battle.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionEndSkill);
            battle.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _actionEndExportDamage);

            foreach (var keyValuePair in _dictionary)
            {
                ObjectPoolUtility.DamageExporterMetersPool.Release(keyValuePair.Value);
            }

            _dictionary.Clear();
        }

        private void _OnCastSkill(EventCastSkill args)
        {
            // DONE: 只统计该组件主人释放的技能.
            if (args.skill.actor != this.actor)
            {
                return;
            }
            
            DamageExporter damageExporter = _GetMasterExporter(args.skill);
            if (!_dictionary.TryGetValue(damageExporter, out var damageExportMeters))
            {
                damageExportMeters = ObjectPoolUtility.DamageExporterMetersPool.Get();
                _dictionary.Add(damageExporter, damageExportMeters);
            }

            if (damageExportMeters.isRecord != false)
            {
                // DONE: 技能未正常结束, 抛个Log.
                LogProxy.LogWarningFormat("主人{0}的 DamageExporter {1}, 未正常结束, 程序请检查!", damageExporter.actor.name, damageExporter.GetID());
            }

            damageExportMeters.isRecord = true;
        }

        private void _OnEndSkill(EventEndSkill args)
        {            
            // DONE: 只统计该组件主人释放的技能.
            if (args.skill.actor != this.actor)
            {
                return;
            }
            
            DamageExporter damageExporter = _GetMasterExporter(args.skill);
            if (!_dictionary.TryGetValue(damageExporter, out var damageExportMeters))
            {
                return;
            }
            
            // DONE: 发事件造成
            var list = ObjectPoolUtility.DamageMetersListPool.Get();
            foreach (var damageMeter in damageExportMeters.damageMeters)
            {
                list.Add(damageMeter.Value);
            }
            
            var eventDamageMeter = this.battle.eventMgr.GetEvent<EventDamageExporterMeter>();
            eventDamageMeter.Init(damageExporter, list);
            this.battle.eventMgr.Dispatch(EventType.OnDamageMeter, eventDamageMeter);
            
            // DONE: 技能结束了, 那就重置参数, 重头统计伤害.
            ObjectPoolUtility.DamageMetersListPool.Release(list);
            damageExportMeters.Reset();
        }

        private void _OnExportDamage(EventExportDamage args)
        {
            // DONE: 只统计该组件主人造成的伤害.
            if (args.exporter.GetCaster() != this.actor)
            {
                return;
            }
            
            DamageExporter damageExporter = _GetMasterExporter(args.exporter);
            if (!_dictionary.TryGetValue(damageExporter, out var damageExportMeters))
            {
                return;
            }

            using (ProfilerDefine.ActorDamageMetersOnExportDamagePMarker.Auto())
            {

                if (!damageExportMeters.damageMeters.TryGetValue(args.hurtActor, out var damageMeter))
                {
                    damageExportMeters.Add(args.hurtActor);
                    damageMeter = damageExportMeters.damageMeters[args.hurtActor];
                }

                if (args.damageType == DamageType.Add)
                {
                    damageMeter.cure += args.damageInfo.damage;
                    damageMeter.realCure += args.damageInfo.realDamage;
                    // damageMeter.hpShieldCure += args.damageInfo.hpShieldDamage;
                    damageMeter.isCriticalCure |= args.damageInfo.isCritical;
                }
                else if (args.damageType == DamageType.Sub)
                {
                    damageMeter.damage += args.damageInfo.damage;
                    damageMeter.realDamage += args.damageInfo.realDamage;
                    // damageMeter.hpShieldDamage += args.damageInfo.hpShieldDamage;
                    damageMeter.isCriticalDamage |= args.damageInfo.isCritical;
                }
            }
        }

        private static DamageExporter _GetMasterExporter(DamageExporter damageExporter)
        {
            DamageExporter result = damageExporter;
            
            // TODO 这里没有统计BUFF的伤害来源, 因为BUFF目前没有记录是哪个技能创建的, 只记录了是哪个Actor创建的.
            // DONE: 递归一直找到技能的主技能, 默认主技能为 masterExporter == null 的为主技能.
            while (result is ISkill skill && skill.masterExporter != null)
            {
                result = skill.masterExporter;
            }

            return result;
        }
    }
}