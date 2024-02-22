using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 技能打断和连招数据
    /// </summary>
    public class SkillInterruptLinkController
    {
        private List<ActionSkillLink> _actionSkill;
        private List<ActionSkillLink> _actionSkillFlag;
        private Actor _actor;
        private SkillActive _skill;
        
        //技能状态能否被技能打断
        private Dictionary<object, SkillTypeFlag> _skillInterruptBySkills;
        private Dictionary<object, SkillTypeFlag> _skillInterruptBySkillFrames;//当前帧清除
        private SkillTypeFlag _skillInterruptBySkillFlag;
        //技能状态能否被移动打断
        private bool _skillInterruptByMove;  
        //技能状态可以被移动打断
        public bool skillCanInterruptByMove => _skillInterruptByMove && _SkillInterruptByMove();

        public SkillInterruptLinkController()
        {
            _skillInterruptBySkills = new Dictionary<object, SkillTypeFlag>(4); 
            _skillInterruptBySkillFrames = new Dictionary<object, SkillTypeFlag>(4);
            _actionSkill = new List<ActionSkillLink>();
            _actionSkillFlag = new List<ActionSkillLink>();
        }

        public void Init(Actor actor, SkillActive skill)
        {
            _actor = actor;
            _skill = skill;
        }
        public void Clear()
        {
            _skill = null;
            _skillInterruptByMove = false;
            _skillInterruptBySkillFlag = 0;
            _skillInterruptBySkills.Clear();
            _skillInterruptBySkillFrames.Clear();
            _actionSkill.Clear();
            _actionSkillFlag.Clear();
        }
        

        
        #region 技能态
        /// <summary>
        /// 设置技能连招数据
        /// </summary>
        /// <param name="link"></param>
        public void AddSkillLinkAsset(ActionSkillLink link)
        {
            _actionSkill.Add(link);
        }
        
        /// <summary>
        /// 清除技能连招数据
        /// </summary>
        /// <param name="link"></param>
        public void RemoveSkillLinkAsset(ActionSkillLink link)
        {
            _actionSkill.Remove(link);
        }
        
        /// <summary>
        /// 标记清除技能连招数据 //当帧逻辑update执行完之后销毁
        /// </summary>
        /// <param name="link"></param>
        public void AddSkillLinkAssetFlag(ActionSkillLink link)
        {
            //LogProxy.Log("技能打断连招控制器 标记连招数据 frame = "+ Battle.Instance.frameCount);
            _actionSkillFlag.Add(link);
        }
        
        /// <summary>
        /// 清除标记技能连招数据
        /// </summary>
        /// <param name="link"></param>
        public void RemoveSkillLinkAssetFlag()
        {
            //LogProxy.Log("技能打断连招控制器 标记连招数据 清除 frame = "+ Battle.Instance.frameCount);
            _actionSkillFlag.Clear();
        }

        // 开启技能态被哪些技能打断
        public void SetSkillInterruptBySkill(object owner, SkillTypeFlag newFlag)
        {
            _skillInterruptBySkills[owner] = newFlag;
            _UpdateSkillInterruptFlag();
        }
        
        // 开启技能态被哪些技能打断 当帧销毁标记
        public void SetSkillInterruptBySkillFrame(object owner, SkillTypeFlag newFlag)
        {
            //LogProxy.Log("技能打断连招控制器 增加标记 + skilltypeflag = " + newFlag + " frame = " + Battle.Instance.frameCount);
            _skillInterruptBySkillFrames[owner] = newFlag;
            _UpdateSkillInterruptFlag();
        }
        /// <summary>
        /// 清除标记技能打断数据
        /// </summary>
        /// <param name="link"></param>
        public void RemoveSkillInterruptBySkillFrame()
        {
            //LogProxy.Log("技能打断连招控制器 清理标记 + skilltypeflag = frame = " + Battle.Instance.frameCount);
            _skillInterruptBySkillFrames.Clear();
        }
        // 关闭技能打断
        public void StopSkillInterrupt(object owner)
        {
            _skillInterruptBySkills.Remove(owner);
            _UpdateSkillInterruptFlag();
            
        }

        /// <summary>
        /// 更新连招数据
        /// </summary>
        /// <param name="btnType"></param>
        public bool UpdateLink(PlayerBtnType btnType)
        {
            foreach (var skillLink in _actionSkill)
            {
                var res = skillLink.DoLink(btnType);
                if (res)
                {
                    return true;
                }
            }

            foreach (var skillLink in _actionSkillFlag)
            {
                var res = skillLink.DoLink(btnType);
                if (res)
                {
                    return true;
                }
            }
            
            return false;
        }

        /// <summary>
        /// 更新打断数据
        /// </summary>
        /// <param name="btnType"></param>
        /// <returns></returns>
        public bool UpateInterrupt(PlayerBtnType btnType)
        {
            foreach (var asset in _skillInterruptBySkills)
            {
                if(asset.Key is ActionCanInterrupt canInterrupt)
                {
                    var res = canInterrupt.OnSkillCanInterrupt(btnType);
                    if (res)
                    {
                        return true;
                    }
                }
            }
            
            foreach (var asset in _skillInterruptBySkillFrames)
            {
                if(asset.Key is ActionCanInterrupt canInterrupt)
                {
                    var res = canInterrupt.OnSkillCanInterrupt(btnType);
                    if (res)
                    {
                        return true;
                    }
                }
            }

            return false;
        }
        
        // 设置技能态是否能由移动打断
        public void SetSkillInterruptByMove(bool canInterrupt)
        {
            _skillInterruptByMove = canInterrupt;
        }

        // 技能态尝试被移动打断
        public void SkillTryEndByMove()
        {
            if (_skillInterruptByMove && _actor.HasDirInput() && _SkillInterruptByMove())
            {
                _actor.skillOwner.TryEndSkill();
            }
        }
        
        // 技能态移动打断，判断输入是否合法
        private bool _SkillInterruptByMove()
        {
            var valid = true;
            if (_actor.input != null)
            {
                // 遍历角色的连招数据
                var links = _actor.skillOwner.skillLinkData.links;
                foreach (var iter in links)
                {
                    // 连招处于激活状态，并且状态是Hold类型 
                    var linkData = iter.Value;
                    var stateType = linkData.btnStateType;
                    if (linkData.IsActive() && stateType == PlayerBtnStateType.Hold)
                    {
                        // 这时候也有这个按钮的hold输入，认为不可打断技能
                        var btnType = linkData.playerBtnType;
                        var hasHoldInput = _actor.input.CanConsumeCache(btnType, stateType);
                        if (hasHoldInput)
                        {
                            valid = false;
                            break;
                        }
                    }
                }
            }
            return valid;
        }
        //技能态能否被主动技能打断
        public bool SkillCanInterrupt(SkillType otherType)
        {
            var result = BattleUtil.ContainSkillType(_skillInterruptBySkillFlag, otherType);
            return result;
        }

        private void _UpdateSkillInterruptFlag()
        {
            SkillTypeFlag newFlag = 0;
            foreach (var iter in _skillInterruptBySkills)
            {
                newFlag |= iter.Value;
            }
            
            foreach (var iter in _skillInterruptBySkillFrames)
            {
                newFlag |= iter.Value;
            }
            
            if (_skillInterruptBySkillFlag == newFlag)
            {
                return;
            }
            _skillInterruptBySkillFlag = newFlag;
            _SendInterruptChangeEvent();
        }

        private void _SendInterruptChangeEvent()
        {
            if (_actor == null || _skill == null)
            {
                return;
            }
            var eventData = _actor.battle.eventMgr.GetEvent<EventCanInterruptSkill>();
            eventData.Init(_skill);
            _actor.battle.eventMgr.Dispatch(EventType.CanInterruptSkill, eventData);
        }
        #endregion
    }
}