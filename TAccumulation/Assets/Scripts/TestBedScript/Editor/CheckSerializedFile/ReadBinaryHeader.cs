using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Linq;

namespace UnitySerializedFile
{
    /// Meta flags can be used like this:
    /// transfer.Transfer (someVar, "varname", kHideInEditorMask);
    /// The GenerateTypeTreeTransfer for example reads the metaflag mask and stores it in the TypeTree
    public enum TransferMetaFlags
    {
        kNoTransferFlags = 0,
        /// Putting this mask in a transfer will make the variable be hidden in the property editor
        kHideInEditorMask = 1 << 0,

        /// Makes a variable not editable in the property editor
        kNotEditableMask = 1 << 4,

        /// There are 3 types of PPtrs: kStrongPPtrMask, default (weak pointer)
        /// a Strong PPtr forces the referenced object to be cloned.
        /// A Weak PPtr doesnt clone the referenced object, but if the referenced object is being cloned anyway (eg. If another (strong) pptr references this object)
        /// this PPtr will be remapped to the cloned object
        /// If an  object  referenced by a WeakPPtr is not cloned, it will stay the same when duplicating and cloning, but be NULLed when templating
        kStrongPPtrMask = 1 << 6,
        // unused  = 1 << 7,

        /// kTreatIntegerValueAsBoolean makes an integer variable appear as a checkbox in the editor, be written as true/false to JSON, etc
        kTreatIntegerValueAsBoolean = 1 << 8,

        // unused = 1 << 9,
        // unused = 1 << 10,
        // unused = 1 << 11,

        /// When the options of a serializer tells you to serialize debug properties kSerializeDebugProperties
        /// All debug properties have to be marked kDebugPropertyMask
        /// Debug properties are shown in expert mode in the inspector but are not serialized normally
        kDebugPropertyMask = 1 << 12,

        // Used in TypeTree to indicate that a property is aligned to a 4-byte boundary. Do not specify this flag when
        // transferring variables; call transfer.Align() instead.
        kAlignBytesFlag = 1 << 14,

        // Used in TypeTree to indicate that some child of this typetree node uses kAlignBytesFlag. Do not use this flag.
        kAnyChildUsesAlignBytesFlag = 1 << 15,

        // unused = 1 << 16,
        // unused = 1 << 18,

        // Ignore this property when reading or writing .meta files
        kIgnoreInMetaFiles = 1 << 19,

        // When reading meta files and this property is not present, read array entry name instead (for backwards compatibility).
        kTransferAsArrayEntryNameInMetaFiles = 1 << 20,

        // When writing YAML Files, uses the flow mapping style (all properties in one line, with "{}").
        kTransferUsingFlowMappingStyle = 1 << 21,

        // Tells SerializedProperty to generate bitwise difference information for this field.
        kGenerateBitwiseDifferences = 1 << 22,

        // Makes a variable not be exposed to the animation system
        kDontAnimate = 1 << 23,

        // Encodes a 64-bit signed or unsigned integer as a hex string in text serializers.
        kTransferHex64 = 1 << 24,

        // Use to differentiate between uint16 and C# Char.
        kCharPropertyMask = 1 << 25,

        //do not check if string is utf8 valid, (usually all string must be valid utf string, but sometimes we serialize pure binary data to string,
        //for example TextAsset files with extension .bytes. In this case this validation should be turned off)
        //Player builds will never validate data. In editor we validate correct encoding of strings by default.
        kDontValidateUTF8 = 1 << 26,

        // Fixed buffers are serialized as arrays, use this flag to differentiate between regular arrays and fixed buffers.
        kFixedBufferFlag = 1 << 27,

        // It is not allowed to modify this property's serialization data.
        kDisallowSerializedPropertyModification = 1 << 28
    }

    //----------------------------------------------------------------------------------------------------------------------
    // What is this: Lists all known format versions that the SerializedFile has gone through.
    //----------------------------------------------------------------------------------------------------------------------
    public enum SerializedFileFormatVersion
    {
        kUnsupported = 1,           // format no longuer readable.
        kUnknown_2 = 2,             // semantic lost to history, but tested against in code.
        kUnknown_3 = 3,             // semantic lost to history, but tested against in code.
        kUnknown_5 = 5,             // semantic lost to history, but tested against in code.
        kUnknown_6 = 6,             // semantic lost to history, but tested against in code.
        kUnknown_7 = 7,             // semantic lost to history, but tested against in code.
        kUnknown_8 = 8,             // semantic lost to history, but tested against in code.
        kUnknown_9 = 9,             // semantic lost to history, but tested against in code.
        kUnknown_10 = 10,           // Developed in parallel: Version 10 Blobified TypeTree
        kHasScriptTypeIndex = 11,   // Developed in parallel: Version 11 Script References
        kUnknown_12 = 12,           // Version: 12  Blobified TypeTree & Script References
        kHasTypeTreeHashes = 13,
        kUnknown_14 = 14,           // semantic lost to history, but tested against in code.
        kSupportsStrippedObject = 15,
        kRefactoredClassId = 16,    // (5.5.a1 martinz) widened serialized ClassID to 32 bit.
        kRefactorTypeData = 17,     // (5.5.a1 martinz) moved all other type-data from Object to Type
        kRefactorShareableTypeTreeData = 18, // 2019.1 : TypeTree's now reference a shareable/cachable data set
        kTypeTreeNodeWithTypeFlags = 19, // 2019.1: TypeTree's can contain nodes that express managed references
        kSupportsRefObject = 20,    // 2019.2: SerializeFile support managed references
        kStoresTypeDependencies = 21, // 2019.2: SerializeFile includes info on types that depend on other types

        kCurrentSerializeVersion = kStoresTypeDependencies, // increment when changing the serialization format and add an enum above for previous version logic checks
    }

