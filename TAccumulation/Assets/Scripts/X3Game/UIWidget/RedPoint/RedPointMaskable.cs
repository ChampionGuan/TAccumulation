using UnityEngine;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public class RedPointMaskable : MonoBehaviour
    {
        // Start is called before the first frame update
        Material[] materials = null;
        UnityEngine.UI.MaskableGraphic[] masks = null;
        public void Reset()
        {
            if (materials != null)
            {
                for (int i = 0; i < masks.Length; i++)
                {
                    masks[i].material = materials[i];
                }
            }
        }

        void Awake()
        {
            Save();
        }

        private void OnDisable()
        {
            Reset();
        }

        void Save()
        {
            masks = this.GetComponentsInChildren<UnityEngine.UI.MaskableGraphic>(true);
            materials = new Material[masks.Length];
            for (int i = 0; i < masks.Length; i++)
            {
                materials[i] = masks[i].material;
            }
        }
    }

}
