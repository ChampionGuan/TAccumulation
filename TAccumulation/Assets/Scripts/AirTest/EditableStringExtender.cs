using System;
using Unity.Collections.LowLevel.Unsafe;

/// <summary>
/// 修改字符串内容
/// （谨记不要超出字符串原有大小）
/// </summary>
public static class EditableStringExtender
{
    public static string AllocateString(int length)
    {
        string str = new string((char)0, length);
        str.UnsafeClear();
        return str;
    }

    public static unsafe string UnsafeAppend(this string str, char ch)
    {
        return UnsafeInsert(str, str.Length, ch);
    }
    public static unsafe string UnsafeAppend(this string str, char[] chars, int startIndex = 0, int length = -1)
    {
        return UnsafeInsert(str, str.Length, chars, startIndex, length);
    }
    public static unsafe string UnsafeAppend(this string str, string chars, int startIndex = 0, int length = -1)
    {
        return UnsafeInsert(str, str.Length, chars, startIndex, length);
    }
    public static unsafe string UnsafeAppend(this string str, long num)
    {
        return UnsafeInsert(str, str.Length, num);
    }

    public static unsafe string UnsafeInsert(this string str, int index, char ch)
    {
        return UnsafeInsert(str, index, &ch, 1);
    }
    public static unsafe string UnsafeInsert(this string str, int index, char[] chars, int startIndex = 0, int length = -1)
    {
        if (length == -1)
            length = chars.Length;
        fixed (char* ptr = chars)
        {
            UnsafeInsert(str, index, ptr + startIndex, length);
        }

        return str;
    }
    public static unsafe string UnsafeInsert(this string str, int index, string chars, int startIndex = 0, int length = -1)
    {
        if (length == -1)
            length = chars.Length;
        fixed (char* ptr = chars)
        {
            UnsafeInsert(str, index, ptr + startIndex, length);
        }

        return str;
    }

    public static unsafe string UnsafeInsert(this string str, int index, char* v, int length)
    {
        fixed (char* ptr = str)
        {
            char* cptr = ptr + index;
            StringCopy(cptr, cptr + length, str.Length + 1 - index);

            for (int i = 0; i < length; i++)
                *(cptr + i) = *(v + i);

            int* iptr = (int*)ptr - 1;
            *iptr = *iptr + length;
        }

        return str;
    }

    public static unsafe string UnsafeAppend(this string str, float value, int length = 2)
    {
        int len = (int)Math.Pow(10.0f, length);
        long big = (long)value;
        long small = Math.Abs(((long)(value * len) - big * len));
        str.UnsafeAppend(big);
        str.UnsafeAppend('.');
        int smallLen = 0;
        long num = small;
        while (num > 0)
        {
            num /= 10;
            smallLen++;
        }

        for (int i = 0, imax = length - smallLen; i < imax; i++)
        {
            str.UnsafeAppend(0);
        }

        str.UnsafeAppend(small);

        return str;
    }
    
    public static unsafe string UnsafeInsert(this string str, int index, long num)
    {
        int length;
        LongToChars(num, out length);
        return UnsafeInsert(str, index, charCache, charCache.Length - length, length);
    }

    public static unsafe void UnsafeClear(this string str)
    {
        fixed (char* ptr = str)
        {
            int* iptr = (int*)ptr - 1;
            UnsafeUtility.MemClear(ptr, sizeof(char) * (*iptr));
            *iptr = 0;
        }
    }

    public static unsafe void UnsafeRemove(this string str, int index = 0, int length = -1)
    {
        int strLength = str.Length;
        if (index >= strLength)
            return;

        int maxLength = strLength - index;
        if (length > maxLength || length == -1)
            length = maxLength;

        int endIndex = index + length;
        fixed (char* ptr = str)
        {
            StringCopy(ptr, ptr - length, strLength + 1 - endIndex);
            
            int* iptr = (int*)ptr - 1;
            *iptr = *iptr - length;
        }
    }

    //unsafe delegate void MemCpyImpl(byte* src, byte* dest, int len);
    //static MemCpyImpl memcpyimpl = (MemCpyImpl)Delegate.CreateDelegate(typeof(MemCpyImpl), typeof(Buffer).GetMethod("Memmove", BindingFlags.Static | BindingFlags.NonPublic));

    //本想调用memcpy一类方法利用SIMD来快速复制数据，但系统没给正常的方法，可用的接口都是internal的，不同版本可能不一致。反正不在乎性能就先用普通的循环吧。
    static unsafe void StringCopy(char* src, char* dest, int len)
    {
        UnsafeUtility.MemCpy((void*)dest,(void*)src,  sizeof(char) * len);
        // if (dest < src)
        // {
        //     for (int i = 0; i < len; i++)
        //     {
        //         *(dest + i) = *(src + i);
        //     }
        // }
        // else
        // {
        //     for (int i = len - 1; i >= 0; i--)
        //     {
        //         *(dest + i) = *(src + i);
        //     }
        // }
    }

    static char[] charCache = new char[20];
    static void LongToChars(long num, out int length)
    {
        if (num == 0)
        {
            length = 1;
            charCache[charCache.Length - 1] = (char)(0x30);
            return;
        }

        bool isMinus = false;
        if (num < 0)
        {
            isMinus = true;
            num = -num;
        }

        int i = 0;
        int endIndex = charCache.Length - 1;
        while (num > 0)
        {
            charCache[endIndex - i] = (char)(0x30 + num % 10);
            num /= 10;
            i++;
        }

        if (isMinus)
        {
            charCache[endIndex - i] = '-';
            i++;
        }

        length = i;
    }
}