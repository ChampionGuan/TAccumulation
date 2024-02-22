using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Game
{
    [ExecuteAlways]
    [XLua.LuaCallCSharp]
    public class GuidanceNode : MonoBehaviour
    {
        static Dictionary<string, GuidanceNode> s_Dict = new Dictionary<string, GuidanceNode>();

        public static GuidanceNode Get(string id) 
        {
            if (string.IsNullOrEmpty(id))
                return null;
            if (!s_Dict.TryGetValue(id, out GuidanceNode node))
                return null;
            return node;
        }

        public static GameObject GetGameObject(string id)
        {
            var node = Get(id);
            if (node == null)
                return null;
            return node.gameObject;
        }

        [SerializeField]
        string m_Id;

        public string Id { get { return m_Id; } }

        private void Awake()
        {
            if(!string.IsNullOrEmpty(m_Id))
            {
                s_Dict[m_Id] = this;
            }
        }

        private void OnDestroy()
        {
            if (!string.IsNullOrEmpty(m_Id))
            {
                s_Dict.Remove(m_Id);
            }
        }
    }
}

