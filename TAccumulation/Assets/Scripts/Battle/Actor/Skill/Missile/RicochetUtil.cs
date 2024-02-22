using System.Collections.Generic;

namespace X3Battle
{
    public static class RicochetUtil
    {
        // 递归收集弹射的子弹群 ID
        public static void GatherRicochetMissile(int childMissileID, ref HashSet<int> childIDs)
        {
            if (childIDs == null)
            {
                return;
            }
            
            if (childIDs.Contains(childMissileID))
            {
                return;
            }

            childIDs.Add(childMissileID);
            
            var missileCfg = TbUtil.GetCfg<MissileCfg>(childMissileID);
            if (missileCfg != null && missileCfg.ricochetActive && missileCfg.ricochetMissileID > 0)
            {
                GatherRicochetMissile(missileCfg.ricochetMissileID, ref childIDs);
            }
        }
    }
}