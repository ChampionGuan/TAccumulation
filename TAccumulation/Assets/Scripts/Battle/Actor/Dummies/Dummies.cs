using System;
using System.Collections.Generic;
using UnityEngine;
using X3.Character;
using ISubsystem = X3.Character.ISubsystem;

namespace X3Battle
{
    public class Dummies
    {
        public Dictionary<string, Dummy> AllDummies => m_Dummies;

        private X3Skeleton m_X3Skeleton;
        private Dictionary<string, Dummy> m_Dummies = new Dictionary<string, Dummy>();

        public void Init(List<Dummy> dummys, Transform root)
        {
            GetCharacterSubSystem(root);
            foreach (var dummy in dummys)
            {
                string name = dummy.name;
                if (m_Dummies.ContainsKey(name))
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("配置中挂点名字重复：{0}, 配置数据将会冲突", name);
                    continue;
                }

                m_Dummies[name] = new Dummy(name, dummy.bonePath, dummy.localPos, dummy.localAngle, dummy.syncType);
                m_Dummies[name].Init(root);
            }
        }

        public bool TryAddDummy(string name, Transform dummyTrans, Transform boneTrans)
        {
            if (!m_Dummies.ContainsKey(name))
            {
                m_Dummies[name] = new Dummy(name, dummyTrans, boneTrans);
                return true;
            }

            return false;
        }

        public Transform GetDummyTrans(string name)
        {
            // todo 重新找策划对，整理这个设定
            // Skeleton 系统内预设了一部分挂点
            var tgt = m_X3Skeleton?.GetDummyByName(name);
            if (null != tgt)
            {
                return tgt;
            }

            return m_Dummies.TryGetValue(name, out var dummy) ? dummy.GetDummy() : null;
        }

        public Dummy GetDummy(string name)
        {
            return m_Dummies.TryGetValue(name, out var dummy) ? dummy : null;
        }

        private void GetCharacterSubSystem(Transform root)
        {
            var x3Character = root.GetComponentInChildren<X3Character>();
            if (null == x3Character)
            {
                m_X3Skeleton = null;
                return;
            }

            var subSysType = ISubsystem.Type.MAX_NUM;
            foreach (var property in typeof(X3Skeleton).GetCustomAttributes(typeof(SubsystemAttr), false))
            {
                subSysType = (property as SubsystemAttr).type;
                break;
            }

            m_X3Skeleton = x3Character.GetSubsystem(subSysType) as X3Skeleton;
        }

        public void Update()
        {
            foreach (var dummy in m_Dummies.Values)
            {
                dummy.Tick();
            }
        }
    }

    public partial class Dummy
    {
        public enum SyncType
        {
            Normal = 0,
            Pos,
        }

        [NonSerialized]
        private Transform _dummy;
        [NonSerialized]
        private Transform _bindBone;
        [NonSerialized]
        private Transform _boneRoot;

        public Dummy(string name, string bonePath, Vector3 localPos, Vector3 localAngle, SyncType syncType)
        {
            this.name = name;
            this.bonePath = bonePath;
            this.localPos = localPos;
            this.localAngle = localAngle;
            this.syncType = syncType;
        }

        public Dummy(string name, Transform dummyTrans, Transform boneTrans)
        {
            this.name = name;
            _dummy = dummyTrans;
            _bindBone = boneTrans;
            TryResetDummyPos();
        }

        public Transform GetDummy()
        {
            TryBindBone();
            return _dummy;
        }

        public Transform GetBone()
        {
            TryBindBone();
            return _bindBone;
        }

        public void Init(Transform boneRoot)
        {
            if (boneRoot == null)
                return;

            _boneRoot = boneRoot;
#if UNITY_EDITOR
            _bindBone = null;
#endif
            _dummy = boneRoot.Find(name) ?? new GameObject(name).transform;
            TryBindBone();
        }

        // 部分骨骼和武器绑定，随着武器的更换而出现
        private void TryBindBone()
        {
            if (_bindBone != null || _boneRoot == null) return;

            if (_dummy == null)
            {
                Init(_boneRoot);
                return;
            }

            _bindBone = _boneRoot.Find(bonePath);
            if (syncType == SyncType.Pos)
            {
                _dummy.SetParent(_boneRoot);
            }
            else
            {
                _dummy.SetParent(_bindBone != null ? _bindBone : _boneRoot);
            }

            TryResetDummyPos();
        }

        private void TryResetDummyPos()
        {
            // 骨骼作为一个挂点时， 位置由动画控制
            if (_dummy == _bindBone) return;

            if (syncType == SyncType.Pos)
            {
                if (null != _bindBone) _dummy.position = _bindBone.position + localPos;
            }
            else if (syncType == SyncType.Normal)
            {
                _dummy.localPosition = localPos;
                _dummy.localEulerAngles = localAngle;
            }
        }

        public void Tick()
        {
            if (syncType == SyncType.Pos)
            {
                if (null == _bindBone || null == _dummy) return;
                _dummy.position = _bindBone.position + _boneRoot.rotation * localPos;
            }
        }
    }
}