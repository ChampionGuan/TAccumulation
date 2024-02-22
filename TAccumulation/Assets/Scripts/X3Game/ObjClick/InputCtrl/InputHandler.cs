// Name：InputHandler
// Created by jiaozhu
// Created Time：2022-04-21 12:18

using System;
using System.Collections.Generic;
using PapeGames.X3UI;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public class InputHandler : InputBase
    {
        #region 私有属性
        private InputComponent.ThresholdCheckType moveThresholdType = InputComponent.ThresholdCheckType.HV;
        private InputComponent.ThresholdCheckType dragThresholdType = InputComponent.ThresholdCheckType.HOrV;
        private float gestureThresholdDis = InputComponent.GESTURE_DIS_THRESHOLD;
        private float moveThresholdDis = 0;
        private float dragUpdateThreshold = -1;
        private float longPressDt = InputComponent.LONG_PRESS_DURATION_THRESHOLD;
        private float scaleThreshold=0;
        private float angleThreshold=0;
        InputComponent.TouchEventType blockType = InputComponent.TouchEventType.NONE;
        private InputBaseDelegate inputDelegate;
        private string clickEffect;
        private string dragEffect;
        private string longPressEffect;
        private string clickTargetEffect;
        private string dragTargetEffect;
        private string longPressTargetEffect;
        private bool isTouchDownObj = false;
        private InputComponent.EffectType effectType = InputComponent.EffectType.Click | InputComponent.EffectType.Drag | InputComponent.EffectType.LongPress;
        private InputComponent.EffectType targetEffectType = InputComponent.EffectType.Click | InputComponent.EffectType.Drag | InputComponent.EffectType.LongPress;
        private float gestureRatio = InputComponent.GESTURE_HORIZONTAL_RATIO;

        private int framesCount = 5;
        private LinkedList<Vector2> framesPos = new LinkedList<Vector2>(); // 记录过去若干帧，指针停留的坐标
        #endregion

        #region 本地公开方法
        public void SetDelegate(InputBaseDelegate inputDelegate)
        {
            this.inputDelegate = inputDelegate;
        }
        
        public void SetTouchBlockEnableByUI(InputComponent.TouchEventType touchType, bool isBlock)
        {
            if (isBlock)
            {
                blockType |= touchType;
            }
            else
            {
                blockType &= ~touchType;
            }
        }

        #region 手势检测比值

        /// <summary>
        /// 设置手势检测比值
        /// </summary>
        /// <param name="gestureRatio"></param>
        public void SetGestureRatio(float gestureRatio)
        {
            this.gestureRatio = gestureRatio;
        }

        /// <summary>
        /// 计算手势
        /// </summary>
        /// <param name="ratio"></param>
        /// <param name="flag"></param>
        /// <returns></returns>
        public InputComponent.GestrueType GetGesture(float ratio,float flag=-1)
        {
            if (ratio >= gestureRatio)
            {
                if (flag > 0)
                {
                    return InputComponent.GestrueType.UP;
                }
                else
                {
                    return InputComponent.GestrueType.DOWN;
                }
            }
            else
            {
                if (flag > 0)
                {
                    return InputComponent.GestrueType.RIGHT;
                }
                else
                {
                    return InputComponent.GestrueType.LEFT;
                }
            }
        }

        #endregion
        

        #region 设置特效相关

        /// <summary>
        /// 设置特效
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetEffect(string clickEffect = null, string dragEffect = null, string longPressEffect = null)
        {
            this.clickEffect = clickEffect;
            this.dragEffect = dragEffect;
            this.longPressEffect = longPressEffect;
        }
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetTargetEffect(string clickEffect = null, string dragEffect = null, string longPressEffect = null)
        {
            this.clickTargetEffect = clickEffect;
            this.dragTargetEffect = dragEffect;
            this.longPressTargetEffect = longPressEffect;
        }
        
        /// <summary>
        /// 设置目标特效开关
        /// </summary>
        /// <param name="effectType"></param>
        /// <param name="isEnable"></param>
        public void SetTargetEffectEnable(InputComponent.EffectType effectType,bool isEnable)
        {
            if (isEnable)
            {
                this.targetEffectType |= effectType;
            }
            else
            {
                this.targetEffectType &= ~effectType;
            }
        }
        
        /// <summary>
        /// 设置手势特效开关
        /// </summary>
        /// <param name="effectType"></param>
        /// <param name="isEnable"></param>
        public void SetEffectEnable(InputComponent.EffectType effectType,bool isEnable)
        {
            if (isEnable)
            {
                this.effectType |= effectType;
            }
            else
            {
                this.effectType &= ~effectType;
            }
        }

        #endregion

        #region 设置阈值相关

        public void SetLongPressDt(float dt)
        {
            longPressDt = dt;
        }

        /// <summary>
        /// 设置手势移动阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetGestureThresholdDis(float value)
        {
            gestureThresholdDis = value;
        }

        /// <summary>
        ///  设置移动检测类型
        /// </summary>
        /// <param name="checkType"></param>
        public void SetMoveThresholdCheckType(InputComponent.ThresholdCheckType checkType)
        {
            moveThresholdType = checkType;
        }
        
        /// <summary>
        /// 设置滑动检测类型
        /// </summary>
        /// <param name="checkType"></param>
        public void SetDragUpdateThresholdCheckType(InputComponent.ThresholdCheckType checkType)
        {
            dragThresholdType = checkType;
        }

        /// <summary>
        /// 设置移动检测
        /// </summary>
        /// <param name="thresholdDis"></param>
        public void SetMoveThresholdDis(float thresholdDis,InputComponent.ThresholdCheckType moveThresholdType=InputComponent.ThresholdCheckType.HV)
        {
            moveThresholdDis = thresholdDis;
            SetMoveThresholdCheckType(moveThresholdType);
        }

        /// <summary>
        /// 设置手势移动阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetDragUpdateThreshold(float value = 0,InputComponent.ThresholdCheckType moveThresholdType=InputComponent.ThresholdCheckType.HV)
        {
            dragUpdateThreshold = value;
            SetDragUpdateThresholdCheckType(moveThresholdType);
        }

        /// <summary>
        /// 设置缩放
        /// </summary>
        /// <param name="value"></param>
        public void SetScaleThreshold(float value)
        {
            scaleThreshold = value;
        }
        
        /// <summary>
        /// 设置旋转
        /// </summary>
        /// <param name="value"></param>
        public void SetAngleThreshold(float value)
        {
            angleThreshold = value;
        }

        #endregion
        #endregion

        # region 逻辑检测相关

        /// <summary>
        /// 检测屏蔽
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public bool IsBlock(InputComponent.TouchEventType type)
        {
            if (type != InputComponent.TouchEventType.NONE && (blockType & type) == type)
            {
                return CommonUtility.IsPointerOverGameObject();
            }

            return false;
        }

        /// <summary>
        /// 检测移动
        /// </summary>
        /// <param name="dis"></param>
        /// <returns></returns>
        public bool IsMoved(float dis)
        {
            return Mathf.Abs(dis) >= moveThresholdDis;
        }

        /// <summary>
        /// 是否移动
        /// </summary>
        /// <param name="pos1"></param>
        /// <param name="pos2"></param>
        /// <returns></returns>
        public bool IsMoved(Vector2 pos1, Vector2 pos2)
        {
            Vector2 delta = (pos1 - pos2);
            float dis = 0;
            switch (moveThresholdType)
            {
                case InputComponent.ThresholdCheckType.HV:
                    dis = Mathf.Abs(delta.x) + Mathf.Abs(delta.y);
                    break;
                case InputComponent.ThresholdCheckType.HOrV:
                    return IsMoved(delta.x) || IsMoved(delta.y);
                case InputComponent.ThresholdCheckType.Horizontal:
                    dis = Mathf.Abs(delta.x);
                    break;
                case InputComponent.ThresholdCheckType.Vertical:
                    dis = Mathf.Abs(delta.y);
                    break;
            }

            return IsMoved(dis);
        }



        /// <summary>
        /// 检测手势距离
        /// </summary>
        /// <param name="dis"></param>
        /// <returns></returns>
        public bool IsGesture(float dis)
        {
            return dis > gestureThresholdDis;
        }

        /// <summary>
        /// 是否达到长按条件
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        public bool IsLongPress(float dt)
        {
            return dt >= longPressDt;
        }

        /// <summary>
        /// 缩放是否变
        /// </summary>
        /// <param name="scaleDelta"></param>
        /// <returns></returns>
        public bool IsScaleChanged(float scaleDelta)
        {
            return Mathf.Abs(scaleDelta) > scaleThreshold;
        }

        /// <summary>
        /// 通过过去若干帧记录的坐标，判断手势的方向
        /// </summary>
        /// <returns></returns>
        public bool IsMoveChanged()
        {
            Vector2 p0 = GetLastFramesPos();
            Vector2 p1 = GetFirstFramesPos();
            float deltaX = p1.x - p0.x;
            float deltaY = p1.y - p0.y;
            return IsMoveChanged(deltaX, deltaY);
        }
        
        /// <summary>
        /// 是否有移动变化
        /// </summary>
        /// <param name="dis"></param>
        /// <returns></returns>
        public bool IsMoveChanged(float dis)
        {
            return Mathf.Abs(dis) > dragUpdateThreshold;
        }
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <returns></returns>
        public bool IsMoveChanged(float x,float y)
        {
            float dis = 0;
            switch (dragThresholdType)
            {
                case InputComponent.ThresholdCheckType.HOrV:
                    return IsMoveChanged(x) || IsMoveChanged(y);
                case InputComponent.ThresholdCheckType.HV:
                    dis = Mathf.Abs(x) + Mathf.Abs(y);
                    break;
                case InputComponent.ThresholdCheckType.Horizontal:
                    dis = x;
                    break;
                case InputComponent.ThresholdCheckType.Vertical:
                    dis = y;
                    break;
            }
            return IsMoveChanged(dis);
        }
        
        /// <summary>
        /// 旋转是否变
        /// </summary>
        /// <param name="angleDelta"></param>
        /// <returns></returns>
        public bool IsAngleChanged(float angleDelta)
        {
            return Mathf.Abs(angleDelta) > angleThreshold;
        }

        /// <summary>
        /// 是否可以触发
        /// </summary>
        /// <param name="eventType"></param>
        /// <returns></returns>
        bool IsCanExecute(InputComponent.TouchEventType eventType)
        {
            return !IsBlock(eventType);
        }

        #endregion

        # region 委托事件相关

        #region 通用相关
        public void OnTouchDown(Vector2 pos)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_DOWN)) return;
            inputDelegate?.OnTouchDown(pos);
            OnClickEffect();
        }

        public void OnTouchUp(Vector2 pos)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_UP)) return;
            inputDelegate?.OnTouchUp(pos);
        }
        
        public void OnGesture(InputComponent.GestrueType gesture)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_GESTURE)) return;
            inputDelegate?.OnGesture(gesture);
        }
        
        public void OnDestroy(GameObject obj)
        {
            try
            {
                if (InputComponent.IsRebooting)
                {
                    SetDelegate(null);
                    return;
                }
                inputDelegate?.OnDestroy(obj);
            }
            catch (Exception e)
            {
                
            }
            
        }
        #endregion

        #region drag相关
        public void OnBeginDrag(Vector2 pos)
        {
            (inputDelegate as InputDragDelegate)?.OnBeginDrag(pos);
        }

        public void OnDrag(Vector2 pos, Vector2 deltaPos, InputComponent.GestrueType gesture)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_DRAG)) return;
            (inputDelegate as InputDragDelegate)?.OnDrag(pos, deltaPos, gesture);
            OnDragEffect(isTouchDownObj);
            isTouchDownObj = false;
        }

        public void OnEndDrag(Vector2 pos)
        {
            (inputDelegate as InputDragDelegate)?.OnEndDrag(pos);
        }
        #endregion

        #region scroll 相关
        public void OnBeginScrollWheel(float scrollWheel, float delta)
        {
            (inputDelegate as InputScrollDelegate)?.OnBeginScrollWheel(scrollWheel, delta);
        }

        public void OnScrollWheel(float scrollWheel, float delta)
        {
            (inputDelegate as InputScrollDelegate)?.OnScrollWheel(scrollWheel, delta);
        }

        public void OnEndScrollWheel(float scrollWheel, float delta)
        {
            (inputDelegate as InputScrollDelegate)?.OnEndScrollWheel(scrollWheel, delta);
        }
        #endregion
        
        #region 多点触控操作相关
        public void OnBeginDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2)
        {
            (inputDelegate as InputMultiDelegate)?.OnBeginDoubleTouchMove(delta, pos1, pos2);
        }

        public void OnDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_MULTI_TOUCH)) return;
            (inputDelegate as InputMultiDelegate)?.OnDoubleTouchMove(delta, pos1, pos2);
        }

        public void OnEndDoubleTouchMove(float delta, Vector2 pos1, Vector2 pos2)
        {
            (inputDelegate as InputMultiDelegate)?.OnEndDoubleTouchMove(delta, pos1, pos2);
        }

        public void OnBeginDoubleTouchScale(float delta, float scale)
        {
            (inputDelegate as InputMultiDelegate)?.OnBeginDoubleTouchScale(delta, scale);
        }

        public void OnDoubleTouchScale(float delta, float scale)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_MULTI_TOUCH)) return;
            (inputDelegate as InputMultiDelegate)?.OnDoubleTouchScale(delta, scale);
        }

        public void OnEndDoubleTouchScale(float delta, float scale)
        {
            (inputDelegate as InputMultiDelegate)?.OnEndDoubleTouchScale(delta, scale);
        }

        public void OnBeginDoubleTouchRotate(float delta, float angle)
        {
            (inputDelegate as InputMultiDelegate)?.OnBeginDoubleTouchRotate(delta, angle);
        }

        public void OnDoubleTouchRotate(float delta, float angle)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_MULTI_TOUCH)) return;
            (inputDelegate as InputMultiDelegate)?.OnDoubleTouchRotate(delta, angle);
        }

        public void OnEndDoubleTouchRotate(float delta, float angle)
        {
            (inputDelegate as InputMultiDelegate)?.OnEndDoubleTouchRotate(delta, angle);
        }
        #endregion

        #region 点击相关

        public void OnTouchClick(Vector2 pos)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_CLICK)) return;
            (inputDelegate as InputClickDelegate)?.OnTouchClick(pos);
        }


        public void OnTouchDownObj(GameObject obj)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_DOWN)) return;
            (inputDelegate as InputClickDelegate)?.OnTouchDownObj(obj);
            OnTouchDownSound(obj);
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_CLICK)) return;
            isTouchDownObj = obj != null;
            OnClickEffect(isTouchDownObj);
        }

        public void OnTouchDownNoCheckObj(GameObject obj)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_DOWN)) return;
            (inputDelegate as InputClickDelegate)?.OnTouchDownNoCheckObj(obj);
        }

        public void OnLongPress(Vector2 pos)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_LONGPRESS)) return;
            (inputDelegate as InputClickDelegate)?.OnLongPress(pos);
            OnLongPressEffect();
        }

        public void OnLongPressObj(GameObject obj)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_LONGPRESS)) return;
            (inputDelegate as InputClickDelegate)?.OnLongPressObj(obj);
            OnLongPressEffect(true);
        }

        public void OnTouchClickObj(GameObject obj)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_CLICK)) return;
            (inputDelegate as InputClickDelegate)?.OnTouchClickObj(obj);
            OnTouchClickSound(obj);
        }
        
        public void OnTouchClickCol(Collider col)
        {
            if (!IsCanExecute(InputComponent.TouchEventType.ON_TOUCH_CLICK)) return;
            (inputDelegate as InputClickDelegate)?.OnTouchClickCol(col);
        }
        

        #endregion

        #endregion
        
        #region 清理逻辑
        public override void ClearState()
        {
            base.ClearState();
            moveThresholdType = InputComponent.ThresholdCheckType.HV;
            dragThresholdType = InputComponent.ThresholdCheckType.HOrV;
            isTouchDownObj = false;
            inputDelegate = null;
            gestureThresholdDis = InputComponent.GESTURE_DIS_THRESHOLD;
            dragUpdateThreshold = -1;
            longPressDt = InputComponent.LONG_PRESS_DURATION_THRESHOLD;
            blockType = InputComponent.TouchEventType.NONE;
            scaleThreshold = angleThreshold = moveThresholdDis = 0;
            gestureRatio = InputComponent.GESTURE_HORIZONTAL_RATIO;
            effectType = InputComponent.EffectType.Click | InputComponent.EffectType.Drag |
                         InputComponent.EffectType.LongPress;
            SetTargetEffectEnable(effectType,true);
            SetEffectEnable(effectType,true);
            SetEffect();
            SetTargetEffect();
        }
        #endregion
        
        #region 音效相关
        public void OnTouchClickSound(GameObject obj)
        {
            SoundFXHandler.Play(obj, AutoPlayMode.OnClick);
        }
        
        public void OnTouchDownSound(GameObject obj)
        {
            SoundFXHandler.Play(obj, AutoPlayMode.OnTouchDown);
        }
        #endregion
        #region 特效相关

        private bool IsEffectEnable(InputComponent.EffectType effectType)
        {
            return (effectType & this.effectType) == effectType;
        }
        
        private bool IsTargetEffectEnable(InputComponent.EffectType effectType)
        {
            return (effectType & this.targetEffectType) == effectType;
        }

        public void OnClickEffect(bool isTarget=false)
        {
            if (isTarget)
            {
                if (!IsTargetEffectEnable(InputComponent.EffectType.Click))
                {
                    isTarget = false;
                }
            }
            if (!IsEffectEnable(InputComponent.EffectType.Click))
            {
                return;
            }

            string effectName = isTarget ? clickTargetEffect : clickEffect;
            if (string.IsNullOrEmpty(effectName)) return;
            int order = isTarget?1:0;
            InputEffectMgr.ShowEffect(InputEffectMgr.EffectType.Click,effectName,order);
        }

        public void OnDragEffect(bool isTarget=false)
        {
            if (isTarget)
            {
                if (!IsTargetEffectEnable(InputComponent.EffectType.Drag))
                {
                    isTarget = false;
                }
            }
            if (!IsEffectEnable(InputComponent.EffectType.Drag))
            {
                return;
            }
            string effectName = isTarget ? dragTargetEffect : dragEffect;
            if (string.IsNullOrEmpty(effectName)) return;
            int order = isTarget?1:0;
            InputEffectMgr.ShowEffect(InputEffectMgr.EffectType.Drag,effectName,order);
        }

        public void OnLongPressEffect(bool isTarget=false)
        {
            if (isTarget)
            {
                if (!IsTargetEffectEnable(InputComponent.EffectType.LongPress))
                {
                    isTarget = false;
                }
            }
            if (!IsEffectEnable(InputComponent.EffectType.LongPress))
            {
                return;
            }
            string effectName = isTarget ? longPressTargetEffect : longPressEffect;
            if (string.IsNullOrEmpty(effectName)) return;
            int order = isTarget?1:0;
            InputEffectMgr.ShowEffect(InputEffectMgr.EffectType.LongPress,effectName,order);
        }

        #endregion

        public void ClearFramesPos()
        {
            if (framesPos != null)
                framesPos.Clear();
        }
        
        public void AddFramesPos(Vector2 pos)
        {
            if (framesPos == null)
                framesPos = new LinkedList<Vector2>();
            if (framesPos.Count > framesCount)
            {
                framesPos.RemoveLast();
            }

            framesPos.AddFirst(pos);
        }

        public Vector2 GetLastFramesPos()
        {
            if(framesPos != null && framesPos.Count > 0)
                return framesPos.Last.Value;
            return new Vector2(0.0f, 0.0f);
        }

        public Vector2 GetFirstFramesPos()
        {
            if(framesPos != null && framesPos.Count > 0)
                return framesPos.First.Value;
            return new Vector2(0.0f, 0.0f);
        }
    }
}