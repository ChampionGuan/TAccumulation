using System;
using System.Collections.Generic;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class DirectDamageBox : DamageBox
    {
        private Actor _target = null;
        
        public void Init(DamageExporter damageExporter, int id, int groupID, int level, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, List<Actor> excludeSet, float damageProportion, float? extDuration = null, Actor target = null)
        {
            this._Init(damageExporter, id, groupID, level, damageBoxCfg, hitParamConfig, excludeSet, damageProportion, extDuration);
            _target = target;
        }

        protected override List<Actor> _PickDamageBoxTargets(out List<CollisionDetectionInfo> collisionInfos)
        {
            List<Actor> results = null;
            using (ProfilerDefine.DamageBox_DirectDamageBox_PickDamageBoxTargets.Auto())
            {
                _reuseActorCollisionInfo.Clear();
                _reuseActors.Clear();
                collisionInfos = _reuseActorCollisionInfo;

                Actor target = null;
                switch (_damageBoxCfg.DirectSelectType)
                {
                    case DirectSelectType.Self:
                        target = _damageExporter.actor;
                        break;
                    case DirectSelectType.SkillTarget:
                        target = _damageExporter.actor.skillOwner?.GetTarget();
                        break;
                    case DirectSelectType.SpecifyTarget:
                        target = _target;
                        break;
                    case DirectSelectType.Girl:
                        target = Battle.Instance.actorMgr.girl;
                        break;
                    case DirectSelectType.Boy:
                        target = Battle.Instance.actorMgr.boy;
                        break;
                }

                results = _reuseActors;
                if (target != null)
                {
                    if (!_dynamicExcludeRoles.Contains(target))
                    {
                        results.Add(target);
                    }
                }
            }

            return results;
        }

        protected override void _OnReset()
        {
            _target = null;
        }
    }
}