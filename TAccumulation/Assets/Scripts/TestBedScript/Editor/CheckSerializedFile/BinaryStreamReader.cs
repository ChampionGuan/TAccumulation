using System;
using System.IO;
using System.Text;

public class BinaryStreamReader : MemoryStream
{
    public BinaryStreamReader(byte[] buffer, int index, int count)
        : base(buffer, index, count)
    {
    }

    public string ReadString()
    {
        StringBuilder builder = new StringBuilder();
        int c = 0;
        while ((c = base.ReadByte()) != 0)
        {
            builder.Append((char)c);
        }
        return builder.ToString();
    }

    public string ReadString2()
    {
        int len = ReadSInt32();

        byte[] buffer = new byte[len];
        base.Read(buffer, 0, len);
        string str = Encoding.Default.GetString(buffer);
        AlignStreamReader(4);

        return str;
    }

    public UInt64 ReadUInt64()
    {
        byte[] buffer = new byte[8];
        base.Read(buffer, 0, 8);
        return BitConverter.ToUInt64(buffer, 0);
    }

    public Int64 ReadSInt64()
    {
        byte[] buffer = new byte[8];
        base.Read(buffer, 0, 8);
        return BitConverter.ToInt64(buffer, 0);
    }

    public uint ReadUInt32()
    {
        byte[] buffer = new byte[4];
        base.Read(buffer, 0, 4);
        return BitConverter.ToUInt32(buffer, 0);
    }

    public int ReadSInt32()
    {
        byte[] buffer = new byte[4];
        base.Read(buffer, 0, 4);
        return BitConverter.ToInt32(buffer, 0);
    }

    public UInt16 ReadUInt16()
    {
        byte[] buffer = new byte[2];
        base.Read(buffer, 0, 2);
        return BitConverter.ToUInt16(buffer, 0);
    }

    public Int16 ReadSInt16()
    {
        byte[] buffer = new byte[2];
        base.Read(buffer, 0, 2);
        return BitConverter.ToInt16(buffer, 0);
    }

    public bool ReadBoolean()
    {
        byte[] buffer = new byte[1];
        base.Read(buffer, 0, 1);
        return BitConverter.ToBoolean(buffer, 0);
    }

    public void AlignStreamReader(int alignment)
    {
        long pos = base.Position;
        //long padding = alignment - pos + (pos / alignment) * alignment;
        //if (padding != alignment) { base.Position += padding; }
        if ((pos % alignment) != 0) { base.Position += alignment - (pos % alignment); }
    }
}