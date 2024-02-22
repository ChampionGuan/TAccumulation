using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButton]
    [Category("X3Battle/通用/Action")]
    [Name("修改子弹的模板属性—弹射功能\nFAModifyMissileCfgRicochet")]
    public class FAModifyMissileCfgRicochet : FlowAction
    {
        [Name("子弹ID")]
        public int missileID;

        // 弹射功能独立参数
        [Name("是否开启弹射")]
        public bool ricochetActive;  // (独立参数) 是否开启弹射，默认false
        [ShowIf("ricochetActive", 1)]
        [Name("弹射子弹ID")]
        public int ricochetMissileID;  // （独立参数）弹射的子弹ID
        [ShowIf("ricochetActive", 1)]
        [Name("弹射判定半径")]
        public float ricochetRadius = 5f; // （独立参数）弹射索敌半径
        
        // 弹射功能共享参数
        [ShowIf("ricochetActive", 1)]
        [Name("允许单位被重复弹射")]
        public bool ricochetAllowRepeat = true;  // (共享参数) 子弹命中A弹射至B后，B能够反向弹给A。
        [ShowIf("ricochetActive", 1)]
        [Name("最大弹射次数")]
        public int ricochetMaxNum = 1;  // (共享参数)生成弹射子弹的次数，超过上限不再生成子弹
        [ShowIf("ricochetActive", 1)]
        [Name("最大弹群数量")]
        public int ricochetMaxMissilesNum = 5;  // （共享参数）指所有在场某子弹和它弹射弹群的最大数量
        [ShowIf("ricochetActive", 1)]
        [Name("弹射子弹阵营")]
        public FactionRelationship ricochetFactionRelationship = FactionRelationship.Enemy;  //(共享参数) 能够弹射的目标类型

        protected override void _Invoke()
        {
            var targetID = missileID;
            if (targetID > 0)
            {
                var missileCfg = TbUtil.LoadModifyCfg<MissileCfg>(targetID);
                if (missileCfg != null)
                {
                    missileCfg.ricochetActive = ricochetActive;
                    missileCfg.ricochetMissileID = ricochetMissileID;
                    missileCfg.ricochetRadius = ricochetRadius;
                    missileCfg.ricochetAllowRepeat = ricochetAllowRepeat;
                    missileCfg.ricochetMaxNum = ricochetMaxNum;
                    missileCfg.ricochetMaxMissilesNum = ricochetMaxMissilesNum;
                    missileCfg.ricochetFactionRelationship = ricochetFactionRelationship;
                }
            }
        }
    }
}