    public enum SerializedFileLoadError
    {
        kSerializedFileLoadError_None = 0,
        kSerializedFileLoadError_HigherSerializedFileVersion = 1,
        kSerializedFileLoadError_OversizedFile = 2,
        kSerializedFileLoadError_MergeConflicts = 3,
        kSerializedFileLoadError_EmptyOrCorruptFile = 4,
        kSerializedFileLoadError_Unknown = -1
    }

    public struct SerializedFileHeader
    {
        public uint m_MetadataSize;
        public uint m_FileSize;
        public uint m_Version;
        public uint m_DataOffset;
        public int m_Endianess;
        //public byte m_Endianess;
        //public byte[] m_Reserved = new byte[3];

        public void SwapEndianess()
        {
            ReadBinaryHeader.SwapEndianBytes(ref m_MetadataSize);
            ReadBinaryHeader.SwapEndianBytes(ref m_FileSize);
            ReadBinaryHeader.SwapEndianBytes(ref m_Version);
            ReadBinaryHeader.SwapEndianBytes(ref m_DataOffset);
        }
    }

    public struct ObjectInfo
    {
        public uint byteStart;
        public uint byteSize;
        public uint typeID;
    }

    public struct LocalSerializedObjectIdentifier
    {
        public int localSerializedFileIndex;
        public long localIdentifierInFile;
    }

    public class FileIdentifier
    {
        public string pathName = string.Empty;
        public int type;
        public uint[] data = new uint[4];
    }

    public struct TypeTreeNode
    {
        public short m_Version;          // The version of the serialization format as represented by this type tree.  Usually determined by Transfer() functions.
        public byte m_Level;             // Level in the hierarchy (0 is the root)
        public byte m_TypeFlags;         // Possible values see ETypeFlags

        public uint m_TypeStrOffset;     // The type of the variable (eg. "Vector3f", "int")
        public uint m_NameStrOffset;     // The name of the property (eg. "m_LocalPosition")
        public int m_ByteSize;           // = -1 if its not determinable (arrays)
        public int m_Index;              // The index of the property (Prefabs use this index in the override bitset)

        // Serialization meta data (eg. to hide variables in the property editor)
        // Children or their meta flags with their parents!
        public uint m_MetaFlag;

        public enum ETypeFlags
        {
            kFlagNone = 0,
            kFlagIsArray = (1 << 0),
            kFlagIsManagedReference = (1 << 1),
            kFlagIsManagedReferenceRegistry = (1 << 2),
            kFlagIsArrayOfRefs = (1 << 3)
        };

        // When node is private reference, this holds the 64bit "hash" of the TypeTreeShareableData of the refed type.
        // stores Hash128::PackToUInt64(). Why? because the Hash128 type is to expensive to initialize cpu wise(memset)
        // 0 <=> does not reference a type.
        // note: if this is deamed to much data (tends to always be zero), we could move the hash to TypeTreeShareableData as a vector and just keep a byte index here.
        public long m_RefTypeHash;

        public void Initialize(int level, long refTypeHash = 0)
        {
            m_Level = (byte)level;
            m_NameStrOffset = 0;
            m_TypeStrOffset = 0;
            m_Index = -1;
            m_TypeFlags = 0;
            m_Version = 1;
            m_MetaFlag = (uint)TransferMetaFlags.kNoTransferFlags;
            m_ByteSize = -1;
            m_RefTypeHash = 0;
        }

        public void AddTypeFlags(ETypeFlags flags) { m_TypeFlags |= (byte)flags; }
        public bool IsArray() { return (m_TypeFlags & (byte)ETypeFlags.kFlagIsArray) != 0; }
        public bool IsManagedReference() { return (m_TypeFlags & (byte)ETypeFlags.kFlagIsManagedReference) != 0; }
        public bool IsManagedReferenceRegistry() { return (m_TypeFlags & (byte)ETypeFlags.kFlagIsManagedReferenceRegistry) != 0; }
        public bool IsArrayOfRefs() { return (m_TypeFlags & (byte)ETypeFlags.kFlagIsArrayOfRefs) != 0; }
    }

    public class TypeTree
    {
        public string m_Type;
        public string m_Name;

        public TypeTreeNode m_Node;
        public List<TypeTree> m_Children = new List<TypeTree>();
        public TypeTree m_Father;

        public string m_DebugValue;

        public TypeTree AddChildNode()
        {
            TypeTree child = new TypeTree();
            child.m_Node.Initialize(this.m_Node.m_Level + 1);
            this.m_Children.Add(child);

            return child;
        }

        public bool IsBasicDataType()
        {
            return m_Children.Count == 0 && m_Node.m_ByteSize > 0;
        }

        public bool IsNull() { return m_Node.m_Version == 0; }
        public string Type() { return m_Type; }
        public string Name() { return m_Name; }

        public int ByteSize() { return m_Node.m_ByteSize; }
        public TransferMetaFlags MetaFlags() { return (TransferMetaFlags)m_Node.m_MetaFlag; }

        public override string ToString()
        {
            return $"{m_Name} ({m_Type})";
        }
    }

    public class ReadBinaryHeader
    {
        public SerializedFileHeader Header;
        public string UnityVersion;
        public byte FileEndianess;
        public uint TargetPlatform;
        public bool EnableTypeTree;

        public List<SerializedType> Types = null;
        public Dictionary<long, ObjectInfo> Objects = null;
        public List<LocalSerializedObjectIdentifier> ScriptTypes = null;
        public List<FileIdentifier> Externals = null;
        public List<SerializedType> RefTypes = null;

        public string DebugPath;
        public int ReadOffset;
        public int ReadEndOffset;

        public static void SwapEndianBytes(ref UInt16 i) { i = (UInt16)((i << 8) | (i >> 8)); }
        public static void SwapEndianBytes(ref Int16 i) { i = (Int16)((i << 8) | (i >> 8)); }
        public static void SwapEndianBytes(ref UInt32 i) { i = (i >> 24) | ((i >> 8) & 0x0000ff00) | ((i << 8) & 0x00ff0000) | (i << 24); }
        public static void SwapEndianBytes(ref Int32 i) { i = (i >> 24) | ((i >> 8) & 0x0000ff00) | ((i << 8) & 0x00ff0000) | (i << 24); }

