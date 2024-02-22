using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取关卡参数\nGetLevelParam")]
    public class FAGetLevelParam : FlowAction
    {
        public enum LevelParamType
        {
            TimeLimitType, // 计时类型
            TimeLimit,  // 时间长度
            StageLevel, // 关卡等级
            StateID, // 关卡ID
        }

        public BBParameter<LevelParamType> ParamType = new BBParameter<LevelParamType>(LevelParamType.StateID);

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<int>("Param", () =>
            {
                var levelParamType = ParamType.GetValue();
                switch (levelParamType)
                {
                    case LevelParamType.TimeLimitType:
                        return Battle.Instance.config.TimeLimitType;
                    case LevelParamType.TimeLimit:
                        return Battle.Instance.config.TimeLimit;
                    case LevelParamType.StageLevel:
                        return Battle.Instance.config.Level;
                    case LevelParamType.StateID:
                        return Battle.Instance.config.ID;
                    default:
                        throw new ArgumentOutOfRangeException();
                }
                return -1;
            });
        }
    }
}
