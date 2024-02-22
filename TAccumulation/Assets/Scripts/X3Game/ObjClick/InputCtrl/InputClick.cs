using System.Collections.Generic;
using Framework;
using UnityEngine;
using ClickType = X3Game.InputComponent.ClickType;
using TouchType = X3Game.InputComponent.TouchEventType;
using PapeGames.X3;
using X3Battle;

namespace X3Game
{
    public class InputClick : InputBase
    {
        /// <summary>
        /// 接受的点击类型（点击位置，点击物体）
        /// </summary>
        public ClickType Click = ClickType.POS;

        /// <summary>
        /// raycast的layerMask
        /// </summary>
        public int LayerMask = UnityEngine.LayerMask.NameToLayer("Everything");

        /// <summary>
        /// 射线检测距离
        /// </summary>
        public float MaxDistance = Mathf.Infinity;

        float beginPressTime;
        bool executeLongPressSuccess = false;

        /// <summary>
        /// 是否检验列表中是否是某个节点的子节点
        /// </summary>
        public bool IsNeedCheckParent = false;

        List<GameObject> checkObjects = new List<GameObject>();
        List<Camera> cameraList = new List<Camera>();
        GameObject clickTarget;
        Collider clickCol;

        /// <summary>
        /// 获取碰撞检测物体
        /// </summary>
        /// <returns></returns>
        public List<GameObject> GetCheckList()
        {
            return checkObjects;
        }

        /// <summary>
        /// 清理
        /// </summary>
        public void ClearCheckObjs()
        {
            checkObjects.Clear();
        }

        /// <summary>
        /// 刷新检测obj
        /// </summary>
        public void RefreshCollider(GameObject rootObj)
        {
            List<Collider> res = ListPool<Collider>.Get();
            rootObj.GetComponentsInChildren<Collider>(true, res);
            for (int i = 0; i < res.Count; i++)
            {
                AddCheckObj(res[i].gameObject);
            }

            ListPool<Collider>.Release(res);
        }        
        
        /// <summary>
        /// 删除collider
        /// </summary>
        public void ClearColliders(GameObject rootObj)
        {
            List<Collider> res = ListPool<Collider>.Get();
            rootObj.GetComponentsInChildren<Collider>(true, res);
            foreach (var col in res)
            {
                Object.Destroy(col);
            }

            ListPool<Collider>.Release(res);
        }
        
        /// <summary>
        /// 添加camera
        /// </summary>
        /// <param name="camera"></param>
        public void AddRaycastCamera(Camera camera)
        {
            if (camera != null)
            {
                if (!cameraList.Contains(camera))
                {
                    cameraList.Add(camera);
                }
            }
        }

        /// <summary>
        /// 清理camera
        /// </summary>
        /// <param name="camera"></param>
        public void RemoveRaycastCamera(Camera camera)
        {
            if (camera != null)
            {
                cameraList.Remove(camera);
            }
        }

        /// <summary>
        /// 检测相机有效性
        /// </summary>
        public void CheckCamera()
        {
            for (int i = cameraList.Count - 1; i >= 0; i--)
            {
                if (XLuaHelper.IsNull(cameraList[i]))
                {
                    cameraList.RemoveAt(i);
                }
            }
        }

        /// <summary>
        /// 添加检测obj
        /// </summary>
        /// <param name="obj"></param>
        public void AddCheckObj(GameObject obj)
        {
            if (obj != null && !checkObjects.Contains(obj))
            {
                checkObjects.Add(obj);
            }
        }

        public override void OnTouchUp(Vector2 pos)
        {
            if (IsTouchTypeEnable(TouchType.ON_TOUCH_CLICK))
            {
                if (!executeLongPressSuccess)
                {
                    OnClick(pos);
                }
            }

            clickTarget = null;
            clickCol = null;
            base.OnTouchUp(pos);
        }

