using UnityEngine;

namespace X3Game
{
    public enum CommonItemMark
    {
        FxAlpha = 1 << 0,
        //Test1 = 1 << 1,
        //Test2 = 1 << 2,
        //Test3 = 1 << 3,
    }
    
    public interface ICommonItemCtrl
    {
        CommonItemMark Mark { get; }
        void Effect(float value);
        //TODO 如果有其他的值的类型就重载
    }
    
    public class CommonItemCtrl : MonoBehaviour, ICommonItemCtrl
    {
        [SerializeField] private CommonItemMark m_Mark;

        public CommonItemMark Mark => m_Mark;

        public void Effect(float value)
        {
            switch (m_Mark)
            {
                case CommonItemMark.FxAlpha:
                    this.FxAlphaEffect(value);
                    break;
            }
        }
    }

    public static class CommonItemMarkExtension
    {
        private const float TOLERANCE = 0.001f;
        public static void FxAlphaEffect(this CommonItemCtrl obj, float value)
        {
            if (value > 0)
            {
                obj.gameObject.SetActive(true);
            }
            else if(value - 0 < TOLERANCE)
            {
                obj.gameObject.SetActive(false);
            }
        }
    }
}