using System;
using System.Diagnostics;

namespace LCG
{
    public class MessageBlock
    {
        private byte[] _cache;
        private Int32 _rdPtr;
        private Int32 _wrPtr;

        public MessageBlock()
        {
            //初始2kb容量
            _cache = new byte[1024 * 2];
            _rdPtr = 0;
            _wrPtr = 0;
        }
        /// <summary>
        /// 已写入长度
        /// </summary>
        public Int32 Length
        {
            get
            {
                if (_wrPtr < _rdPtr)
                {
                    return _wrPtr + _cache.Length - _rdPtr;
                }
                else
                {
                    return _wrPtr - _rdPtr;
                }
            }
        }
        /// <summary>
        /// 尚剩余长度
        /// </summary>
        public Int32 Space
        {
            get
            {
                if (_wrPtr < _rdPtr)
                {
                    return _rdPtr - _wrPtr;
                }
                else
                {
                    return _rdPtr + _cache.Length - _wrPtr;
                }
            }
        }
        /// <summary>
        /// 写入
        /// </summary>
        /// <param name="dataBlock"></param>
        /// <param name="dataLen"></param>
        public void Write(byte[] dataBlock ,int dataLen)
        {
            if(dataLen >= Space)
            {
                //扩充容量
                _cache = BufferExpand(Length + dataLen);
            }
            int len = _wrPtr + dataLen - _cache.Length;
            if(len > 0)
            {
                //首尾接
                Array.Copy(dataBlock, 0, _cache, _wrPtr, dataLen - len);
                Array.Copy(dataBlock, dataLen - len, _cache, 0, len);
                _wrPtr = len;
            }
            else
            {
                Array.Copy(dataBlock, 0, _cache, _wrPtr, dataLen);
                _wrPtr += dataLen;
            }
        }   
        /// <summary>
        /// 读取一个字节
        /// </summary>
        /// <returns></returns>
        public byte ReadByte()
        {
            byte cur = _cache[_rdPtr];
            _rdPtr += 1;
            return cur;
        }
        /// <summary>
        /// 读取多个字节
        /// </summary>
        /// <param name="dataLen"></param>
        /// <returns></returns>
        public byte[] ReadBytes(Int32 dataLen)
        {
            if(dataLen > Length)
            {
                UnityEngine.Debug.Log("获取字节长度不够！！");
                return null;
            }
            byte[] stream = new byte[dataLen];

            int len = _rdPtr + dataLen - _cache.Length;
            if (len > 0)
            {
                //首尾接
                Array.Copy(_cache, _rdPtr, stream, 0, dataLen - len);
                Array.Copy(_cache, 0, stream, dataLen - len, len);
                _rdPtr = len;
            }
            else
            {
                Array.Copy(_cache, _rdPtr, stream, 0, dataLen);
                _rdPtr += dataLen;
            }
            return stream;
        }        
        /// <summary>
        /// 设置读取位置
        /// </summary>
        /// <param name="offset"></param>
        /// <returns></returns>
        public Int32 SetReadPtr(Int32 offset)
        {
            _rdPtr += offset;
            Debug.Assert(_rdPtr >= 0 && _rdPtr <= _wrPtr);

            return _rdPtr;
        }
        /// <summary>
        /// 缓冲扩充
        /// </summary>
        private byte[] BufferExpand(int dataLen)
        {
            //2倍容量扩升
            int length = _cache.Length ;
            while (length <= dataLen)
            {
                length *= 2;
            }
            int len = Length;
            byte[] newBuffer = new byte[length];

            if(_wrPtr < _rdPtr)
            {
                Array.Copy(_cache, _rdPtr, newBuffer, 0, _cache.Length - _rdPtr);
                Array.Copy(_cache, 0, newBuffer, _cache.Length - _rdPtr, _wrPtr);
            }
            else if(_wrPtr > _rdPtr)
            {
                Array.Copy(_cache, _rdPtr, newBuffer, 0, len);
            }
            _rdPtr = 0;
            _wrPtr = len;
            return newBuffer;
        }
    }
}
