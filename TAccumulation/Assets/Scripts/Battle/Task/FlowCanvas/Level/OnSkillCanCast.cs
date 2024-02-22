using System;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("指定角色指定技能由不可释放到可释放监听器\nOnSkillCanCast")]
    public class OnSkillCanCast : FlowListener
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<SkillSlotType> skillType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillIndex = new BBParameter<int>();
        public int skillTag = -1;
        
        private SkillState _skillState = SkillState.None;
        private Actor _skillCaster;
        private int _slotId;
        private int _timerId;
        private Action<int, int> _actionTick;

        public OnSkillCanCast()
        {
            _actionTick = _TickAction;
        }

        protected override void _RegisterEvent()
        {
            _skillCaster = _battle.actorMgr.GetActor(actorId.value) ?? _actor;
            if (_skillCaster == null)
            {
                PapeGames.X3.LogProxy.LogError($"角色ActorId={actorId.value}配置错误，请找策划五当或五当！");
                return;
            }

            var slotIdVar = _skillCaster.skillOwner.GetSlotID(skillType.value, skillIndex.value);
            if (slotIdVar == null)
            {
                _LogError($"技能skillID={skillIndex.value}, 配置错误，请找策划五当或五当！");
                _skillState = SkillState.None;
            }
            else
            {
                _slotId = slotIdVar.Value;

                var skillSlot = _skillCaster.skillOwner.GetSkillSlot(_slotId);
                if (skillSlot == null)
                {
                    return;
                }
                
                if (skillTag != -1 && !skillSlot.skill.HasSkillTag(skillTag))
                {
                    return;
                }

                if (_skillCaster.skillOwner.CanCastSkillBySlot(_slotId, false, false))
                {
                    _skillState = SkillState.FirstCanCast;
                }
                else
                {
                    _skillState = SkillState.CanNotCast;
                }
            }
            
            _timerId = _actor.timer.AddTimer(null, 0f, 0f, -1, "", null, _actionTick);
        }

        protected override void _UnRegisterEvent()
        {
            _skillState = SkillState.None;
            
            _actor.timer.Discard(null, _timerId);
            _timerId = 0;
        }

        
        private void _TickAction(int id, int repeatCount)
        {
            if (!_isRegisterEvent)
            {
                return;
            }

            if (_skillState == SkillState.FirstCanCast && !_skillCaster.skillOwner.CanCastSkillBySlot(_slotId, false, false))
            {
                _skillState = SkillState.CanNotCast;
            }
            else if (_skillState == SkillState.CanNotCast && _skillCaster.skillOwner.CanCastSkillBySlot(_slotId, false, false))
            {
                _Trigger();
            }
        }

        enum SkillState
        {
            None,
            FirstCanCast,
            CanNotCast,
        }

#if UNITY_EDITOR

        protected override void OnNodeInspectorGUI()
        {
            if ( this.GetType().RTIsDefined<HasRefreshButtonAttribute>(true) ) {
                if ( GUILayout.Button("Refresh") ) { GatherPorts(); }
                EditorUtils.Separator();
            }

            var objectDrawer = PropertyDrawerFactory.GetObjectDrawer(this.GetType());
            var content = EditorUtils.GetTempContent(name.SplitCamelCase());
            objectDrawer.DrawGUI(content, this, new InspectedFieldInfo());

            EditorUtils.Separator();
            DrawValueInputsGUI();
        }

#endif
    }
}
