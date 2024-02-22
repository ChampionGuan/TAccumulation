// Name：InputComponent_Enum
// Created by jiaozhu
// Created Time：2022-03-25 11:15

using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class InputComponent
    {
        #region 枚举类型

        /// <summary>
        /// 点击类型
        /// </summary>
        public enum ClickType
        {
            NONE = 0,
            POS = 1 << 1,
            TARGET = 1 << 2,
            LONG_PRESS = 1 << 3,
        }

        /// <summary>
        /// 手势类型
        /// </summary>
        public enum GestrueType
        {
            NONE,
            LEFT,
            RIGHT,
            UP,
            DOWN
        }
        
        public enum EffectType
        {
            Click = 1<<1,
            Drag = 1<<2,
            LongPress = 1<<3,
        }

        /// <summary>
        /// 点击事件类型
        /// </summary>
        public enum TouchEventType
        {
            NONE = 0,
            ON_TOUCH_DOWN = 1 << 1,
            ON_TOUCH_UP = 1 << 2,
            ON_LONGPRESS = 1 << 3,
            ON_TOUCH_CLICK = 1 << 4,
            ON_DRAG = 1 << 5,
            ON_GESTURE = 1 << 6,
            ON_MULTI_TOUCH = 1 << 7,
            INDIS = 1 << 8,
            OUTDIS = 1 << 9,
            TOUCH_COUNT_INCREASE = 1<< 10,
            TOUCH_COUNT_REDUCE = 1 << 11,
            TOUCH_COUNT_CHANGED = 1 << 12,
        }

        /// <summary>
        /// 支持类型
        /// </summary>
        public enum CtrlType
        {
            NONE,
            CLICK = 1 << 1,
            DRAG = 1 << 2,
            MULTI_TOUCH = 1 << 3,
            EVENT = 1 << 4,
            MOUSE_SCROLL = 1 << 5,
            HANDLER = 1 << 6,
        }
        
        /// <summary>
        /// 移动阈值方向
        /// </summary>
        public enum ThresholdCheckType
        {
            HV,
            HOrV,
            Horizontal,
            Vertical,
        }

        #endregion

        public static  float GESTURE_DIS_THRESHOLD
        {
            get { return X3GameSettings.Instance.UISettings.GestureThresholdDis;}
        }

        public static float GESTURE_HORIZONTAL_RATIO
        {
            get { return Mathf.Tan(  Mathf.Deg2Rad*X3GameSettings.Instance.UISettings.GestureHorizontalAngle);}
        }

        public static float MOVE_THRESHOLD
        {
            get
            {
                return CommonUtility.GetMoveThreshold();
            }
        }

        public static float LONG_PRESS_DURATION_THRESHOLD
        {
            get
            {
                return X3GameSettings.Instance.UISettings.LongPressDuration;
            }
        }
        public static readonly float DOUBLE_SCALE_THRESHOLD = 0;
        public static  readonly float DOUBLE_ANGLE_THRESHOLD = 0;
        public static  readonly float DOUBLE_MOVE_THRESHOLD = 0;
    }
}