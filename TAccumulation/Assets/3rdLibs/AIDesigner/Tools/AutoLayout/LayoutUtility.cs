using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using TreeTaskTree = AIDesigner.AutoLayout.Tree<AIDesigner.TreeTask>;

namespace AIDesigner.AutoLayout
{
    public static class LayoutUtility
    {
        private static float s_defaultGap = Define.MeshSize / 2;

        public static void Layout(TreeTask treeRoot)
        {
            if (treeRoot == null)
            {
                LogProxy.LogWarning("传入节点为空，布局停止");
            }

            var layoutTree = BuildLayoutTree(treeRoot);
            Paper<TreeTask>.Layout(layoutTree);
            ApplyLayoutRecursive(layoutTree, null);
        }

        public static TreeTaskTree BuildLayoutTree(TreeTask treeRoot)
        {
            if (treeRoot == null)
            {
                return null;
            }

            var allChildWrappers = new List<TreeTaskTree>();

            if (treeRoot.Children != null && treeRoot.IsFoldout)
            {
                // 先创建儿子
                foreach (var child in treeRoot.Children)
                {
                    var childTree = BuildLayoutTree(child);
                    if (childTree == null)
                    {
                        continue;
                    }

                    allChildWrappers.Add(childTree);
                }
            }

            // 再创建当前
            return new TreeTaskTree(
                CalcLayoutWidth(treeRoot),
                treeRoot.TaskRect.height + treeRoot.VariableRect.height,
                treeRoot.TaskRect.y,
                allChildWrappers, treeRoot);
        }

        private static void ApplyLayoutRecursive(TreeTaskTree node, TreeTaskTree parent)
        {
            // 设置当前节点offset
            if (parent != null)
            {
                // offset是顶中点间的距离，但是Layout的rect还包括注释宽度，这里要减去注释宽度
                Vector2 offset = new Vector2(
                    CalcTopCenterXFromLayoutResult(node) -
                    CalcTopCenterXFromLayoutResult(parent),
                    node.m_y - parent.m_y);
                node.m_innerData.SetOffset(offset, false);
            }

            // 设置子节点offset
            foreach (var child in node.m_children)
            {
                ApplyLayoutRecursive(child, node);
            }

            //注：由于节点更新rect的时候会强制将中心置于网格中心，所以排列后的节点无法完全均匀分布。不是布局工具的bug
        }

        /// <summary>
        /// 计算AutoLayout宽度
        /// </summary>
        private static float CalcLayoutWidth(TreeTask task)
        {
            // layout的时候comment也要考虑
            return task.TaskRect.width + s_defaultGap * 2 +
                   (string.IsNullOrEmpty(task.Comment) ? 0 : task.CommentRect.width);
        }

        /// <summary>
        /// 使用Layout结果得到计算task的顶中点x坐标
        /// </summary>
        private static float CalcTopCenterXFromLayoutResult(TreeTaskTree node)
        {
            // 因为layout的时候加入了comment的宽度，需要将comment的宽度去除再计算顶中点的坐标。
            return node.m_x + (node.m_width + s_defaultGap - (String.IsNullOrEmpty(node.m_innerData.Comment)
                ? 0
                : node.m_innerData.CommentRect.width)) / 2;
        }
    }
}