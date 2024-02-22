using System;
using System.Collections.Generic;
using UnityEngine;

namespace PapeGames.X3
{
    public class CheckClickCount : MonoBehaviour
    {
        public int TimeLimit = 5;
        public int NeedClickCount = 8;
        private Queue<float> clickTimeQueue = new Queue<float>();
        public delegate void OnCheckClickSuccessDelegate();
        public OnCheckClickSuccessDelegate OnCheckClickSuccess;

        private void OnEnable()
        {
            clickTimeQueue.Clear();
        }

        protected void Update()
        {
            if (Input.GetMouseButtonUp(0))
            {
                clickTimeQueue.Enqueue(Time.unscaledTime);
                if (clickTimeQueue.Count != NeedClickCount) return;
                if (Time.unscaledTime - clickTimeQueue.Peek() >TimeLimit) //超时丢弃
                {
                    clickTimeQueue.Dequeue();
                }
                else
                {
                    OnCheckClickSuccess();
                }
            }
        }
    }
}