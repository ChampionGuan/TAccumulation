namespace UnityEngine
{
    public class DrawCoorPointAttribute : PropertyAttribute
    {
        public string label;

        public string showCondition;
        public string showCondition2;

        public string editorCondition;

        // 当目标变量为true时，该字段必须为true
        public string referenceTrueValue;
        
        public DrawCoorPointAttribute(string label, string showCondition = null, string editorCondition = null, string referenceTrueValue = null, string showCondition2 = null)
        {
            this.label = label;
            this.showCondition = showCondition;
            this.editorCondition = editorCondition;
            this.referenceTrueValue = referenceTrueValue;
            this.showCondition2 = showCondition2;
        }
    }
}