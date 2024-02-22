using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using XLua;

namespace PapeGames.X3UI
{
    /// <summary>
    /// 摇杆组件
    /// </summary>
    /// <remarks>
    /// Creator: Zhanbo
    /// Create Date: 2021-02-22
    /// Updater: Zhanbo
    /// Last Update: 2021-02-22
    /// </remarks>
    [LuaCallCSharp]
    [CSharpCallLua]
    [DisallowMultipleComponent]
    public class X3Joystick : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler, IUIComponent
    {
        /// <summary>
        /// 摇杆类型
        /// </summary>
        public enum EJoystick
        {
            /// <summary>
            /// 固定位置，默认显示
            /// </summary>
            Normal = 1,

            /// <summary>
            /// 固定位置，默认隐藏
            /// </summary>
            NormalHide = 2,

            /// <summary>
            /// 跟随按下的位置，默认隐藏
            /// </summary>
            FollowHide = 3,
        }

        /// <summary>
        /// 摇杆类型
        /// </summary>
        [SerializeField] EJoystick eJoystick;

        /// <summary>
        /// 摇杆Group
        /// </summary>
        [SerializeField] GameObject JoystickGroup;

        /// <summary>
        /// 大圆
        /// </summary>
        [SerializeField] RectTransform JoystickBackGround;

        /// <summary>
        /// 小圆
        /// </summary>
        [SerializeField] RectTransform JoystickForward;

        /// <summary>
        /// 箭头
        /// </summary>
        [SerializeField] RectTransform JoystickArow;

        /// <summary>
        /// 死区区域
        /// </summary>
        [SerializeField] private float DeadArea = 0.0f;

        /// <summary>
        /// 行走区域
        /// </summary>
        [SerializeField] private float WalkArea = 0.4f;

        /// <summary>
        /// 摇杆按下的回调
        /// </summary>
        public UnityAction<PointerEventData> OnJoystickDown;

        /// <summary>
        /// 摇杆抬起的回调
        /// </summary>
        public UnityAction<PointerEventData> OnJoystickUp;

        /// <summary>
        /// 摇杆拖拽的回调
        /// </summary>
        public UnityAction<Vector2> OnJoystickDrag;

        /// <summary>
        /// 摇杆被按下：Update里面的回调
        /// </summary>
        public UnityAction<Vector2> OnJoystickUpdate;

        /// <summary>
        /// 摇杆被按下：Update里面的回调(XY)
        /// </summary>
        public UnityAction<float, float> OnJoystickXYUpdate;

        /// <summary>
        /// 摇杆被按下：FixUpdate里面的回调
        /// </summary>
        public UnityAction<Vector2> OnJoystickFixUpdate;

        /// <summary>
        /// 摇杆被按下：LateUpdate里面的回调
        /// </summary>
        public UnityAction<Vector2> OnJoystickLateUpdate;

        /// <summary>
        /// 摇杆是否进入死区
        /// </summary>
        public bool IsInDeadArea
        {
            get => m_IsInDeadArea;
            set
            {
                if (m_IsInDeadArea == value)
                {
                    return;
                }

                if (value)
                {
                    if (OnEnterDeadArea != null)
                    {
                        OnEnterDeadArea();
                    }
                }
                else
                {
                    if (OnExitDeadArea != null)
                    {
                        OnExitDeadArea();
                    }
                }

                m_IsInDeadArea = value;
            }
        }

        private bool m_IsInDeadArea = false;

        /// <summary>
        /// 摇杆是否进入行走区域
        /// </summary>
        public bool IsInWalkArea
        {
            get => m_IsInWalkArea;
            set
            {
                if (m_IsInWalkArea == value)
                {
                    return;
                }

                if (value)
                {
                    if (OnEnterWalkArea != null)
                    {
                        OnEnterWalkArea();
                    }
                }
                else
                {
                    if (OnExitWalkArea != null)
                    {
                        OnExitWalkArea();
                    }
                }

                m_IsInWalkArea = value;
            }
        }

        private bool m_IsInWalkArea = false;

        /// <summary>
        /// 摇杆是否被按下
        /// </summary>
        private bool m_IsJoystickDown = false;

        /// <summary>
        /// 进入死区的回调
        /// </summary>
        public UnityAction OnEnterDeadArea;

        /// <summary>
        /// 退出死区的回调
        /// </summary>
        public UnityAction OnExitDeadArea;

        /// <summary>
        /// 进入行走区域的回调
        /// </summary>
        public UnityAction OnEnterWalkArea;

        /// <summary>
        /// 退出行走区域的回调
        /// </summary>
        public UnityAction OnExitWalkArea;

        /// <summary>
        /// 大圆半径
        /// </summary>
        private int m_BigR;

        /// <summary>
        /// 小圆半径
        /// </summary>
        private int m_SmallR;

        /// <summary>
        /// 摇杆拖拽的偏移
        /// </summary>
        private Vector2 m_DragVector = Vector2.zero;

        /// <summary>
        /// 摇杆对应的Local位置
        /// </summary>
        private Vector2 m_LocalPointInRectangle;

