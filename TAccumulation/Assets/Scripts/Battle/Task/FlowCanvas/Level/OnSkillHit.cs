using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("NPC技能命中监听器\nListener:NPCSkillHit")]
    public class OnSkillHit : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<int> skillId = new BBParameter<int>();

        private Action<EventExportDamage> _actionOnSkillHit;

        public OnSkillHit()
        {
            _actionOnSkillHit = _OnSkillHit;
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventExportDamage>(EventType.ExportDamage, _actionOnSkillHit, "OnSkillHit._OnSkillHit");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventExportDamage>(EventType.ExportDamage, _actionOnSkillHit);
        }

        private void _OnSkillHit(EventExportDamage arg)
        {
            if (IsReachMaxCount())
                return;
            if (arg.exporter.actor == null)
                return;
            if (arg.exporter.actor.spawnID != actorId.GetValue())
                return;
            if (arg.exporter.exporterType != DamageExporterType.Skill)
                return;
            if (!(arg.exporter is ISkill skill))
                return;
            if (skill.GetID() != skillId.GetValue())
                return;
            _Trigger();
        }
    }
}
