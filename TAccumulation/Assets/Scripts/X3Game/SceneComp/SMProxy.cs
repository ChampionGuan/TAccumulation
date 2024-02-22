using UnityEngine;
using System.Collections.Generic;
using System;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class SMProxy : StateMachineBehaviour
    {
        public delegate void SMEventAction(Animator animator, int tag, int eventID, int stateNameHash, int layerIdx);

        public int Tag;
        public bool StateUpdateEnabled = false;
        private static SMEventAction s_OnSMEvent;

        public static void SetCallback(SMEventAction callback)
        {
            s_OnSMEvent = callback;
        }
        
        public override void OnStateEnter(
            Animator animator,
            AnimatorStateInfo stateInfo,
            int layerIndex)
        {
            InvokeSMEvent(SMEvent.OnStateEnter, animator, stateInfo, layerIndex);
        }

        public override void OnStateUpdate(
            Animator animator,
            AnimatorStateInfo stateInfo,
            int layerIndex)
        {
            if (!StateUpdateEnabled)
                return;
            InvokeSMEvent(SMEvent.OnStateUpdate, animator, stateInfo, layerIndex);
        }

        public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            InvokeSMEvent(SMEvent.OnStateExit, animator, stateInfo, layerIndex);
        }

        public override void OnStateMachineEnter(Animator animator, int stateMachinePathHash)
        {
            s_OnSMEvent?.Invoke(animator, this.Tag, (int)SMEvent.OnStateMachineEnter, 0, 0);
        }

        public override void OnStateMachineExit(Animator animator, int stateMachinePathHash)
        {
            s_OnSMEvent?.Invoke(animator, this.Tag, (int)SMEvent.OnStateMachineExit, 0, 0);
        }
        
        private void InvokeSMEvent(SMEvent eventID, Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            s_OnSMEvent?.Invoke(animator, this.Tag, (int)eventID, stateInfo.shortNameHash, layerIndex);
        }
        
        public enum SMEvent
        {
            OnStateEnter,
            OnStateUpdate,
            OnStateExit,
            OnStateMachineEnter,
            OnStateMachineExit
        }
        
        
        [XLua.CSharpCallLua] public static List<Type> CSCallLuaTypes = new List<Type>()
        {
            typeof(SMEventAction)
        };
    }
}