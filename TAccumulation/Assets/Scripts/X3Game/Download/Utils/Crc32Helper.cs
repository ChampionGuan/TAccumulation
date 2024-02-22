using System;

namespace X3Game.Download
{
    public static class Crc32Helper
    {
        //Polynomial Representations Reversed
        private const uint Poly = 0xedb88320u;
        //Polynomial Representations Reversed reciprocal
        //private const uint Poly = 0x82F63B78u;
        
        private static readonly uint[] s_table = new uint[16 * 256];
        
        static Crc32Helper()
        {
            for (uint i = 0; i < 256; i++)
            {
                uint res = i;
                for (int t = 0; t < 16; t++)
                {
                    for (int k = 0; k < 8; k++) res = (res & 1) == 1 ? Poly ^ (res >> 1) : (res >> 1);
                    s_table[(t * 256) + i] = res;
                }
            }
        }
        
        /// <summary>
        /// Computes CRC-32C from multiple buffers.
        /// Call this method multiple times to chain multiple buffers.
        /// </summary>
        /// <param name="initialCrc">
        /// Initial CRC value for the algorithm. It is zero for the first buffer.
        /// Subsequent buffers should have their initial value set to CRC value returned by previous call to this method.
        /// </param>
        /// <param name="input">Input buffer containing data to be checksummed.</param>
        /// <returns>Accumulated CRC-32C of all buffers processed so far.</returns>
        public static uint Append(uint initialCrc, byte[] input)
        {
            if (input == null)
                throw new ArgumentNullException("input");
            return Append(initialCrc, input, 0, input.Length);
        }
        
        /// <summary>
        /// Computes CRC-32 from multiple buffers.
        /// Call this method multiple times to chain multiple buffers.
        /// </summary>
        /// <param name="initialCrc">
        /// Initial CRC value for the algorithm. It is zero for the first buffer.
        /// Subsequent buffers should have their initial value set to CRC value returned by previous call to this method.
        /// </param>
        /// <param name="input">Input buffer with data to be checksummed.</param>
        /// <param name="offset">Offset of the input data within the buffer.</param>
        /// <param name="length">Length of the input data in the buffer.</param>
        /// <returns>Accumulated CRC-32C of all buffers processed so far.</returns>
        public static uint Append(uint initialCrc, byte[] input, int offset, int length)
        {
            if (input == null)
                throw new ArgumentNullException("input");
            if (offset < 0 || length < 0 || offset + length > input.Length)
                throw new ArgumentOutOfRangeException("length");
            
            if (length == 0)
                return initialCrc;
            
            uint crcLocal = uint.MaxValue ^ initialCrc;

            uint[] table = s_table;
            while (length >= 16)
            {
                var a = table[(3 * 256) + input[offset + 12]]
                        ^ table[(2 * 256) + input[offset + 13]]
                        ^ table[(1 * 256) + input[offset + 14]]
                        ^ table[(0 * 256) + input[offset + 15]];

                var b = table[(7 * 256) + input[offset + 8]]
                        ^ table[(6 * 256) + input[offset + 9]]
                        ^ table[(5 * 256) + input[offset + 10]]
                        ^ table[(4 * 256) + input[offset + 11]];

                var c = table[(11 * 256) + input[offset + 4]] 
                        ^ table[(10 * 256) + input[offset + 5]] 
                        ^ table[(9 * 256) + input[offset + 6]] 
                        ^ table[(8 * 256) + input[offset + 7]];

                var d = table[(15 * 256) + ((crcLocal ^ input[offset]) & 0xff)]
                        ^ table[(14 * 256) + (((crcLocal >> 8) ^ input[offset + 1]) & 0xff)]
                        ^ table[(13 * 256) + (((crcLocal >> 16) ^ input[offset + 2]) & 0xff)]
                        ^ table[(12 * 256) + (((crcLocal >> 24) ^ input[offset + 3]) & 0xff)];

                crcLocal = d ^ c ^ b ^ a;
                offset += 16;
                length -= 16;
            }

            while (--length >= 0)
                crcLocal = table[(crcLocal ^ input[offset++]) & 0xff] ^ crcLocal >> 8;

            return crcLocal ^ uint.MaxValue;
        }
    }
}


