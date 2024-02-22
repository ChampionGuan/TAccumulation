using System.Collections.Generic;
using PapeGames;
using UnityEngine;

namespace X3Battle
{
    public class GameObjectVisiblePool:GameObjectPool
    {
        private Dictionary<GameObject, VisiblePoolItem> _datas;
        public GameObjectVisiblePool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
            _datas = new Dictionary<GameObject, VisiblePoolItem>();
        }
        
        protected override void OnGet(Object obj, string name)
        {
            GameObject go = obj as GameObject;
            if (go == null)
                return;

            _datas.TryGetValue(go, out var com);
            if (com == null)
            {
                com = VisiblePoolTool.RecordPoolItem(go);
                _datas[go] = com;
            }
            VisiblePoolTool.EnablePoolItemBehavioursByItem(com, true);
            if (!string.IsNullOrEmpty(name))
                obj.name = name;
        }

        protected override void OnRecycle(Object obj)
        {
            GameObject go = obj as GameObject;
            if (go == null)
                return;
            _datas.TryGetValue(go, out var com);
            if (com != null)
            {
                VisiblePoolTool.EnablePoolItemBehavioursByItem(com, false);   
            }

            go.transform.SetParent(poolTrans, false);
        }
    }
}