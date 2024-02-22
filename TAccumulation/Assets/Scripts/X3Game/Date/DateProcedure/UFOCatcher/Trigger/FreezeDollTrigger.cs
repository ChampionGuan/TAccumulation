using Boo.Lang;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    /// <summary>
    /// 男主个性化，冰冻娃娃抓取检测，冰冻碰到的娃娃
    /// </summary>
    public class FreezeDollTrigger : MonoBehaviour
    {
        public Collider collider;
        
        private void OnTriggerEnter(Collider other)
        {
            var dollcheck = other.gameObject.GetComponent<DollCheckCollider>();
            if (dollcheck)
            {
                EventMgr.Dispatch("FreezeDollTrigger", new List<Object>() {collider, other, gameObject });
            }

            /*if (controller.isFreezeState)
            {
                var dollcheck = other.gameObject.GetComponent<DollCheckCollider>();
                if (dollcheck)
                {
                    if (dollcheck.root)
                    {
                        var dollAction = dollcheck.root.GetComponent<DollAction>();
                        if (!controller.freezeDollList.Find((a) => a == dollAction))
                        {
                            dollAction.SetFreezeParent(transform);
                            controller.freezeDollList.Add(dollAction);
                        }
                    }
                }
            }*/
        }
    }
}