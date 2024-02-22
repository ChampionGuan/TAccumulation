using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TouchType = X3Game.InputComponent.TouchEventType;

namespace X3Game
{
    public class InputMultiTouch : InputBase
    {
        float curDis, lastDis;
        private Vector2 curDir, lastDir;
        private Vector2 pos1, pos2, lastPos1, lastPos2;
        private bool isBegin = false;
        private Vector2 beginPos1, beginPos2, beginDir;
        private float beginDis;
        private float angle;
        private float lastAngle;
        private float scale, lastScale;

        enum MultiTouchType
        {
            None = 0,
            Move = 1 << 1,
            Scale = 1 << 2,
            Rotate = 1 << 3,
        }

        private MultiTouchType curTouchType = MultiTouchType.None;

        public override void OnTouchDown(Vector2 pos)
        {
            base.OnTouchDown(pos);
        }

        public override void OnTouchUp(Vector2 pos)
        {
            base.OnTouchUp(pos);
            CheckUp();
        }

        public override bool OnUpdate(Vector2 pos)
        {
            if (IsTouchTypeEnable(TouchType.ON_MULTI_TOUCH))
            {
                if (IsTouchTypeEnable(TouchType.TOUCH_COUNT_CHANGED))
                {
                    CheckUp();
                }

                if (InputComponent.IsMultiTouch)
                {
                    var touch1 = InputComponent.GetTouch(0);
                    var touch2 = InputComponent.GetTouch(1);
                    pos1 = InputComponent.GetTouchPos(0);
                    pos2 = InputComponent.GetTouchPos(1);
                    if (!isBegin)
                    {
                        isBegin = true;
                        beginPos1 = pos1;
                        beginPos2 = pos2;
                        beginDir = beginPos2 - beginPos1;
                        beginDis = beginDir.sqrMagnitude;
                        Calcuate();
                        CopyValueToLast();
                    }
                    Calcuate();
                    if (touch1 != null && touch2 != null && (touch1.Value.phase == TouchPhase.Moved || touch2.Value.phase == TouchPhase.Moved))
                    {
                        CheckMove();
                        CheckScale();
                        CheckRotate();
                    }
                    CopyValueToLast();
                }
            }
            else
            {
                CheckUp();
            }

            return base.OnUpdate(pos);
        }

        void Calcuate()
        {
            curDir = pos2 - pos1;
            curDis = curDir.sqrMagnitude;
            scale = curDis / beginDis;
            angle += GetFlag() * Vector2.Angle(curDir, lastDir);
        }

        void CopyValueToLast()
        {
            lastPos1 = pos1;
            lastPos2 = pos2;
            lastDir = curDir;
            lastDis = curDis;
            lastAngle = angle;
            lastScale = scale;
        }

        void CheckUp()
        {
            if (isBegin)
            {
                if (IsTouchTypeEnable(MultiTouchType.Move))
                {
                    SetTouchTypeEnable(MultiTouchType.Move, false);
                    InputHandler.OnEndDoubleTouchMove(curDis - lastDis, pos1, pos2);
                }

                if (IsTouchTypeEnable(MultiTouchType.Scale))
                {
                    SetTouchTypeEnable(MultiTouchType.Scale, false);
                    InputHandler.OnEndDoubleTouchScale(scale - lastScale, scale);
                }

                if (IsTouchTypeEnable(MultiTouchType.Rotate))
                {
                    SetTouchTypeEnable(MultiTouchType.Rotate, false);
                    InputHandler.OnEndDoubleTouchRotate(angle - lastAngle, angle);
                }
            }

            ClearState();
        }

        void CheckMove()
        {
            if (!IsTouchTypeEnable(MultiTouchType.Move))
            {
                SetTouchTypeEnable(MultiTouchType.Move, true);
                InputHandler.OnBeginDoubleTouchMove(curDis - lastDis, pos1, pos2);
            }
            else
            {
                if (InputHandler.IsMoveChanged(curDis-lastDis))
                {
                    InputHandler.OnDoubleTouchMove(curDis - lastDis, pos1, pos2);
                }
            }
        }

        void CheckScale()
        {
            if (!IsTouchTypeEnable(MultiTouchType.Scale))
            {
                SetTouchTypeEnable(MultiTouchType.Scale, true);
                InputHandler.OnBeginDoubleTouchScale(scale - lastScale, scale);
            }
            else
            {
                if (InputHandler.IsScaleChanged(scale - lastScale))
                {
                    InputHandler.OnDoubleTouchScale(scale - lastScale, scale);
                }
            }
        }

        void CheckRotate()
        {
            
            if (!IsTouchTypeEnable(MultiTouchType.Rotate))
            {
                SetTouchTypeEnable(MultiTouchType.Rotate, true);
                InputHandler.OnBeginDoubleTouchRotate(angle - lastAngle, angle);
            }
            else
            {
                if (InputHandler.IsAngleChanged(lastAngle - angle))
                {
                    InputHandler.OnDoubleTouchRotate(angle - lastAngle, angle);
                }
            }
        }

        int GetFlag()
        {
            var res = Vector3.Cross(new Vector3(curDir.x, curDir.y, 0), new Vector3(lastDir.x, lastDir.y, 0)).z < 0;
            return res ? 1 : -1;
        }

        public override void ClearState()
        {
            base.ClearState();
            curDir = lastDir = pos1 = pos2 = lastPos1 = lastPos2 = Vector2.zero;
            curTouchType = MultiTouchType.None;
            lastAngle = angle = curDis = lastDis = lastScale = scale = 0;
            isBegin = false;
        }

        /// <summary>
        /// 设置点击类型
        /// </summary>
        /// <param name="touchType"></param>
        /// <param name="isEnable"></param>
        void SetTouchTypeEnable(MultiTouchType touchType, bool isEnable)
        {
            if (isEnable)
            {
                if (touchType == MultiTouchType.None)
                {
                    curTouchType = touchType;
                }
                else
                {
                    curTouchType |= touchType;
                }
            }
            else
            {
                curTouchType &= ~touchType;
            }
        }

        /// <summary>
        /// 检测是否有效
        /// </summary>
        /// <param name="touchType"></param>
        /// <returns></returns>
        bool IsTouchTypeEnable(MultiTouchType touchType)
        {
            return (curTouchType & touchType) == touchType;
        }
    }
}