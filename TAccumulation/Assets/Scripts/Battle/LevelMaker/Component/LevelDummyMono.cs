using UnityEngine;

namespace LevelMaker
{
    [ExecuteInEditMode]
    public class LevelDummyMono : MonoBehaviour
    {
        static LevelDummyMono s_Ins;

        public static LevelDummyMono Ins { get { return s_Ins; } }

        public static LevelDummyMono Create()
        {
            if (s_Ins != null)
            {
                return s_Ins;
            }
            
            var go = new GameObject("LevelDummyMono", typeof(LevelDummyMono));
            go.hideFlags = HideFlags.DontSave;
            var comp = go.GetComponent<LevelDummyMono>();
            s_Ins = comp;
            if (Application.isPlaying)
                DontDestroyOnLoad(go);
            return comp;
        }

        public static void Destroy()
        {
            if (s_Ins != null)
                GameObject.DestroyImmediate(s_Ins.gameObject);
            s_Ins = null;
        }

        private void Awake()
        {
            s_Ins = this;
        }

        private void OnEnable()
        {
            s_Ins = this;
        }

        private void OnDestroy()
        {
            s_Ins = null;
        }

    }
}
