// Name：InputMouseScroll
// Created by jiaozhu
// Created Time：2022-03-30 14:21

using UnityEngine;

namespace X3Game
{
    public class InputMouseScroll : InputBase
    {
        static readonly string MOUSE_SCROLL_WHEEL = "Mouse ScrollWheel";
        float curScrollWhell, lastScrollWhell;
        private bool isBegin;

        public override bool OnUpdate(Vector2 pos)
        {
            curScrollWhell = Input.GetAxis(MOUSE_SCROLL_WHEEL);
            if (curScrollWhell != 0)
            {
                if (!isBegin)
                {
                    isBegin = true;
                    InputHandler.OnBeginScrollWheel(curScrollWhell, curScrollWhell - lastScrollWhell);
                }
                else
                {
                    if (!Mathf.Approximately(curScrollWhell - lastScrollWhell, 0))
                    {
                        InputHandler.OnScrollWheel(curScrollWhell, curScrollWhell - lastScrollWhell);
                    }
                }
                lastScrollWhell = curScrollWhell;
            }
            else
            {
                if (isBegin)
                {
                    isBegin = false;
                    InputHandler.OnEndScrollWheel(curScrollWhell, curScrollWhell - lastScrollWhell);
                    ClearState();
                }
            }

            return base.OnUpdate(pos);
        }

        public override void ClearState()
        {
            base.ClearState();
            isBegin = false;
            curScrollWhell = lastScrollWhell = 0;
        }

        public override bool AlwaysUpdate()
        {
            return true;
        }
    }
}