using UnityEngine;

namespace X3Battle
{
    public class SkillState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Skill;

        public SkillState(ActorMainState actorMainState) : base(actorMainState)
        {
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            if (_actor.input != null && _actor.skillOwner.interruptLinkController != null 
                                     && _actor.input.sortDatas.Count > 0)
            {
                //处理技能的跳转和打断逻辑 按照输入优先级进行处理
                var interruptLinkController = _actor.skillOwner.interruptLinkController;
                foreach (var inputData in _actor.input.sortDatas)
                {
                    if (inputData.Value == null)
                    {
                        continue;
                    }
                
                    //先处理linkdata 连招 --清心
                    var res = interruptLinkController.UpdateLink(inputData.Key);
                    if (res)
                    {
                        //LogProxy.Log("技能打断连招控制器 技能状态 连招 + btnType = " + inputData.Key + " frame = " + Battle.Instance.frameCount);
                        break;
                    }

                    //再处理技能打断数据
                    res = interruptLinkController.UpateInterrupt(inputData.Key);
                    if (res)
                    {
                        //LogProxy.Log("技能打断连招控制器 技能状态 打断 + btnType = " + inputData.Key + " frame = " + Battle.Instance.frameCount);
                        break;
                    }
                }
            
                //清除标记打断数据
                interruptLinkController.RemoveSkillInterruptBySkillFrame();
                //清除标记连招数据
                interruptLinkController.RemoveSkillLinkAssetFlag();
                //处理能否被移动打断
                interruptLinkController.SkillTryEndByMove();
                //如果直接切换成move状态 直接return
                if (_mainState.mainStateType == ActorMainStateType.Move)
                {
                    return;
                }
            }
            
            if (_actor.locomotion?.moveType != MoveType.Num && _actor.locomotion?.destDir != Vector3.zero )
            {
                _mainState.TryToState(ActorMainStateType.Move);
            }
        }

        protected override void OnExit(ActorMainStateType toStateType)
        {
            if (toStateType != ActorMainStateType.Skill)
            {
                this._actor.skillOwner?.TryEndSkill();
            }
        }
    }
}