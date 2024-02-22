using System.Text;
using PapeGames.X3;
using UnityEngine.Playables;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public static class DebugUtility
    {
        public static string GetGraphDesc(PlayableGraph graph)
        {
            string ret = string.Empty;
            var sb = StringUtility.GetStringBuilder();
            if (graph.IsValid())
            {
                int outputCount = graph.GetOutputCount();
                sb.AppendLine(graph.ToString());
                sb.AppendLine($"outputCount:{outputCount}, isPlaying:{graph.IsPlaying()}, isDone:{graph.IsDone()}");
                for (int i = 0; i < outputCount; i++)
                {
                    var playableOutput = graph.GetOutput(i);
                    sb.Append($"-[{i}]{playableOutput.GetType().Name}");
                    var playable = playableOutput.GetSourcePlayable();
                    sb.Append(" << ");
                    GetPlayableDesc(playable, 1, i, sb);
                    sb.AppendLine();
                }
            }
            else
            {
                sb.AppendLine("invalid graph");
            }
            ret = sb.ToString();
            StringUtility.ReleaseStringBuilder(sb);
            return ret;
        }

        internal static void GetPlayableDesc(Playable playable, float weight, int port, StringBuilder sb)
        {
            if (playable.IsValid())
            {
                var inputCount = playable.GetInputCount();
                sb.Append($"[{port}]-{playable.GetType().Name}, time:{playable.GetTime()}, weight:{weight}, inputCount:{inputCount}");
                if (inputCount > 0)
                {
                    sb.Append("{");
                    for (int i = 0; i < inputCount; i++)
                    {
                        var childPlayable = playable.GetInput(i);
                        GetPlayableDesc(childPlayable, playable.GetInputWeight(i), i, sb);
                        if (i < inputCount - 1)
                            sb.Append(", ");
                    }
                    sb.Append("}");
                }
 
            }
            else
            {
                sb.Append($"[{port}]-invalid playable");
            }
        }
    }
}