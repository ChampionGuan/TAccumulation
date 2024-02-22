namespace X3Battle
{
    public class BSCBase
    {
        protected BattleSequencer _battleSequencer;
        protected BSContext _context;

        public BSCBase() { }

        public void Init(BattleSequencer battleSequencer, BSContext context)
        {
            this._battleSequencer = battleSequencer;
            _context = context;   
            _OnInit();
        }

        /// <summary>
        /// build
        /// </summary>
        /// <returns>是否成功</returns>
        public bool Build()
        {
            return _OnBuild();
        }
        
        /// <summary>
        /// Tick
        /// </summary>
        /// <param name="deltaTime"></param>
        public void Tick(float deltaTime)
        {
            _OnTick(deltaTime);
        }

        /// <summary>
        /// 销毁
        /// </summary>
        public void Destroy()
        {
            _OnDestroy();
        }

        protected virtual void _OnInit()
        {
        }

        protected virtual bool _OnBuild()
        {
            return true;
        }

        protected virtual void _OnTick(float deltaTime)
        {
        }

        protected virtual void _OnDestroy()
        {
        }
    }
}