        public static void SwapEndianBytes(ref UInt64 i)
        {
            UInt32[] p = new UInt32[2];
            p[0] = (UInt32)(i >> 32);
            p[1] = (UInt32)(i);
            UInt32 u = (p[0] >> 24) | (p[0] << 24) | ((p[0] & 0x00ff0000) >> 8) | ((p[0] & 0x0000ff00) << 8);
            p[0] = (p[1] >> 24) | (p[1] << 24) | ((p[1] & 0x00ff0000) >> 8) | ((p[1] & 0x0000ff00) << 8);
            p[1] = u;
        }

        public static int AlignToPowerOfTwo(int value, int alignment)
        {
            return (value + (alignment - 1)) & ~(alignment - 1);
        }

        // Rounds up a number to the next multiple of 4.
        // if /size/ is already a multiple of 4, then it will return /size/.
        public static int Align4(int size)
        {
            return AlignToPowerOfTwo(size, 4);
        }

        //convert structure T to byte[]   
        public static byte[] WriteFileCache(object objStruct)
        {
            //get the size of structure  
            int size = Marshal.SizeOf(objStruct);

            //define buffer arrays 
            byte[] buffer = new byte[size];
            //Alloc unmanaged memory and Copy structure to unmanaged memory 
            IntPtr ipStruct = Marshal.AllocHGlobal(size);
            Marshal.StructureToPtr(objStruct, ipStruct, false);
            //Copy to the byte array  
            Marshal.Copy(ipStruct, buffer, 0, size);
            //Free unmanaged  memory  
            Marshal.FreeHGlobal(ipStruct);
            return buffer;
        }

        public static void ReadFileCache<T>(out T t, byte[] data, int offset, int size)
        {
            if (offset + size > data.Length)
            {
                t = default(T);
                return;
            }

            //Alloc unmanaged memory and copy bytes data to memory 
            IntPtr ptr = Marshal.AllocHGlobal(size);

            Marshal.Copy(data, offset, ptr, size);

            //Convert IntPtr to structure  
            t = (T)Marshal.PtrToStructure(ptr, typeof(T));

            //Free unmanaged memory  
            Marshal.FreeHGlobal(ptr);
        }

        public static void ReadFileCache<T>(out T[] ts, byte[] data, int offset, int size, int length)
        {
            if (offset + size * length > data.Length)
            {
                ts = default(T[]);
                return;
            }

            ts = new T[length];
            for (int i = 0; i < length; i++)
            {
                ReadFileCache(out ts[i], data, offset, size);
                offset += size;
            }
        }

        public TypeTree GetTypeTree(long fileID)
        {
            ObjectInfo found;
            if (!Objects.TryGetValue(fileID, out found))
                return null;

            return GetTypeTree(found);
        }

        public TypeTree GetTypeTree(ObjectInfo found)
        {
            if (found.typeID >= Types.Count)
                return null;

            SerializedType type = Types[(int)found.typeID];
            return type.m_OldType;
        }

        static int kLittleEndian = 0, kBigEndian = 1, kActiveEndianess = kLittleEndian;
        static uint kHeaderSize_Ver8 = 12;
        public SerializedFileLoadError ReadHeader(string path, byte[] data)
        {
            DebugPath = path;
            ReadOffset = 0;
            ReadEndOffset = data.Length;
            if (ReadEndOffset <= 0)
                return SerializedFileLoadError.kSerializedFileLoadError_EmptyOrCorruptFile;

            if (ReadEndOffset < Marshal.SizeOf(Header))
                return SerializedFileLoadError.kSerializedFileLoadError_Unknown;

            ReadFileCache(out Header, data, ReadOffset, Marshal.SizeOf(Header));
            if (kActiveEndianess == kLittleEndian)
                Header.SwapEndianess();

            // Consistency check if the file is a valid serialized file.
            if ((int)Header.m_MetadataSize == -1)
                return SerializedFileLoadError.kSerializedFileLoadError_Unknown;
            if (Header.m_Version == (uint)SerializedFileFormatVersion.kUnsupported)
                return SerializedFileLoadError.kSerializedFileLoadError_Unknown;
            if (Header.m_Version > (uint)SerializedFileFormatVersion.kCurrentSerializeVersion)
                return SerializedFileLoadError.kSerializedFileLoadError_HigherSerializedFileVersion;

            uint metadataSize, metadataOffset;
            uint dataSize, dataOffset;
            uint dataEnd;

            if (Header.m_Version >= (uint)SerializedFileFormatVersion.kUnknown_9)
            {
                if ((ReadOffset + Header.m_FileSize) > ReadEndOffset || Header.m_DataOffset > Header.m_FileSize || Header.m_FileSize == 0 || Header.m_FileSize == 0xFFFFFFFF)
                    return SerializedFileLoadError.kSerializedFileLoadError_Unknown;

                // [Header][metadata[...]][data]

                metadataOffset = (uint)Marshal.SizeOf(Header);
                metadataSize = Header.m_MetadataSize;

                FileEndianess = (byte)Header.m_Endianess;

                dataOffset = Header.m_DataOffset;
                dataSize = Header.m_FileSize - Header.m_DataOffset;
                dataEnd = dataOffset + dataSize;

                if (dataEnd == 0)
                    return SerializedFileLoadError.kSerializedFileLoadError_Unknown;
            }
            else
            {
                // [Header][data][metadata]

                // We set dataOffset to zero, because offsets in object table are file-start based
                dataOffset = 0;
                dataSize = Header.m_FileSize - Header.m_MetadataSize - kHeaderSize_Ver8;
                dataEnd = Header.m_FileSize - Header.m_MetadataSize;

                // Offset by one, because we're reading the endianess flag right here
                metadataOffset = Header.m_FileSize - Header.m_MetadataSize + 1;
                metadataSize = Header.m_MetadataSize - 1;

                if ((int)metadataSize == -1 || (ReadOffset + Header.m_FileSize) > ReadEndOffset || dataEnd > Header.m_FileSize)
                    return SerializedFileLoadError.kSerializedFileLoadError_Unknown;

                ReadFileCache(out FileEndianess, data, ReadOffset + (int)metadataOffset - 1, Marshal.SizeOf(FileEndianess));
            }

            // Check endianess validity
            if (FileEndianess != kBigEndian && FileEndianess != kLittleEndian)
                return SerializedFileLoadError.kSerializedFileLoadError_Unknown;

            bool metaDataRead;
            if (FileEndianess == kActiveEndianess)
                metaDataRead = ReadMetadata(Header.m_Version, data, ReadOffset + (int)metadataOffset, (int)metadataSize, dataOffset, dataEnd);
            else
                metaDataRead = ReadMetadata(Header.m_Version, data, ReadOffset + (int)metadataOffset, (int)metadataSize, dataOffset, dataEnd);
            if (!metaDataRead)
            {
                Debug.LogErrorFormat("Invalid serialized file header. File: \"{0}\".", DebugPath);
                return SerializedFileLoadError.kSerializedFileLoadError_Unknown;
            }

            return SerializedFileLoadError.kSerializedFileLoadError_None;
        }

