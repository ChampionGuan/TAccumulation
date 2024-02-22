using UnityEngine;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public partial class InputComponent : MonoBehaviour
    {
        #region 公开静态接口

        /// <summary>
        /// 全局点击开关
        /// </summary>
        public static bool IsGlobalTouchEnabled = true;

        public static bool IsRebooting = false;

        /// <summary>
        /// 当前点击数量
        /// </summary>
        public static int TouchCount
        {
            get
            {
                
#if UNITY_EDITOR
                return Input.GetMouseButton(0) ? 1 : 0;
#endif
                return Input.touchCount;
            }
        }

        /// <summary>
        /// 当前是否是多点操作
        /// </summary>

        public static bool IsMultiTouch
        {
            get { return TouchCount >= 2; }
        }

        /// <summary>
        /// 是否支持多点触控
        /// </summary>
        public static bool IsMultiTouchEnable
        {
            get { return Input.multiTouchEnabled; }
        }

        private static Vector2 s_CurPos;

        /// <summary>
        /// 获取第二个手指坐标
        /// 注意：真机上当多点触控的时候Input.touches里面的对应关系是，从做到右的
        /// </summary>
        public static Vector2 GetTouchPos(int touchIdx = 0)
        {
            float x = 0, y = 0;

            if (Application.isMobilePlatform)
            {
                if (touchIdx < TouchCount)
                {
                    var p = Input.touches[touchIdx].position;
                    x = p.x;
                    y = p.y;
                }
            }
            else
            {
                var pos = Input.mousePosition;
                x = pos.x;
                y = pos.y;
            }

            s_CurPos.x = x;
            s_CurPos.y = y;
            return s_CurPos;
        }
        
        /// <summary>
        /// 获取第二个手指坐标
        /// 注意：真机上当多点触控的时候Input.touches里面的对应关系是，从做到右的
        /// </summary>
        public static Touch? GetTouch(int touchIdx = 0)
        {
            if (IsMultiTouchEnable && Application.isMobilePlatform)
            {
                if (touchIdx < TouchCount)
                {
                    return Input.touches[touchIdx];
                }
            }

            return null;

        }

        /// <summary>
        /// 获取xyz数值
        /// </summary>
        /// <param name="idx"></param>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        public static void GetTouchPosXY(int idx, out float x, out float y)
        {
            Vector2 v = GetTouchPos(idx);
            x = v.x;
            y = v.y;
        }

        #endregion

        #region 公有方法

        /// <summary>
        /// 设置委托
        /// </summary>
        /// <param name="inputDelegate"></param>
        public void SetDelegate(InputBaseDelegate inputDelegate)
        {
            InternalSetDelegate(inputDelegate);
        }

        /// <summary>
        /// 设置委托,为lua使用
        /// </summary>
        /// <param name="inputDelegate"></param>
        public void SetDelegateAll(InputDelegate inputDelegate)
        {
            SetDelegate(inputDelegate);
        }

        /// <summary>
        /// 设置特效
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetEffect(string clickEffect = null, string dragEffect = null, string longPressEffect = null)
        {
            InternalSetEffect(clickEffect,dragEffect,longPressEffect);
        }
        
        /// 设置特效
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetTargetEffect(string clickEffect = null, string dragEffect = null, string longPressEffect = null)
        {
            InternalSetTargetEffect(clickEffect,dragEffect,longPressEffect);
        }
        
        /// 设置特效
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetEffectEnable(EffectType effectType,bool isEnable)
        {
            InternalSetEffectEnable(effectType,isEnable);
        }
        
        /// 设置特效
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetTargetEffectEnable(EffectType effectType,bool isEnable)
        {
            InternalSetTargetEffectEnable(effectType,isEnable);
        }

        /// 设置横向手势角度
        /// </summary>
        /// <param name="clickEffect"></param>
        /// <param name="dragEffect"></param>
        /// <param name="longPressEffect"></param>
        public void SetGestureAngle(float angle)
        {
            InternalSetGestureRatio(Mathf.Tan(Mathf.Deg2Rad*angle));
        }

        /// <summary>
        /// 清理状态信息
        /// </summary>
        public void Clear()
        {
            InternalClear();
        }

        /// <summary>
        /// 设置输入监控类型
        /// </summary>
        /// <param name="type"></param>
        public void SetCtrlType(CtrlType type, bool isRemove = false)
        {
            InternalSetCtrlType(type, isRemove);
        }

        /// <summary>
        /// 设置点击相应类型
        /// </summary>
        /// <param name="clickType"></param>
        public void SetClickType(ClickType clickType, bool isRemove = false)
        {
            InternalSetClickType(clickType, isRemove);
        }

        /// <summary>
        /// 设置被ui屏蔽的点击事件
        /// </summary>
        /// <param name="touchType"></param>
        public void SetTouchBlockEnableByUI(TouchEventType touchType, bool isBlock)
        {
            InternalSetTouchBlockEnableByUI(touchType, isBlock);
        }

        /// <summary>
        /// 设置点击开关
        /// </summary>
        /// <param name="isEnable"></param>
        public void SetTouchEnable(bool isEnable)
        {
            if (isEnable != isTouchEnable)
            {
                isTouchEnable = isEnable;
                if (!isEnable)
                {
                    if (ClearTouch())
                    {
                        InternalCheck();
                    }
                }
            }
        }

        /// <summary>
        /// 设置是否自动check
        /// </summary>
        /// <param name="isAuto"></param>
        public void SetIsAuto(bool isAuto)
        {
            this.isAuto = isAuto;
        }

        /// <summary>
        /// 是否有效
        /// </summary>
        public bool IsTouchEnable
        {
            get => isTouchEnable && gameObject!=null && gameObject.activeSelf;
            set => isTouchEnable = value;
        }

        /// <summary>
        /// 检测
        /// </summary>
        public void Check()
        {
            InternalCheck();
        }

        #endregion
    }
}