        /// <summary>
        /// 箭头的Local角度
        /// </summary>
        private Vector3 m_ArrowLocalEulerAngles;

        /// <summary>
        /// 摇杆区域的RectTransform：用于设置Follow的位置
        /// </summary>
        private RectTransform m_RectTransform;

        /// <summary>
        /// 摇杆被键盘按下的偏移
        /// </summary>
        private Vector2 m_DragKeyBoardVector;

        /// <summary>
        /// 是否按下键盘
        /// </summary>
        private bool m_IsPressKeyCode = false;

        /// <summary>
        /// 垂直方向按下的键盘值
        /// </summary>
        private int m_PreVertKeyCode = 0;

        /// <summary>
        /// 水平方向按下的键盘值
        /// </summary>
        private int m_PreHoriKeyCode = 0;

        /// <summary>
        /// 箭头是否显示
        /// </summary>
        private bool m_IsArrowActive = false;

        /// <summary>
        /// Group是否显示
        /// </summary>
        private bool m_IsGroupActive = false;

        public void Awake()
        {
            m_BigR = (int) (JoystickBackGround.sizeDelta.x * 0.5f);
            m_SmallR = (int) (JoystickForward.sizeDelta.x * 0.5f);

            if (JoystickGroup != null)
            {
                m_IsGroupActive = (eJoystick == EJoystick.Normal);
                JoystickGroup.SetActive(m_IsGroupActive);
            }

            if (JoystickArow != null)
            {
                m_IsArrowActive = false;
                JoystickArow.gameObject.SetActive(m_IsArrowActive);
                m_ArrowLocalEulerAngles = JoystickArow.localEulerAngles;
            }

            m_RectTransform = (RectTransform) transform;
        }

        public void OnEnable()
        {
            InternalReset();
        }

        public void OnDisable()
        {
            //隐藏的时候调用抬起回调
            OnPointerUp(null);
            //隐藏Group
            SetJoystickGroupActive(false);
        }

        private void OnDestroy()
        {
            X3Game.X3GameUIWidgetEntry.EventDelegate?.OnDestroy(this, this.GetInstanceID());
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            m_IsJoystickDown = true;
            OnJoystickDown?.Invoke(eventData);
            X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickDown(this, this.GetInstanceID(), eventData);

            SetJoystickGroupActive(true);
            //刚按下,这里需要重置
            IsInDeadArea = true;
            IsInWalkArea = false;

            //按下跟随
            if (eJoystick == EJoystick.FollowHide)
            {
                Vector2 AnchoredPos =
                    PapeGames.X3.RTUtility.ScreenPosToAnchoredPos(JoystickBackGround, eventData.position);
                /*var MaxX = m_RectTransform.rect.width - m_BigR;
                var MinX = m_BigR;
                var MaxY = m_RectTransform.rect.height - m_BigR;
                var MinY = m_BigR;
                AnchoredPos.x = Mathf.Clamp(AnchoredPos.x, MinX, MaxX);
                AnchoredPos.y = Mathf.Clamp(AnchoredPos.y, MinY, MaxY);*/
                JoystickBackGround.anchoredPosition = AnchoredPos;
                //如果是边缘区域,需要更新中间小球的位置
                /*if (AnchoredPos.x <= MinX || AnchoredPos.x >= MaxX || AnchoredPos.y <= MinY || AnchoredPos.y >= MaxY)
                {
                    OnDrag(eventData);
                }*/
            }
            _HandleClickAndDrag(eventData);
        }

        public void OnDrag(PointerEventData eventData)
        {
            _HandleClickAndDrag(eventData);
        }

        private void _HandleClickAndDrag(PointerEventData eventData)
        {
            if (!m_IsJoystickDown)
                return;

            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(JoystickBackGround, eventData.position,
                eventData.pressEventCamera, out m_LocalPointInRectangle))
            {
                m_LocalPointInRectangle.x = m_LocalPointInRectangle.x / m_BigR;
                m_LocalPointInRectangle.y = m_LocalPointInRectangle.y / m_BigR;

                m_DragVector = m_LocalPointInRectangle;
                m_DragVector = (m_DragVector.magnitude > 1.0f) ? m_DragVector.normalized : m_DragVector;

                var x = m_DragVector.x * (m_BigR - m_SmallR);
                var y = m_DragVector.y * (m_BigR - m_SmallR);
                JoystickForward.anchoredPosition = new Vector2(x, y);

                //箭头显示
                if (JoystickArow)
                {
                    float angle = Mathf.Atan2(y, x) * Mathf.Rad2Deg - 90;
                    JoystickArow.localEulerAngles = new Vector3(0, 0, angle);
                }

                //拖拽回调
                var dir = m_DragVector.normalized;
                OnJoystickDrag?.Invoke(dir);
                X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickDrag(this, this.GetInstanceID(),
                    dir.x, dir.y);

                var magnitude = m_DragVector.magnitude;
                //死区
                IsInDeadArea = (magnitude < DeadArea);
                SetArrowActive(!IsInDeadArea);
                //行走区域
                IsInWalkArea = (!IsInDeadArea && (magnitude < WalkArea));
            }
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            InternalReset();
            OnJoystickUp?.Invoke(eventData);
            X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickUp(this, this.GetInstanceID(), eventData);
        }

