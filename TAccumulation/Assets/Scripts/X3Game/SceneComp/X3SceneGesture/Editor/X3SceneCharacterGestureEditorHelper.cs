using Cinemachine;
using PapeGames.X3;
using UnityEngine;

namespace X3Game.SceneGesture
{
    public static class X3SceneCharacterGestureEditorHelper
    {
        private static GameObject CreateVirtualCamera(Transform parent = null, string name = "StaticCamera")
        {
            GameObject go = new GameObject(name);
            var camera = go.AddComponent<CinemachineVirtualCamera>();
            camera.Priority = 60;
            
            go.SetActive(false);
            if (parent != null)
            {
                var tf = go.transform;
                tf.parent = parent;
                tf.localPosition = Vector3.zero;
                tf.localScale = Vector3.one;
                tf.localRotation = Quaternion.identity;
            }

            return go;
        }
        public static AnimCtrlCamState CreateAnimCtrlCamera(Transform parent = null, string name = "AnimCtrlCamera")
        {
            var go = CreateVirtualCamera(parent, name);
            return CreateAnimCtrlCamState(go, name);
        }

        public static StaticCamState CreateStaticCamera(Transform parent = null, string name = "StaticCamera")
        {
            var go = CreateVirtualCamera(parent, name);
            return CreateStaticCamState(go, name);
        }
        
        public static AnimCtrlCamState CreateAnimCtrlCamState(GameObject go, string name)
        {
            ClearState(go);
            var state = go.AddComponent<AnimCtrlCamState>();
            state.Key = name;
            return state;
        }

        public static StaticCamState CreateStaticCamState(GameObject go, string name)
        {
            ClearState(go);
            var state = go.AddComponent<StaticCamState>();
            state.Key = name;
            return state;
        }

        public static void ClearState(GameObject go)
        {
            go.RemoveComponent<StateBase>();
        }
    }
}