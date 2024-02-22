using System;

namespace X3Battle
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple=false, Inherited=false)]
    public class BuffActionAttribute : System.Attribute
    {
        private string _name;
        public string name => _name;
            
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="UIName">编辑器上显示的名字</param>
        public BuffActionAttribute(string UIName)
        {
            _name = UIName;
        }
    }
        
    [AttributeUsage(AttributeTargets.Field, AllowMultiple=false, Inherited=true)]
    public class BuffLableAttribute : System.Attribute
    {
        private string _name;
        public string name => _name;
            
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="UIName">编辑器上显示的名字</param>
        public BuffLableAttribute(string UIName)
        {
            _name = UIName;
        }
    }
}