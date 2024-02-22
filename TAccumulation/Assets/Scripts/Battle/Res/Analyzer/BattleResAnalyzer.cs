using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class BattleResAnalyzer : ResAnalyzer
    {
        private BattleArg _arg;
        public override int ResID => 0;

        public BattleResAnalyzer(BattleArg arg) : base(null)
        {
            _arg = arg;
        }

        protected override void DirectAnalyze()
        {
            ClearCache();
            // 关卡
            var levelResAnalyzer = new BattleLevelResAnalyzer(_arg.levelID, resModule);
            levelResAnalyzer.Analyze();

            // 女主
            new HeroResAnalyzer(_arg.girlID, resModule).Analyze();
            
            var girlAnalyzer = new SuitResAnalyzer(_arg.girlSuitID, parent:resModule);
            girlAnalyzer.Analyze();

            // 女主武器
            var weaponAnalyzer = new WeaponResAnalyzer(_arg.girlWeaponID, resModule);
            weaponAnalyzer.Analyze();

            // 男主
            new HeroResAnalyzer(_arg.boyID, resModule).Analyze();
            
            var boyAnalyzer = new SuitResAnalyzer(_arg.boySuitID, parent:resModule);
            boyAnalyzer.Analyze();

            ClearCache();
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BattleResAnalyzer analyzer)
            {
                return true;
            }
            return false;
        }
    }
}