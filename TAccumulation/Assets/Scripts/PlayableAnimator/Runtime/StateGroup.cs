using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3.PlayableAnimator
{
    [Serializable]
    public class StateGroup : State
    {
        [HideInInspector] [SerializeField] private List<string> m_States = new List<string>();
        [SerializeField] private bool m_AutoTransition;

        public float autoDuration => 0.1f;
        public bool autoTransition => m_AutoTransition;

        public StateGroup(Vector2 position, string name, string tag) : base(position, name, tag)
        {
        }

        public StateGroup DeepCopy()
        {
            var state = new StateGroup(m_Position, m_Name, m_Tag)
            {
                m_Transitions = new List<Transition>()
            };

            state.m_States.AddRange(m_States);
            return state;
        }

        public bool HasChild(string stateName)
        {
            return m_States.Contains(stateName);
        }

        public void RemoveChild(string stateName)
        {
            if (HasChild(stateName))
            {
                m_States.Remove(stateName);
            }
        }

        public void AddChild(string stateName)
        {
            if (!HasChild(stateName))
            {
                m_States.Add(stateName);
            }
        }

        public void ClearChild()
        {
            m_States.Clear();
        }
    }
}
