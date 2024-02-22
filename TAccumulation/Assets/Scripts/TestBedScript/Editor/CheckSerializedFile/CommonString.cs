using UnityEngine;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;

namespace Unity
{
    public static class CommonString
    {
        public static string BufferBegin;

        public static string GetCurrentPath()
        {
            StackTrace st = new StackTrace(new StackFrame(true));
            StackFrame sf = st.GetFrame(0);
            string dirName = Path.GetDirectoryName(sf.GetFileName());

            return dirName;
        }

        static CommonString()
        {
            StringBuilder builder = new StringBuilder();

            string dirName = GetCurrentPath();
            string[] lines = File.ReadAllLines(dirName + Path.DirectorySeparatorChar +  "CommonStrings.h");
            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i];
                if (string.IsNullOrEmpty(line))
                    continue;

                const string match = "COMMON_STRING_ENTRY";
                if (!line.Contains(match))
                    continue;

                int startIndex = match.Length + 1;
                string buffer = line.Substring(startIndex, line.Length - 1 - startIndex);
                string[] split = buffer.Split(new char[] { ',' });
                string b = split[1].Trim();

                builder.Append(b + "\0");
            }
            BufferBegin = builder.ToString();
        }
    }
}        