using UnityEngine;

namespace PapeGames
{
    [DisallowMultipleComponent]
    public class VisiblePoolItem :MonoBehaviour
    {
        [SerializeField]
        [LabelText("子节点需要特殊处理的脚本", null, "false")]
        public Behaviour[] behaviours = null;
        
        public void Record()
        {
            behaviours = VisiblePoolTool.GenerateDatas(gameObject);
        }

        public bool HasData()
        {
            return behaviours != null && behaviours.Length > 0;
        }

        public void DisableBehaviours()
        {
            if (behaviours == null)
            {
                return;   
            }
            for (int i = 0; i < behaviours.Length; i++)
            {
                if (behaviours[i] == null)
                {
                    continue;
                }
                behaviours[i].enabled = false;
            }
        }

        public void EnableBehaviours()
        {
            if (behaviours == null)
            {
                return;   
            }
            for (int i = 0; i < behaviours.Length; i++)
            {
                if (behaviours[i] == null)
                {
                    continue;
                }

                behaviours[i].enabled = true;
            }
        }
    }
}