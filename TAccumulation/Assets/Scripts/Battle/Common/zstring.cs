using System;
using System.Collections.Generic;
using Unity.Collections.LowLevel.Unsafe;

/*
 介绍：
    C# 0GC字符串补充方案。结合gstring与CString两者特点（向这两个方案的作者致敬），只有一个文件，性能与使用方便性高于两者。

 报告地址：
    https://coh5.cn/p/1ace6338.html

 使用方式：
    1.Unity引擎将zstring.cs文件放于plugins目录下即可使用（不在plugins目录，则IOS打包或IL2CPP打包等FULLAOT方式编译不过），或者直接把结构体定义放入zstring类中；其余C#程序将zstring.cs直接放入工程使用即可。

    2.（最佳性能）当update每帧刷新标签显示，或者大量UI飘字，或者该字符串是短时间使用的则使用如下方式：
        using (zstring.Block())
        {
            uiText1.text=(zstring)"hello world"+" you";
            uiText2.text=zstring.format("{0},{1}","hello","world");
        }
        此方式设置的string值位于浅拷贝缓存中，一定时间可能会改变,出作用域后正确性不予保证。

     3.资源路径这种需要常驻的则需要intern一下在作用域外使用

         using (zstring.Block())
        {
            zstring a="Assets/";
            zstring b=a+"prefabs/"+"/solider.prefab";
            prefabPath1=b.Intern();

            prefabPath2=zstring.format("{0},{1}","hello","world").Intern();
        }
        此方式设置的string值位于深拷贝缓存中，游戏运行期间不会改变，可以在作用域外使用。

    4.不可使用zstring作为类的成员变量，不建议在using作用域中写for循环，而是在for循环内using。

    5.首次调用时会初始化类，分配各种空间，建议游戏启动时调用一次using(zstring.Block()){}

    6.0GC。时间消耗上，短字符串处理，zstring比gstring时间少20%~30%，比原生慢。大字符串处理，zstring比gstring时间少70%~80%，接近原生string速度。

    7.追求极限性能的话，核心函数可以用C++Dll中的 memcpy内存拷贝函数，性能提升10%~20%，一般没这个必要。

    10.有事请联系 871041532@outlook.com 或 QQ(微信)：871041532
 */
namespace X3Battle
{
    public class zstring
    {
        static Queue<zstring>[] g_cache;  //idx特定字符串长度,深拷贝核心缓存
        static Dictionary<int, Queue<zstring>> g_secCache;  //key特定字符串长度value字符串栈，深拷贝次级缓存
        static Stack<zstring> g_shallowCache;  //浅拷贝缓存

        static Stack<zstring_block> g_blocks;  //zstring_block缓存栈
        static Stack<zstring_block> g_open_blocks;  //zstring已经打开的缓存栈      
        
        static Dictionary<int, string> g_intern_table;  //字符串intern表
        static Queue<string>[] g_intern_preload_strs;  // Intern预加载待用的字符串
        static Dictionary<int, Queue<string>> g_intern_sec_preload;  // Intern预加载待用二级缓存
            
        static zstring_block g_current_block;//zstring所在的block块
        static List<int> g_finds;//字符串replace功能记录子串位置
        static List<zstring> g_format_args;//存储格式化字符串值

        const int DEFAULT_FORMAT_ARGS_NUM = 16;  // 默认字符串参数数组长度
        const int INITIAL_CACHE_CAPACITY = 24;  // 浅拷贝字符串最大长度
        const int INITIAL_STACK_CAPACITY = 16;  // 浅拷贝每种字符串长度对应数量

        const int INTERN_PRELOAD_LENGTH = 16;  // intern表预加多少长度的串
        const int INTERN_PRELOAD_CAPACITY = 64;  // intern表每种长度的串预加载多少个
        
        const int INITIAL_INTERN_CAPACITY = 512;  // Internr容器初始容量
        
        const int INITIAL_BLOCK_CAPACITY = 8;  // gblock块数量  
        const int INITIAL_OPEN_CAPACITY = 5;  // 默认打开层数为5
        const int INITIAL_SHALLOW_CAPACITY = 64;  // 默认50个浅拷贝用
        const char NEW_ALLOC_CHAR = 'X';  // 填充char
        
        private bool isShallow = false;  //是否浅拷贝
        [NonSerialized]
        string _value;//值
        [NonSerialized]
        bool _disposed;//销毁标记

        public static bool isInit { get; private set; }

        // 初始化
        public static void Init()
        {
            if (isInit)
            {
                return;
            }
            isInit = true;
            
            Initialize(INITIAL_CACHE_CAPACITY,
                INITIAL_STACK_CAPACITY,
                INITIAL_BLOCK_CAPACITY,
                INITIAL_INTERN_CAPACITY,
                INITIAL_OPEN_CAPACITY,
                INITIAL_SHALLOW_CAPACITY
            );
            g_finds = new List<int>(10);
            g_format_args = new List<zstring>(DEFAULT_FORMAT_ARGS_NUM);
            for (int i = 0; i < DEFAULT_FORMAT_ARGS_NUM; i++)
            {
                g_format_args.Add(null);
            }
        }

        // 卸载
        public static void UnInit()
        {
            if (!isInit)
            {
                return;
            }
            isInit = false;
            
            g_cache = null;
            g_secCache = null;
            g_shallowCache = null;

            g_blocks = null;
            g_open_blocks = null;
            g_intern_table = null;
            g_current_block = null;
            g_finds = null;
            g_format_args = null;
            g_intern_preload_strs = null;
            g_intern_sec_preload = null;
        }

        // 外面的字符串还给preload缓存，用于复用
        private static void _Release2Preload(string strs)
        {
            var length = strs.Length;
            
            if (length < g_intern_preload_strs.Length)
            {
                var stack = g_intern_preload_strs[length];
                stack.Enqueue(strs);
            }
            else
            {
                g_intern_sec_preload.TryGetValue(length, out var queue);
                if (queue == null)
                {
                    queue = new Queue<string>(INTERN_PRELOAD_CAPACITY);
                    g_intern_sec_preload.Add(length, queue);
                }
                queue.Enqueue(strs);
            }
        }
        
