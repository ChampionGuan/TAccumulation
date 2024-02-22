using System.Linq;
using System.Text;

namespace AIDesigner
{
    public class TreeTaskVariable : ReferenceVariable
    {
        public TreeTaskVariable(string key, VarType type, string desc, ArrayType arrayType, bool isShared,
            bool isAnyType, Options options) : base(key, type, desc, arrayType, isShared, isAnyType, options)
        {
        }

        public TreeTaskVariable(string key, VarType type, object value, string desc, ArrayType arrayType, bool isShared,
            string sharedKey, bool isAnyType, Options options) : base(key, type, value, desc, arrayType, isShared,
            sharedKey, isAnyType, options)
        {
        }

        public new void SetType(VarType type)
        {
        }

        public new TreeTaskVariable DeepCopy()
        {
            var var = new TreeTaskVariable(Key, Type, Value, Desc, ArrayType, IsShared, SharedKey, IsAnyType,
                Options?.DeepCopy());
            foreach (var v in ArrayVar)
            {
                var.ArrayVar.Add(v.DeepCopy());
            }

            return var;
        }
    }

    public static class TreeTaskVariableExtension
    {
        public static string ToDebugString(this TreeTaskVariable variable)
        {
            // 原名(共享变量名): 枚举名(值)
            SharedVariable sharedVariable = null;
            if (variable.IsShared && variable.SharedFlag)
            {
                sharedVariable = TreeChart.Instance.CurrTree.GetSharedVariable(variable.SharedKey);
            }

            var sb = new StringBuilder();
            sb.Append($"{AIDesignerLogicUtility.ToUpperFirst(variable.Key)}");
            if (sharedVariable != null)
            {
                sb.Append($" ({AIDesignerLogicUtility.ToUpperFirst(sharedVariable.Key)})");
            }

            if (sharedVariable is ReferenceVariable refVariable && refVariable.IsArray)
            {
                var arrayValueText = refVariable.ArrayVar.Count > 0
                    ? refVariable.ArrayVar.Select(item => item.Value.ToString())
                        .Aggregate((totalOutput, itemOutput) => totalOutput + ", " + itemOutput)
                    : string.Empty;
                sb.Append($": [{arrayValueText}]");
                return sb.ToString();
            }
            else
            {
                if (variable.Type == VarType.Int && variable.Options != null)
                {
                    sb.Append($": {variable.Options.Keys[variable.Options.SelectedIndex]}");
                }
                else
                {
                    sb.Append($": {sharedVariable?.Value ?? variable.Value}");
                }

                return sb.ToString();
            }
        }
    }
}