        public void InternalReset()
        {
            m_IsJoystickDown = false;
            m_DragVector = Vector2.zero;
            JoystickForward.anchoredPosition = m_DragVector;

            SetJoystickGroupActive(eJoystick == EJoystick.Normal);
            if (JoystickArow != null)
            {
                JoystickArow.localEulerAngles = m_ArrowLocalEulerAngles;
            }

            SetArrowActive(false);
        }

        public void ResetStatus()
        {
            OnJoystickDown = null;
            OnJoystickUp = null;
            OnJoystickDrag = null;
            OnJoystickUpdate = null;
            OnJoystickXYUpdate = null;
            OnJoystickFixUpdate = null;
            OnJoystickLateUpdate = null;
            OnEnterDeadArea = null;
            OnExitDeadArea = null;
            OnEnterWalkArea = null;
            OnExitWalkArea = null;
        }

        public void Update()
        {
#if UNITY_EDITOR
            m_DragKeyBoardVector = Vector2.zero;
            var prevIsPress = m_IsPressKeyCode;
            m_IsPressKeyCode = false;
            
            var isUpPress = Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow);
            var isDownPress = Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow);
            var isLeftPress = Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow);
            var isRightPress = Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow);
            
            //如果同时按下，保持之前的按键不变
            if (isUpPress && isDownPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x,
                    m_PreVertKeyCode == (int) KeyCode.UpArrow ? -1 : 1);
            }
            else if (isUpPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x, 1);
                m_PreVertKeyCode = (int) KeyCode.UpArrow;
            }
            else if (isDownPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(m_DragKeyBoardVector.x, -1);
                m_PreVertKeyCode = (int) KeyCode.DownArrow;
            }
            
            //如果同时按下，保持之前的按键不变
            if (isLeftPress && isRightPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(m_PreHoriKeyCode == (int) KeyCode.RightArrow ? -1 : 1,
                    m_DragKeyBoardVector.y);
            }
            else if (isLeftPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(-1, m_DragKeyBoardVector.y);
                m_PreHoriKeyCode = (int) KeyCode.LeftArrow;
            }
            else if (isRightPress)
            {
                m_IsPressKeyCode = true;
                m_DragKeyBoardVector = new Vector2(1, m_DragKeyBoardVector.y);
                m_PreHoriKeyCode = (int) KeyCode.RightArrow;
            }
            
            if (!prevIsPress && m_IsPressKeyCode)
            {
                OnJoystickDown?.Invoke(null);
                X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickDown(this, this.GetInstanceID(), null);
            }
            
            
            if (prevIsPress && !m_IsPressKeyCode)
            {
                OnJoystickUp?.Invoke(null);
                X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickUp(this, this.GetInstanceID(), null);
            }
            
            if (m_IsPressKeyCode)
            {
                var dir = m_DragKeyBoardVector.normalized;
                OnJoystickUpdate?.Invoke(dir);
                OnJoystickXYUpdate?.Invoke(dir.x, dir.y);
                X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickUpdate(this, this.GetInstanceID(),
                    dir.x, dir.y);
            }
#endif

            if (!m_IsJoystickDown)
                return;
            
            /*if (!gameObject.visibleInHierarchy)
            {
                OnPointerUp(null);
                return;
            }*/

            if (IsInDeadArea)
            {
                return;
            }

            var dir2 = m_DragVector.normalized;
            OnJoystickUpdate?.Invoke(dir2);
            OnJoystickXYUpdate?.Invoke(dir2.x, dir2.y);
            X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickUpdate(this, this.GetInstanceID(),
                dir2.x, dir2.y);
        }

        public void FixedUpdate()
        {
            if (!m_IsJoystickDown)
                return;

            if (IsInDeadArea)
            {
                return;
            }
            
            var dir = m_DragVector.normalized;
            OnJoystickFixUpdate?.Invoke(dir);
            X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickFixUpdate(this, this.GetInstanceID(), dir.x, dir.y);
        }

        public void LateUpdate()
        {
            if (!m_IsJoystickDown)
                return;

            if (IsInDeadArea)
            {
                return;
            }

            var dir = m_DragVector.normalized;
            OnJoystickLateUpdate?.Invoke(dir);
            X3Game.X3GameUIWidgetEntry.EventDelegate?.X3Joystick_OnJoystickLateUpdate(this, this.GetInstanceID(), dir.x, dir.y);
        }

        public void SetJoystickGroupActive(bool bActive)
        {
            if (m_IsGroupActive == bActive)
                return;
            m_IsGroupActive = bActive;
            if (JoystickGroup != null)
            {
                JoystickGroup.SetActive(m_IsGroupActive);
            }
        }

        public void SetArrowActive(bool bActive)
        {
            if (m_IsArrowActive == bActive)
                return;
            m_IsArrowActive = bActive;

            if (JoystickArow != null)
            {
                JoystickArow.gameObject.SetActive(bActive);
            }
        }
    }
}