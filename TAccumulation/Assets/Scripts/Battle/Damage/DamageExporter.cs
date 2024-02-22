using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class DamageExporter
    {       
        private DamageExporter _masterExporter;

        public DamageExporter masterExporter => _masterExporter;

        public float finalDamageAddAttr { get; private set; } // 34号属性伤害增加值

        public void SetFinalDamageAddAttr(float value)
        {
            finalDamageAddAttr = value;
        }
        
        public void SetMasterExporter(DamageExporter exporter)
        {
            _masterExporter = exporter;
            _caster = null;
            _caster = GetCaster();
            _skillType = GetSkillType();
            // 设置Master主人时，继承此刻主人增伤信息
            if (exporter != null)
            {
                SetFinalDamageAddAttr(exporter.finalDamageAddAttr);
            }
        }

        public Actor actor { get; protected set; }
        public DamageExporterType exporterType { get; protected set; }
        
        protected int _id;

        /// <summary> 伤害组字典 </summary>
        private Dictionary<int, DamageBoxGroup> _damageBoxGroups = new Dictionary<int, DamageBoxGroup>(5);

        private List<DamageBoxGroup> _tempDamageBoxGroups = new List<DamageBoxGroup>(5);
        private List<DamageBox> _damageBoxes = new List<DamageBox>(20); // 伤害包围盒

        private Actor _caster = null;
        private SkillType? _skillType = null;

        #region DamageBox.ID生成器

        private int _damageBoxID;

        protected int _GenerateDamageBoxID()
        {
            return ++_damageBoxID;
        }

        #endregion

        public DamageExporter(DamageExporterType exporterType)
        {
            this.exporterType = exporterType;
        }

        public void Init(int id, Actor actor, DamageExporter damageExporter)
        {
            if (actor == null)
            {
                LogProxy.LogError("DamageExporter.Init() 参数actor不能为null.");
            }
            
            this.actor = actor;
            this._id = id;
            this._damageBoxID = 0;
            this._masterExporter = damageExporter;

            this._damageBoxes.Clear();
            this._damageBoxGroups.Clear();
        }
        
        public List<DamageBox> GetDamageBoxs()
        {
            return _damageBoxes;
        }

        public virtual int GetID()
        {
            return this._id;
        }

        public virtual int GetCfgID()
        {
            return this._id;
        }
        public virtual int GetLevel()
        {
            return 1;
        }

        public virtual int GetLayer()
        {
            return 1;
        }

        public virtual Actor GetCaster()
        {
            if (_caster != null)
            {
                return _caster;
            }
            
            Actor caster = this.actor;
            while (caster != null)
            {
                if (caster.attributeOwner != null)
                {
                    break;
                }

                caster = caster.master;
            }

            _caster = caster;
            return caster;
        }

        // 获取释放时的位置
        public Vector3 GetCastingPosition()
        {
            return _OnGetCastingPosition();
        }
        
        protected virtual Vector3 _OnGetCastingPosition()
        {
            return actor.transform.position;
        }
        
        // 获取释放时的朝向
        public Quaternion GetCastingRotation()
        {
            return _OnGetCastingRotation();
        }
        
        protected virtual Quaternion _OnGetCastingRotation()
        {
            return actor.transform.rotation;
        }

        /// <summary>
        /// 获取最近的父技能
        /// </summary>
        /// <returns></returns>
        public virtual ISkill GetNearMasterExporter()
        {
            DamageExporter exporter = this;
            while (exporter != null)
            {
                if (exporter is ISkill skill && exporter.actor != null && exporter.actor.attributeOwner != null)
                {
                    return skill;
                }

                exporter = exporter.masterExporter;
            }

            return null;
        }

        /// <summary>
        /// 获取技能type
        /// </summary>
        /// <returns></returns>
        public virtual SkillType GetSkillType()
        {
            if (_skillType != null) return _skillType.Value;
            
            var iSkill = GetNearMasterExporter();
            if (iSkill != null)
            {
                _skillType = iSkill.config.Type;
                return iSkill.config.Type;
            }
            
            return SkillType.None;
        }
        
        private string GetExporterTypeName()
        {
            return exporterType == DamageExporterType.Skill ? "Skill" : "Buff";
        }

        /// <summary>
        /// 新增的碰撞盒相关逻辑，创建碰撞盒
        /// </summary>
        /// <param name="isContinuousMode">是否连续</param>
        /// <param name="excludeSet">排除列表</param>
        /// <param name="damageBoxId">伤害包围盒Id</param>
        /// <param name="level"></param>
        /// <param name="dynamicExcludes"></param>
        /// <param name="angleY">旋转偏移, 可空，空则用damageBox参数</param>
        /// <param name="position">位置偏移，可空，空则用damageBox参数</param>
        /// <param name="duration">持续时长，默认为null走配置</param>
        /// <param name="damageProportion"></param>
        /// <returns></returns>
        public void CastDamageBox(List<Actor> excludeSet, int damageBoxId, int level, out List<Actor> dynamicExcludes, Vector3? angleY, Vector3? position, float? duration = null, float damageProportion = 1f, bool? isContinue = null, int? layerMask = null, Vector3? terminalPos = null, ShapeBoxInfo shapeBoxInfo = null, int damageBoxGroupID = 0)
        {
            dynamicExcludes = null;
            if (damageBoxId == 0)
            {
                LogProxy.Log("【战斗】策划设定damageBoxId=0伤害盒默认无效. 直接return");
                return;
            }

            var damageBoxCfg = TbUtil.GetCfg<DamageBoxCfg>(damageBoxId);
            if (damageBoxCfg == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("请联系策划【卡宝】, DamageBoxCfg配置：伤害包围盒(id={0}）找不到，{1}，{2}(id={3})，", damageBoxId, BattleUtil.GetActorDebugInfo(this.actor.config), this.GetExporterTypeName(), this._id);
                return;
            }

            CastDamageBox(excludeSet, damageBoxCfg, null, level, out dynamicExcludes, angleY, position, duration, damageProportion, isContinue, layerMask: layerMask, terminalPos: terminalPos, shapeBoxInfo: shapeBoxInfo, damageBoxGroupID);
        }

        // TODO for 老艾. 理论上可以优化掉这个接口, 只留上面那个.
        public void CastDamageBox(List<Actor> excludeSet, DamageBoxCfg damageBoxCfg, Actor target, int level, out List<Actor> dynamicExcludes, Vector3? angleY, Vector3? position, float? duration = null, float damageProportion = 1f, bool? isContinue = null, int? layerMask = null, Vector3? terminalPos = null, ShapeBoxInfo shapeBoxInfo = null, int damageBoxGroupID = 0)
        {
            dynamicExcludes = null;
            var hitParamConfig = TbUtil.GetHitParamConfig(damageBoxCfg.HitParamID, level, GetLayer());
            if (hitParamConfig == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat($"请联系策划【卡宝】, HitParam配置表：伤害(id={damageBoxCfg.HitParamID}, level={level})找不到, {BattleUtil.GetActorDebugInfo(this.actor.config)}，{this.GetExporterTypeName()}(id={this._id}");
                return;
            }

            CastDamageBox(excludeSet, damageBoxCfg, hitParamConfig, target, level, out dynamicExcludes, angleY, position, duration, damageProportion, isContinue, layerMask, terminalPos, shapeBoxInfo, damageBoxGroupID);
        }

        public void CastDamageBox(List<Actor> excludeSet, DamageBoxCfg damageBoxCfg, HitParamConfig hitParamConfig, Actor target, int level, out List<Actor> dynamicExcludes, Vector3? angleY = null, Vector3? position = null, float? duration = null, float damageProportion = 1f, bool? isContinue = null, int? layerMask = null, Vector3? terminalPos = null, ShapeBoxInfo shapeBoxInfo = null, int damageBoxGroupID = 0)
        {
            dynamicExcludes = null;
            DamageBox damageBox = null;
            int damageBoxID = _GenerateDamageBoxID();
            if (damageBoxCfg.CheckTargetType == CheckTargetType.Physical)
            {
                PhysicsDamageBox physicsDamageBox = ObjectPoolUtility.PhysicsDamageBoxPool.Get();
                using (ProfilerDefine.DamageBox_CastDamageBox_PhysicsDamageBox.Auto())
                {
                    physicsDamageBox.Init(this, damageBoxID, damageBoxGroupID, level, damageBoxCfg, hitParamConfig, excludeSet, damageProportion, duration, angleY, position, isContinue, layerMask, terminalPos: terminalPos, shapeBoxInfo: shapeBoxInfo);    
                }
                damageBox = physicsDamageBox;
            }
            else if (damageBoxCfg.CheckTargetType == CheckTargetType.Direct)
            {
                DirectDamageBox directDamageBox = ObjectPoolUtility.DirectDamagePool.Get();
                using (ProfilerDefine.DamageBox_CastDamageBox_DirectDamageBox.Auto())
                {
                    directDamageBox.Init(this, damageBoxID, damageBoxGroupID, level, damageBoxCfg, hitParamConfig, excludeSet, damageProportion, duration, target);    
                }
                damageBox = directDamageBox;
            }
            
            if (damageBox == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("请联系策划【卡宝】, DamageBoxCfg配置：伤害包围盒(id={0}）找不到，{1}，{2}(id={3})，", damageBoxCfg.ID, BattleUtil.GetActorDebugInfo(this.actor.config), this.GetExporterTypeName(), this._id);
                return;
            }
            
            dynamicExcludes = damageBox.dynamicExcludeRoles;
            
            // DONE: 尝试创建伤害盒组.
            _TryCreateDamageBoxGroup(damageBoxGroupID);
            
            // DONE: 添加伤害盒至伤害盒组.
            _TryAddDamageBoxToGroup(damageBoxGroupID, damageBox);
            
            using (ProfilerDefine.DamageBox_CastDamageBox_TryEvaluate.Auto())
            {
                damageBox.TryEvaluate();
            }

            _damageBoxes.Add(damageBox);
        }

        /// <summary>
        /// 由子类调用，更新包围盒
        /// </summary>
        /// <param name="deltaTime">帧间隔</param>
        protected void _UpdateDamageBoxes(float deltaTime)
        {
            // 此处考虑到遍历时输出伤害，可能Update内部又向数组插入内容，使用双循环确保正确性
            var count = _damageBoxes.Count;
            for (int i = 0; i < count; i++)
            {
                if (_damageBoxes.Count == 0)
                {
                    // 循环过程中直接clear掉了
                    return;
                }
                var damageBox = _damageBoxes[i];
                if (damageBox.IsEnd())
                {
                    continue;
                }
                
                damageBox.Update(deltaTime);
            }
            
            count = _damageBoxes.Count;
            for (int i = count - 1; i >= 0; i--)
            {
                if (_damageBoxes.Count == 0)
                {
                    // 循环过程中直接clear掉了
                    return;
                }
                var damageBox = _damageBoxes[i];
                if (damageBox.IsEnd())
                {
                    _DestroyDamageBox(damageBox);
                }
            }
        }
        
        /// <summary>
        /// 由子类调用，销毁所有攻击盒
        /// </summary>
        protected void _DestroyDamageBoxes()
        {
            while (_damageBoxes.Count > 0)
            {
                _DestroyDamageBox(_damageBoxes[_damageBoxes.Count - 1]);
            }
            _damageBoxes.Clear();

            _DestroyAllDamageBoxGroup();
        }

        public void ClearDamageBoxes()
        {
            _DestroyDamageBoxes();
        }

        private void _DestroyDamageBox(DamageBox damageBox)
        {
            _TryRemoveDamageBoxFromGroup(damageBox.GroupID, damageBox);
            damageBox.Destroy();
            if (damageBox is PhysicsDamageBox physicsDamageBox)
            {
                ObjectPoolUtility.PhysicsDamageBoxPool.Release(physicsDamageBox);
            }
            else if (damageBox is DirectDamageBox directDamageBox)
            {
                ObjectPoolUtility.DirectDamagePool.Release(directDamageBox);
            }

            _damageBoxes.Remove(damageBox);
        }
        
        public virtual void Destroy()
        {
            this._DestroyDamageBoxes();
            this.actor = null;
            this._masterExporter = null;
            this._caster = null;
			this._skillType = null;
            this.SetFinalDamageAddAttr(0);
        }
        
        public void HitAny(DamageBox damageBox)
        {
            if (damageBox.lastHitTargets.Count <= 0)
            {
                return;
            }
            
            // 伤害盒命中任何单位事件
            var eventData = actor.battle.eventMgr.GetEvent<EventBoxHitActors>();
            eventData.Init(damageBox, GetCaster(), this as ISkill);
            actor.battle.eventMgr.Dispatch(EventType.OnBoxHitActors, eventData);

            var damageParam = DamageParam.Create(this, damageBox.damageBoxCfg, damageBox.hitParamConfig, damageBox.damageProportion, damageBox.lastHitTargets);
            damageParam.exportedDamageAction = damageBox.OnDamageActor;
            actor.battle.damageProcess.ExportDamage(damageParam);
            _OnHitAny(damageBox);
        }

        // TODO for 老艾 DamageBox不要暴露给DamageExporter之外的类. 方案: 把外界关心的数据包个类给出去.
        protected virtual void _OnHitAny(DamageBox damageBox)
        {

        }

        // 是否忽略碰到的角色
        public virtual bool HittingIgnoreActor(Actor actor)
        {
            return false;
        }

        #region DamageBoxGroup接口

        private void _TryCreateDamageBoxGroup(int groupID)
        {
            if (groupID == 0)
            {
                return;
            }

            if (_damageBoxGroups.ContainsKey(groupID))
            {
                return;
            }

            var damageBoxGroup = ObjectPoolUtility.DamageBoxGroupPool.Get();
            damageBoxGroup.Init(groupID);
            _damageBoxGroups.Add(groupID, damageBoxGroup);
        }

        private void _TryAddDamageBoxToGroup(int groupID, DamageBox damageBox)
        {
            if (groupID == 0)
            {
                return;
            }

            if (!_damageBoxGroups.TryGetValue(groupID, out var damageBoxGroup))
            {
                return;
            }

            damageBoxGroup.AddBox(damageBox);
        }

        private void _TryRemoveDamageBoxFromGroup(int groupID, DamageBox damageBox)
        {
            if (groupID == 0)
            {
                return;
            }
            
            if (!_damageBoxGroups.TryGetValue(groupID, out var damageBoxGroup))
            {
                return;
            }

            damageBoxGroup.RemoveBox(damageBox);
        }

        private void _DestroyDamageBoxGroup(DamageBoxGroup damageBoxGroup)
        {
            _damageBoxGroups.Remove(damageBoxGroup.ID);
            ObjectPoolUtility.DamageBoxGroupPool.Release(damageBoxGroup);
        }

        private void _DestroyAllDamageBoxGroup()
        {
            foreach (var keyValuePair in _damageBoxGroups)
            {
                _tempDamageBoxGroups.Add(keyValuePair.Value);
            }
            
            for (var i = _tempDamageBoxGroups.Count - 1; i >= 0; i--)
            {
                _DestroyDamageBoxGroup(_tempDamageBoxGroups[i]);
            }

            _tempDamageBoxGroups.Clear();
        }

        public void OnHitActorUpdateTimes(int groupID, int damageBoxInsID, List<Actor> hitActors)
        {
            if (groupID == 0)
            {
                return;
            }

            if (!_damageBoxGroups.TryGetValue(groupID, out var damageBoxGroup))
            {
                return;
            }

            damageBoxGroup.OnHitActorUpdateTimes(damageBoxInsID, hitActors);
        }

        #endregion
    }
}