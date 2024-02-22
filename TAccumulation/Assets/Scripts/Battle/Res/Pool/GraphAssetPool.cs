using UnityEngine;

namespace X3Battle
{
    public class GraphAssetPool : GameObjectPool
    {
        public GraphAssetPool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
        }

        protected override void OnGet(Object obj, string name)
        {
            GameObject go = obj as GameObject;
            if (go == null)
                return;
            if (!string.IsNullOrEmpty(name))
                go.name = name;
        }

        protected override void OnRecycle(Object obj)
        {
            GameObject go = obj as GameObject;
            // 编辑器下关闭游戏，可能obj为空，导致报错
            if (go == null)
                return;
            go.transform.SetParent(poolTrans, false);
        }
    }
}