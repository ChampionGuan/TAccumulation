using System.Collections;
using Cinemachine;
using PapeGames.X3;
using Unity.Mathematics;
using UnityEngine;
using GestrueType = X3Game.InputComponent.GestrueType;
using X3Game.SceneGesture;

namespace X3Game
{
    [RequireComponent(typeof(InputComponent))]
    public class ObjViewer : MonoBehaviour, InputDragDelegate
    {
        [SerializeField] private Camera m_Camera;
        [SerializeField] protected Transform m_Target;
        [SerializeField] protected Vector3 m_Offset;
        [SerializeField] protected float m_DragSpeed = 0.6f;
        [SerializeField] protected float m_DragDamp = 0.1f;
        private Transform m_ControlTarget = null;
        private Coroutine m_DragInertial;
        private bool m_IsDragging = false;
        private Vector2 m_LastDragDelta = Vector2.zero;
        private GestureRotationCtrl m_RotationCtrl = new GestureRotationCtrl();

        public void SetTarget(Transform target, Vector3 offset = default(Vector3))
        {
            m_Target = target;
            m_Offset = offset;
            InitTarget();
        }

        public void SetCamera(Camera cam)
        {
            m_Camera = cam;
        }

        public float DragSpeed
        {
            get => m_DragSpeed;
            set
            {
                m_DragSpeed = value;
                if (m_RotationCtrl != null)
                {
                    m_RotationCtrl.DragCoefficient = value;
                }
            }
        }

        public float DragDamp
        {
            get => m_DragDamp;
            set
            {
                m_DragDamp = value;
                if (m_RotationCtrl != null)
                    m_RotationCtrl.DragDamp = value;
            }
        }

        public void ResetRotation()
        {
            m_RotationCtrl.ForceStop();
            if (m_ControlTarget)
                m_ControlTarget.localRotation = Quaternion.identity;
        }

        #region Mono Events

        private void Awake()
        {
            var go = new GameObject("ControlTarget");
            go.transform.SetParent(transform, false);
            m_ControlTarget = go.transform;
            m_ControlTarget.localRotation = Quaternion.identity;
            m_ControlTarget.localScale = Vector3.one;
            m_ControlTarget.localPosition = Vector3.zero;
            
            m_RotationCtrl.ScreenSize = CameraUtility.GetScreenSize();
            m_RotationCtrl.Target = m_ControlTarget;
            m_RotationCtrl.RotateType = RotateType.Free;
            m_RotationCtrl.DragCoefficient = DragSpeed;
            m_RotationCtrl.DragDamp = DragDamp;
            
            var workHorse = GetComponent<InputComponent>();
            workHorse.SetDelegate(this);
            workHorse.SetCtrlType(InputComponent.CtrlType.DRAG);
            workHorse.SetTouchBlockEnableByUI(InputComponent.TouchEventType.ON_TOUCH_DOWN, true);
        }

        private void Start()
        {
            if (m_Camera == null)
                m_Camera = CameraUtility.MainCamera;
            InitTarget();
        }

        private void Update()
        {
            m_RotationCtrl.OnUpdate(Time.deltaTime);
        }
        
        private void InitTarget()
        {
            if (m_Target != null)
            {
                m_Target.SetParent(m_ControlTarget, false);
                m_Target.localRotation = Quaternion.identity;
                var mf = m_Target.GetComponentInChildren<MeshFilter>();
                Vector3 localPos = Vector3.zero;
                if (mf != null && mf.sharedMesh != null)
                {
                    //yes, we need local bounds
                    localPos = -mf.sharedMesh.bounds.center;
                }
                localPos += m_Offset;
                m_Target.localPosition = localPos;
                m_ControlTarget.localPosition = -localPos;
                //todo:这个逻辑最好是在外面处理
                var rigibody = m_Target.GetComponentInChildren<Rigidbody>();
                if (rigibody)
                {
                    GameObject.Destroy(rigibody);
                }
            }
        }

        void OnDestroy()
        {
        }

        #endregion

        #region Drag Bussiness
        #endregion

        #region Touch Handler

        public void OnTouchDown(Vector2 pos)
        {
        }

        public void OnTouchUp(Vector2 pos)
        {
        }

        public void OnBeginDrag(Vector2 pos)
        {
            m_RotationCtrl.OnDragBegin(pos);
        }

        public void OnDrag(Vector2 pos, Vector2 deltaPos, GestrueType gesture)
        {
            m_RotationCtrl.OnDragUpdate(deltaPos, pos);
            Debug.LogFormat("OnDrag: {0}, {1}", deltaPos.x, deltaPos.y);
        }

        public void OnEndDrag(Vector2 pos)
        {
            m_RotationCtrl.OnDragEnd(pos);
        }

        #region Unnecessary

        public void OnGesture(GestrueType gesture)
        {
        }

        public void OnDestroy(GameObject obj)
        {
        }

        #endregion

        #endregion
    }
}