        //不支持构造
        private zstring()
        {
            throw new NotSupportedException();
        }
        
        //带默认长度的构造
        private zstring(int length)
        {
            _value = new string(NEW_ALLOC_CHAR, length);
        }
        //浅拷贝专用构造
        private zstring(string value, bool shallow)
        {
            if (!shallow)
            {
                throw new NotSupportedException();
            }
            _value = value;
            isShallow = true;
        }

        //析构
        private void dispose()
        {
            if (_disposed)
                throw new ObjectDisposedException(this);

            if (isShallow)//深浅拷贝走不同缓存
            {
                g_shallowCache.Push(this);
            }
            else
            {
                Queue<zstring> stack;
                if (g_cache.Length > Length)
                {
                    stack = g_cache[Length];//取出valuelength长度的栈，将自身push进去
                }
                else
                {
                    stack = g_secCache[Length];
                }
                stack.Enqueue(this);
            }
            //memcpy(_value, NEW_ALLOC_CHAR);//内存拷贝至value
            _disposed = true;
        }

        //由string获取相同内容zstring，深拷贝
        private static zstring get(string value)
        {
            if (value == null)
                return null;
#if DBG
            if (log != null)
                log("Getting: " + value);
#endif
            var result = get(value.Length);
            memcpy(dst: result, src: value);//内存拷贝
            return result;
        }
        //由string浅拷贝入zstring
        private static zstring getShallow(string value)
        {
            if (g_current_block == null)
            {
                throw new InvalidOperationException("nstring 操作必须在一个nstring_block块中。");
            }
            zstring result;
            if (g_shallowCache.Count == 0)
            {
                result = new zstring(value, true);
            }
            else
            {
                result = g_shallowCache.Pop();
                result._value = value;
            }
            result._disposed = false;
            g_current_block.push(result);//zstring推入块所在栈
            return result;
        }
        
        // 深拷贝
        public string DeepToString()
        {
            return _DeepCopy(_value);
        }

        private static string _DeepCopy(string value)
        {
            string returnValue = null;
            var length = value.Length;
                
            // 先从池中取
            if (length < INTERN_PRELOAD_LENGTH)
            {
                // 从一级缓存中取
                var stack = g_intern_preload_strs[length];
                if (stack.Count > 0)
                {
                    returnValue = stack.Dequeue();
                }
            }
            else
            {
                // 从二级缓存中取
                g_intern_sec_preload.TryGetValue(length, out var queue);
                if (queue != null && queue.Count > 0)
                {
                    returnValue = queue.Dequeue();
                }
            }
                
            // 池中没有，新建一个
            if (returnValue == null)
            {
                returnValue =  new string(NEW_ALLOC_CHAR, length);  
            }
            memcpy(returnValue, value);
            
            return returnValue;  
        }

        /// <summary>
        /// 将string加入intern表中, 如果存在则直接返回，不存在深拷贝一份存入再返回
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        private static string _CopyIntern(string value)
        {
            int hash = value.GetHashCode();
            if (g_intern_table.ContainsKey(hash))
            {
                return g_intern_table[hash];
            }
            else
            {
                string interned = _DeepCopy(value);
                g_intern_table.Add(hash, interned);
                return interned;
            }
        }
        
        //手动添加方法
        private static void getStackInCache(int index, out Queue<zstring> outStack)
        {
            int length = g_cache.Length;
            if (length > index)//从核心缓存中取
            {
                outStack = g_cache[index];
            }
            else//从次级缓存中取
            {
                if (!g_secCache.TryGetValue(index, out outStack))
                {
                    outStack = new Queue<zstring>(INITIAL_STACK_CAPACITY);
                    g_secCache[index] = outStack;
                }
            }
        }
        //获取特定长度zstring
        private static zstring get(int length)
        {
            if (g_current_block == null || length <= 0)
                throw new InvalidOperationException("zstring 操作必须在一个zstring_block块中。");

            zstring result;
            Queue<zstring> stack;
            getStackInCache(length, out stack);
            //从缓存中取Stack
            if (stack.Count == 0)
            {
                result = new zstring(length);
            }
            else
            {
                result = stack.Dequeue();
            }
            result._disposed = false;
            g_current_block.push(result);//zstring推入块所在栈
            return result;
        }

        //value是10的次方数
        private static int get_digit_count(long value)
        {
            int cnt;
            for (cnt = 1; (value /= 10) > 0; cnt++) ;
            return cnt;
        }

        //value是10的次方数
        private static uint get_digit_count(uint value)
        {
            uint cnt;
            for (cnt = 1; (value /= 10) > 0; cnt++) ;
            return cnt;
        }

        //value是10的次方数
        private static int get_digit_count(int value)
        {
            int cnt;
            for (cnt = 1; (value /= 10) > 0; cnt++) ;
            return cnt;
        }

        //获取char在input中start起往后的下标
        private static int internal_index_of(string input, char value, int start)
        {
            return internal_index_of(input, value, start, input.Length - start);
        }
        //获取string在input中起始0的下标
        private static int internal_index_of(string input, string value)
        {
            return internal_index_of(input, value, 0, input.Length);
        }
        //获取string在input中自0起始下标
        private static int internal_index_of(string input, string value, int start)
        {
            return internal_index_of(input, value, start, input.Length - start);
        }
        //获取格式化字符串
        private unsafe static zstring internal_format(string input, int num_args)
        {
            if (input == null)
                throw new ArgumentNullException("value");

            // 新字符串长度
            int resultLen = input.Length;
            int searchIndex = 0;
            for (int i = 0; i < num_args; i++)
            {
                searchIndex = internal_index_of(input, '{', searchIndex);
                if (searchIndex == -1)
                {
                    if (i < num_args - 1)
                    {
                        throw new Exception("zstring.Format, 格式化参数数量与花括号数量不匹配！请检查参数");
                    }
                    break;
                }
                
                var formatLen = i < 10 ? 3 : 4;
                searchIndex += formatLen;
                resultLen -= formatLen;
                zstring arg = g_format_args[i];
                resultLen += arg.Length;
            }
            
            // 从缓存池中取一个字符串
            zstring result = get(resultLen);
            string resultValue = result._value;
            
            // 拷贝值
            searchIndex = 0;
            int inputIndex = 0;
            int resultIndex = 0;
            for (int argIndex = 0; argIndex < num_args; argIndex++)
            {
                searchIndex = internal_index_of(input, '{', searchIndex);
                if (searchIndex == -1)
                {
                    break;
                }
                
                string arg = g_format_args[argIndex]._value;
                
                fixed (char* ptrResult = resultValue)
                {
                    for (int i = inputIndex; i < searchIndex; i++)
                    {
                        ptrResult[resultIndex++] = input[inputIndex++];
                    }

                    for (int i = 0; i < arg.Length; i++)
                    {
                        ptrResult[resultIndex++] = arg[i];
                    }
                }
                
                var formatLen = argIndex < 10 ? 3 : 4;
                inputIndex += formatLen;
                searchIndex += formatLen;
            }

            fixed (char* ptrResult = resultValue)
            {
                for (int i = inputIndex; i < input.Length; i++)
                {
                    ptrResult[resultIndex++] = input[i];
                }  
            }

            return result;
        }

