using System;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public enum RogueStageType
    {
        None = 0,
        /// <summary> 普通战斗 </summary>
        NormalFight = 1,
        /// <summary> 精英战斗 </summary>
        EliteFight = 2,
        /// <summary> Boss战斗 </summary>
        BossFight = 3,
        /// <summary> 事件 </summary>
        Event = 4,
        /// <summary> 趣味玩法 </summary>
        FunGameplay = 5,
        /// <summary> 休息区 </summary>
        ResetArea = 6,
    }
    
    [Flags]
    public enum RogueStageFlag
    {
        NormalFight = 1 << RogueStageType.NormalFight,    
        EliteFight = 1 << RogueStageType.EliteFight,    
        BossFight = 1 << RogueStageType.BossFight,
        Event = 1 << RogueStageType.Event,    
        FunGameplay = 1 << RogueStageType.FunGameplay,    
        ResetArea = 1 << RogueStageType.ResetArea,    
    }

    /// <summary>
    /// 关卡步骤
    /// </summary>
    public enum RogueStageStep
    {
        Before,
        Mid,
        End,
    }

    public enum RogueInterActorTag
    {
        None,
        Door,
    }
    
    /// <summary>
    /// 奖励类型
    /// </summary>
    public enum RogueRewardType
    {
        None = 0,
        /// <summary> 词条奖励 </summary>
        Entry,
        /// <summary> 道具奖励 </summary>
        Prop,
    }
	
    // 逻辑节点基类
    public interface EntryExpressionNode : IReset
    {
        bool GetResult();
    }

    // 逻辑根节点
    public class EntryExpressionRootNode : EntryExpressionBranchNode
    {
        private Func<int, bool> _checkItemFunc;

        public void Init(string expressionStr, Func<int, bool> checkItemFunc)
        {
            _checkItemFunc = checkItemFunc;
            if (expressionStr.Contains("("))
            {
                // 包含括号情况比较复杂需要分三步：s1：剥离最外层|符号 s2：剥离括号 s3：生成leafNode
                // S1：剥离最外层|符号  (1&2|3)&(4|5)&6 | 7
                List<S2IntValue> subStrInfos = new List<S2IntValue>(); // 记录字串起始索引和长度
                var inBracket = false; // 是否在括号区间内
                var subStrStartIndex = 0;
                for (int i = 0; i < expressionStr.Length; i++)
                {
                    var curChar = expressionStr[i];
                    if (curChar == '(')
                    {
                        inBracket = true; // 进入了括号区间
                    }
                    else if (curChar == ')')
                    {
                        inBracket = false; // 结束了括号区间
                    }
                    else if (!inBracket && curChar == '|') // 检测到括号区间外的|
                    {
                        subStrInfos.Add(new S2IntValue()
                        {
                            ID = subStrStartIndex,
                            Value = i - subStrStartIndex,
                        });
                        subStrStartIndex = i + 1;
                    }
                }

                if (subStrStartIndex < expressionStr.Length)
                {
                    subStrInfos.Add(new S2IntValue()
                    {
                        ID = subStrStartIndex,
                        Value = expressionStr.Length - subStrStartIndex,
                    });
                }

                // S2：准备剥离括号  (1&2|3)&(4|5)&6        7
                for (int subStrIndex = 0; subStrIndex < subStrInfos.Count; subStrIndex++)
                {
                    using (zstring.Block())
                    {
                        var subStrInfo = subStrInfos[subStrIndex];
                        var subStr = ((zstring)expressionStr).Substring(subStrInfo.ID, subStrInfo.Value);
                        if (_IsLeafStr(subStr))
                        {
                            // 数字类型字串，直接生成leaf
                            _GenerateLeafNode(this, subStr);
                        }
                        else
                        {
                            // 非数字类型子串，先生成branch，再由branch生成leaf
                            var childNode = ObjectPoolUtility.EntryExpressionBranchNodePool.Get();
                            if (subStr.Contains("("))
                            {
                                var grandStrs = ObjectPoolUtility.CommonZstringList.Get();
                                subStr.Split(grandStrs, '(', ')'); // 1&2|3   &   4|5    &6
                                foreach (var grandStr in grandStrs)
                                {
                                    if (_IsLeafStr(grandStr))
                                    {
                                        // 数字类型字串，直接生成leaf
                                        _GenerateLeafNode(childNode, grandStr);
                                    }
                                    else if (grandStr != "&")
                                    {
                                        // S3：不包含括号，属于最简单的情况，直接解析生成leafNode即可
                                        var grand = ObjectPoolUtility.EntryExpressionBranchNodePool.Get();
                                        _GenerateLeafNode(grand, grandStr);
                                        childNode.children.Add(grand);
                                    }
                                }

                                ObjectPoolUtility.CommonZstringList.Release(grandStrs);
                            }
                            else
                            {
                                // S3：不包含括号，属于最简单的情况，直接解析生成leafNode即可
                                _GenerateLeafNode(childNode, subStr);
                            }

                            this.children.Add(childNode);
                        }

                        if (subStrIndex > 0)
                        {
                            this.orIndexs.Add(subStrIndex);
                        }
                    }
                }
            }
            else
            {
                // S3：不包含括号，属于最简单的情况，直接解析生成leafNode即可
                _GenerateLeafNode(this, expressionStr);
            }
        }

        // 某个字符串是否为leafStr
        private bool _IsLeafStr(string expressionStr)
        {
            for (int i = 0; i < expressionStr.Length; i++)
            {
                var subChar = expressionStr[i];
                if ((expressionStr.Length <= 1 || i > 0) &&
                    (subChar == '(' || subChar == ')' || subChar == '&' || subChar == '|'))
                {
                    return false;
                }
            }

            return true;
        }

        // 生成leafNode
        private void _GenerateLeafNode(EntryExpressionBranchNode branchNode, string expressionStr)
        {
            using (zstring.Block())
            {
                var childStrs = ObjectPoolUtility.CommonZstringList.Get();
                ((zstring)expressionStr).Split(childStrs, '|', '&');
                foreach (var numStr in childStrs)
                {
                    var childNode = ObjectPoolUtility.EntryExpressionLeafNodePool.Get();
                    childNode.Index = int.Parse(numStr);
                    childNode.checkItemFunc = this._checkItemFunc;
                    branchNode.children.Add(childNode);
                }

                ObjectPoolUtility.CommonZstringList.Release(childStrs);

                var subStrIndex = 0;
                for (int i = 0; i < expressionStr.Length; i++)
                {
                    var curChar = expressionStr[i];
                    var isOr = curChar == '|';
                    var isAnd = curChar == '&';
                    if (isOr || isAnd)
                    {
                        subStrIndex++;
                        if (isOr)
                        {
                            branchNode.orIndexs.Add(subStrIndex);
                        }
                    }
                }
            }
        }
    }

    // 逻辑叶节点
    public class EntryExpressionLeafNode : EntryExpressionNode
    {
        public int Index;

        public Func<int, bool> checkItemFunc;

        public bool GetResult()
        {
            var result = checkItemFunc(Index);
            return result;
        }

        public void Reset()
        {
            Index = 0;
            checkItemFunc = null;
        }
    }

    // 逻辑枝干节点
    public class EntryExpressionBranchNode : EntryExpressionNode
    {
        public List<EntryExpressionNode> children = new List<EntryExpressionNode>();
        public List<int> orIndexs = new List<int>();

        public bool GetResult()
        {
            var result = true;
            if (orIndexs.Count == 0)
            {
                foreach (var child in children)
                {
                    result = child.GetResult();
                    if (!result)
                    {
                        break;
                    }
                }
            }
            else
            {
                result = false;
                var startIndex = 0;
                foreach (var orIndex in orIndexs)
                {
                    var orRegionResult = true;
                    for (int i = startIndex; i < orIndex; i++)
                    {
                        orRegionResult = children[i].GetResult();
                        if (!orRegionResult)
                        {
                            // 一个【或区间内】是与逻辑，得到false即可跳出当前或区间判断
                            break;
                        }
                    }

                    startIndex = orIndex;
                    if (orRegionResult)
                    {
                        // 【或区间】与【或区间】之间是或逻辑，得到true即可跳出整个判断
                        result = true;
                        break;
                    }
                }

                // 前面区间得出结果为false，则继续判断最后一个区间
                if (!result)
                {
                    var orRegionResult = true;
                    for (int i = startIndex; i < children.Count; i++)
                    {
                        orRegionResult = children[i].GetResult();
                        if (!orRegionResult)
                        {
                            // 一个【或区间内】是与逻辑，得到false即可跳出当前或区间判断
                            break;
                        }
                    }

                    result = orRegionResult;
                }
            }

            return result;
        }

        public void Reset()
        {
            orIndexs.Clear();
            foreach (var child in children)
            {
                if (child is EntryExpressionBranchNode branchNode)
                {
                    ObjectPoolUtility.EntryExpressionBranchNodePool.Release(branchNode);
                }
                else if (child is EntryExpressionLeafNode leafNode)
                {
                    ObjectPoolUtility.EntryExpressionLeafNodePool.Release(leafNode);
                }
            }

            children.Clear();
        }
    }
}