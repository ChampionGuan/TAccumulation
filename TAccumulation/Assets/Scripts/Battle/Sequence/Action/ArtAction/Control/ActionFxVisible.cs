using UnityEngine.Playables;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class ActionFxVisible : BSAction
    {
        public GameObject gameObject = null;

        protected override void _OnInit()
        {
            var clip = GetClipAsset<ControlPlayableAsset>();
            var go = GetExposedValue(clip.sourceGameObject);
            if (go == null)
                return;
            
            gameObject = go;
            if (!gameObject.activeSelf)
            {
                gameObject.SetActive(false);
            }
            gameObject.SetVisible(false);
        }

        protected override void _OnEnter()
        {
            if (gameObject == null)
                return;

            if (!gameObject.activeSelf)
            {
                gameObject.SetActive(true);
            }
            gameObject.SetVisible(true);
        }

        protected override void _OnExit()
        {
            if (gameObject != null)
            {
                gameObject.SetVisible(false);
            }
        }
        
        protected override void _OnDestroy()
        {
            if (gameObject == null)
                return;
            
            gameObject.SetVisible(false);
        }
    }
}