        private bool ReadMetadata(uint version, byte[] data, int metadataOffset, int metadataSize, uint dataOffset, uint dataFileEnd)
        {
            BinaryStreamReader me = new BinaryStreamReader(data, metadataOffset, metadataSize);

            // Read Unity version file was built with
            string unityVersion = string.Empty;
            if (version >= (uint)SerializedFileFormatVersion.kUnknown_7)
            {
                unityVersion = me.ReadString();
            }
            UnityVersion = unityVersion;

            // Build target platform verification
            if (version >= (uint)SerializedFileFormatVersion.kUnknown_8)
            {
                TargetPlatform = me.ReadUInt32();
            }

            EnableTypeTree = true;
            if (version >= (uint)SerializedFileFormatVersion.kHasTypeTreeHashes)
            {
                EnableTypeTree = me.ReadBoolean();
            }

            // Read number of types
            int typeCount = me.ReadSInt32();

            //this check is only needed for older versions since that is the only case where compatibilityMapOldTypeIdToTypeIndex is needed
            if (typeCount < 1 && version < (uint)SerializedFileFormatVersion.kRefactoredClassId)
            {
                Debug.LogError("Unable to load type information from file " + DebugPath);
                return false;
            }

            // Read	types
            Types = new List<SerializedType>(typeCount);

            // This stored the mapping of old typeIDs to new typeIDs
            Dictionary<int, int> compatibilityMapOldTypeIdToTypeIndex = new Dictionary<int, int>();
            // This indicates whether a type has been fully updated when loading from an older version
            List<bool> typeFullyUpdated = Enumerable.Repeat(version >= (uint)SerializedFileFormatVersion.kRefactorTypeData, typeCount).ToList();

            // Prior to 2018.3, the script ID hash was not written for m_ScriptTypeIndex >= 0
            // Files written using previous versions must skip this to prevent corruption
            bool ignoreScriptTypeForHash = false;
            //if (UnityVersion(unityVersion) < kWriteIDHashForScriptTypeVersion)
            //{
            //    ignoreScriptTypeForHash = true;
            //}

            for (int i = 0; i < typeCount; i++)
            {
                int originalTypeId = 0;

                SerializedType type = new SerializedType(0, false);
                if (!type.ReadType(false, me, version, EnableTypeTree, ignoreScriptTypeForHash))
                    return false;

                Types.Add(type);
                //if (version < (uint)SerializedFileFormatVersion.kRefactoredClassId)
                //    compatibilityMapOldTypeIdToTypeIndex[originalTypeId] = i;
            }

            if (version >= (uint)SerializedFileFormatVersion.kUnknown_7 && version < (uint)SerializedFileFormatVersion.kUnknown_14)
            {
                // Skip the useless bigIDEnabled flag.
                int bigIDEnabled = me.ReadSInt32();
            }

            // Read number of objects
            int objectCount = me.ReadSInt32();

            // Read Objects
            Objects = new Dictionary<long, ObjectInfo>(objectCount);
            for (int i = 0; i < objectCount; i++)
            {
                ObjectInfo value = new ObjectInfo();

                long fileID = ReadLocalIdentifier(me, version);
                value.byteStart = me.ReadUInt32();
                value.byteSize = me.ReadUInt32();
                value.typeID = me.ReadUInt32();

                short oldClassID = 0;
                if (version < (uint)SerializedFileFormatVersion.kRefactoredClassId)
                    oldClassID = me.ReadSInt16();

                if (version <= (uint)SerializedFileFormatVersion.kUnknown_10)
                {
                    // This field has been removed from ObjectInfor from version 11.
                    ushort isDestroyed;
                    isDestroyed = me.ReadUInt16();
                }

                bool readScriptTypeIdxFromObjectInfo = version >= (uint)SerializedFileFormatVersion.kHasScriptTypeIndex && version < (uint)SerializedFileFormatVersion.kRefactorTypeData;
                bool readStrippedFromObjectInfo = version >= (uint)SerializedFileFormatVersion.kSupportsStrippedObject && version < (uint)SerializedFileFormatVersion.kRefactorTypeData;

                short scriptTypeIdx = -1;
                if (readScriptTypeIdxFromObjectInfo)
                    scriptTypeIdx = me.ReadSInt16();

                bool stripped = false;
                if (readStrippedFromObjectInfo)
                    stripped = me.ReadBoolean();

                if (version < (uint)SerializedFileFormatVersion.kRefactorTypeData)
                {
                    SerializedType serializedType = Types[(int)value.typeID];

                    // Version 10 introduced script pptr being stored in the header, but for previous versions we try to extract
                    // the script reference from the m_Script field using the type tree.
                    // note ObjectStoredSerializableManagedRef: no need to handle it here as it's for legacy projects that predata SO.
                    if (version < (uint)SerializedFileFormatVersion.kHasScriptTypeIndex && serializedType.m_PersistentTypeID == SerializedType.kMonoBehaviourPersistentID)
                    {
                        TypeTree typeTree = serializedType.m_OldType;
                        if (typeTree == null)
                        {
                            Debug.LogError("Script extraction failure");
                            return false;
                        }

                        LocalSerializedObjectIdentifier scriptReference = new LocalSerializedObjectIdentifier();
                        if (!ExtractScriptTypeReference(data, typeTree, (int)(value.byteStart + dataOffset + ReadOffset), FileEndianess != kActiveEndianess, ref scriptReference))
                        {
                            Debug.LogError("Script extraction failure");
                            return false;
                        }

                        scriptTypeIdx = (short)AddUniqueItemToArray(ScriptTypes, scriptReference);
                    }

                    // in previous versions the type was contained partially in object data.
                    // Now we move the objects type data into the type array.
                    // Since there is potential duplication between objects sharing types, we do it only once, then validate.
                    if (value.typeID < typeFullyUpdated.Count && !typeFullyUpdated[(int)value.typeID])
                    {
                        serializedType.m_IsStrippedType = stripped;
                        serializedType.m_ScriptTypeIndex = scriptTypeIdx;

                        typeFullyUpdated[(int)value.typeID] = true;
                    }

                    if (serializedType.m_IsStrippedType != stripped)
                    {
                        Debug.LogErrorFormat("Invalid serialized file. File: \"{0}\"", DebugPath);
                        return false;
                    }

                    if (serializedType.m_ScriptTypeIndex != scriptTypeIdx)
                    {
                        value.typeID = (uint)FindOrCreateSerializedTypeForUnityType(Types, serializedType, stripped, scriptTypeIdx, (int)value.typeID);
                    }
                }

                value.byteStart += dataOffset;

                if (value.byteStart + value.byteSize < value.byteStart || value.byteStart + value.byteSize > dataFileEnd)
                    return false;

                Objects.Add(fileID, value);
            }

            if (version >= (uint)SerializedFileFormatVersion.kHasScriptTypeIndex)
            {
                // Read Script Types
                int scriptTypeCount = me.ReadSInt32();

                if (me.Position + scriptTypeCount * (sizeof(int) + sizeof(long)) > dataFileEnd)
                    return false;

                ScriptTypes = new List<LocalSerializedObjectIdentifier>(scriptTypeCount);
                for (int i = 0; i < scriptTypeCount; i++)
                {
                    LocalSerializedObjectIdentifier preload = new LocalSerializedObjectIdentifier();
                    preload.localSerializedFileIndex = me.ReadSInt32();
                    preload.localIdentifierInFile = ReadLocalIdentifier(me, version);

                    ScriptTypes.Add(preload);
                }
            }

            // Read externals/pathnames
            int externalsCount = me.ReadSInt32();

            Externals = new List<FileIdentifier>(externalsCount);
            for (int i = 0; i < externalsCount; i++)
            {
                FileIdentifier external = new FileIdentifier();

                if (version >= (uint)SerializedFileFormatVersion.kUnknown_5)
                {
                    if (version >= (uint)SerializedFileFormatVersion.kUnknown_6)
                    {
                        ///@TODO: Remove from serialized file format
                        string tempEmpty = me.ReadString();
                    }

                    for (int g = 0; g < 4; g++)
                    {
                        external.data[g] = me.ReadUInt32();
                    }

                    external.type = me.ReadSInt32();
                }
                external.pathName = me.ReadString();

                Externals.Add(external);
            }

            if (version >= (uint)SerializedFileFormatVersion.kSupportsRefObject)
            {
                // Read number of ref types.
                int refCount = me.ReadSInt32();
                RefTypes = new List<SerializedType>(refCount);

                // Read ref types.
                for (int i = 0; i < refCount; ++i)
                {
                    SerializedType type = new SerializedType(0, false);
                    if (!type.ReadType(true, me, version, EnableTypeTree, false))
                    {
                        Debug.LogError("Unable to load reference type information from file " + DebugPath);
                        return false;
                    }

                    RefTypes.Add(type);
                }
            }
            // Read Userinfo string
            if (version >= (uint)SerializedFileFormatVersion.kUnknown_5)
            {
                string userInformation = me.ReadString();
            }

            return me.Position == me.Length;
        }

