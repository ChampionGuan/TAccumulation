using System;
using Framework;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class GameObjectPool:BattleResPool
    {
        public GameObjectPool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
        }
        
        protected override void OnGet(Object obj, string name)
        {
            GameObject go = obj as GameObject;
            if (go == null)
                return;
            go.SetActive(true);
            if (!string.IsNullOrEmpty(name))
                go.name = name;
        }

        protected override void OnRecycle(Object obj)
        {
            GameObject go = obj as GameObject;
            // 编辑器下关闭游戏，可能obj为空，导致报错
            if (go == null)
                return;
            go.SetActive(false);
            go.transform.SetParent(poolTrans, false);
        }
    }
}