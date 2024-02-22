using Cinemachine;
using PapeGames.X3;
using UnityEngine;

namespace X3Game.SceneGesture
{
    public class TransformCtrl:IDragEventHandler
    {
        public bool Controllable { get; private set; }
        public bool IsBlending => m_IsPosBlending || m_IsRotBlending;

        public float DragCoefficient
        {
            set
            {
                if (m_RotationCtrl != null)
                    m_RotationCtrl.DragCoefficient = value;
            }
        }

        public float DragDamp
        {
            set
            {
                if (m_RotationCtrl != null)
                    m_RotationCtrl.DragDamp = value;
            }
        }

        public float MaxSpeed
        {
            set
            {
                if (m_RotationCtrl != null)
                    m_RotationCtrl.MaxSpeed = value;
            }
        }

        public RotateType RotateType
        {
            set
            {
                if (m_RotationCtrl != null)
                    m_RotationCtrl.RotateType = value;
            }
        }
        public float MinRestoreSpeed { get; set; }

        public CinemachineBlendDefinition.Style BlendType { get; set; }
        public AnimationCurve CustomCurve { get; set; }
        public Vector3 RotOffset { get; set; } = Vector3.zero;
        public Vector3 PosOffset { get; set; } = Vector3.zero;

        private Transform m_Target;
        private Transform m_Pivot;

        private Vector3 m_InitPos;
        private Quaternion m_InitRot;
        private IX3CharacterWave m_Wave;

        #region Set Transisiton Parameters

        private bool m_IsPosBlending = false;
        private bool m_IsRotBlending = false;
        private Vector3 m_StartPos;
        private Vector3 m_AimPos;
        private Quaternion m_StartRot;
        private Quaternion m_AimRot;
        private float m_PosTime;
        private float m_PosDuration;
        private float m_RotTime;
        private float m_RotDuration;

        #endregion

        private GestureRotationCtrl m_RotationCtrl = new GestureRotationCtrl();

        public TransformCtrl()
        {
            m_RotationCtrl.ScreenSize = CameraUtility.GetScreenSize();
            m_RotationCtrl.OnTargetRotate = OnTargetRotate;
        }

        public void OnUpdate(float dt)
        {
            if (m_Target == null)
                return;

            ExeTransition(dt);
            m_RotationCtrl.OnUpdate(dt);
        }

        public void OnLateUpdate(float dt)
        {
        }

        public void OnDragBegin(Vector2 touchPos)
        {
            if (!Controllable)
                return;

            m_IsRotBlending = false;
            m_RotationCtrl.OnDragBegin(touchPos);
        }
        public void OnDragUpdate(Vector2 dragDelta, Vector2 touchPos)
        {
            if (!Controllable)
                return;

            m_RotationCtrl.OnDragUpdate(dragDelta, touchPos);
        }

        public void OnDragEnd(Vector2 touchPos)
        {
            if (!Controllable)
                return;

            m_RotationCtrl.OnDragEnd(touchPos);
        }

        private void ExeTransition(float dt)
        {
            if (m_IsPosBlending)
            {
                m_PosTime += dt;

                if (m_PosTime >= m_PosDuration)
                {
                    m_Target.localPosition = m_AimPos;
                    m_IsPosBlending = false;

                    m_PosDuration = 0;
                    m_PosTime = 0;
                }
                else
                {
                    m_Target.localPosition = Vector3.Lerp(m_StartPos, m_AimPos,
                        BlendHelper.GetBlendWeight(Mathf.Clamp01(m_PosTime / m_PosDuration), BlendType, CustomCurve));
                }
            }

            if (m_IsRotBlending)
            {
                m_RotTime += dt;
                if (m_RotTime >= m_RotDuration)
                {
                    m_Target.localRotation = m_AimRot;
                    m_IsRotBlending = false;

                    m_RotDuration = 0;
                    m_RotTime = 0;
                }
                else
                {
                    m_Target.localRotation = Quaternion.Lerp(m_StartRot, m_AimRot,
                        BlendHelper.GetBlendWeight(Mathf.Clamp01(m_RotTime / m_RotDuration), BlendType,
                            CustomCurve));
                }
            }

            //旋转结束恢复控制
            if (!m_IsPosBlending && !m_IsRotBlending)
            {
                Controllable = true;
            }
        }

