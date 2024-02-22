using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/创建交互物")]
    [Serializable]
    public class CreateInterActorAsset : BSActionAsset<CreateInterActor>
    {
        [LabelText("创建类型")]
        public CreateInterActorType createType = CreateInterActorType.StageId;
        
        [LabelText("组ID", showCondition:"enum:createType==0")]
        public int groupId;
        
        [LabelText("标签", showCondition:"enum:createType==1")]
        public int tag;
        
        [LabelText("关卡编辑器InterActorID", showCondition:"enum:createType==2")]
        public int id;
        
        [LabelText("覆盖InterActorID")]
        public int interActorIdTwo;
    }

    public class CreateInterActor : BSAction<CreateInterActorAsset>
    {
        protected override void _OnInit()
        {
            _CreateInterAction(true);
        } 
        
        protected override void _OnEnter()
        {
            _CreateInterAction(false);
        }

        private void _CreateInterAction(bool isPreload)
        {
            if (context.battle.actorMgr == null)
            {
                return;
            }

            var actorMgr = context.battle.actorMgr;

            switch (clip.createType)
            {
                case CreateInterActorType.GroupID:
                {
                    foreach (var stageConfigInterActor in actorMgr.stageConfig.InterActors)
                    {
                        if(stageConfigInterActor.GroupID != clip.groupId) continue;
                        _Create(isPreload, stageConfigInterActor.ID);
                    }
                }
                    break;
                case CreateInterActorType.Tag:
                {
                    foreach (var stageConfigInterActor in actorMgr.stageConfig.InterActors)
                    {
                        if(stageConfigInterActor.Tag != clip.tag) continue;
                        _Create(isPreload, stageConfigInterActor.ID, clip.interActorIdTwo);
                    }
                }
                    break;
                case CreateInterActorType.StageId:
                {
                    _Create(isPreload, clip.id, clip.interActorIdTwo);

                }
                    break;
            }
        }

        private void _Create(bool isPreload,int interActorIdOne, int interActorIdTwo = 0)
        {
            if (isPreload)
            {
                context.battle.actorMgr.PreloadInterAction(interActorIdOne);  
            }
            else
            {
                context.battle.actorMgr.CreateInterActor(interActorIdOne, interActorIdTwo);  
            }
        }
    }

    public enum CreateInterActorType
    {
        GroupID = 0,
        Tag,
        StageId,
    }
}