        private long ReadLocalIdentifier(BinaryStreamReader me, uint version)
        {
            long fileID;
            if (version >= (uint)SerializedFileFormatVersion.kUnknown_14)
            {
                me.AlignStreamReader(4);
                Int64 fileID64 = me.ReadSInt64();
                fileID = fileID64;
            }
            else
            {
                Int32 fileID32 = me.ReadSInt32();
                fileID = fileID32;
            }
            return fileID;
        }

        private bool ExtractScriptTypeReference(byte[] data, TypeTree typeTree, int byteStart, bool swapEndian, ref LocalSerializedObjectIdentifier outputReference)
        {
            int offset = 0;

            foreach (TypeTree cur in typeTree.m_Children)
            {
                if (cur.IsNull())
                    return false;

                if (cur.ByteSize() == -1)
                    return false;

                if (cur.Name() == "m_Script")
                    break;

                offset += cur.ByteSize();
                if ((cur.MetaFlags() & TransferMetaFlags.kAlignBytesFlag) != 0)
                    offset = Align4(offset);
            }

            int[] serializedData;
            ReadFileCache(out  serializedData, data, offset + byteStart, sizeof(int), 2);
            if (swapEndian)
            {
                SwapEndianBytes(ref serializedData[0]);
                SwapEndianBytes(ref serializedData[1]);
            }

            outputReference.localSerializedFileIndex = serializedData[0];
            outputReference.localIdentifierInFile = serializedData[1];

            return true;
        }

