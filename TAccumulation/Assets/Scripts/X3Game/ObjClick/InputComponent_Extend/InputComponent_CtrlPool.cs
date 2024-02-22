// Name：InputComponent_CtrlPool
// Created by jiaozhu
// Created Time：2022-04-21 11:14

using System.Collections.Generic;

namespace X3Game
{
    public partial class InputComponent
    {
        #region 私有静态属性

        static Dictionary<InputComponent.CtrlType, List<InputBase>> ctrlPools =
            new Dictionary<InputComponent.CtrlType, List<InputBase>>();

        #endregion

        #region ctrl池相关

        /// <summary>
        /// 从池中获取ctrl
        /// </summary>
        /// <param name="ctrlType"></param>
        /// <returns></returns>
        static InputBase GetCtrlFromPool(InputComponent.CtrlType ctrlType)
        {
            InputBase res = null;
            List<InputBase> pool;
            if (ctrlPools.TryGetValue(ctrlType, out pool))
            {
                if (pool.Count > 0)
                {
                    res = pool[0];
                    pool.RemoveAt(0);
                }
            }

            if (res == null)
            {
                switch (ctrlType)
                {
                    case CtrlType.CLICK:
                        res = new InputClick();
                        break;
                    case CtrlType.DRAG:
                        res = new InputDrag();
                        break;
                    case CtrlType.MULTI_TOUCH:
                        res = new InputMultiTouch();
                        break;
                    case CtrlType.EVENT:
                        res = new InputEventType();
                        break;
                    case CtrlType.MOUSE_SCROLL:
                        res = new InputMouseScroll();
                        break;
                    case CtrlType.HANDLER:
                        res = new InputHandler();
                        break;
                }
            }

            return res;
        }

        /// <summary>
        /// 回收ctrl
        /// </summary>
        /// <param name="ctrl"></param>
        /// <param name="ctrlType"></param>
        static void ReleaseCtrl(InputBase ctrl, InputComponent.CtrlType ctrlType)
        {
            if (ctrl != null)
            {
                ctrl.Clear();
                List<InputBase> pool;
                if (!ctrlPools.TryGetValue(ctrlType, out pool))
                {
                    pool = new List<InputBase>();
                    ctrlPools[ctrlType] = pool;
                }

                if (!pool.Contains(ctrl))
                {
                    pool.Add(ctrl);
                }
            }
        }

        #endregion
    }
}