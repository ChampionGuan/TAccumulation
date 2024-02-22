using System;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class EmptyPool:BattleResPool
    {
        public EmptyPool(BattlePoolMgr mgr, BattleResType type) : base(mgr, type)
        {
        }

        public override Object Get(ResLoadArg arg)
        {
            // do nothing
            return null;    
        }

        public override void Recycle(Object obj, ResLoadArg arg)
        {
            // do nothing
        }
    }
}