        //获取char在字符串中start开始的下标
        private unsafe static int internal_index_of(string input, char value, int start, int count)
        {
            if (start < 0 || start >= input.Length)
                // throw new ArgumentOutOfRangeException("start");
                return -1;

            if (start + count > input.Length)
                return -1;
            // throw new ArgumentOutOfRangeException("count=" + count + " start+count=" + start + count);

            fixed (char* ptr_this = input)
            {
                int end = start + count;
                for (int i = start; i < end; i++)
                    if (ptr_this[i] == value)
                        return i;
                return -1;
            }
        }
        //获取value在input中自start起始下标
        private unsafe static int internal_index_of(string input, string value, int start, int count)
        {
            int input_len = input.Length;

            if (start < 0 || start >= input_len)
                throw new ArgumentOutOfRangeException("start");

            if (count < 0 || start + count > input_len)
                throw new ArgumentOutOfRangeException("count=" + count + " start+count=" + (start + count));

            if (count == 0)
                return -1;

            fixed (char* ptr_input = input)
            {
                fixed (char* ptr_value = value)
                {
                    int found = 0;
                    int end = start + count;
                    for (int i = start; i < end; i++)
                    {
                        for (int j = 0; j < value.Length && i + j < input_len; j++)
                        {
                            if (ptr_input[i + j] == ptr_value[j])
                            {
                                found++;
                                if (found == value.Length)
                                    return i;
                                continue;
                            }
                            if (found > 0)
                                break;
                        }
                    }
                    return -1;
                }
            }
        }
        //移除string中自start起始count长度子串
        private unsafe static zstring internal_remove(string input, int start, int count)
        {
            if (start < 0 || start >= input.Length)
                throw new ArgumentOutOfRangeException("start=" + start + " Length=" + input.Length);

            if (count < 0 || start + count > input.Length)
                throw new ArgumentOutOfRangeException("count=" + count + " start+count=" + (start + count) + " Length=" + input.Length);

            if (count == 0)
                return input;

            zstring result = get(input.Length - count);
            internal_remove(result, input, start, count);
            return result;
        }
        //将src中自start起count长度子串复制入dst
        private unsafe static void internal_remove(string dst, string src, int start, int count)
        {
            fixed (char* src_ptr = src)
            {
                fixed (char* dst_ptr = dst)
                {
                    for (int i = 0, j = 0; i < dst.Length; i++)
                    {
                        if (i >= start && i < start + count) // within removal range
                            continue;
                        dst_ptr[j++] = src_ptr[i];
                    }
                }
            }
        }
        //字符串replace，原字符串，需替换子串，替换的新子串
        private unsafe static zstring internal_replace(string value, string old_value, string new_value)
        {
            // "Hello, World. There World" | World->Jon =
            // "000000000000000000000" (len = orig - 2 * (world-jon) = orig - 4
            // "Hello, 00000000000000"
            // "Hello, Jon00000000000"
            // "Hello, Jon. There 000"
            // "Hello, Jon. There Jon"

            // "Hello, World. There World" | World->Alexander =
            // "000000000000000000000000000000000" (len = orig + 2 * (alexander-world) = orig + 8
            // "Hello, 00000000000000000000000000"
            // "Hello, Alexander00000000000000000"
            // "Hello, Alexander. There 000000000"
            // "Hello, Alexander. There Alexander"

            if (old_value == null)
                throw new ArgumentNullException("old_value");

            if (new_value == null)
                throw new ArgumentNullException("new_value");

            int idx = internal_index_of(value, old_value);
            if (idx == -1)
                return value;

            g_finds.Clear();
            g_finds.Add(idx);

            // 记录所有需要替换的idx点
            while (idx + old_value.Length < value.Length)
            {
                idx = internal_index_of(value, old_value, idx + old_value.Length);
                if (idx == -1)
                    break;
                g_finds.Add(idx);
            }

            // calc the right new total length
            int new_len;
            int dif = old_value.Length - new_value.Length;
            if (dif > 0)
                new_len = value.Length - (g_finds.Count * dif);
            else
                new_len = value.Length + (g_finds.Count * -dif);

            zstring result = get(new_len);
            fixed (char* ptr_this = value)
            {
                fixed (char* ptr_result = result._value)
                {
                    for (int i = 0, x = 0, j = 0; i < new_len;)
                    {
                        if (x == g_finds.Count || g_finds[x] != j)
                        {
                            ptr_result[i++] = ptr_this[j++];
                        }
                        else
                        {
                            for (int n = 0; n < new_value.Length; n++)
                                ptr_result[i + n] = new_value[n];

                            x++;
                            i += new_value.Length;
                            j += old_value.Length;
                        }
                    }
                }
            }
            return result;
        }
        //向字符串value中自start位置插入count长度的to_insertChar
        private unsafe static zstring internal_insert(string value, char to_insert, int start, int count)
        {
            // "HelloWorld" (to_insert=x, start=5, count=3) -> "HelloxxxWorld"

            if (start < 0 || start >= value.Length)
                throw new ArgumentOutOfRangeException("start=" + start + " Length=" + value.Length);

            if (count < 0)
                throw new ArgumentOutOfRangeException("count=" + count);

            if (count == 0)
                return get(value);

            int new_len = value.Length + count;
            zstring result = get(new_len);
            fixed (char* ptr_value = value)
            {
                fixed (char* ptr_result = result._value)
                {
                    for (int i = 0, j = 0; i < new_len; i++)
                    {
                        if (i >= start && i < start + count)
                            ptr_result[i] = to_insert;
                        else
                            ptr_result[i] = ptr_value[j++];
                    }
                }
            }
            return result;
        }
        //向input字符串中插入to_insert串，位置为start
        private unsafe static zstring internal_insert(string input, string to_insert, int start)
        {
            if (input == null)
                throw new ArgumentNullException("input");

            if (to_insert == null)
                throw new ArgumentNullException("to_insert");

            if (start < 0 || start >= input.Length)
                throw new ArgumentOutOfRangeException("start=" + start + " Length=" + input.Length);

            if (to_insert.Length == 0)
                return get(input);

            int new_len = input.Length + to_insert.Length;
            zstring result = get(new_len);
            internal_insert(result, input, to_insert, start);
            return result;
        }
        
