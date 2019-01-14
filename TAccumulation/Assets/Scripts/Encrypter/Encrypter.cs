using System;
using System.Security.Cryptography;
using System.IO;
using System.Text;
using UnityEngine;

//  加密方式          加密向量       是否可逆
//  MD5、SHA          不需要         不可逆
//  RSA               不需要         可逆
//  AES、DES           需要          可逆

#region md5
public static class MD5Encrypter
{
    public static string BuildFileMD5(string filePath)
    {
        StringBuilder sb = new StringBuilder();
        using (FileStream fs = new FileStream(filePath, FileMode.Open))
        {
            MD5 md5 = MD5.Create();
            byte[] hash = md5.ComputeHash(fs);
            foreach (byte b in hash)
            {
                sb.Append(b.ToString("x2"));
            }
        }

        return sb.ToString();
    }
    public static string BuildStringMD5(string value)
    {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] data = Encoding.UTF8.GetBytes(value);
        byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
        md5.Clear();

        string destString = "";
        for (int i = 0; i < md5Data.Length; i++)
        {
            destString += Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
        }
        destString = destString.PadLeft(32, '0');
        return destString;
    }
}
#endregion

#region sha
public static class SHAEncrypter
{
    public static string SHA1Encrypt(string normalTxt)
    {
        var bytes = Encoding.Default.GetBytes(normalTxt);
        var SHA = new SHA1CryptoServiceProvider();
        var encryptbytes = SHA.ComputeHash(bytes);
        return Convert.ToBase64String(encryptbytes);
    }
    //public static string SHA256Encrypt(string normalTxt)
    //{
    //    var bytes = Encoding.Default.GetBytes(normalTxt);
    //    var SHA256 = new SHA256CryptoServiceProvider();
    //    var encryptbytes = SHA256.ComputeHash(bytes);
    //    return Convert.ToBase64String(encryptbytes);
    //}
    //public static string SHA384Encrypt(string normalTxt)
    //{
    //    var bytes = Encoding.Default.GetBytes(normalTxt);
    //    var SHA384 = new SHA384CryptoServiceProvider();
    //    var encryptbytes = SHA384.ComputeHash(bytes);
    //    return Convert.ToBase64String(encryptbytes);
    //}
    //public static string SHA512Encrypt(string normalTxt)
    //{
    //    var bytes = Encoding.Default.GetBytes(normalTxt);
    //    var SHA512 = new SHA512CryptoServiceProvider();
    //    var encryptbytes = SHA512.ComputeHash(bytes);
    //    return Convert.ToBase64String(encryptbytes);
    //}
}
#endregion

#region rsa
public static class RSAEncrypter
{
    /// <summary>
    /// RSA加密
    /// </summary>
    /// <param name="plaintext">明文</param>
    /// <param name="publicKey">公钥</param>
    /// <returns>密文字符串</returns>
    public static string Encrypt(string plaintext, string publicKey)
    {
        UnicodeEncoding ByteConverter = new UnicodeEncoding();
        byte[] dataToEncrypt = ByteConverter.GetBytes(plaintext);
        using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
        {
            RSA.FromXmlString(publicKey);
            byte[] encryptedData = RSA.Encrypt(dataToEncrypt, false);
            return Convert.ToBase64String(encryptedData);
        }
    }
    /// <summary>
    /// RSA解密
    /// </summary>
    /// <param name="ciphertext">密文</param>
    /// <param name="privateKey">私钥</param>
    /// <returns>明文字符串</returns>
    public static string Decrypt(string ciphertext, string privateKey)
    {
        UnicodeEncoding byteConverter = new UnicodeEncoding();
        using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
        {
            RSA.FromXmlString(privateKey);
            byte[] encryptedData = Convert.FromBase64String(ciphertext);
            byte[] decryptedData = RSA.Decrypt(encryptedData, false);
            return byteConverter.GetString(decryptedData);
        }
    }
    /// <summary>
    /// 数字签名
    /// </summary>
    /// <param name="plaintext">原文</param>
    /// <param name="privateKey">私钥</param>
    /// <returns>签名</returns>
    public static string BuildSign(string plaintext, string privateKey)
    {
        UnicodeEncoding ByteConverter = new UnicodeEncoding();
        byte[] dataToEncrypt = ByteConverter.GetBytes(plaintext);

        using (RSACryptoServiceProvider RSAalg = new RSACryptoServiceProvider())
        {
            RSAalg.FromXmlString(privateKey);
            //使用SHA1进行摘要算法，生成签名
            byte[] encryptedData = RSAalg.SignData(dataToEncrypt, new SHA1CryptoServiceProvider());
            return Convert.ToBase64String(encryptedData);
        }
    }
    /// <summary>
    /// 验证签名
    /// </summary>
    /// <param name="plaintext">原文</param>
    /// <param name="SignedData">签名</param>
    /// <param name="publicKey">公钥</param>
    /// <returns></returns>
    public static bool VerifySigned(string plaintext, string SignedData, string publicKey)
    {
        using (RSACryptoServiceProvider RSAalg = new RSACryptoServiceProvider())
        {
            RSAalg.FromXmlString(publicKey);
            UnicodeEncoding ByteConverter = new UnicodeEncoding();
            byte[] dataToVerifyBytes = ByteConverter.GetBytes(plaintext);
            byte[] signedDataBytes = Convert.FromBase64String(SignedData);
            return RSAalg.VerifyData(dataToVerifyBytes, new SHA1CryptoServiceProvider(), signedDataBytes);
        }
    }
}
#endregion

