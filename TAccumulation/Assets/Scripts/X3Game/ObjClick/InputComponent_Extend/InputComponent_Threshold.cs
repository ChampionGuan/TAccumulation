// Name：InputComponent_Threshold
// Created by jiaozhu
// Created Time：2022-04-22 10:26

namespace X3Game
{
    public partial class InputComponent
    {
        #region 阈值设置相关

        /// <summary>
        /// 设置手势移动阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetGestureThresholdDis(float value)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetGestureThresholdDis(value);
        }

        /// <summary>
        /// 设置移动检测
        /// </summary>
        /// <param name="thresholdDis"></param>
        public void SetMoveThresholdDis(float thresholdDis,ThresholdCheckType moveThresholdType=ThresholdCheckType.HV)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetMoveThresholdDis(thresholdDis,moveThresholdType);
        }

        /// <summary>
        /// 设置移动检测
        /// </summary>
        /// <param name="thresholdDis"></param>
        public void SetDefaultMoveThresholdDis()
        {
            SetMoveThresholdDis(MOVE_THRESHOLD);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="moveThresholdType"></param>
        public void SetMoveThresholdCheckType(ThresholdCheckType moveThresholdType)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetMoveThresholdCheckType(moveThresholdType);
        }
        
        /// <summary>
        /// 
        /// </summary>
        /// <param name="moveThresholdType"></param>
        public void SetDragUpdateThresholdCheckType(ThresholdCheckType moveThresholdType)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetDragUpdateThresholdCheckType(moveThresholdType);
        }


        /// <summary>
        /// 设置手势移动阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetDragUpdateThreshold(float value = 0,ThresholdCheckType checkType=ThresholdCheckType.HOrV)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetDragUpdateThreshold(value,checkType);
        }
        
        /// <summary>
        /// 设置缩放阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetScaleThreshold(float value = 0)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetScaleThreshold(value);
        }
        
        /// <summary>
        /// 设置旋转阈值
        /// </summary>
        /// <param name="value"></param>
        public void SetAngleThreshold(float value = 0)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetAngleThreshold(value);
        }

        #endregion
    }
}