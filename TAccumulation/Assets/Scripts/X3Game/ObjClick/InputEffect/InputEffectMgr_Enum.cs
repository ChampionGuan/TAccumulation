// Name：InputEffect_Enum
// Created by jiaozhu
// Created Time：2022-07-11 00:43

namespace X3Game
{
    public partial class InputEffectMgr
    {
        public enum InputType
        {
            None,
            TouchDown,
            Drag,
            TouchUp,
            LongPress,
        }

        public enum EffectType
        {
            Click,
            Drag,
            LongPress,
        }

        public enum FilterType
        {
            Shield,
            Override,
        }
    }
}