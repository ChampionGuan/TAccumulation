using PapeGames.CutScene.BlackBoard;
using X3Battle;
using XLua;

namespace PapeGames.CutScene
{
    [LuaCallCSharp]
    public class X3CutSceneBlackBoardHelper
    {
        /// <summary>
        /// 设置显隐
        /// </summary>
        /// <param name="targetKey"></param>
        /// <param name="visible"></param>
        /// <returns></returns>
        public static VisibleCommand SetVisible(string targetKey, bool visible)
        {
            var cmd = new VisibleCommand();
// 黑板资产里配置的key
            cmd.targetKey = targetKey;
// 传递参数，该指令只有一个布尔值参数，用于控制显隐
            cmd.parameters = new Variable[] { new VarBoolean() { Value = visible } };
// 插入黑板指令表中
            BlackBoardTable.Add(cmd);
            return cmd;
        }

        /// <summary>
        /// 添加一个Command
        /// </summary>
        /// <param name="command"></param>
        public static void Add(ICommand command)
        {
            BlackBoardTable.Add(command);
        }

        /// <summary>
        /// 移除一个Command
        /// </summary>
        /// <param name="command"></param>
        public static void Remove(ICommand command)
        {
            BlackBoardTable.Remove(command);
        }

        /// <summary>
        /// 黑板清理
        /// </summary>
        public static void Clear()
        {
            BlackBoardTable.Clear();
        }
    }
}