        //字符串拼接
        private unsafe static zstring internal_concat(string s1, string s2)
        {
            int total_length = s1.Length + s2.Length;
            zstring result = get(total_length);
            fixed (char* ptr_result = result._value)
            {
                fixed (char* ptr_s1 = s1)
                {
                    fixed (char* ptr_s2 = s2)
                    {
                        memcpy(dst: ptr_result, src: ptr_s1, length: s1.Length, src_offset: 0);
                        memcpy(dst: ptr_result, src: ptr_s2, length: s2.Length, src_offset: s1.Length);
                    }
                }
            }
            return result;
        }
        //将to_insert串插入src的start位置，内容写入dst
        private unsafe static void internal_insert(string dst, string src, string to_insert, int start)
        {
            fixed (char* ptr_src = src)
            {
                fixed (char* ptr_dst = dst)
                {
                    fixed (char* ptr_to_insert = to_insert)
                    {
                        for (int i = 0, j = 0, k = 0; i < dst.Length; i++)
                        {
                            if (i >= start && i < start + to_insert.Length)
                                ptr_dst[i] = ptr_to_insert[k++];
                            else
                                ptr_dst[i] = ptr_src[j++];
                        }
                    }
                }
            }
        }

        //将长度为count的数字插入dst中，起始位置为start，dst的长度需大于start+count
        private unsafe static void longcpy(char* dst, long value, int start, int count)
        {
            int end = start + count;
            for (int i = end - 1; i >= start; i--, value /= 10)
                *(dst + i) = (char)(value % 10 + 48);
        }

        //将长度为count的数字插入dst中，起始位置为start，dst的长度需大于start+count
        private unsafe static void intcpy(char* dst, int value, int start, int count)
        {
            int end = start + count;
            for (int i = end - 1; i >= start; i--, value /= 10)
                *(dst + i) = (char)(value % 10 + 48);
        }

        //--------------------------------------手敲memcpy-------------------------------------//
        private static int m_charLen = sizeof(char);
        private unsafe static void memcpy(char* dest, char* src, int count)
        {
            // 此处换成Unity的内存拷贝函数，性能高3%，坏处是非Unity项目用不了
            UnsafeUtility.MemCpy(dest, src, count * m_charLen);
        }
        //-----------------------------------------------------------------------------------------//

        //将字符串dst用字符src填充
        private unsafe static void memcpy(string dst, char src)
        {
            fixed (char* ptr_dst = dst)
            {
                int len = dst.Length;
                for (int i = 0; i < len; i++)
                    ptr_dst[i] = src;
            }
        }
        
        //将字符拷贝到dst指定index位置
        private unsafe static void memcpy(string dst, char src, int index)
        {
            fixed (char* ptr = dst)
                ptr[index] = src;
        }
        //将相同长度的src内容拷入dst
        private unsafe static void memcpy(string dst, string src)
        {
            if (dst.Length != src.Length)
                throw new InvalidOperationException("两个字符串参数长度不一致。");
            fixed (char* dst_ptr = dst)
            {
                fixed (char* src_ptr = src)
                {
                    memcpy(dst_ptr, src_ptr, dst.Length);
                }
            }
        }
        //将src指定length内容拷入dst，dst下标src_offset偏移
        private unsafe static void memcpy(char* dst, char* src, int length, int src_offset)
        {
            memcpy(dst + src_offset, src, length);
        }

        private unsafe static void memcpy(string dst, string src, int length, int src_offset)
        {
            fixed (char* ptr_dst = dst)
            {
                fixed (char* ptr_src = src)
                {
                    memcpy(ptr_dst + src_offset, ptr_src, length);
                }
            }
        }

        public class zstring_block : IDisposable
        {
            readonly Stack<zstring> stack;

            internal zstring_block(int capacity)
            {
                stack = new Stack<zstring>(capacity);
            }

            internal void push(zstring str)
            {
                stack.Push(str);
            }

            internal IDisposable begin()//构造函数
            {
#if DBG
                if (log != null)
                    log("Began block");
#endif
                return this;
            }

            void IDisposable.Dispose()//析构函数
            {
#if DBG
                if (log != null)
                    log("Disposing block");
#endif
                while (stack.Count > 0)
                {
                    var str = stack.Pop();
                    str.dispose();//循环调用栈中zstring的Dispose方法
                }
                zstring.g_blocks.Push(this);//将自身push入缓存栈

                //赋值currentBlock
                g_open_blocks.Pop();
                if (g_open_blocks.Count > 0)
                {
                    zstring.g_current_block = g_open_blocks.Peek();
                }
                else
                {
                    zstring.g_current_block = null;
                }
            }
        }

        // Public API
        #region 

        public static Action<string> Log = null;

        public static uint DecimalAccuracy = 3; // 小数点后精度位数
        
        //获取字符串长度
        public int Length
        {
            get { return _value.Length; }
        }
        
