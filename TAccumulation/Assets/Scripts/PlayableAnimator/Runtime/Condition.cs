using System;
using UnityEngine;

namespace X3.PlayableAnimator
{
    //[Serializable]
    //public abstract class Condition : ScriptableObject
    //{
    //    [SerializeField] private bool m_Mute;

    //    public bool mute => m_Mute;

    //    public abstract Condition DeepCopy();
    //    public abstract bool IsMeet(StateMotion fromState);
    //    public abstract NewCondition Convert();

    //    public virtual void OnMeet()
    //    {
    //    }
    //}

    [Serializable]
    public abstract class Condition
    {
        [SerializeField] private bool m_Mute;

        public bool mute => m_Mute;

        public abstract Condition DeepCopy();
        public abstract bool IsMeet(StateMotion fromState);

        public virtual void OnMeet()
        {
        }
    }
}