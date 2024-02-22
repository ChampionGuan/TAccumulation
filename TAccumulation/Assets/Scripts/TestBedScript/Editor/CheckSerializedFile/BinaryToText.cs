using UnityEngine;
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace UnitySerializedFile
{
    public class BinaryToText
    {
        static char[] kHexToLiteral = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
        private static string GUIDToString(UInt32[] data)
        {
            char[] name = new char[32];
            for (int i = 0; i < 4; i++)
            {
                for (int j = 7; j >= 0; j--)
                {
                    UInt32 cur = data[i];
                    cur >>= (j * 4);
                    cur &= 0xF;
                    name[i * 8 + j] = kHexToLiteral[cur];
                }
            }
            return new string(name);
        }

        public static void Convert(ReadBinaryHeader btf, TextWriter writer, byte[] data)
        {
            writer.WriteLine("%YAML 1.1");
            writer.WriteLine("%TAG !u! tag:unity3d.com,2011:");

            // Output the object's	
            foreach (long fileID in btf.Objects.Keys)
            {
                ObjectInfo fileValue = btf.Objects[fileID];
                int byteStart = (int)fileValue.byteStart;
                int classId = (int)fileValue.typeID;
                TypeTree type = btf.GetTypeTree(fileID);

                writer.WriteLine(string.Format("--- !u!{1} &{0}", fileID, classId));
                int offset = byteStart;
                RecursiveOutput(btf, writer, type, data, ref offset);
            }
            writer.Close();
        }

        private static void TAB(TextWriter writer, int tab)
        {
            for (int t = 0; t < tab; t++)
                writer.Write("  ");
        }

        private static string OutputValue(TypeTree type, byte[] data, ref int offset)
        {
            ref TypeTreeNode t = ref type.m_Node;

            string result = string.Empty;
            if (type.m_Type == "float")
            {
                float value = BitConverter.ToSingle(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "double")
            {
                double value = BitConverter.ToDouble(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "int")
            {
                int value = BitConverter.ToInt32(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "unsigned int")
            {
                uint value = BitConverter.ToUInt32(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "SInt32" || type.m_Type == "Type*")
            {
                int value = BitConverter.ToInt32(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "UInt32")
            {
                uint value = BitConverter.ToUInt32(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "SInt16")
            {
                Int16 value = BitConverter.ToInt16(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "UInt16")
            {
                UInt16 value = BitConverter.ToUInt16(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "SInt64")
            {
                Int64 value = BitConverter.ToInt64(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "UInt64")
            {
                UInt64 value = BitConverter.ToUInt64(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "SInt8" || type.m_Type == "UInt8")
            {
                //int value = (int)BitConverter.ToChar(data, offset);
                byte value = data[offset];
                result = value.ToString();
            }
            else if (type.m_Type == "char")
            {
                char value = BitConverter.ToChar(data, offset);
                result = value.ToString();
            }
            else if (type.m_Type == "bool")
            {
                bool value = BitConverter.ToBoolean(data, offset);
                result = (value ? 1 : 0).ToString();
            }
            else
            {
                Debug.LogError("Unsupported type! " + type.m_Type);
            }
            offset += t.m_ByteSize;

            return result;
        }

        private static void WriteValue(TextWriter writer, TypeTree type, string value)
        {
            type.m_DebugValue = value;
            writer.Write(value);
        }

        static int kArrayMemberColumns = 25;
        static int kLargeBinaryCount = 1024;
        public static void RecursiveOutput(ReadBinaryHeader btf, TextWriter writer, TypeTree type, byte[] data, ref int offset, int tab = 0, bool writeTab = true, bool writeName = true, bool writeLine = true)
        {
            ref TypeTreeNode t = ref type.m_Node;

            if (type.m_Type == "Vector3f" && t.m_ByteSize != 12)
            {
                Debug.LogError("Unsupported type! " + type.m_Type);
            }

            if (type.IsBasicDataType())
            {
                // basic data type
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, OutputValue(type, data, ref offset));
                if (writeLine) writer.WriteLine();
            }
            else if (t.IsArray())
            {
                // Extract and Print size
                int size = BitConverter.ToInt32(data, offset);
                offset += 4;

                if (size <= 0)
                {
                    writer.WriteLine(" []");
                }

                // Print children
                for (int i = 0; i < size; i++)
                {
                    TAB(writer, tab - 1);
                    writer.Write("- ");
                    //char buffy[64]; sprintf (buffy, "%s[%d]", type.m_Name.c_str (), i);
                    RecursiveOutput(btf, writer, type.m_Children[1], data, ref offset, tab - 1, false, false, true);
                }
            }
            else if (type.m_Type == "string")
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractString(type, data, ref offset));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "Vector4f" && t.m_ByteSize == 16)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractVector(type, data, ref offset, 4));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "Vector3f" && t.m_ByteSize == 12)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractVector(type, data, ref offset, 3));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "Vector2f" && t.m_ByteSize == 8)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractVector(type, data, ref offset, 2));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "int4_storage" && t.m_ByteSize == 16)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractIntVector(type, data, ref offset, 4));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "int3_storage" && t.m_ByteSize == 12)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractIntVector(type, data, ref offset, 3));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "int2_storage" && t.m_ByteSize == 8)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractIntVector(type, data, ref offset, 2));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "int1_storage" && t.m_ByteSize == 4)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractIntVector(type, data, ref offset, 1));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "Quaternionf" && t.m_ByteSize == 16)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractVector(type, data, ref offset, 4));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "ColorRGBA" && t.m_ByteSize == 16)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractRGBA(type, data, ref offset, 4));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type.StartsWith("PPtr<") && t.m_ByteSize == 12)
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractPPtr(btf, type, data, ref offset));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "GUID")
            {
                if (writeTab) TAB(writer, tab);
                if (writeName) writer.Write(type.m_Name + ": ");

                WriteValue(writer, type, ExtractGUID(type, data, ref offset));
                if (writeLine) writer.WriteLine();
            }
            else if (type.m_Type == "vector")
            {
                TAB(writer, tab);
                if (type.m_Father != null)
                {
                    writer.Write(type.m_Name + ":");
                }
                else
                {
                    writer.Write(type.m_Type + ":");
                }

                int size = BitConverter.ToInt32(data, offset);
                if (size > 0)
                {
                    writer.WriteLine();
                }
                RecursiveOutput(btf, writer, type.m_Children[0], data, ref offset, tab);
            }
            else if (type.m_Type == "pair")
            {
                RecursiveOutput(btf, writer, type.m_Children[0], data, ref offset, tab, false, false, false);
                writer.Write(": ");
                RecursiveOutput(btf, writer, type.m_Children[1], data, ref offset, tab, false, false, false);
                writer.WriteLine();
            }
            else if (type.m_Type == "Generic Mono" || type.m_Type == "Keyframe")
            {
                RecursiveOutput(btf, writer, type.m_Children[0], data, ref offset, tab, false, true, true);
                for (int i = 1; i < type.m_Children.Count; i++)
                {
                    TAB(writer, tab + 1);
                    RecursiveOutput(btf, writer, type.m_Children[i], data, ref offset, tab, false, true, true);
                }
            }
            else
            {
                if (writeTab) TAB(writer, tab);
                if (type.m_Father == null)
                {
                    writer.Write(type.m_Type + ":");    
                }
                else if (!type.m_Father.m_Node.IsArray())
                {
                    writer.Write(type.m_Name + ":");
                }

                if (!(type.m_Father != null && type.m_Father.m_Node.IsArray()) 
                    && !(type.m_Children.Count == 1 && type.m_Children[0].m_Node.IsArray() && BitConverter.ToInt32(data, offset) == 0))
                    writer.WriteLine();

                tab++;
                for (int i = 0; i < type.m_Children.Count; i++)
                {
                    RecursiveOutput(btf, writer, type.m_Children[i], data, ref offset, tab, i == 0 ? writeTab : true, true, true);
                }
                tab--;
            }

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }
        }

        private static string ExtractString(TypeTree type, byte[] data, ref int offset)
        {
            ref TypeTreeNode t = ref type.m_Node;

            int size = BitConverter.ToInt32(data, offset);
            byte[] str = new byte[size];
            for (int i = 0; i < size; i++)
            {
                str[i] = data[offset + i + 4];//sizeof(SInt32)
            }

            offset += 4 + size;//sizeof(SInt32)

            if ((t.m_MetaFlag & (uint)(TransferMetaFlags.kAnyChildUsesAlignBytesFlag | TransferMetaFlags.kAlignBytesFlag)) != 0)
                offset = Align4(offset);

            string extString = Encoding.UTF8.GetString(str);
            return GetUnicodeString(extString);
        }

        private static string GetUnicodeString(string str)
        {
            char[] hex_seq = new char[4];
            int n = str.Length;
            StringBuilder builder = new StringBuilder();

            bool hexflag = false;
            for (int i = 0; i < n; i++)
            {
                if (str[i] >= 32 && str[i] <= 126)
                {
                    builder.Append(str[i]);
                    continue;
                }

                // Default, turn into a \uXXXX sequence
                IntToHex(str[i], hex_seq);
                builder.Append("\\u");
                builder.Append(hex_seq);
                hexflag = true;
            }

            string uniString = builder.ToString();

            if (!hexflag)
                if (uniString.Contains("-") || uniString.Contains(":"))
                    return '\'' + uniString + '\'';
                else
                    return uniString;
            else
                return '"' + uniString + '"';
        }

        private static void IntToHex(int n, char[] hex)
        {
            int num;

            for (int i = 0; i < 4; i++)
            {
                num = n % 16;

                if (num < 10)
                    hex[3 - i] = (char)('0' + num);
                else
                    hex[3 - i] = (char)('A' + (num - 10));

                n >>= 4;
            }
        }

        private static string ExtractVector(TypeTree type, byte[] data, ref int offset, int dimension)
        {
            ref TypeTreeNode t = ref type.m_Node;

            char[] dim = new char[] { 'x', 'y', 'z', 'w' };
            StringBuilder builder = new StringBuilder();
            builder.Append("{");
            for (int i = 0; i < dimension; ++i)
            {
                float v = BitConverter.ToSingle(data, offset);
                if (i != 0)
                    builder.Append(", ");
                builder.Append(dim[i] + ": " + v);
                offset += 4;
            }
            builder.Append('}');

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }

            return builder.ToString();
        }

        private static string ExtractIntVector(TypeTree type, byte[] data, ref int offset, int dimension)
        {
            ref TypeTreeNode t = ref type.m_Node;

            char[] dim = new char[] { 'x', 'y', 'z', 'w' };
            StringBuilder builder = new StringBuilder();
            builder.Append("{");
            for (int i = 0; i < dimension; ++i)
            {
                int v = BitConverter.ToInt32(data, offset);
                if (i != 0)
                    builder.Append(", ");
                builder.Append(dim[i] + ": " + v);
                offset += 4;
            }
            builder.Append('}');

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }

            return builder.ToString();
        }

        private static string ExtractRGBA(TypeTree type, byte[] data, ref int offset, int dimension)
        {
            ref TypeTreeNode t = ref type.m_Node;

            char[] dim = new char[] { 'r', 'g', 'b', 'a' };
            StringBuilder builder = new StringBuilder();
            builder.Append("{");
            for (int i = 0; i < dimension; ++i)
            {
                float v = BitConverter.ToSingle(data, offset);
                if (i != 0)
                    builder.Append(", ");
                builder.Append(dim[i] + ": " + v);
                offset += 4;
            }
            builder.Append('}');

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }

            return builder.ToString();
        }

        private static string ExtractPPtr(ReadBinaryHeader btf, TypeTree type, byte[] data, ref int offset)
        {
            ref TypeTreeNode t = ref type.m_Node;

            int fileID = BitConverter.ToInt32(data, offset);
            long pathID = BitConverter.ToInt64(data, offset + 4);

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }

            offset += 12;

            if (fileID == 0)
            {
                return "{" + string.Format("fileID: {0}", pathID) + "}";
            }
            else
            {
                FileIdentifier reference = btf.Externals[fileID - 1];
                return "{" + string.Format("fileID: {0}, guid: {1}, type: {2}", pathID, GUIDToString(reference.data), reference.type) + "}";
            }
        }

        private static string ExtractGUID(TypeTree type, byte[] data, ref int offset)
        {
            ref TypeTreeNode t = ref type.m_Node;

            uint[] guid = new uint[4];
            for (int i = 0; i < 4; ++i)
            {
                uint v = BitConverter.ToUInt32(data, offset);
                guid[i] = v;
                offset += 4;
            }

            if ((t.m_MetaFlag & (uint)TransferMetaFlags.kAlignBytesFlag) != 0)
            {
                offset = Align4(offset);
            }

            return GUIDToString(guid);
        }

        private static int Align4(int size)
        {
            int value = ((size + 3) >> 2) << 2;
            return value;
        }
    }

}