        //类构造：cache_capacity缓存栈字典容量，stack_capacity缓存字符串栈容量，block_capacity缓存栈容量，intern_capacity缓存,open_capacity默认打开层数
        static void Initialize(int cache_capacity, int stack_capacity, int block_capacity, int intern_capacity, int open_capacity, int shallowCache_capacity)
        {
            g_cache = new Queue<zstring>[cache_capacity];
            g_secCache = new Dictionary<int, Queue<zstring>>(cache_capacity);
            g_blocks = new Stack<zstring_block>(block_capacity);
            g_intern_table = new Dictionary<int, string>(intern_capacity);
            g_open_blocks = new Stack<zstring_block>(open_capacity);
            g_shallowCache = new Stack<zstring>(shallowCache_capacity);
            for (int c = 0; c < cache_capacity; c++)
            {
                var stack = new Queue<zstring>(stack_capacity);
                for (int j = 0; j < stack_capacity; j++)
                    stack.Enqueue(new zstring(c));
                g_cache[c] = stack;
            }

            for (int i = 0; i < block_capacity; i++)
            {
                var block = new zstring_block(block_capacity * 2);
                g_blocks.Push(block);
            }
            for (int i = 0; i < shallowCache_capacity; i++)
            {
                g_shallowCache.Push(new zstring(null, true));
            }
            
            // intern 预加载待用处理
            g_intern_preload_strs = new Queue<string>[INTERN_PRELOAD_LENGTH];
            for (int i = 0; i < INTERN_PRELOAD_LENGTH; i++)
            {
                var stack = new Queue<string>(INTERN_PRELOAD_CAPACITY);
                for (int j = 0; j < INTERN_PRELOAD_CAPACITY; j++)
                {
                    stack.Enqueue(new string(NEW_ALLOC_CHAR, i));    
                }
                g_intern_preload_strs[i] = stack;
            }

            g_intern_sec_preload = new Dictionary<int, Queue<string>>();
        }

        //using语法所用。从zstring_block栈中取出一个block并将其置为当前g_current_block，在代码块{}中新生成的zstring都将push入块内部stack中。当离开块作用域时，调用块的Dispose函数，将内栈中所有zstring填充初始值并放入zstring缓存栈。同时将自身放入block缓存栈中。（此处有个问题：使用Stack缓存block，当block被dispose放入Stack后g_current_block仍然指向此block，无法记录此block之前的block，这样导致zstring.Block()无法嵌套使用）
        public static IDisposable Block()
        {
            // if (release2PreloadStrs != null)
            // {
            //     _Release2Preload(release2PreloadStrs);    
            // }
            
            if (g_blocks.Count == 0)
                g_current_block = new zstring_block(INITIAL_BLOCK_CAPACITY * 2);
            else
                g_current_block = g_blocks.Pop();

            g_open_blocks.Push(g_current_block);//新加代码，将此玩意压入open栈
            return g_current_block.begin();
        }
        
        /// <summary>
        /// 将当前时刻的zstring value放入intern缓存中以供外部使用
        /// 如果池中有内容相同字符串，返回池中字符串，否则深拷贝一份放入池中返回
        /// </summary>
        /// <returns></returns>
        public string Intern()
        {
            //string interned = new string(NEW_ALLOC_CHAR, _value.Length);
            //memcpy(interned, _value);
            //return interned;
            return _CopyIntern(_value);
        }

        /// <summary>
        /// 将普通的外部string放入Intern缓存中，并返回
        /// 如果池中有相同内容字符串，返回池中字符串，否则将strs加入池中后返回
        /// </summary>
        /// <param name="strs">注意！外部字符串一定不能再被外部逻辑修改内容</param>
        /// <returns></returns>
        public static string Intern(string strs)
        {
            if (!isInit)
            {
                return strs;
            }
            
            if (strs == null)
            {
                return null;
            }

            int hash = strs.GetHashCode();
            if (g_intern_table.TryGetValue(hash, out var internString))
            {
                return internString;
            }
            else
            {
                g_intern_table.Add(hash, strs);
                return strs;
            }
        }

        /// <summary>
        /// 将当前时刻的zstring value放入intern缓存中以供外部使用
        /// 如果池中有内容相同字符串，返回池中字符串，否则深拷贝一份放入池中返回
        /// </summary>
        /// <param name="strs"></param>
        /// <returns></returns>
        public static string Intern(zstring strs)
        {
            return strs.Intern();
        }

        //下标取值函数
        public char this[int i]
        {
            get { return _value[i]; }
            set { memcpy(this, value, i); }
        }
        //获取hashcode
        public override int GetHashCode()
        {
            return _value.GetHashCode();
        }
        //字面值比较
        public override bool Equals(object obj)
        {
            if (obj == null)
                return ReferenceEquals(this, null);

            var gstr = obj as zstring;
            if (gstr != null)
                return gstr._value == this._value;

            var str = obj as string;
            if (str != null)
                return str == this._value;

            return false;
        }
        //转化为string
        public override string ToString()
        {
            return _value;
        }
        //bool->zstring转换
        public static implicit operator zstring(bool value)
        {
            return get(value ? "True" : "False");
        }

        // long - >zstring转换
        public unsafe static implicit operator zstring(long value)
        {
            // e.g. 125
            // first pass: count the number of digits
            // then: get a zstring with length = num digits
            // finally: iterate again, get the char of each digit, memcpy char to result
            bool negative = value < 0;
            value = Math.Abs(value);
            int num_digits = get_digit_count(value);
            zstring result;
            if (negative)
            {
                result = get(num_digits + 1);
                fixed (char* ptr = result._value)
                {
                    *ptr = '-';
                    longcpy(ptr, value, 1, num_digits);
                }
            }
            else
            {
                result = get(num_digits);
                fixed (char* ptr = result._value)
                    longcpy(ptr, value, 0, num_digits);
            }
            return result;
        }

