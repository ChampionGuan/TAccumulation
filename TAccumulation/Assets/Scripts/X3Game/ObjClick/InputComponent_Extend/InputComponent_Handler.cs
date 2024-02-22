// Name：InputComponent_Handler
// Created by jiaozhu
// Created Time：2022-04-20 18:46

using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    public partial class InputComponent
    {
        #region 私有变量

        List<InputBase> handlers = new List<InputBase>();
        Dictionary<CtrlType, InputBase> handlerMap = new Dictionary<CtrlType, InputBase>();

        bool isTouchEnable = true;
        bool isAuto = true;
        int lastTouchCount;
        private static bool isInit = false;

        #endregion

#if UNITY_EDITOR
        Rect screenRect;
#endif

        #region 私有处理函数

        private void Start()
        {
#if UNITY_EDITOR
            screenRect = new Rect(0, 0, Screen.width, Screen.height);
#endif
        }


        /// <summary>
        /// 是否在屏幕内
        /// </summary>
        /// <param name="pos"></param>
        /// <returns></returns>
        bool IsInScreen(Vector2 pos)
        {
            bool isIn = true;
#if UNITY_EDITOR
            isIn = screenRect.Contains(pos);
#endif
            return isIn;
        }


        /// <summary>
        /// 检测控制器委托
        /// </summary>
        void InternalSetDelegate(InputBaseDelegate inputDelegate)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetDelegate(inputDelegate);
        }

        void InternalSetTouchBlockEnableByUI(TouchEventType touchType, bool isBlock)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetTouchBlockEnableByUI(touchType, isBlock);
        }

        void InternalSetEffect(string clickEffect = null, string dragEffect=null,string longPress=null)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetEffect(clickEffect, dragEffect,longPress);
        }
        
        void InternalSetTargetEffect(string clickEffect = null, string dragEffect=null,string longPress=null)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetTargetEffect(clickEffect, dragEffect,longPress);
        }
        
        void InternalSetEffectEnable(EffectType effectType,bool isEnable)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetEffectEnable(effectType, isEnable);
        }
        
        void InternalSetTargetEffectEnable(EffectType effectType,bool isEnable)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetTargetEffectEnable(effectType, isEnable);
        }

        void InternalSetGestureRatio(float ratio)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetGestureRatio(ratio);
        }

        #region 本地ctrl管理
        /// <summary>
        /// 添加ctrl
        /// </summary>
        /// <param name="ctrlType"></param>
        InputBase AddCtrl(CtrlType ctrlType)
        {
            if (!handlerMap.ContainsKey(ctrlType))
            {
                InputBase res = GetCtrlFromPool(ctrlType);
                if (ctrlType != CtrlType.HANDLER)
                {
                    res.InputHandler = GetOrAddCtrl<InputHandler>(CtrlType.HANDLER);
                }

                handlerMap.Add(ctrlType, res);
                handlers.Add(res);
                return res;
            }

            return GetCtrl(ctrlType);
        }

        /// <summary>
        /// 删除ctrl
        /// </summary>
        /// <param name="ctrlType"></param>
        void RemoveCtrl(CtrlType ctrlType)
        {
            InputBase res = this.GetCtrl(ctrlType);
            if (res != null)
            {
                handlers.Remove(res);
                handlerMap.Remove(ctrlType);
                ReleaseCtrl(res, ctrlType);
            }
        }

        /// <summary>
        /// 获取ctrl
        /// </summary>
        /// <param name="ctrlType"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        T GetOrAddCtrl<T>(CtrlType ctrlType) where T : InputBase
        {
            T t = GetCtrl(ctrlType) as T;
            if (t == null)
            {
                AddCtrl(ctrlType);
            }

            t = GetCtrl(ctrlType) as T;
            return t;
        }

        /// <summary>
        /// 获取ctrl
        /// </summary>
        /// <param name="ctrlType"></param>
        /// <returns></returns>
        InputBase GetCtrl(CtrlType ctrlType)
        {
            InputBase res;
            handlerMap.TryGetValue(ctrlType, out res);
            return res;
        }
        #endregion
        
        #region 逻辑更新检测
        /// <summary>
        /// 更新
        /// </summary>
        void Update()
        {
            if (isAuto)
            {
                InternalCheck();
            }
        }


        /// <summary>
        /// 内部检测函数
        /// </summary>
        void InternalCheck(bool force=false)
        {
            if (!force && (!IsGlobalTouchEnabled || !isTouchEnable || handlers.Count == 0))
            {
                return;
            }

            if (Input.GetMouseButtonDown(0))
            {
                OnTouchDown(GetTouchPos());
            }
            if (Input.GetMouseButtonUp(0))
            {
                if (GetCurTouchType() != TouchEventType.NONE)
                {
                    OnTouchUp(GetTouchPos());
                }
            }

            if (GetCurTouchType() == TouchEventType.NONE)
            {
                //2021/12/24 喵喵和禾禾不需要这个功能，当初始没有触发TouchDown的时候不需要补TouchDown事件 by 峻峻
                //if (Input.GetMouseButton(0))
                //{
                //    OnTouchDown(GetTouchPos());
                //}
                OnAlwaysUpdate(GetTouchPos());
                return;
            }
            else
            {
                if (!Input.GetMouseButton(0))
                {
                    if ((GetCurTouchType() & TouchEventType.ON_TOUCH_UP) != TouchEventType.ON_TOUCH_UP)
                    {
                        OnExit(GetTouchPos());
                        return;
                    }
                }
            }

            if (IsMultiTouchEnable)
            {
                CheckTouchCountChanged();
            }
            OnUpdate(GetTouchPos());
            OnUpdateFinish();
        }
        #endregion
        
        #region 本地交互事件派发

        /// <summary>
        /// 获取当前类型
        /// </summary>
        /// <returns></returns>
        TouchEventType GetCurTouchType()
        {
            var ctrl = GetCtrl(CtrlType.EVENT);
            if (ctrl != null)
                return ctrl.CurTouchType;
            return TouchEventType.NONE;
        }

        /// <summary>
        /// 按下
        /// </summary>
        /// <param name="pos"></param>
        void OnTouchDown(Vector2 pos)
        {
#if UNITY_EDITOR
            if (!IsInScreen(pos))
            {
                return;
            }
#endif
            lastTouchCount = TouchCount;
            InputBase handler;
            for (int i = 0; i < handlers.Count; i++)
            {
                handler = handlers[i];
                handler.CurTouchType = GetCurTouchType();
                handler.OnTouchDown(pos);
            }
        }

        /// <summary>
        /// 抬起
        /// </summary>
        /// <param name="pos"></param>
        void OnTouchUp(Vector2 pos)
        {
            lastTouchCount = TouchCount;
            InputBase handler;
            for (int i = 0; i < handlers.Count; i++)
            {
                handler = handlers[i];
                handler.CurTouchType = GetCurTouchType();
                handler.OnTouchUp(pos);
            }
        }

        /// <summary>
        /// 更新
        /// </summary>
        /// <param name="pos"></param>
        void OnUpdate(Vector2 pos)
        {
            InputBase handler;
            for (int i = 0; i < handlers.Count; i++)
            {
                handler = handlers[i];
                handler.CurTouchType = GetCurTouchType();
                handler.OnUpdate(pos);
            }
        }

        /// <summary>
        /// 无条件更新
        /// </summary>
        /// <param name="pos"></param>
        void OnAlwaysUpdate(Vector2 pos)
        {
            InputBase handler;
            for (int i = 0; i < handlers.Count; i++)
            {
                handler = handlers[i];
                if (handler.AlwaysUpdate())
                {
                    handler.CurTouchType = GetCurTouchType();
                    handler.OnUpdate(pos);
                }
            }
        }

        /// <summary>
        /// 退出
        /// </summary>
        /// <param name="pos"></param>
        void OnExit(Vector2 pos)
        {
            InputBase handler;
            for (int i = 0; i < handlers.Count; i++)
            {
                handler = handlers[i];
                handler.CurTouchType = GetCurTouchType();
                handler.OnExit(pos);
                handler.OnTouchUp(pos);
                handler.OnUpdate(pos);
            }
        }

        void CheckTouchCountChanged()
        {
            if (lastTouchCount != TouchCount)
            {
                InputBase handler;
                for (int i = 0; i < handlers.Count; i++)
                {
                    handler = handlers[i];
                    handler.OnTouchCountChanged(TouchCount,lastTouchCount);
                }
            }
            lastTouchCount = TouchCount;
        }

        void OnUpdateFinish()
        {
            GetOrAddCtrl<InputEventType>(CtrlType.EVENT).OnUpdateFinish();
        }

        #endregion
        
        #region 私有逻辑

        /// <summary>
        /// 清理点击相关
        /// </summary>
        bool ClearTouch()
        {
            if (GetCurTouchType() != TouchEventType.NONE)
            {
                OnExit(GetTouchPos());
                return true;
            }

            return false;
        }

        private void OnDisable()
        {
            ClearTouch();
        }

        /// <summary>
        /// 销毁
        /// </summary>
        private void OnDestroy()
        {
#if !UNITY_EDITOR
            if (PapeGames.X3.AppContext.Instance.IsQuiting)
                return;
#endif

            InputHandler ctrl = GetCtrl(CtrlType.HANDLER) as InputHandler;
            if (ctrl != null)
            {
                ctrl.OnDestroy(gameObject);
            }

            InternalClear();
        }

        void InternalClear()
        {
            foreach (var item in handlerMap)
            {
                ReleaseCtrl(item.Value, item.Key);
            }

            handlerMap.Clear();
            handlers.Clear();
            isAuto = true;
            isTouchEnable = true;
        }

        /// <summary>
        /// 设置ctrl
        /// </summary>
        /// <param name="type"></param>
        /// <param name="isRemove"></param>
        void InternalSetCtrlType(CtrlType type, bool isRemove = false)
        {
            if (!isRemove)
            {
                GetOrAddCtrl<InputEventType>(CtrlType.EVENT);
                GetOrAddCtrl<InputEventType>(CtrlType.HANDLER);
            }

            if ((type & CtrlType.CLICK) == CtrlType.CLICK)
            {
                if (isRemove)
                {
                    RemoveCtrl(CtrlType.CLICK);
                }
                else
                {
                    AddCtrl(CtrlType.CLICK);
                }
            }

            if ((type & CtrlType.DRAG) == CtrlType.DRAG)
            {
                if (isRemove)
                {
                    RemoveCtrl(CtrlType.DRAG);
                }
                else
                {
                    AddCtrl(CtrlType.DRAG);
                }
            }

            if ((type & CtrlType.MULTI_TOUCH) == CtrlType.MULTI_TOUCH)
            {
                if (isRemove)
                {
                    RemoveCtrl(CtrlType.MULTI_TOUCH);
                }
                else
                {
                    AddCtrl(CtrlType.MULTI_TOUCH);
                }
            }

            if ((type & CtrlType.MOUSE_SCROLL) == CtrlType.MOUSE_SCROLL)
            {
                if (isRemove)
                {
                    RemoveCtrl(CtrlType.MOUSE_SCROLL);
                }
                else
                {
                    AddCtrl(CtrlType.MOUSE_SCROLL);
                }
            }

            if ((type & CtrlType.EVENT) == CtrlType.EVENT)
            {
                if (isRemove)
                {
                    RemoveCtrl(CtrlType.EVENT);
                }
                else
                {
                    AddCtrl(CtrlType.EVENT);
                }
            }
        }

        /// <summary>
        /// 设置点击类型
        /// </summary>
        /// <param name="clickType"></param>
        /// <param name="isRemove"></param>
        void InternalSetClickType(ClickType clickType, bool isRemove = false)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                if (!isRemove)
                {
                    ctrl.Click |= clickType;
                }
                else
                {
                    ctrl.Click &= ~clickType;
                }
            }
        }
        #endregion

        #endregion
    }
}