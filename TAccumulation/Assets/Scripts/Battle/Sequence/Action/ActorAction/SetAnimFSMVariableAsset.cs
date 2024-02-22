using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色运动/设置动画逻辑FSM的参数")]
    [Serializable]
    public class SetAnimFSMVariableAsset : BSActionAsset<ActionSetAnimFsmVariable>
    {
        [LabelText("勾选:进入设置  不勾:退出设置")]
        public bool isSetOnEnter;
        [LabelText("勾选变量bool   不勾:float类型")]
        public bool isVariableBoolType;

        [LabelText("Anim逻辑FSM变量名")]
        public string variableName;
        [LabelText("Anim逻辑FSM变量的参数")]
        public float variableValue;
    }

     public class ActionSetAnimFsmVariable: BSAction<SetAnimFSMVariableAsset>
     {
         protected override void _OnEnter()
         {
             if (clip.isSetOnEnter)
             {
                 if(clip.isVariableBoolType)
                     context.actor.locomotion.SetAnimFSMVariable(clip.variableName, clip.variableValue == 1);
                 else
                     context.actor.locomotion.SetAnimFSMVariable(clip.variableName, clip.variableValue);
             }
         }

         protected override void _OnExit()
         {
             if (!clip.isSetOnEnter)
             {
                 if (clip.isVariableBoolType)
                     context.actor.locomotion.SetAnimFSMVariable(clip.variableName, clip.variableValue == 1);
                 else
                     context.actor.locomotion.SetAnimFSMVariable(clip.variableName, clip.variableValue);
             }
         }    
     }
}