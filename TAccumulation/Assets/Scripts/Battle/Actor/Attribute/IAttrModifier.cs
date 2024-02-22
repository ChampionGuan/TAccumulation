using System.Collections.Generic;

namespace X3Battle
{
    /// <summary>
    /// 在GetValue时的额外计算
    /// 需要满足交换律，不同顺序不影响
    /// </summary>
    public interface IAttrModifier
    {
        float ChangeAttrValue(AttrType type, float value);
    }
}