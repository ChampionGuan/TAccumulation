using Unity.Collections.LowLevel.Unsafe;

namespace X3Battle
{
    // 基于zstring，只能在战斗中用
    public class RewritingString
    {
        private static int _charLen = sizeof(char);
        
        private int _maxLength;
        private string _data;
        
        public RewritingString(int length)
        {
            _ExpandData(length);
        }

        private void _ExpandData(int length)
        {
            _data = new string(' ', length);
            _maxLength = length;
        }
        
        public static implicit operator string(RewritingString rewritingString)
        {
            return rewritingString._data;
        }

        private unsafe void _EvalData(string targetValue)
        {
            var targetLength = targetValue.Length;
            if (targetLength > _maxLength)
            {
                _ExpandData(targetLength);
            }
            
            fixed (char* dataPtr = _data)
            {
                var lenPtr = (int*)(dataPtr - 2);
                *lenPtr = targetLength;
            }
            
            fixed (char* dstPtr = _data)
            {
                fixed (char* srcPtr = targetValue)
                {
                    UnsafeUtility.MemCpy(dstPtr, srcPtr, targetLength * _charLen);
                }
            }
        }

        public RewritingString ReConcat(string str1)
        {
            _EvalData(str1);
            return this;
        }
        
        public RewritingString ReConcat(string str1, string str2)
        {
            using (zstring.Block())
            {
                var target = (zstring)str1 + str2;
                _EvalData(target);
            }

            return this;
        }
        
        public RewritingString ReConcat(string str1, string str2, string str3)
        {
            using (zstring.Block())
            {
                var target = (zstring)str1 + str2 + str3;
                _EvalData(target);
            }   
            
            return this;
        }

        // 无GC的Format
        /**
         * 使用demo：
         * 1.外部模块创建并长期持有rewritingString，比如UI上显示技能描述的面板Text，或者飘字Text等
         *       var rstring = new RewritingString(50);  // 预估一下大概使用长度，扩容会有GC，不扩容没GC
         * 2.当需要format字符串时：
         *       uiText.text = rstring.ReFormat("123{0}, {456}xx", params);
         * 3.注意：
         *       3.1 format时，如果长度不足内部会扩容，所以需要一开始构造函数中给个合适长度。当然，太长了也会浪费。
         *       3.2 为了性能，配表时input参数请按照顺序 "{0}xxx{1}xxx{2}xxx{3}xxx"格式来，不支持"{0}xxx{1}xxx{0}xxx{2}"这种
         *       3.3 目前string[] paramStrs最多支持99个可变参数，真超出了也不会崩，会报个Exception。
         */
        public RewritingString ReFormat(string input, string[] paramStrs)
        {
            using (zstring.Block())
            {
                var target = zstring.Format(input, paramStrs);
                _EvalData(target);
            }
            
            return this;
        }
        
        // TODO 考虑优化空间
        public RewritingString ReConcat(string str1, string str2, string str3, int int4)
        {
            using (zstring.Block())
            {
                var target = (zstring)str1 + str2 + str3 + int4;
                _EvalData(target);
            }
            
            return this;
        }
        
    }
}