#region aes
public static class AESEncrypter
{
    //key就是自定义加密key，自己定义的简单串；
    //iv是initialization vector的意思，就是加密的初始话矢量，初始化加密函数的变量
    //默认密钥向量
    public static byte[] IV = { 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF };

    /// <summary>
    /// 加密
    /// </summary>
    /// <param name="normalTxt">明文</param>
    /// <param name="key">加密字符串16位</param>
    /// <returns>密文字符串</returns>
    public static string Encrypt(string normalTxt, string key)
    {
        var bytes = Encoding.Default.GetBytes(normalTxt);
        SymmetricAlgorithm des = Rijndael.Create();
        des.Key = Encoding.Default.GetBytes(key);
        des.IV = IV;
        using (MemoryStream ms = new MemoryStream())
        {
            CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(), CryptoStreamMode.Write);
            cs.Write(bytes, 0, bytes.Length);
            cs.FlushFinalBlock();
            return Convert.ToBase64String(ms.ToArray());
        }
    }
    /// <summary>
    /// 解密
    /// </summary>
    /// <param name="securityTxt">密文</param>
    /// <param name="key">加密字符串16位</param>
    /// <returns>明文字符串</returns>
    public static string Decrypt(string securityTxt, string key)
    {
        try
        {
            var bytes = Convert.FromBase64String(securityTxt);
            SymmetricAlgorithm des = Rijndael.Create();
            des.Key = Encoding.Default.GetBytes(key);
            des.IV = IV;
            using (MemoryStream ms = new MemoryStream())
            {
                CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(), CryptoStreamMode.Write);
                cs.Write(bytes, 0, bytes.Length);
                cs.FlushFinalBlock();
                return Convert.ToBase64String(ms.ToArray());
            }
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }
}
#endregion

#region des
public static class DESEncrypter
{
    //key就是自定义加密key，自己定义的简单串；
    //iv是initialization vector的意思，就是加密的初始话矢量，初始化加密函数的变量
    //默认密钥向量,8位就好了
    public static byte[] IV = { 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF };

    /// <summary>
    /// 加密
    /// </summary>
    /// <param name="normalTxt">明文</param>
    /// <param name="encryptKey">加密字符串8位</param>
    /// <returns>密文字符串</returns>
    public static string Encrypt(string normalTxt, string encryptKey)
    {
        var bytes = Encoding.Default.GetBytes(normalTxt);
        var key = Encoding.UTF8.GetBytes(encryptKey.PadLeft(8, '0').Substring(0, 8));
        using (MemoryStream ms = new MemoryStream())
        {
            var encry = new DESCryptoServiceProvider();
            CryptoStream cs = new CryptoStream(ms, encry.CreateEncryptor(key, IV), CryptoStreamMode.Write);
            cs.Write(bytes, 0, bytes.Length);
            cs.FlushFinalBlock();
            return Convert.ToBase64String(ms.ToArray());
        }
    }
    /// <summary>
    /// 解密
    /// </summary>
    /// <param name="securityTxt">密文</param>
    /// <param name="encryptKey">加密字符串</param>
    /// <returns>明文字符串</returns>
    public static string Decrypt(string securityTxt, string encryptKey)
    {
        try
        {
            var bytes = Convert.FromBase64String(securityTxt);
            var key = Encoding.UTF8.GetBytes(encryptKey.PadLeft(8, '0').Substring(0, 8));
            using (MemoryStream ms = new MemoryStream())
            {
                var descrypt = new DESCryptoServiceProvider();
                CryptoStream cs = new CryptoStream(ms, descrypt.CreateDecryptor(key, IV), CryptoStreamMode.Write);
                cs.Write(bytes, 0, bytes.Length);
                cs.FlushFinalBlock();
                return Encoding.UTF8.GetString(ms.ToArray());
            }

        }
        catch (Exception)
        {
            return string.Empty;
        }
    }
}
#endregion

public class Encrypter : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {
        string txt = "txtbuild";
        string key = "smkdd";
        // md5
        Debug.Log(MD5Encrypter.BuildStringMD5(txt));
        // sha1
        Debug.Log(SHAEncrypter.SHA1Encrypt(txt));
        // des
        string desTxt = DESEncrypter.Encrypt(txt, key);
        Debug.Log(desTxt);
        Debug.Log(DESEncrypter.Decrypt(desTxt, key) == txt);
    }

    // Update is called once per frame
    void Update()
    {

    }
}