        #region public set functions

        public void SetTarget(Transform target)
        {
            m_Target = target;
            m_RotationCtrl.Target = target;

            InitPosAndRot(0);
        }

        public void SetPivot(Transform pivot, float duration, bool forceUpdate = true)
        {
            if (m_Target == null)
            {
                m_Pivot = pivot;
                m_RotationCtrl.Pivot = pivot;
                return;
            }

            if (pivot != m_Pivot && pivot != m_RotationCtrl.Pivot || forceUpdate)
            {
                Controllable = false;

                m_Pivot = pivot;
                m_RotationCtrl.Pivot = pivot;

                InitPosAndRot(duration);
            }
        }

        public void SetInitPosAndRot(Vector3 localPos, Quaternion localRot, float duration, bool needInit = true)
        {
            m_InitPos = localPos;
            m_InitRot = localRot;

            if (needInit)
            {
                InitPosAndRot(duration);
            }
        }

        public float InitPosAndRot(float duration)
        {
            if (m_Target == null)
                return 0;

            if (m_Pivot != null)
                Controllable = false;

            var initPos = m_InitPos + PosOffset;
            var intRot = m_InitRot * Quaternion.Euler(RotOffset);

            //需要停止旋转惯性
            m_RotationCtrl.ForceStop();
            if (duration <= 0)
            {
                m_Target.localPosition = initPos;
                m_Target.localRotation = intRot;
                Controllable = true;
                m_IsPosBlending = false;
                m_IsRotBlending = false;
            }
            else
            {
                var transitAngle = Quaternion.Angle(m_Target.localRotation, intRot);
                if (MinRestoreSpeed > float.Epsilon)
                {
                    duration = Mathf.Min(duration, transitAngle / MinRestoreSpeed);
                }

                m_StartPos = m_Target.localPosition;
                m_StartRot = m_Target.localRotation;
                m_AimPos = initPos;
                m_AimRot = intRot;
                m_IsPosBlending = true;
                m_IsRotBlending = true;
                m_PosDuration = duration;
                m_RotDuration = duration;
                m_PosTime = 0;
                m_RotTime = 0;
            }

            return duration;
        }

        public void SetLocalPosition(Vector3 localPos, float duration)
        {
            if (m_Target == null)
                return;

            if (duration <= 0)
            {
                m_Target.localPosition = localPos;
                m_IsPosBlending = false;
                Controllable = true;
            }
            else
            {
                m_StartPos = m_Target.localPosition;
                m_AimPos = localPos;
                m_IsPosBlending = true;
                m_PosDuration = duration;
                m_PosTime = 0;
            }
        }

        public void SetLocalRotation(Vector3 euler, float duration)
        {
            if (m_Target == null)
                return;

            if (duration <= 0)
            {
                m_Target.localRotation = Quaternion.Euler(euler);
                m_IsRotBlending = false;
                Controllable = true;
            }
            else
            {
                m_StartRot = m_Target.localRotation;
                m_AimRot = Quaternion.Euler(euler);
                m_IsRotBlending = true;
                m_RotDuration = duration;
                m_RotTime = 0;
            }
        }

        public void SetLocalRotation(Quaternion localRot, float duration)
        {
            if (m_Target == null)
                return;

            if (duration <= 0)
            {
                m_Target.localRotation = localRot;
                m_IsRotBlending = false;
                Controllable = true;
            }
            else
            {
                m_StartRot = m_Target.localRotation;
                m_AimRot = localRot;
                m_IsRotBlending = true;
                m_RotDuration = duration;
                m_RotTime = 0;
            }
        }

        #endregion

        #region 角色水波纹

        public void SetTargetWave(IX3CharacterWave wave)
        {
            m_Wave = wave;
        }

        void OnTargetRotate(float angle)
        {
            if (m_Wave != null)
            {
                m_Wave.OnTargetRotate(angle);
            }
        }

        #endregion
    }
}