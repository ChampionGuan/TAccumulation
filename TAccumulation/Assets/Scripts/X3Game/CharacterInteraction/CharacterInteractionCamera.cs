using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using PiRhoSoft.Utilities;
using UnityEngine;

namespace X3Game
{
    public class CharacterInteractionCamera : MonoBehaviour
    {
        public enum FollowType
        {
            Lever,
            Follow,
        };

        public Transform[] targets;
        [LabelText("跟随类型")]
        public FollowType type = FollowType.Lever;
        [LabelText("中心点比例")]
        public float center = 0.5f;
        [LabelText("位置跟随强度")]
        public float omega = 1;
        [LabelText("旋转跟随强度")]
        public float omegaR = 1;

        // Start is called before the first frame update
        DTweenVector3 _position;
        DTweenQuaternion _rotation;

        private Vector3 centerPos;
        private Quaternion initRot;
        private Vector3 initPos;
        private Vector3 initTarPos;
        private Vector3 initCenterToCamVector;
        private Vector3 initTarToCamera;

        private bool isInit = false;
        private Vector3 up;

        void Start()
        {
            Init();
        }

        private void OnDisable()
        {
            isInit = false;
        }

        public void Init()
        {
            if (isInit)
            {
                return;
            }

            if (targets == null || targets.Length == 0)
                return;
            initRot = transform.rotation;
            initPos = transform.position;
            _position = new DTweenVector3(initPos, omega);
            _rotation = new DTweenQuaternion(initRot, omegaR);

            initTarPos = GetTargetPos();
            centerPos = initTarPos + (initPos - initTarPos) * center;

            up = transform.up;
            initCenterToCamVector = ProjectOntoPlane(initPos - centerPos);
            initTarToCamera = ProjectOntoPlane(initPos - initTarPos);
            isInit = true;
        }

        // Update is called once per frame
        void Update()
        {
            Init();
            if (isInit)
            {
                var targetPos = GetTargetPos();
                Vector3 aimPos;
                Quaternion aimRot;
                switch (type)
                {
                    case FollowType.Lever:
                        aimPos = (centerPos - targetPos) / center + targetPos;

                        _position.omega = omega;
                        _position.Step(aimPos);
                        transform.position = _position;
                        
                        var curCenter = targetPos + (_position - targetPos) * center;
                        aimRot = Quaternion.FromToRotation(initCenterToCamVector, ProjectOntoPlane(_position - curCenter)) *
                                 initRot;
                        _rotation.omega = omegaR;
                        _rotation.Step(aimRot);
                        transform.rotation = _rotation;
                        break;
                    case FollowType.Follow:
                        aimPos = targetPos - initTarPos + initPos;
                        _position.omega = omega;
                        _position.Step(aimPos);
                        transform.position = _position;

                        aimRot =
                            Quaternion.FromToRotation(initTarToCamera, ProjectOntoPlane(_position - targetPos)) *
                            initRot;
                        _rotation.omega = omegaR;
                        _rotation.Step(aimRot);
                        transform.rotation = _rotation;
                        break;
                }
            }
        }

        Vector3 ProjectOntoPlane(Vector3 input)
        {
            return (input - Vector3.Dot(input, up) * up);
        }

        Vector3 GetTargetPos()
        {
            var pos = Vector3.zero;
            if (targets == null || targets.Length == 0)
                return pos;

            for (int i = 0; i < targets.Length; i++)
            {
                pos += targets[i].position;
            }

            return pos / targets.Length;
        }

        struct DTweenVector3
        {
            public Vector3 position;
            public Vector3 velocity;
            public float omega;

            public DTweenVector3(Vector3 position, float omega)
            {
                this.position = position;
                this.velocity = Vector3.zero;
                this.omega = omega;
            }

            public void Step(Vector3 target)
            {
                var dt = Time.deltaTime;
                var n1 = velocity - (position - target) * (omega * omega * dt);
                var n2 = 1 + omega * dt;
                velocity = n1 / (n2 * n2);
                position += velocity * dt;
            }

            public static implicit operator Vector3(DTweenVector3 m)
            {
                return m.position;
            }
        }

        struct DTweenQuaternion
        {
            [StructLayout(LayoutKind.Explicit)]
            struct QVUnion
            {
                [FieldOffset(0)] public Vector4 v;
                [FieldOffset(0)] public Quaternion q;
            }

            static Vector4 q2v(Quaternion q)
            {
                return new Vector4(q.x, q.y, q.z, q.w);
            }

            QVUnion _rotation;

            public Quaternion rotation
            {
                get { return _rotation.q; }
                set { _rotation.q = value; }
            }

            public Vector4 velocity;
            public float omega;

            public DTweenQuaternion(Quaternion rotation, float omega)
            {
                _rotation.v = Vector4.zero; // needed for suppressing warnings
                _rotation.q = rotation;
                velocity = Vector4.zero;
                this.omega = omega;
            }

            public void Step(Quaternion target)
            {
                var vtarget = q2v(target);
                // We can use either of vtarget/-vtarget. Use closer one.
                if (Vector4.Dot(_rotation.v, vtarget) < 0) vtarget = -vtarget;
                var dt = Time.deltaTime;
                var n1 = velocity - (_rotation.v - vtarget) * (omega * omega * dt);
                var n2 = 1 + omega * dt;
                velocity = n1 / (n2 * n2);
                _rotation.v = (_rotation.v + velocity * dt).normalized;
            }

            public static implicit operator Quaternion(DTweenQuaternion m)
            {
                return m.rotation;
            }
        }
    }
}