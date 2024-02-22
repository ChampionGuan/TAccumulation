using UnityEngine;
using TouchType = X3Game.InputComponent.TouchEventType;
using GestrueType = X3Game.InputComponent.GestrueType;

namespace X3Game
{
    public class InputDrag : InputBase
    {
        Vector2 beginPos = Vector2.zero;
        Vector2 dragPos = Vector2.zero;
        Vector2 dragDelta = Vector2.zero;
        Vector2 lastPos = Vector2.zero;
        float deltaX, deltaY;
        private bool isBegin = false;

        public override void OnTouchDown(Vector2 pos)
        {
            base.OnTouchDown(pos);
            isBegin = false;
            beginPos = pos;
            CalculatePos(pos);
        }

        public override void OnTouchUp(Vector2 pos)
        {
            base.OnTouchUp(pos);
            if (IsTouchTypeEnable(TouchType.ON_GESTURE))
            {
                lastPos = InputHandler.GetLastFramesPos(); // 判断手势时，LastPos 用若干帧前的点
                CalculatePos(pos);
                InputHandler.OnGesture(CurGesture);
            }

            if (isBegin)
            {
                isBegin = false;
                InputHandler.OnEndDrag(pos);
            }
        }

        public override bool OnUpdate(Vector2 pos)
        {
            if (IsTouchTypeEnable(TouchType.ON_DRAG))
            {
                if(IsTouchTypeEnable(TouchType.TOUCH_COUNT_CHANGED))
                {
                    CalculatePos(pos);
                    OnTouchUp(pos);
                    OnTouchDown(pos);
                }
                CalculatePos(pos);
                if (!isBegin)
                {
                    isBegin = true;
                    InputHandler.OnBeginDrag(pos);
                }
                else
                {
                    if (isMoveChanged())
                    {
                        InputHandler.OnDrag(pos, dragDelta, CurGesture);
                    }
                }
            }

            return true;
        }

        bool isMoveChanged()
        {
            return InputHandler.IsMoveChanged();
        }

        public override void ClearState()
        {
            base.ClearState();
            beginPos = Vector2.zero;
            dragPos = beginPos;
            lastPos = dragPos;
            dragDelta = dragPos;
            deltaX = 0;
            deltaY = 0;
            isBegin = false;
        }

        void CalculatePos(Vector2 pos)
        {
            dragPos = pos;
            dragDelta = dragPos - lastPos;
            lastPos = dragPos;
            deltaX = Mathf.Abs(dragDelta.x);
            deltaY = Mathf.Abs(dragDelta.y);
            CheckGesture();
        }

        void CheckGesture()
        {
            if (!isMoveChanged())
            {
                CurGesture = GestrueType.NONE;
                return;
            }

            CurGesture = InputHandler.GetGesture(deltaY / deltaX, dragDelta.x);
        }
    }
}