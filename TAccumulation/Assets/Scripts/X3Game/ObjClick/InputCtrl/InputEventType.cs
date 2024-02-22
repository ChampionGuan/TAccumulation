using UnityEngine;
using TouchType = X3Game.InputComponent.TouchEventType;

namespace X3Game
{
    public class InputEventType : InputBase
    {
        Vector2 beginPos;
        // Vector2 lastPos;
        private bool isExit = false;

        public override void OnTouchDown(Vector2 pos)
        {
            base.OnTouchDown(pos);
            isExit = false;
            beginPos = pos;
            InputHandler.ClearFramesPos();
            InputHandler.AddFramesPos(pos);
            // lastPos = pos;
            ChangeTouchType(TouchType.ON_TOUCH_DOWN);
            if ((CurTouchType & TouchType.ON_TOUCH_DOWN) == TouchType.ON_TOUCH_DOWN)
            {
                InputHandler.OnTouchDown(pos);
            }
        }

        public override void OnTouchUp(Vector2 pos)
        {
            base.OnTouchUp(pos);
            CheckType(pos);
            ChangeTouchType(TouchType.ON_TOUCH_UP);
            if (!isExit)
            {
                if ((CurTouchType & TouchType.INDIS) == TouchType.INDIS)
                {
                    ChangeTouchType(TouchType.ON_TOUCH_CLICK);
                }
                var lastPos =  InputHandler.GetLastFramesPos();
                var delta = pos - lastPos;
                if (InputHandler.IsGesture(Mathf.Abs(delta.x)+Mathf.Abs(delta.y)))
                {
                    ChangeTouchType(TouchType.ON_GESTURE);
                }
            }

            isExit = false;
        }

        public override bool OnUpdate(Vector2 pos)
        {
            if (IsTouchTypeEnable(TouchType.ON_TOUCH_DOWN))
            {
                CheckType(pos);
                // lastPos = pos;
                InputHandler.AddFramesPos(pos);
            }
            else if (IsTouchTypeEnable(TouchType.ON_TOUCH_UP))
            {
                ChangeTouchType(TouchType.NONE);
                InputHandler.OnTouchUp(pos);
            }

            return true;
        }

        void CheckType(Vector2 pos)
        {
            if (IsTouchTypeEnable(TouchType.ON_TOUCH_DOWN))
            {
                if (Input.touchCount >= 2)
                {
                    ChangeTouchType(TouchType.ON_MULTI_TOUCH);
                }
                else
                {
                    ChangeTouchType(TouchType.ON_MULTI_TOUCH, false, true);
                }

                if (IsTouchTypeEnable(TouchType.INDIS))
                {
                    CheckMoved(pos, beginPos);
                    if (IsTouchTypeEnable(TouchType.INDIS))
                    {
                        ChangeTouchType(TouchType.ON_LONGPRESS);
                    }
                }
                else if (IsTouchTypeEnable(TouchType.OUTDIS))
                {
                    ChangeTouchType(TouchType.ON_DRAG);
                }
                else
                {
                    CheckMoved(pos, beginPos);
                }
            }
        }

        public override void OnExit(Vector2 pos)
        {
            isExit = true;
            ChangeTouchType(TouchType.NONE);
            ChangeTouchType(TouchType.ON_TOUCH_UP);
        }

        public override void OnTouchCountChanged(int newCount, int oldCount)
        {
            base.OnTouchCountChanged(newCount, oldCount);
            if (newCount > oldCount)
            {
                ChangeTouchType(TouchType.TOUCH_COUNT_INCREASE);
            }
            else
            {
                ChangeTouchType(TouchType.TOUCH_COUNT_REDUCE);
            }
            ChangeTouchType(TouchType.TOUCH_COUNT_CHANGED);
        }

        public void OnUpdateFinish()
        {
            ChangeTouchType(TouchType.TOUCH_COUNT_INCREASE, false, true);
            ChangeTouchType(TouchType.TOUCH_COUNT_REDUCE, false, true);
            ChangeTouchType(TouchType.TOUCH_COUNT_CHANGED, false, true);
        }

        /// <summary>
        /// 检测滑动
        /// </summary>
        void CheckMoved(Vector2 pos, Vector2 beginPos)
        {
            if (InputHandler.IsMoved(beginPos,pos))
            {
                ChangeTouchType(TouchType.OUTDIS);
            }
            else
            {
                ChangeTouchType(TouchType.INDIS);
            }
        }

        void ChangeTouchType(TouchType st, bool isForce = false, bool isRemove = false)
        {
            if (isRemove)
            {
                CurTouchType &= ~st;
                return;
            }

            if (!isForce && st != TouchType.NONE && (CurTouchType & st) == st)
            {
                return;
            }

            if (InputHandler.IsBlock(st))
            {
                return;
            }

            switch (st)
            {
                case TouchType.ON_TOUCH_DOWN:
                case TouchType.NONE:
                    CurTouchType = st;
                    break;
                case TouchType.ON_TOUCH_UP:
                    ChangeTouchType(TouchType.ON_TOUCH_DOWN | TouchType.ON_DRAG, false, true);
                    break;
                case TouchType.ON_GESTURE:
                    ChangeTouchType(TouchType.ON_DRAG, false, true);
                    break;
                case TouchType.OUTDIS:
                    ChangeTouchType(TouchType.INDIS | TouchType.ON_LONGPRESS, false, true);
                    break;
            }

            CurTouchType |= st;
        }
    }
}