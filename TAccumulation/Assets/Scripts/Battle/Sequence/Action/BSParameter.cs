using System;
using NodeCanvas.Framework;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    // blackboard来源类型
    public enum BSBlackboardType
    {
        ActionModule = 0,  // 动作模组黑板
        Battle = 1,  // 战斗黑板
        Actor = 2,  // 角色黑板（目前还没支持）
    }

    public interface IBSParameter
    {
        T GetValue<T>(IBlackboard blackboard);  // 获取变量
        void SetValue<T>(IBlackboard blackboard, T t);  // 设置变量
        void ResetToOriginal();  // 重置变量为初始值
        IBSParameter CreateRuntimeParameter();
        bool IsFromBlackboard();
    }
    
    // 动作模组参数基类
    [Serializable]
    public abstract class BSParameter<T> : IBSParameter
    {
        // 黑板来源（序列化字段）
        public BSBlackboardType blackboardType;
        
        // 引用变量名（序列化字段）
        public string variableName;
        
        //  是否从黑板直接取值（序列化字段）
        public bool isFromBlackboard = true;

        // 获取值
        public T1 GetValue<T1>(IBlackboard blackboard)
        {
            var value = _GetValue(blackboard);
            if (value.GetType() == typeof(T1))
            {
                return (T1)Convert.ChangeType(value, typeof(T1));
            }
            else
            {
                LogProxy.LogErrorFormat("动作模组BSParameter取值异常，类型不匹配，将返回默认值！");
                return default;
            }
        }

        // 设置值
        public void SetValue<T1>(IBlackboard blackboard, T1 value)
        {
            if (value.GetType() == typeof(T))
            {
                var tValue = (T)Convert.ChangeType(value, typeof(T));
                _SetValue(blackboard, tValue);
            }
            else
            {
                LogProxy.LogErrorFormat("动作模组BSParameter设置值异常，类型不匹配，本次操作无效！");
            }
        }

        public void ResetToOriginal()
        {
        }

        // BSParameter是资源，不是实例存在一对多关系。当直接储存数值的参数需要用到重置功能时，返回一个runTimeParameter
        public IBSParameter CreateRuntimeParameter()
        {
            if (isFromBlackboard)
            {
                return this;
            }
            else
            {
                var runTimeParameter = new BSRuntimeParameter<T>();
                runTimeParameter.Init(this);
                return runTimeParameter;
            }
        }

        public bool IsFromBlackboard()
        {
            return isFromBlackboard;
        }

        // 获取值
        private T _GetValue(IBlackboard blackboard)
        {
            T value = default;
            if (isFromBlackboard)
            {
                var success = false;
                if (blackboard != null)
                {
                    var variable = blackboard.GetVariable<T>(variableName);
                    if (variable != null)
                    {
                        value = variable.GetValue();
                        success = true;
                    }
                }
                
                if (!success)
                {
                    LogProxy.LogError("动作模组BSParameter取值异常，没找到对应变量，或者黑板为空, 将返回默认值！");   
                }
            }
            else
            {
                value = _OnGetDirectValue();
            }
            
            return value;
        }

        // 设置值
        private void _SetValue(IBlackboard blackboard, T t)
        {
            if (isFromBlackboard)
            {
                var success = false;
                if (blackboard != null)
                {
                    var variable = blackboard.GetVariable<T>(variableName);
                    if (variable != null)
                    {
                        variable.SetValue(t);
                        success = true;
                    }
                }

                if (!success)
                {
                    LogProxy.LogError("动作模组BSParameter设置值异常，没找到对应变量，或者黑板为空！");
                }
            }
        }

        // 需子类实现，直接获取DirectValue
        protected virtual T _OnGetDirectValue()
        {
            return default;
        }
    }

    // 读共享，写复制
    // 运行时使用DirectInputValue模式的参数，当被Set值时会创建出一个新对象
    public class BSRuntimeParameter<T> : IBSParameter
    {
        private BSParameter<T> _parameter;
        private bool _isModified;  // 直接模式
        private T _value;
        
        public void Init(BSParameter<T> parameter)
        {
            _parameter = parameter;
        }
        
        public T1 GetValue<T1>(IBlackboard blackboard)
        {
            if (_isModified)
            {
                if (_value.GetType() == typeof(T1))
                {
                    return (T1)Convert.ChangeType(_value, typeof(T1));
                }
                else
                {
                    LogProxy.LogErrorFormat("动作模组BSParameter取值异常，类型不匹配，将返回默认值！");
                    return default;
                }
            }
            else
            {
                return _parameter.GetValue<T1>(blackboard);
            }
        }
        
        public void SetValue<T1>(IBlackboard blackboard, T1 t)
        {
            if (_value.GetType() == typeof(T1))
            {
                _value = (T)Convert.ChangeType(t, typeof(T));
                _isModified = true;
            }
            else
            {
                LogProxy.LogErrorFormat("动作模组BSParameter设置值异常，类型不匹配！");
            }
        }

        public void ResetToOriginal()
        {
            _isModified = false;
            _value = default;
        }

        public bool IsFromBlackboard()
        {
            return false;
        }
        
        public IBSParameter CreateRuntimeParameter()
        {
            throw new NotImplementedException("BSRuntimeParameter不支持再生成runTimeParameter, 请检查代码！");
        }
    }


    // Int子类（需要编辑器直接输入值，加上directInputValue）
    [Serializable]
    public class BSParameterInt : BSParameter<int>
    {
        public int directInputValue;
        
        protected override int _OnGetDirectValue()
        {
            return directInputValue;
        }
    }
    
    // float子类（需要编辑器直接输入值，加上directInputValue）
    [Serializable]
    public class BSParameterFloat : BSParameter<float>
    {
        public float directInputValue;
        
        protected override float _OnGetDirectValue()
        {
            return directInputValue;
        }
    }
    
    // Actor子类 (不需要编辑器编辑值，不加directInputValue)
    [Serializable]
    public class BSParameterActor : BSParameter<Actor>
    {
    }
}