        //int->zstring转换
        public unsafe static implicit operator zstring(int value)
        {
            // e.g. 125
            // first pass: count the number of digits
            // then: get a zstring with length = num digits
            // finally: iterate again, get the char of each digit, memcpy char to result
            bool negative = value < 0;
            value = Math.Abs(value);
            int num_digits = get_digit_count(value);
            zstring result;
            if (negative)
            {
                result = get(num_digits + 1);
                fixed (char* ptr = result._value)
                {
                    *ptr = '-';
                    intcpy(ptr, value, 1, num_digits);
                }
            }
            else
            {
                result = get(num_digits);
                fixed (char* ptr = result._value)
                    intcpy(ptr, value, 0, num_digits);
            }
            return result;
        }

        //float->zstring转换
        public unsafe static implicit operator zstring(float value)
        {
            // e.g. 3.148
            bool negative = value < 0;
            if (negative) value = -value;
            long mul = (long)Math.Pow(10, DecimalAccuracy);
            long number = (long)(value * mul); // gets the number as a whole, e.g. 3148
            int left_num = (int)(number / mul); // left part of the decimal point, e.g. 3
            int right_num = (int)(number % mul); // right part of the decimal pnt, e.g. 148
            int left_digit_count = get_digit_count(left_num); // e.g. 1
            int right_digit_count = get_digit_count(right_num); // e.g. 3
            //int total = left_digit_count + right_digit_count + 1; // +1 for '.'
            int total = left_digit_count + (int)DecimalAccuracy + 1; // +1 for '.'

            zstring result;
            if (negative)
            {
                result = get(total + 1); // +1 for '-'
                fixed (char* ptr = result._value)
                {
                    *ptr = '-';
                    intcpy(ptr, left_num, 1, left_digit_count);
                    *(ptr + left_digit_count + 1) = '.';
                    int offest = (int)DecimalAccuracy - right_digit_count;
                    for (int i = 0; i < offest; i++)
                        *(ptr + left_digit_count + i + 1) = '0';
                    intcpy(ptr, right_num, left_digit_count + 2 + offest, right_digit_count);
                }
            }
            else
            {
                result = get(total);
                fixed (char* ptr = result._value)
                {
                    intcpy(ptr, left_num, 0, left_digit_count);
                    *(ptr + left_digit_count) = '.';
                    int offest = (int)DecimalAccuracy - right_digit_count;
                    for (int i = 0; i < offest; i++)
                        *(ptr + left_digit_count + i + 1) = '0';
                    intcpy(ptr, right_num, left_digit_count + 1 + offest, right_digit_count);
                }
            }
            return result;
        }
        //string->zstring转换
        public static implicit operator zstring(string value)
        {
            //return get(value);
            return getShallow(value);
        }
        //string->zstring转换
        public static zstring shallow(string value)
        {
            return getShallow(value);
        }
        //zstring->string转换
        public static implicit operator string(zstring value)
        {
            return value._value;
        }
        //+重载
        public static zstring operator +(zstring left, zstring right)
        {
            return internal_concat(left._value, right._value);
        }
        
