using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    [DisallowMultipleComponent]
    public class RedPoint : MonoBehaviour
    {
        /// <summary>
        /// 配置表红点id
        /// </summary>
        [HideInInspector]
        public int Id;

        /// <summary>
        /// 显示的时候事件名称
        /// </summary>
        public static string EnableEventName;

        /// <summary>
        /// 隐藏的时候事件名称
        /// </summary>
        public static string DisableEventName;

        /// <summary>
        /// 节点被销毁的时候事件
        /// </summary>
        public static string DestroyEventName;

        /// <summary>
        /// 清理多余的实例
        /// </summary>
        public static string ReleaseEventName;

        /// <summary>
        /// 红点节点名称
        /// </summary>
        public static string RedPointName;


        void Check()
        {
            for (int i = 0; i<transform.childCount; i++)
            {
                var trans = transform.GetChild(i);
                if (trans.name.Equals(RedPointName))
                {
                    UIUtility.SetActive(trans, false);
                    EventMgr.Dispatch(ReleaseEventName, trans.gameObject);
                }
            }
        }

        void Awake()
        {
            Check();
        }

        private void OnEnable()
        {
            EventMgr.Dispatch(EnableEventName, this);
        }

        private void OnDisable()
        {
            EventMgr.Dispatch(DisableEventName, this);
        }

        private void OnDestroy()
        {
            EventMgr.Dispatch(DestroyEventName, this);
        }
    }
}

