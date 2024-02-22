// Name：InputEffectMgr_Init
// Created by jiaozhu
// Created Time：2022-07-10 21:48

namespace X3Game
{
    public partial class InputEffectMgr
    {
        protected override void Init()
        {
            base.Init();
            InitInput();
        }

        protected override void UnInit()
        {
            Clear();
            base.UnInit();
        }

        public void Clear()
        {
            ClearObj();
            ClearEffect();
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
        }
    }
}