        static int AddUniqueItemToArray(List<LocalSerializedObjectIdentifier> arr, LocalSerializedObjectIdentifier v)
        {
            int index = arr.IndexOf(v);
            if (index >= 0)
                return index;

            arr.Add(v);
            return arr.Count - 1;
        }

        static int FindOrCreateSerializedTypeForUnityType(List<SerializedType> serializedTypes, SerializedType unityType, bool isStripped, short scriptTypeIndex, int originalTypeId = -1)
        {
            int findPersistentTypeID = unityType.m_PersistentTypeID;
            for (int i = 0; i < serializedTypes.Count; ++i)
            {
                SerializedType serializedType = serializedTypes[i];
                if (serializedType.m_PersistentTypeID == findPersistentTypeID &&
                    serializedType.m_IsStrippedType == isStripped &&
                    serializedType.m_ScriptTypeIndex == scriptTypeIndex &&
                    (originalTypeId < 0 || serializedTypes[originalTypeId].m_PersistentTypeID == findPersistentTypeID))
                {
                    return i;
                }
                i++;
            }

            {
                SerializedType serializedType = new SerializedType(findPersistentTypeID, isStripped, scriptTypeIndex);
                serializedTypes.Add(serializedType);
            }

            if (originalTypeId >= 0 && serializedTypes[originalTypeId].m_OldTypeHash != serializedTypes[serializedTypes.Count - 1].m_OldTypeHash)
            {
                if (serializedTypes[originalTypeId].m_OldType != null)
                {
                    serializedTypes[serializedTypes.Count - 1].m_OldType = serializedTypes[originalTypeId].m_OldType;
                }
                serializedTypes[serializedTypes.Count - 1].m_OldTypeHash = serializedTypes[originalTypeId].m_OldTypeHash;
            }

            return serializedTypes.Count - 1;
        }

        static uint kMaxSerializedFileSize = 4294967295U;// 4Gb
        public static string PrintSerializedFileLoadError(string printablePath, int fileSize, SerializedFileLoadError error)
        {
            string errorMessage = string.Empty;
            switch (error)
            {
                case SerializedFileLoadError.kSerializedFileLoadError_Unknown:
                    errorMessage = string.Format("Unknown error occurred while loading '{0}'.", printablePath);
                    break;

                case SerializedFileLoadError.kSerializedFileLoadError_HigherSerializedFileVersion:
                    errorMessage = string.Format("Failed to load '{0}'. File may be corrupted or was serialized with a newer version of Unity.", printablePath);
                    break;

                case SerializedFileLoadError.kSerializedFileLoadError_MergeConflicts:
                    errorMessage = string.Format("The file '{0}' seems to have merge conflicts. Please open it in a text editor and fix the merge.\n", printablePath);
                    break;

                case SerializedFileLoadError.kSerializedFileLoadError_OversizedFile:
                    errorMessage = string.Format("Serialized file size of {0} ({1} bytes) exceeds maximum. File name: '{2}'.  Serialized files over {3} ({4} bytes) cannot be loaded by the player.  Some likely ways to reduce this are utilizing asset bundles, re-balancing asset locations, or limiting their serialized size e.g. limiting the maximum texture sizes.", EditorUtility.FormatBytes(fileSize), fileSize, printablePath, EditorUtility.FormatBytes(kMaxSerializedFileSize), kMaxSerializedFileSize);
                    break;

                case SerializedFileLoadError.kSerializedFileLoadError_EmptyOrCorruptFile:
                    errorMessage = string.Format("Error loading the file '{0}'. File is either empty or corrupted, please verify the file contents.", printablePath);
                    break;

                case SerializedFileLoadError.kSerializedFileLoadError_None:
                    break;
            }

            return errorMessage;
        }
    }

    public class SerializedType
    {
        public TypeTree m_OldType;
        public TypeTreeNode[] m_Nodes;
        public string m_StringBuffer;

        public int m_PersistentTypeID;

        public Hash128 m_ScriptID;         // Hash generated from assembly name, namespace, and class name, only available for script.
        public Hash128 m_OldTypeHash;      // Old type tree hash.

        public bool m_IsStrippedType;
        public short m_ScriptTypeIndex;
        public int m_Equals;

        public uint[] m_TypeDependencies;

        // Only used for Referenced types
        public string m_KlassName;
        public string m_NameSpace;
        public string m_AsmName;

        public SerializedType(int typeID, bool isStrippedType, short scriptTypeIdx = -1)
        {
            m_PersistentTypeID = typeID;
            m_IsStrippedType = isStrippedType;
            m_ScriptTypeIndex = scriptTypeIdx;
            m_Equals = kNotCompared;
        }

