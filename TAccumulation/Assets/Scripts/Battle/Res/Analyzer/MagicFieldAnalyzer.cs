using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 法术场解析
    /// </summary>
    public class MagicFieldAnalyzer: ResAnalyzer
    {
        private int _magicFieldID;
        public override int ResID => _magicFieldID;
        
        public MagicFieldAnalyzer(ResModule parent, int magicFieldID) : base(parent)
        {
            _magicFieldID = magicFieldID;
        }

        protected override void DirectAnalyze()
        {
            if (_magicFieldID <= 0)
            {
                return;
            }
            
            var cfg = TbUtil.GetCfg<MagicFieldCfg>(_magicFieldID);
            if (cfg == null)
            {
                return;
            }

            ResAnalyzeUtil.AnalyzeActionModule(resModule, cfg.ActionModule);
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is MagicFieldAnalyzer analyzer)
            {
                return analyzer._magicFieldID == _magicFieldID;
            }

            return false;
        }
    }
}