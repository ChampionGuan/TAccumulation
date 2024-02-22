using UnityEngine;
using UnityEngine.Playables;
using PapeGames.X3;
using UObject = UnityEngine.Object;

namespace X3Game
{
    public static class X3AnimatorUtility
    {
        public static void Play(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Play(stateName);
            }
        }

        public static void Play(UObject obj, string stateName, DirectorWrapMode wrapMode)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Play(stateName, wrapMode);
            }
        }

        public static void Play(UObject obj, string stateName, float initialTime)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Play(stateName, initialTime);
            }
        }

        public static void Play(UObject obj, string stateName, DirectorWrapMode wrapMode, float initialTime)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Play(stateName, wrapMode, initialTime);
            }
        }

        public static void Crossfade(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName);
            }
        }

        public static void Crossfade(UObject obj, string stateName, float transitionDuration)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName, transitionDuration);
            }
        }

        public static void Crossfade(UObject obj, string stateName, DirectorWrapMode wrapMode)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName, wrapMode);
            }
        }

        public static void Crossfade(UObject obj, string stateName, float initialTime, float transitionDuration)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName, initialTime, transitionDuration);
            }
        }

        public static void Crossfade(UObject obj, string stateName, float transitionDuration, DirectorWrapMode wrapMode)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName, transitionDuration, wrapMode);
            }
        }

        public static void Crossfade(UObject obj, string stateName, float initialTime, float transitionDuration,
            DirectorWrapMode wrapMode)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Crossfade(stateName, initialTime, transitionDuration, wrapMode);
            }
        }

        public static void FastForward(UObject obj, string stateName, float normalizedTime)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.FastForward(stateName, normalizedTime);
            }
        }

        public static void Pause(UObject obj)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Pause();
            }
        }

        public static void Resume(UObject obj)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Resume();
            }
        }

        public static void Stop(UObject obj)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Stop();
            }
        }

        public static bool IsPlaying(UObject obj)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.IsPlaying;
            }

            return false;
        }

        public static bool IsPaused(UObject obj)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.IsPaused;
            }

            return false;
        }

        public static bool HasState(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.HasState(stateName);
            }

            return false;
        }

        public static float GetStateLength(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.GetStateLength(stateName);
            }

            return 0;
        }

        public static float GetStateTime(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.GetStateTime(stateName);
            }

            return 0;
        }

        public static float GetStateRemainingTime(UObject obj, string stateName)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                return comp.GetStateRemainingTime(stateName);
            }

            return 0;
        }

        public static bool SetAssetId(UObject obj, int assetId)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.AssetId = assetId;
                return true;
            }

            return false;
        }

        public static bool SetTag(UObject obj, int tag)
        {
            var comp = GetComp(obj);
            if (comp)
            {
                comp.Tag = tag;
                return true;
            }

            return false;
        }

        public static bool SetDataProviderEnabled(UObject obj, bool enabled, bool withErrorLog = false)
        {
            var comp = GetComp(obj, withErrorLog);
            if (comp)
            {
                comp.DataProviderEnabled = enabled;
                return true;
            }

            return false;
        }

        public static bool ClearExternalStateCache(UObject obj, bool withErrorLog = false)
        {
            var comp = GetComp(obj, withErrorLog);
            if (comp)
            {
                comp.ClearExternalStateCache();
                return true;
            }

            return false;
        }

        public static X3Animator Get(UObject obj)
        {
            return GetComp(obj);
        }

        public static X3Animator GetOrAdd(UObject obj)
        {
            var go = ComponentUtility.GetGameObject(obj);
            if (go == null)
                return null;
            var comp = go.GetOrAddComponent<X3Animator>();
            return comp;
        }

        public static void SetLocalPosition(UObject obj, float x, float y, float z)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.localPosition = new Vector3(x, y, z);
            }
        }

        public static Vector3 GetLocalPosition(UObject obj)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                return tf.localPosition;
            }

            return Vector3.zero;
        }

        public static void SetLocalRotation(UObject obj, float x, float y, float z)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.localRotation = Quaternion.Euler(x, y, z);
            }
        }

        public static void RotateAround(UObject obj, Vector3 point, Vector3 axis, float angle)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.RotateAround(point, axis, angle);
            }
        }

        public static Quaternion GetLocalRotation(UObject obj)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                return tf.localRotation;
            }

            return Quaternion.identity;
        }

        public static Vector3 GetLocalEulerAngles(UObject obj)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                return tf.localEulerAngles;
            }

            return Vector3.zero;
        }

        public static void SetLocalScale(UObject obj, float x, float y, float z)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.localScale = new Vector3(x, y, z);
            }
        }

        public static void GetPositionXYZ(UObject obj, out float x, out float y, out float z)
        {
            var position = GetPosition(obj);
            x = position.x;
            y = position.y;
            z = position.z;
        }

        public static Vector3 GetPosition(UObject obj)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                return tf.position;
            }

            return Vector3.zero;
        }

        public static void SetPosition(UObject obj, float x, float y, float z)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.position = new Vector3(x, y, z);
            }
        }

        public static void SetRotation(UObject obj, float x, float y, float z)
        {
            var tf = GetActualTF(obj);
            if (tf != null)
            {
                tf.rotation = Quaternion.Euler(x, y, z);
            }
        }

        private static Transform GetActualTF(UObject obj, bool withErrorLog = false)
        {
            Transform tf = null;
            if (ComponentUtility.GetComponent<X3Animator>(obj, out X3Animator comp))
            {
                var handle = PapeGames.CutScene.CutSceneManager.Instance.GetHandleWithTag(comp.Tag);
                if (handle.IsValid() && handle.Ctrl != null)
                {
                    tf = handle.Ctrl.transform;
                }
                else
                {
                    tf = comp.transform;
                }
            }
            else
            {
                if (withErrorLog)
                    X3Debug.LogErrorFormat("Find no x3animator from {0}", obj == null ? "null" : obj.name);
            }

            return tf;
        }

        private static X3Animator GetComp(UObject obj, bool withErrorLog = false)
        {
            X3Animator comp = null;
            if (!ComponentUtility.GetComponent<X3Animator>(obj, out comp))
            {
                if (withErrorLog)
                    X3Debug.LogErrorFormat("Find no x3animator from {0}", obj == null ? "null" : obj.name);
            }

            return comp;
        }
    }
}