        public static bool kSwap = false;
        public static int UndefinedPersistentTypeID = -1;
        public static int kMonoBehaviourPersistentID = 114;
        public static int kScriptedImporterPersistentID = 0x7C90B5B3;
        public static int kEqual = 0, kNotEqual = 1, kNotCompared = -1;
        public bool ReadType(bool kIsAReferencedType, BinaryStreamReader me, uint version, bool enableTypeTree, bool ignoreScriptTypeForHash)
        {
            if (version < (uint)SerializedFileFormatVersion.kRefactoredClassId)
            {
                // Before version 'kSerializeVersionRefactoredClassId', the typeID was either the ClassID or - if the ClassID was
                // equal to MonoBehavior - it was a negative identifier used as a key for the TypeMap. Since version 'kSerializeVersionRefactoredClassId'
                // the typeID is a direct index into the m_Types vector and the ClassID is now stored in the Type-Entry and not encoded in the typeID.
                int typeID = me.ReadSInt32();
                m_PersistentTypeID = typeID < 0 ? UndefinedPersistentTypeID : typeID;

                m_IsStrippedType = false;
                m_ScriptTypeIndex = -1;
            }
            else
            {
                m_PersistentTypeID = me.ReadSInt32();
                m_IsStrippedType = me.ReadBoolean();
            }

            if (version >= (uint)SerializedFileFormatVersion.kRefactorTypeData)
            {
                m_ScriptTypeIndex = me.ReadSInt16();
            }

            if (version >= (uint)SerializedFileFormatVersion.kHasTypeTreeHashes)
            {
                // Read the scriptID only when it's script.
                bool readScriptIdHash = m_PersistentTypeID == UndefinedPersistentTypeID || m_PersistentTypeID == kMonoBehaviourPersistentID;

                if (!ignoreScriptTypeForHash)
                    readScriptIdHash |= m_ScriptTypeIndex >= 0;

                if (readScriptIdHash)
                {
                    m_ScriptID = new Hash128(me.ReadUInt32(), me.ReadUInt32(), me.ReadUInt32(), me.ReadUInt32());
                }
                else if (m_PersistentTypeID == kScriptedImporterPersistentID)
                {
                    // This is a patch to recover from bug 1025425, where scripted importers were not getting their
                    // script id stored in the meta: this forces SafeBinaryRead to be used in case script has changed.
                    m_Equals = kNotEqual;
                }
                m_OldTypeHash = new Hash128(me.ReadUInt32(), me.ReadUInt32(), me.ReadUInt32(), me.ReadUInt32());
            }

            if (enableTypeTree)
            {
                m_OldType = new TypeTree();
                if (!ReadTypeTree(me, m_OldType, version))
                {
                    m_OldType = null;
                    return false;
                }

                if (version >= (uint)SerializedFileFormatVersion.kStoresTypeDependencies)
                {
                    if (kIsAReferencedType)
                    {
                        // Only used for Referenced types
                        m_KlassName = me.ReadString();
                        m_NameSpace = me.ReadString();
                        m_AsmName = me.ReadString();
                    }
                    else
                    {
                        int items = me.ReadSInt32();
                        if (items > 0)
                        {
                            m_TypeDependencies = Enumerable.Repeat(0xBAADF00D, items).ToArray();
                            int readSize = sizeof(uint) * items;
                            if (me.Position + readSize < me.Length)
                            {
                                byte[] buffer = new byte[readSize];
                                me.Read(buffer, 0, readSize);
                                ReadBinaryHeader.ReadFileCache(out m_TypeDependencies, buffer, 0, sizeof(uint), items);
                                if (kSwap)
                                {
                                    for (int i = 0; i < m_TypeDependencies.Length; ++i)
                                        ReadBinaryHeader.SwapEndianBytes(ref m_TypeDependencies[i]);
                                }
                            }
                            else
                                return false;
                        }
                    }
                }
            }

            return true;
        }

        private bool ReadTypeTree(BinaryStreamReader me, TypeTree type, uint version)
        {
            if (version >= (uint)SerializedFileFormatVersion.kUnknown_12 || version == (uint)SerializedFileFormatVersion.kUnknown_10)
            {
                return BlobRead(me, type, version);
            }
            else
            {
                return ReadTypeTreeImpl(me, type, version, 0);
            }
        }

        static int kMaxDepth = 50, kMaxChildrenCount = 5000;
        private bool ReadTypeTreeImpl(BinaryStreamReader me, TypeTree type, uint version, int depth)
        {
            ref TypeTreeNode t = ref type.m_Node;

            // Read Type
            string typeString = me.ReadString();
            if (string.IsNullOrEmpty(typeString))
                return false;
            type.m_Type = typeString;

            // Read Name
            string nameString = me.ReadString();
            if (string.IsNullOrEmpty(nameString))
                return false;
            type.m_Name = nameString;

            // Read bytesize
            t.m_ByteSize = me.ReadSInt32();

            // Read variable count
            if (version == (uint)SerializedFileFormatVersion.kUnknown_2)
            {
                int variableCount = me.ReadSInt32();
            }

            // Read Typetree position
            if (version != (uint)SerializedFileFormatVersion.kUnknown_3)
            {
                t.m_Index = me.ReadSInt32();
            }

            // Read TypeFlags
            t.m_TypeFlags = (byte)me.ReadByte();

            // Read version
            t.m_Version = me.ReadSInt16();

            // Read metaflag
            if (version != (uint)SerializedFileFormatVersion.kUnknown_3)
            {
                t.m_MetaFlag = me.ReadUInt32();
            }

            // Read Children count
            int childrenCount = me.ReadSInt32();

            depth++;
            if (depth > kMaxDepth || childrenCount < 0 || childrenCount > kMaxChildrenCount)
            {
                depth--;
                //ErrorString("Fatal error while reading file. Header is invalid!");
                return false;
            }
            // Read children
            for (int i = 0; i < childrenCount; i++)
            {
                TypeTree child = type.AddChildNode();
                if (!ReadTypeTreeImpl(me, child, version, depth))
                {
                    depth--;
                    return false;
                }
                child.m_Father = type;
            }
            depth--;
            return true;
        }