        public override void OnTouchDown(Vector2 pos)
        {
            base.OnTouchDown(pos);
            clickTarget = null;
            clickCol = null;
            executeLongPressSuccess = false;
            beginPressTime = Time.realtimeSinceStartup;
            if (IsTouchTypeEnable(TouchType.ON_TOUCH_DOWN))
            {
                if ((Click & ClickType.TARGET) == ClickType.TARGET)
                {
                    clickTarget = GetRayCastTarget(pos, out clickCol);
                    if (clickTarget != null)
                    {
                        InputHandler.OnTouchDownObj(clickTarget);
                    }

                    InputHandler.OnTouchDownNoCheckObj(clickTarget);
                }
            }
        }

        public override bool OnUpdate(Vector2 pos)
        {
            if (!base.OnUpdate(pos))
            {
                return false;
            }

            if (IsTouchTypeEnable(TouchType.ON_LONGPRESS))
            {
                if ((Click & ClickType.LONG_PRESS) == ClickType.LONG_PRESS)
                {
                    if (InputHandler.IsLongPress(Time.realtimeSinceStartup - beginPressTime))
                    {
                        executeLongPressSuccess = true;
                        beginPressTime = Time.realtimeSinceStartup;
                        OnLongPress(pos);
                    }
                }
            }

            return true;
        }

        void OnClick(Vector2 pos)
        {
            if ((Click & ClickType.POS) == ClickType.POS)
            {
                InputHandler.OnTouchClick(pos);
            }

            if ( (Click & ClickType.TARGET) == ClickType.TARGET)
            {
                if(clickTarget != null)
                    InputHandler.OnTouchClickObj(clickTarget);
                
                if (clickCol != null)
                    InputHandler.OnTouchClickCol(clickCol);
            }
        }

        void OnLongPress(Vector2 pos)
        {
            if (clickTarget != null && (Click & ClickType.TARGET) == ClickType.TARGET)
            {
                InputHandler.OnLongPressObj(clickTarget);
            }

            if ((Click & ClickType.POS) == ClickType.POS)
            {
                InputHandler.OnLongPress(pos);
            }
        }

        bool IsChild<Collider>(Collider collider, GameObject parent)
        {
            if (collider == null) return false;
            List<Collider> res = ListPool<Collider>.Get();
            parent.GetComponents<Collider>(res);
            bool isChild = res.Contains(collider);
            ListPool<Collider>.Release(res);
            return isChild;
        }

        public bool CheckObjValid(GameObject obj,out GameObject target)
        {
            target = obj;
            if (obj != null)
            {
                if (checkObjects.Count > 0)
                {
                    var res = checkObjects.Contains(obj);
                    if (!res)
                    {
                        if (IsNeedCheckParent)
                        {
                            var collider = obj.GetComponent<Collider>();
                            if (collider != null)
                            {
                                foreach (var it in checkObjects)
                                {
                                    if (IsChild(collider, it))
                                    {
                                        target = it;
                                        res = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    return res;
                }

                return true;
            }

            return false;
        }

        GameObject GetRayCastTarget(Vector2 pos, out Collider col)
        {
            GameObject res = null;
            col = null;
            for (int i = 0; i < cameraList.Count; ++i)
            {
                var camera = cameraList[i];
                if (camera != null)
                {
                    var hitCol = CommonUtility.GetRayCastTarget(pos, camera, MaxDistance, LayerMask);
                    if (hitCol != null && CheckObjValid(hitCol.gameObject,out var  obj))
                    {
                        res = obj;
                        col = hitCol;
                        break;
                    }
                }
            }

            return res;
        }

        public override void ClearState()
        {
            base.ClearState();
            IsNeedCheckParent = false;
            cameraList.Clear();
            checkObjects.Clear();
            Click = ClickType.POS;
            LayerMask = UnityEngine.LayerMask.NameToLayer("Everything");
            clickTarget = null;
            MaxDistance = Mathf.Infinity;
            executeLongPressSuccess = false;
            beginPressTime = 0;
        }
    }
}