using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 光环解析
    /// </summary>
    public class HaloAnalyzer: ResAnalyzer
    {
        private int _haloID;
        public override int ResID => _haloID;
        
        public HaloAnalyzer(ResModule parent, int haloID) : base(parent)
        {
            _haloID = haloID;
        }

        protected override void DirectAnalyze()
        {
            if (_haloID <= 0)
            {
                return;
            }
            
            var haloCfg = TbUtil.GetCfg<HaloCfg>(_haloID);
            if (haloCfg == null)
            {
                return;
            }

            // DONE: 解析Buff.
            if (haloCfg.BuffIds != null)
            {
                foreach (int buffId in haloCfg.BuffIds)
                {
                    BuffResAnalyzer analyzer = new BuffResAnalyzer(buffId, parent:resModule);
                    analyzer.Analyze();
                }
            }            
            
            // Trigger解析
            if (haloCfg.TriggerID > 0)
            {
                var triggerAnalyzer = new TriggerAnalyzer(resModule, haloCfg.TriggerID);
                triggerAnalyzer.Analyze();   
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is HaloAnalyzer analyzer)
            {
                return analyzer._haloID == _haloID;
            }

            return false;
        }
    }
}