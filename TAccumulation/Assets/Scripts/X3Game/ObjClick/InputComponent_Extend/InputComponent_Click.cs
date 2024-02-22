// Name：InputComponent_Click
// Created by jiaozhu
// Created Time：2022-04-21 10:58

using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    public partial class InputComponent
    {
        # region Click 相关公开接口

        /// <summary>
        /// 是否检测该节点是否是列表中某个节点的子节点
        /// </summary>
        /// <param name="isNeed"></param>
        public void SetIsNeedCheckParent(bool isNeed)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.IsNeedCheckParent = isNeed;
            }
        }

        /// <summary>
        /// 检测点击相关相机
        /// </summary>
        public void CheckCamera()
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.CheckCamera();
            }
        }

        /// <summary>
        /// 清理点击相关obj
        /// </summary>
        public void ClearCheckObjs()
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.ClearCheckObjs();
            }
        }

        /// <summary>
        /// 检测gameObject是否有效
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public bool IsObjValid(GameObject obj)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                return ctrl.CheckObjValid(obj,out var target);
            }

            return false;
        }

        /// <summary>
        /// 添加点击检测对象
        /// </summary>
        /// <param name="obj"></param>
        public void AddCheckObj(GameObject obj)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.AddCheckObj(obj);
            }
        }

        /// <summary>
        /// 刷新点击collider
        /// </summary>
        /// <param name="obj"></param>
        public void RefreshCollider(GameObject obj)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.RefreshCollider(obj);
            }
        }        
        
        /// <summary>
        /// 删除collider
        /// </summary>
        /// <param name="obj"></param>
        public void ClearColliders(GameObject obj)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.ClearColliders(obj);
            }
        }

        /// <summary>
        /// 添加camera
        /// </summary>
        /// <param name="camera"></param>
        public void AddRaycastCamera(Camera camera)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.AddRaycastCamera(camera);
            }
        }

        /// <summary>
        /// 清理camera
        /// </summary>
        /// <param name="camera"></param>
        public void RemoveRaycastCamera(Camera camera)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.RemoveRaycastCamera(camera);
            }
        }

        #endregion

        #region 点击相关单独设置

        /// <summary>
        /// 获取点击物体检测列表
        /// </summary>
        /// <returns></returns>
        public List<GameObject> GetClickCheckObjs()
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                return ctrl.GetCheckList();
            }

            return null;
        }

        /// <summary>
        /// 设置点击的layermask
        /// </summary>
        /// <param name="layerMask"></param>
        public void SetClickLayerMask(int layerMask)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.LayerMask = layerMask;
            }
        }

        /// <summary>
        /// 设置射线检测距离的maxDis
        /// </summary>
        /// <param name="layerMask"></param>
        public void SetClickRaycastMaxDis(float maxDis)
        {
            InputClick ctrl = GetCtrl(CtrlType.CLICK) as InputClick;
            if (ctrl != null)
            {
                ctrl.MaxDistance = maxDis;
            }
        }

        /// <summary>
        /// 设置长按相应时长，默认和ui保持一致
        /// </summary>
        /// <param name="dt"></param>
        public void SetLongPressDt(float dt)
        {
            GetOrAddCtrl<InputHandler>(CtrlType.HANDLER).SetLongPressDt(dt);
        }

        #endregion
    }
}