        //==重载
        public static bool operator ==(zstring left, zstring right)
        {
            if (ReferenceEquals(left, null))
                return ReferenceEquals(right, null);
            if (ReferenceEquals(right, null))
                return false;
            return left._value == right._value;
        }
        //!=重载
        public static bool operator !=(zstring left, zstring right)
        {
            return !(left._value == right._value);
        }
        //转换为大写
        public unsafe zstring ToUpper()
        {
            var result = get(Length);
            fixed (char* ptr_this = this._value)
            {
                fixed (char* ptr_result = result._value)
                {
                    for (int i = 0; i < _value.Length; i++)
                    {
                        var ch = ptr_this[i];
                        if (char.IsLower(ch))
                            ptr_result[i] = char.ToUpper(ch);
                        else
                            ptr_result[i] = ptr_this[i];
                    }
                }
            }
            return result;
        }
        //转换为小写
        public unsafe zstring ToLower()
        {
            var result = get(Length);
            fixed (char* ptr_this = this._value)
            {
                fixed (char* ptr_result = result._value)
                {
                    for (int i = 0; i < _value.Length; i++)
                    {
                        var ch = ptr_this[i];
                        if (char.IsUpper(ch))
                            ptr_result[i] = char.ToLower(ch);
                        else
                            ptr_result[i] = ptr_this[i];
                    }
                }
            }
            return result;
        }
        //移除剪切
        public zstring Remove(int start)
        {
            return Remove(start, Length - start);
        }
        //移除剪切
        public zstring Remove(int start, int count)
        {
            return internal_remove(this._value, start, count);
        }
        //插入start起count长度字符
        public zstring Insert(char value, int start, int count)
        {
            return internal_insert(this._value, value, start, count);
        }
        //插入start起字符串
        public zstring Insert(string value, int start)
        {
            return internal_insert(this._value, value, start);
        }
        //子字符替换
        public unsafe zstring Replace(char old_value, char new_value)
        {
            zstring result = get(Length);
            fixed (char* ptr_this = this._value)
            {
                fixed (char* ptr_result = result._value)
                {
                    for (int i = 0; i < Length; i++)
                    {
                        ptr_result[i] = ptr_this[i] == old_value ? new_value : ptr_this[i];
                    }
                }
            }
            return result;
        }
        //子字符串替换
        public zstring Replace(string old_value, string new_value)
        {
            return internal_replace(this._value, old_value, new_value);
        }
        //剪切start位置起后续子串
        public zstring Substring(int start)
        {
            return Substring(start, Length - start);
        }
        //剪切start起count长度的子串
        public unsafe zstring Substring(int start, int count)
        {
            if (start < 0 || start >= Length)
                throw new ArgumentOutOfRangeException("start");

            if (count > Length)
                throw new ArgumentOutOfRangeException("count");

            zstring result = get(count);
            fixed (char* src = this._value)
            fixed (char* dst = result._value)
                memcpy(dst, src + start, count);

            return result;
        }
        //子串包含判断
        public bool Contains(string value)
        {
            return IndexOf(value) != -1;
        }
        //字符包含判断
        public bool Contains(char value)
        {
            return IndexOf(value) != -1;
        }
        //子串第一次出现位置
        public int LastIndexOf(string value)
        {
            int idx = -1;
            int last_find = -1;
            while (true)
            {
                idx = internal_index_of(this._value, value, idx + value.Length);
                last_find = idx;
                if (idx == -1 || idx + value.Length >= this._value.Length)
                    break;
            }
            return last_find;
        }
        //字符第一次出现位置
        public int LastIndexOf(char value)
        {
            int idx = -1;
            int last_find = -1;
            while (true)
            {
                idx = internal_index_of(this._value, value, idx + 1);
                last_find = idx;
                if (idx == -1 || idx + 1 >= this._value.Length)
                    break;
            }
            return last_find;
        }
        //字符第一次出现位置
        public int IndexOf(char value)
        {
            return IndexOf(value, 0, Length);
        }
        //字符自start起第一次出现位置
        public int IndexOf(char value, int start)
        {
            return internal_index_of(this._value, value, start);
        }
        //字符自start起count长度内，
        public int IndexOf(char value, int start, int count)
        {
            return internal_index_of(this._value, value, start, count);
        }
        //子串第一次出现位置
        public int IndexOf(string value)
        {
            return IndexOf(value, 0, Length);
        }
        //子串自start位置起，第一次出现位置
        public int IndexOf(string value, int start)
        {
            return IndexOf(value, start, Length - start);
        }
        //子串自start位置起，count长度内第一次出现位置
        public int IndexOf(string value, int start, int count)
        {
            return internal_index_of(this._value, value, start, count);
        }
        //是否以某字符串结束
        public unsafe bool EndsWith(string postfix)
        {
            if (postfix == null)
                throw new ArgumentNullException("postfix");

            if (this.Length < postfix.Length)
                return false;

            fixed (char* ptr_this = this._value)
            {
                fixed (char* ptr_postfix = postfix)
                {
                    for (int i = this._value.Length - 1, j = postfix.Length - 1; j >= 0; i--, j--)
                        if (ptr_this[i] != ptr_postfix[j])
                            return false;
                }
            }

            return true;
        }
        //是否以某字符串开始
        public unsafe bool StartsWith(string prefix)
        {
            if (prefix == null)
                throw new ArgumentNullException("prefix");

            if (this.Length < prefix.Length)
                return false;

            fixed (char* ptr_this = this._value)
            {
                fixed (char* ptr_prefix = prefix)
                {
                    for (int i = 0; i < prefix.Length; i++)
                        if (ptr_this[i] != ptr_prefix[i])
                            return false;
                }
            }

            return true;
        }
        //获取某长度字符串缓存数量
        public static int GetCacheCount(int length)
        {
            Queue<zstring> stack;
            getStackInCache(length, out stack);
            return stack.Count;
        }
        //自身+value拼接
        public zstring Concat(zstring value)
        {
            return internal_concat(this, value);
        }
        //静态拼接方法簇
        public static zstring Concat(zstring s0, zstring s1) { return s0 + s1; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2) { return s0 + s1 + s2; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3) { return s0 + s1 + s2 + s3; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4) { return s0 + s1 + s2 + s3 + s4; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4, zstring s5) { return s0 + s1 + s2 + s3 + s4 + s5; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4, zstring s5, zstring s6) { return s0 + s1 + s2 + s3 + s4 + s5 + s6; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4, zstring s5, zstring s6, zstring s7) { return s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4, zstring s5, zstring s6, zstring s7, zstring s8) { return s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8; }

        public static zstring Concat(zstring s0, zstring s1, zstring s2, zstring s3, zstring s4, zstring s5, zstring s6, zstring s7, zstring s8, zstring s9) { return s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9; }
        
        
        // 不定长序列化
        public static zstring Format(string input, string[] paramStrs)
        {
            if (input == null) throw new ArgumentNullException("input");
            if (paramStrs == null) throw new ArgumentNullException("paramStrs");
            if (paramStrs.Length >= 100)
            {
                throw new Exception("zstring.Format(string, string[])：paramStrs's count is too long!");
            }
            
            var length = paramStrs.Length;
            _TryExpandFormatArgs(length);
            for (int i = 0; i < length; i++)
            {
                g_format_args[i] = paramStrs[i];
            }
            return internal_format(input, length);
        }

        private static void _TryExpandFormatArgs(int total)
        {
            var count = g_format_args.Count;
            for (int i = 0; i < total - count; i++)
            {
                g_format_args.Add(null);
            }
        }
        
