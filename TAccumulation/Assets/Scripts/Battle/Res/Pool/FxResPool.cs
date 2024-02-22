using System.Collections.Generic;
using PapeGames;
using UnityEngine;

namespace X3Battle
{
    // 理论上特效类似的资源应该只使用一种Pool，即可。 统一 FxResVisiblePool
    // 保留此ActivePool,使用Visible原因是因为别的模块active引起的异常消耗（gpu,renderactor...
    public class FxResPool:GameObjectPool, IGetFxPlayer
    {
        protected Dictionary<Object, FxPlayer> _fxPlayersCache;
        
        public FxResPool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
            _fxPlayersCache = new Dictionary<Object, FxPlayer>();
        }

        public override void UnInit()
        {
            base.UnInit();
            _fxPlayersCache = new Dictionary<Object, FxPlayer>();
        }
        
        protected override void OnGet(Object obj, string name)
        {
            base.OnGet(obj, name);
            
            GameObject go = obj as GameObject;
            if (go == null)
                return;
            var fxPlayer = go.GetComponent<FxPlayer>();
            if (fxPlayer == null)
            {
                fxPlayer = go.AddComponent<FxPlayer>();
                fxPlayer.duration = FxPlayerUtility.CalcPlayTime(go, fxPlayer);
            }
            _fxPlayersCache[obj] = fxPlayer;
        }

        public FxPlayer GetFxPlayer(Object obj)
        {
            if (obj == null)
                return null;
            _fxPlayersCache.TryGetValue(obj, out var fxPlayer);
            return fxPlayer;
        }
    }
}