        private bool BlobRead(BinaryStreamReader me, TypeTree type, uint version)
        {
            ref TypeTreeNode t = ref type.m_Node;

            if (version <= (uint)SerializedFileFormatVersion.kRefactorTypeData)
                return BlobReadV17AndPrior(me, type, version);

            uint numberOfNodes;
            numberOfNodes = me.ReadUInt32();
            if (numberOfNodes == 0)
                return true;

            uint numberOfChars = me.ReadUInt32();
            if (kSwap)
            {
                ReadBinaryHeader.SwapEndianBytes(ref numberOfNodes);
                ReadBinaryHeader.SwapEndianBytes(ref numberOfChars);
            }

            if (me.Position + Marshal.SizeOf(t) * numberOfNodes + numberOfChars > me.Length)
                return false;

            {
                int readSize = Marshal.SizeOf(t) * (int)numberOfNodes;
                byte[] buffer = new byte[readSize];
                me.Read(buffer, 0, readSize);
                ReadBinaryHeader.ReadFileCache(out m_Nodes, buffer, 0, Marshal.SizeOf(t), (int)numberOfNodes);
            }
            {
                int readSize = (int)numberOfChars;
                byte[] buffer = new byte[readSize];
                me.Read(buffer, 0, readSize);
                m_StringBuffer = System.Text.Encoding.UTF8.GetString(buffer);
            }

            if (version < (uint)SerializedFileFormatVersion.kRefactorTypeData) // type tree node gets a type flag
            {
                if (kSwap)
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Version);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_TypeStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_NameStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_ByteSize);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Index);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_MetaFlag);
                        n.m_TypeFlags = (byte)(n.m_TypeFlags != 0 ? TypeTreeNode.ETypeFlags.kFlagIsArray : 0);
                    }
                }
                else
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        n.m_TypeFlags = (byte)(n.m_TypeFlags != 0 ? TypeTreeNode.ETypeFlags.kFlagIsArray : 0);
                    }
                }
            }
            else
            {
                if (kSwap)
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Version);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_TypeStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_NameStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_ByteSize);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Index);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_MetaFlag);
                    }
                }
            }

            int index = 0;
            BuildTypeTree(type, index);
            BuildHierarchyTypeTree(type, ref index, 0);

            return true;
        }

        private void BuildTypeTree(TypeTree type, int index)
        {
            ref TypeTreeNode t = ref m_Nodes[index];

            type.m_Node = t;
            type.m_Type = CalculateString(t.m_TypeStrOffset, m_StringBuffer);
            type.m_Name = CalculateString(t.m_NameStrOffset, m_StringBuffer);
        }

        // String bits
        // the MSB is set if the string offset is an offset into the Unity::CommonString::BufferBegin; otherwise it offsets into the
        // TypeTree-local string buffer.
        static uint kCommonStringBit = 0x80000000U;
        static uint kStringOffsetMask = ~kCommonStringBit;
        private string CalculateString(uint offset, string stringBuffer)
        {
            int index = (int)(offset & kStringOffsetMask);
            string buffer = (offset & kCommonStringBit) != 0 ? Unity.CommonString.BufferBegin : stringBuffer;
            return buffer.Substring(index, buffer.IndexOf('\0', index) - index);
        }

        private bool BuildHierarchyTypeTree(TypeTree type, ref int index, int depth)
        {
            index++;

            depth++;
            // Read children 
            for (int childrenCount = 0; index < m_Nodes.Length; index++)
            {
                if (depth > kMaxDepth || childrenCount < 0 || childrenCount > kMaxChildrenCount)
                {
                    depth--;
                    //ErrorString("Fatal error while reading file. Header is invalid!");
                    return false;
                }
                ref TypeTreeNode t = ref m_Nodes[index];
                if (t.m_Level == depth)
                {
                    TypeTree newType = new TypeTree();
                    BuildTypeTree(newType, index);

                    type.m_Children.Add(newType);
                    newType.m_Father = type;
                    childrenCount++;
                    BuildHierarchyTypeTree(newType, ref index, depth);
                }
                else
                {
                    index--;
                    break;
                }
            }
            depth--;
            return true;
        }

        unsafe private bool BlobReadV17AndPrior(BinaryStreamReader me, TypeTree type, uint version)
        {
            ref TypeTreeNode t = ref type.m_Node;

            uint numberOfNodes;
            numberOfNodes = me.ReadUInt32();
            if (numberOfNodes == 0)
                return true;

            uint numberOfChars = me.ReadUInt32();
            if (kSwap)
            {
                ReadBinaryHeader.SwapEndianBytes(ref numberOfNodes);
                ReadBinaryHeader.SwapEndianBytes(ref numberOfChars);
            }

            // Prior to 18, node type was smaller.
            TypeTreeNode dummyNode;
            int oldNodeSize = (int)((long)&(dummyNode.m_RefTypeHash) - (long)&dummyNode);

            if (me.Position + oldNodeSize * numberOfNodes + numberOfChars > me.Length)
                return false;

            {
                int readSize = oldNodeSize * (int)numberOfNodes;
                byte[] buffer = new byte[readSize];
                me.Read(buffer, 0, readSize);
                ReadBinaryHeader.ReadFileCache(out m_Nodes, buffer, 0, oldNodeSize, (int)numberOfNodes);
            }
            {
                int readSize = (int)numberOfChars;
                byte[] buffer = new byte[readSize];
                me.Read(buffer, 0, readSize);
                m_StringBuffer = System.Text.Encoding.UTF8.GetString(buffer);
            }

            if (version < (uint)SerializedFileFormatVersion.kTypeTreeNodeWithTypeFlags)
            {
                if (kSwap)
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Version);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_TypeStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_NameStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_ByteSize);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Index);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_MetaFlag);
                        n.m_TypeFlags = (byte)(n.m_TypeFlags != 0 ? TypeTreeNode.ETypeFlags.kFlagIsArray : 0);
                    }
                }
                else
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        n.m_TypeFlags = (byte)(n.m_TypeFlags != 0 ? TypeTreeNode.ETypeFlags.kFlagIsArray : 0);
                    }
                }
            }
            else
            {
                if (kSwap)
                {
                    for (int i = 0; i < numberOfNodes; ++i)
                    {
                        ref TypeTreeNode n = ref m_Nodes[i];
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Version);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_TypeStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_NameStrOffset);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_ByteSize);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_Index);
                        ReadBinaryHeader.SwapEndianBytes(ref n.m_MetaFlag);
                    }
                }
            }

            int index = 0;
            BuildTypeTree(type, index);
            BuildHierarchyTypeTree(type, ref index, 0);

            return true;
        }
    }
}