        //静态格式化方法簇
        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4, zstring arg5, zstring arg6, zstring arg7, zstring arg8, zstring arg9)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");
            if (arg5 == null) throw new ArgumentNullException("arg5");
            if (arg6 == null) throw new ArgumentNullException("arg6");
            if (arg7 == null) throw new ArgumentNullException("arg7");
            if (arg8 == null) throw new ArgumentNullException("arg8");
            if (arg9 == null) throw new ArgumentNullException("arg9");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            g_format_args[5] = arg5;
            g_format_args[6] = arg6;
            g_format_args[7] = arg7;
            g_format_args[8] = arg8;
            g_format_args[9] = arg9;
            return internal_format(input, 10);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4, zstring arg5, zstring arg6, zstring arg7, zstring arg8)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");
            if (arg5 == null) throw new ArgumentNullException("arg5");
            if (arg6 == null) throw new ArgumentNullException("arg6");
            if (arg7 == null) throw new ArgumentNullException("arg7");
            if (arg8 == null) throw new ArgumentNullException("arg8");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            g_format_args[5] = arg5;
            g_format_args[6] = arg6;
            g_format_args[7] = arg7;
            g_format_args[8] = arg8;
            return internal_format(input, 9);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4, zstring arg5, zstring arg6, zstring arg7)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");
            if (arg5 == null) throw new ArgumentNullException("arg5");
            if (arg6 == null) throw new ArgumentNullException("arg6");
            if (arg7 == null) throw new ArgumentNullException("arg7");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            g_format_args[5] = arg5;
            g_format_args[6] = arg6;
            g_format_args[7] = arg7;
            return internal_format(input, 8);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4, zstring arg5, zstring arg6)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");
            if (arg5 == null) throw new ArgumentNullException("arg5");
            if (arg6 == null) throw new ArgumentNullException("arg6");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            g_format_args[5] = arg5;
            g_format_args[6] = arg6;
            return internal_format(input, 7);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4, zstring arg5)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");
            if (arg5 == null) throw new ArgumentNullException("arg5");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            g_format_args[5] = arg5;
            return internal_format(input, 6);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3, zstring arg4)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");
            if (arg4 == null) throw new ArgumentNullException("arg4");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            g_format_args[4] = arg4;
            return internal_format(input, 5);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2, zstring arg3)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");
            if (arg3 == null) throw new ArgumentNullException("arg3");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            g_format_args[3] = arg3;
            return internal_format(input, 4);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1, zstring arg2)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");
            if (arg2 == null) throw new ArgumentNullException("arg2");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            g_format_args[2] = arg2;
            return internal_format(input, 3);
        }

        public static zstring Format(string input, zstring arg0, zstring arg1)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");
            if (arg1 == null) throw new ArgumentNullException("arg1");

            g_format_args[0] = arg0;
            g_format_args[1] = arg1;
            return internal_format(input, 2);
        }

        public static zstring Format(string input, zstring arg0)
        {
            if (arg0 == null) throw new ArgumentNullException("arg0");

            g_format_args[0] = arg0;
            return internal_format(input, 1);
        }

        // 普通的float->string是隐式转换，小数点后只保留三位有效数字
        // 对于更高精确度需求，隐式转换，可以修改静态变量DecimalAccuracy
        // 显式转换使用此方法即可，函数结束DecimalAccuracy值和之前的一样
        public static zstring FloatToZstring(float value, uint DecimalAccuracy)
        {
            uint oldValue = zstring.DecimalAccuracy;
            zstring.DecimalAccuracy = DecimalAccuracy;
            zstring target = (zstring)value;
            zstring.DecimalAccuracy = oldValue;
            return target;
        }

        //判空或长度
        public static bool IsNullOrEmpty(zstring str)
        {
            return str == null || str.Length == 0;
        }
        //是否以value结束
        public static bool IsPrefix(zstring str, string value)
        {
            return str.StartsWith(value);
        }
        //是否以value开始
        public static bool isPostfix(zstring str, string postfix)
        {
            return str.EndsWith(postfix);
        }

        private static List<zstring> _splitResult = new List<zstring>(32);
        private static List<char> _separators = new List<char>(32);
        
        /// <summary>
        /// 字符串分割
        /// </summary>
        /// <param
        ///     name="originStr">
        /// </param>
        /// <param name="separator">分隔符</param>
        /// <returns>分割结果：①返回的Stack是复用的，外部如果要长期持有，自己用容器存，并且调用每个元素的intern ②空字符串没有意义不再返回</returns>
        private unsafe List<zstring> _Split()
        {
            _splitResult.Clear();
            
            var lastSuitableIdx = -1;
            fixed (char* startPointer = _value)
            {
                for (int i = 0; i < _value.Length; i++)
                {
                    var curChar = startPointer[i];
                    var suitable = false;
                    for (int j = 0; j < _separators.Count; j++)
                    {
                        if (curChar == _separators[j])
                        {
                            suitable = true;
                            break;
                        }   
                    }
                    if (suitable)
                    {
                        var length = i - lastSuitableIdx -1;
                        if (length > 0)
                        {
                            var newZStrs = get(length);
                            fixed (char* destPointer = newZStrs._value)
                            {
                                memcpy(destPointer, startPointer + lastSuitableIdx + 1, length);
                            }
                            _splitResult.Add(newZStrs);   
                        }
                        lastSuitableIdx = i;
                    }
                }

                // remain sub string
                var offsetLength = _value.Length - lastSuitableIdx - 1;
                if (offsetLength > 0)
                {
                    var newZStrs = get(offsetLength);
                    fixed (char* destPointer = newZStrs._value)
                    {
                        memcpy(destPointer, startPointer + lastSuitableIdx + 1, offsetLength);
                    }
                    _splitResult.Add(newZStrs);
                }
            }
            return _splitResult;
        }


        public void Split(List<zstring> result, char separator1)
        {
            var strs = Split(separator1);
            result.Clear();
            foreach (var str in strs)
            {
                result.Add(str);
            }
        }
        
        // 返回值是复用的静态List，会被下次Split修改掉，所以外部不可以持有引用
        public List<zstring> Split(char separator1)
        {
            _separators.Clear();
            _separators.Add(separator1);
            return _Split();
        }
        
        public void Split(List<zstring> result, char separator1, char separator2)
        {
            var strs = Split(separator1, separator2);
            result.Clear();
            foreach (var str in strs)
            {
                result.Add(str);
            }
        }
        
        public void Split(ResetList<zstring> result, char separator1, char separator2)
        {
            var strs = Split(separator1, separator2);
            result.Clear();
            foreach (var str in strs)
            {
                result.Add(str);
            }
        }
        
        // 返回值是复用的静态List，会被下次Split修改掉，所以外部不可以持有引用
        public List<zstring> Split(char separator1, char separator2)
        {
            _separators.Clear();
            _separators.Add(separator1);
            _separators.Add(separator2);
            return _Split();
        }
        
        
        public void Split(List<zstring> result, char separator1, char separator2, char separator3)
        {
            var strs = Split(separator1, separator2, separator3);
            result.Clear();
            foreach (var str in strs)
            {
                result.Add(str);
            }
        }
        
        // 返回值是复用的静态List，会被下次Split修改掉，所以外部不可以持有引用
        public List<zstring> Split(char separator1, char separator2, char separator3)
        {
            _separators.Clear();
            _separators.Add(separator1);
            _separators.Add(separator2);
            _separators.Add(separator3);
            return _Split(); 
        }
        
        public static List<zstring> Split(zstring originStr, char separator1)
        {
            return originStr.Split(separator1);
        }
        
        public static List<zstring> Split(zstring originStr, char separator1, char separator2)
        {
            return originStr.Split(separator1, separator2);
        }
        
        public static List<zstring> Split(zstring originStr, char separator1, char separator2, char separator3)
        {
            return originStr.Split(separator1, separator2, separator3);
        }
        #endregion
    }
}
