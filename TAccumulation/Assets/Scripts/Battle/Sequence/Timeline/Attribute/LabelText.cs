using UnityEngine;

/// <summary>
/// 字段名字的前缀标签，字段前加了之后可以在编辑器中显示中文名称
/// </summary>
public class LabelTextAttribute:PropertyAttribute
{
    public string label;

    public string showCondition;
    public string showCondition2;

    public string editorCondition;

    // 当目标变量为true时，该字段必须为true
    public string referenceTrueValue;

    public int maxArraySize;

    public JumpModuleType jumpType = JumpModuleType.None;
    public CustomDrawType customDrawType = CustomDrawType.Default;

    /// <summary>
    /// 渲染文本Text
    /// </summary>
    /// <param name="label"></param>
    /// <param name="showCondition"> etc. 1."True" 2."False" 3."!isWorldAxis" 4."enum:warnEffectType==0" </param>
    /// <param name="editorCondition"> 同showCondition </param>
    /// <param name="referenceTrueValue"></param>
    public LabelTextAttribute(string label, string showCondition = null, string editorCondition = null, string referenceTrueValue = null, string showCondition2 = null, int maxArraySize = 10, JumpModuleType jumpType = JumpModuleType.None, CustomDrawType drawType = CustomDrawType.Default)
    {
        this.label = label;
        this.showCondition = showCondition;
        this.editorCondition = editorCondition;
        this.referenceTrueValue = referenceTrueValue;
        this.showCondition2 = showCondition2;
        this.maxArraySize = maxArraySize;
        this.jumpType = jumpType;
        this.customDrawType = drawType;
    }
}

public enum JumpModuleType
{
    None,
    ViewSkill,
    ViewActionModule,
    ViewDamageBox,
    ViewMissile,
    ViewBuff,
    ViewSkin,
    ViewMagicField,
    ViewHalo,
    ViewTrigger,
    ViewItem,
    ViewModel,
    ViewRogue,
}

public enum CustomDrawType
{
    Default,  // 默认模式
    BSParameter,  // 绘制黑板参数模式
}