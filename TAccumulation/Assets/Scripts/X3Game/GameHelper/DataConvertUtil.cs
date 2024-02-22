using System;
using System.IO;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using PapeGames.X3;
using UnityEngine;
using X3Game.Cryptography;
using XLua;
using YamlDotNet.Core.Tokens;

namespace X3Game.FaceEdit
{
    [LuaCallCSharp]
    public static class DataConvertUtil
    {
        static byte[] key = new byte[]
        {
            0x8B, 0x24, 0x5D, 0x3E, 0xF1, 0x77, 0xCD, 0x08, 0x3B, 0x5D, 0x64, 0x2A, 0x47, 0x82, 0x63, 0x59,
            0x1C, 0x14, 0x24, 0x5D, 0xF7, 0x32, 0xBD, 0xCE, 0xC2, 0x22, 0x36, 0xC7, 0xF4, 0x4D, 0x59, 0xFF
        };

        public static string GetSavedString(Byte[] bytes)
        {
            if (bytes == null)
            {
                return "";
            }
            return Convert.ToBase64String(Encrypt(Compress(bytes)));
        }

        public static Byte[] GetRealBytes(string inputString)
        {
            if (string.IsNullOrEmpty(inputString))
            {
                X3Debug.LogError("Get Face LocalData Failed: Empty String");
                return null;
            }

            if (!IsBase64String(inputString))
            {
                X3Debug.LogError("Get Face LocalData Failed: Not Base64");
                return null;
            }
            
            return Decompress(Decrypt(Convert.FromBase64String(inputString)));
        }

        static bool IsBase64String(string base64)
        {
            base64 = base64.Trim();
            return (base64.Length % 4 == 0) && Regex.IsMatch(base64, @"^[a-zA-Z0-9\+/]*={0,3}$", RegexOptions.None);
        }
        static byte[] Encrypt(byte[] textBytes)
        {
            var encrypted = new byte[textBytes.Length];
            for (int i = 0; i < textBytes.Length; i++)
            {
                encrypted[i] = (byte)(textBytes[i] ^ key[i % key.Length]);
            }

            return encrypted;
        }
        
        static byte[] Decrypt(byte[] bytes)
        {
            return Encrypt(bytes);
        }
        
        static byte[] Compress(byte[] bytes)
        {
            using (var memoryStream = new MemoryStream())
            {
                using (var gzipStream = new GZipStream(memoryStream, CompressionMode.Compress))
                {
                    gzipStream.Write(bytes, 0, bytes.Length);
                }
                return memoryStream.ToArray();
            }
        }
        
        static byte[] Decompress(byte[] bytes)
        {
            try
            {
                using (var memoryStream = new MemoryStream(bytes))
                {
                    using (var outputStream = new MemoryStream())
                    {
                        using (var decompressStream = new GZipStream(memoryStream, CompressionMode.Decompress))
                        {
                            decompressStream.CopyTo(outputStream);
                        }
                        return outputStream.ToArray();
                    }
                }
            }
            catch (Exception e)
            {
                LogProxy.LogErrorFormat("Get Face LocalData Failed: Decompress fatal error {0}", e.Message);
            }

            return null;
        }
    }
}