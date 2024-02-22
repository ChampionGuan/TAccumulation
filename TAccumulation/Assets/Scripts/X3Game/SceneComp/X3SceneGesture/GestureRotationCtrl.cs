using System;
using PapeGames.X3;
using UnityEngine;

namespace X3Game.SceneGesture
{
    public enum RotateType
    {
        LockX,
        Free,
    }

    public class GestureRotationCtrl : IDragEventHandler
    {
        enum DragState
        {
            None,
            Dragging,
            Inertial,
        }

        private Transform m_Pivot;

        private DragState m_DragState = DragState.None;
        private Vector2 m_DragDelta = Vector2.zero;
        private Vector2 m_TouchPos = Vector2.zero;

        #region Free Rotate

        private Vector2 m_DragStartPos = Vector2.zero;
        private Quaternion m_StartRot = Quaternion.identity;
        private Vector3 m_RotAxisRight = Vector3.right;
        private Vector3 m_RotAxisUp = Vector3.up;
        private Vector3 m_RotAxisTowardsScreen = Vector3.up;
        private Vector3 m_RotAxisFinal = Vector3.up;

        #endregion

        public Transform Target;

        public Transform Pivot
        {
            get => m_Pivot != null ? m_Pivot : Target;
            set => m_Pivot = value;
        }

        public Vector2 ScreenSize { get; set; }
        public RotateType RotateType { get; set; }
        public float DragCoefficient { get; set; }
        public float DragDamp { get; set; }
        public float MaxSpeed { get; set; }

        public Action<float> OnTargetRotate;

        private Transform m_CameraTf = null;

        private Transform cameraTf
        {
            get
            {
                if (m_CameraTf == null && CameraUtility.MainCamera != null)
                    m_CameraTf = CameraUtility.MainCamera.transform;

                return m_CameraTf;
            }
        }

        public void OnDragBegin(Vector2 touchPos)
        {
            m_DragStartPos = touchPos;
            m_TouchPos = touchPos;
            m_StartRot = Target.rotation;
            m_DragState = DragState.Dragging;

            switch (RotateType)
            {
                case RotateType.LockX:
                    BeginDragFixX();
                    break;
                case RotateType.Free:
                    BeginDragFree();
                    break;
            }
        }

        public void OnDragUpdate(Vector2 dragDelta, Vector2 touchPos)
        {
            m_DragDelta = dragDelta;
            m_TouchPos = touchPos;
        }

        public void OnDragEnd(Vector2 touchPos)
        {
            m_DragState = DragState.Inertial;
            m_TouchPos = touchPos;
        }

        public void ForceStop()
        {
            m_DragState = DragState.None;
        }

        public void OnUpdate(float dt)
        {
            m_DragDelta = GetValidDragDelta(dt);
            switch (m_DragState)
            {
                case DragState.Dragging:
                    ExeDrag(dt);
                    break;
                case DragState.Inertial:
                    if (GetDragDistance() > 0.01f)
                    {
                        m_DragDelta *= Mathf.Clamp01(1.0f - DragDamp);
                        m_TouchPos += m_DragDelta;
                        ExeDrag(dt);
                    }
                    else
                    {
                        m_DragState = DragState.None;
                    }

                    break;
            }
        }

        private Vector2 GetValidDragDelta(float dt)
        {
            switch (RotateType)
            {
                case RotateType.LockX:
                    var maxX = MaxSpeed > Mathf.Epsilon
                        ? MaxSpeed * dt * ScreenSize.x / (360 * DragCoefficient)
                        : float.MaxValue;
                    return new Vector2(
                        Mathf.Sign(m_DragDelta.x) * Mathf.Min(Mathf.Abs(m_DragDelta.x), maxX),
                        m_DragDelta.y);
                case RotateType.Free:
                    return m_DragDelta;
            }

            return m_DragDelta;
        }

        private float GetDragDistance()
        {
            switch (RotateType)
            {
                case RotateType.LockX:
                    return Mathf.Abs(m_DragDelta.x);
                case RotateType.Free:
                    return Vector2.SqrMagnitude(m_DragDelta);
            }

            return 0;
        }

        private void BeginDragFixX()
        {
        }

        private void BeginDragFree()
        {
            Vector3 camToTargetVec = Target.position - cameraTf.position;
            m_RotAxisRight = Vector3.Cross(cameraTf.up, camToTargetVec).normalized;
            m_RotAxisUp = Vector3.Cross(camToTargetVec, m_RotAxisRight).normalized;
            m_RotAxisTowardsScreen = -camToTargetVec.normalized;
        }

        private void ExeDrag(float dt)
        {
            switch (RotateType)
            {
                case RotateType.LockX:
                    ExeDragFixX(dt);
                    break;
                case RotateType.Free:
                    ExeDragFree(dt);
                    break;
            }
        }

        private void ExeDragFixX(float dt)
        {
            float angle = -m_DragDelta.x / ScreenSize.x * 360.0f * DragCoefficient;
            Target.RotateAround(Pivot.position, Target.up, angle);
            OnTargetRotate?.Invoke(angle);
        }

        private void ExeDragFree(float dt)
        {
            Vector2 offset = m_TouchPos - m_DragStartPos;
            Debug.LogFormat("m_TouchPos: {0}, {1}", m_TouchPos.x, m_TouchPos.y);
            Debug.LogFormat("m_DragStartPos: {0}, {1}", m_DragStartPos.x, m_DragStartPos.y);
            Debug.LogFormat("Offset: {0}, {1}", offset.x, offset.y);
            Vector2 dir = offset.normalized;

            float upDotDir = Vector2.Dot(Vector2.up, dir);
            float rightDotDir = Vector2.Dot(Vector2.right, dir);
            float upToCurAngleSign = Mathf.Sign(rightDotDir);
            float upToCurAngle = Vector2.Angle(Vector2.up, dir) * upToCurAngleSign;
            float rightToCurAngle = Vector2.Angle(Vector2.right, dir);
            m_RotAxisFinal = Quaternion.AngleAxis(upToCurAngle + 90, m_RotAxisTowardsScreen) * m_RotAxisUp;

            float denominator = Mathf.Min(ScreenSize.x, ScreenSize.y);
            float dragDelta = offset.magnitude / denominator;
            dragDelta *= 360.0f * DragCoefficient;

            var rot = m_StartRot;
            rot = Quaternion.AngleAxis(dragDelta, m_RotAxisFinal) * rot;

            Target.rotation = rot;
        }
    }
}