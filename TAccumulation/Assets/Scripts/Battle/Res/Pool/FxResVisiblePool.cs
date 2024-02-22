using System.Collections.Generic;
using PapeGames;
using UnityEngine;

namespace X3Battle
{
    // 理论上特效类似的资源应该只使用一种Pool，即可。 统一 FxResVisiblePool
    public class FxResVisiblePool:GameObjectVisiblePool, IGetFxPlayer
    {
        protected Dictionary<Object, FxPlayer> _fxPlayersCache;
        
        public FxResVisiblePool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
            _fxPlayersCache = new Dictionary<Object, FxPlayer>();
        }
        
        public override void UnInit()
        {
            base.UnInit();
            _fxPlayersCache = new Dictionary<Object, FxPlayer>();
        }
        
        public override Object Get(ResLoadArg arg)
        {
            var obj = base.Get(arg);
            
            GameObject go = obj as GameObject;
            if (go == null)
                return null;
            var fxPlayer = go.GetComponent<FxPlayer>();
            if (fxPlayer == null)
            {
                fxPlayer = go.AddComponent<FxPlayer>();
                fxPlayer.duration = FxPlayerUtility.CalcPlayTime(go, fxPlayer);
            }
            //特效预加载时 清一下内存 //仅在运行时做,否则打包也调用到,会报wwise错
            if (arg.isPreload && Application.isPlaying)
            {
                //fxPlayer.Recycle(false);//因为VFX已经不创建,不需要ClearVFX
            }
            _fxPlayersCache[obj] = fxPlayer;
            return obj;
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