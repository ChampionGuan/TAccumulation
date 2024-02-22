﻿--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DescriptorProto @ Describes a message type.
---@field string boolean 
--- 
---@field field pbcmessage.FieldDescriptorProto[] 
---@field extension pbcmessage.FieldDescriptorProto[] 
--- 
---@field nested_type pbcmessage.DescriptorProto[] 
---@field enum_type pbcmessage.EnumDescriptorProto[] 
--- 
---@field int32 boolean @ Inclusive.
---@field int32 boolean @ Exclusive.
--- 
---@field ExtensionRangeOptions boolean 
local  DescriptorProto  = {}
---@class pbcmessage.EnumDescriptorProto @ Describes an enum type.
---@field string boolean 
--- 
---@field value pbcmessage.EnumValueDescriptorProto[] 
--- 
---@field EnumOptions boolean 
--- 
---   // Range of reserved numeric values. Reserved values may not be used by
---   // entries in the same enum. Reserved ranges may not overlap.
---   //
---   // Note that this is distinct from DescriptorProto.ReservedRange in that it
---   // is inclusive such that it can appropriately represent the entire int32
---   // domain.
---@field int32 boolean @ Inclusive.
---@field int32 boolean @ Inclusive.
local  EnumDescriptorProto  = {}
---@class pbcmessage.EnumOptions 
--- 
---   // Set this option to true to allow mapping different tag names to the same
---   // value.
---@field bool boolean 
--- 
---   // Is this enum deprecated?
---   // Depending on the target platform, this can emit Deprecated annotations
---   // for the enum, or it will be completely ignored; in the very least, this
---   // is a formalization for deprecating enums.
---@field bool boolean 
--- 
---   reserved 5;  // javanano_as_lite
--- 
---   // The parser stores options it doesn't recognize here. See above.
---@field uninterpreted_option pbcmessage.UninterpretedOption[] 
--- 
---   // Clients can define custom options in extensions of this message. See above.
---   extensions 1000 to max;
local  EnumOptions  = {}
---@class pbcmessage.EnumValueDescriptorProto @ Describes a value within an enum.
---@field string boolean 
---@field int32 boolean 
--- 
---@field EnumValueOptions boolean 
local  EnumValueDescriptorProto  = {}
---@class pbcmessage.EnumValueOptions 
---   // Is this enum value deprecated?
---   // Depending on the target platform, this can emit Deprecated annotations
---   // for the enum value, or it will be completely ignored; in the very least,
---   // this is a formalization for deprecating enum values.
---@field bool boolean 
--- 
---   // The parser stores options it doesn't recognize here. See above.
---@field uninterpreted_option pbcmessage.UninterpretedOption[] 
--- 
---   // Clients can define custom options in extensions of this message. See above.
---   extensions 1000 to max;
local  EnumValueOptions  = {}
---@class pbcmessage.ExtensionRangeOptions @   A given name may only be reserved once.
---   // The parser stores options it doesn't recognize here. See above.
---@field uninterpreted_option pbcmessage.UninterpretedOption[] 
--- 
--- 
---   // Clients can define custom options in extensions of this message. See above.
---   extensions 1000 to max;
local  ExtensionRangeOptions  = {}
---@class pbcmessage.FieldDescriptorProto @ Describes a field within a message.
---     // 0 is reserved for errors.
---     // Order is weird for historical reasons.
---@field  1 pbcmessage.TYPE_DOUBLE 
---@field  2 pbcmessage.TYPE_FLOAT 
---     // Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
---     // negative values are likely.
---@field  3 pbcmessage.TYPE_INT64 
---@field  4 pbcmessage.TYPE_UINT64 
---     // Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
---     // negative values are likely.
---@field  5 pbcmessage.TYPE_INT32 
---@field  6 pbcmessage.TYPE_FIXED64 
---@field  7 pbcmessage.TYPE_FIXED32 
---@field  8 pbcmessage.TYPE_BOOL 
---@field  9 pbcmessage.TYPE_STRING 
---     // Tag-delimited aggregate.
---     // Group type is deprecated and not supported in proto3. However, Proto3
---     // implementations should still be able to parse the group wire format and
---     // treat group fields as unknown fields.
---@field  10 pbcmessage.TYPE_GROUP 
---@field  11 pbcmessage.TYPE_MESSAGE 
--- 
---     // New in version 2.
---@field  12 pbcmessage.TYPE_BYTES 
---@field  13 pbcmessage.TYPE_UINT32 
---@field  14 pbcmessage.TYPE_ENUM 
---@field  15 pbcmessage.TYPE_SFIXED32 
---@field  16 pbcmessage.TYPE_SFIXED64 
---@field  17 pbcmessage.TYPE_SINT32 
---@field  18 pbcmessage.TYPE_SINT64 
local  FieldDescriptorProto  = {}
---@class pbcmessage.FieldOptions @   Clients can define custom options in extensions of this message. See above.
---   // The ctype option instructs the C++ code generator to use a different
---   // representation of the field than it normally would.  See the specific
---   // options below.  This option is not yet implemented in the open source
---   // release -- sorry, we'll try to include it in a future version!
---@field CType boolean 
---     // Default mode.
---@field  0 pbcmessage.STRING 
--- 
---@field  1 pbcmessage.CORD 
--- 
---@field  2 pbcmessage.STRING_PIECE 
local  FieldOptions  = {}
---@class pbcmessage.FileDescriptorProto @ Describes a complete .proto file.
---@field string boolean @ file name, relative to root of source tree
---@field string boolean @ e.g. "foo", "foo.bar", etc.
--- 
---   // Names of files imported by this file.
---@field dependency string[] 
---   // Indexes of the public imported files in the dependency list above.
---@field public_dependency number[] 
---   // Indexes of the weak imported files in the dependency list.
---   // For Google-internal migration only. Do not use.
---@field weak_dependency number[] 
--- 
---   // All top-level definitions in this file.
---@field message_type pbcmessage.DescriptorProto[] 
---@field enum_type pbcmessage.EnumDescriptorProto[] 
---@field service pbcmessage.ServiceDescriptorProto[] 
---@field extension pbcmessage.FieldDescriptorProto[] 
--- 
---@field FileOptions boolean 
--- 
---   // This field contains optional information about the original source code.
---   // You may safely remove this entire field without harming runtime
---   // functionality of the descriptors -- the information is needed only by
---   // development tools.
---@field SourceCodeInfo boolean 
--- 
---   // The syntax of the proto file.
---   // The supported values are "proto2" and "proto3".
---@field string boolean 
local  FileDescriptorProto  = {}
---@class pbcmessage.FileDescriptorSet @ files it parses.
---@field file pbcmessage.FileDescriptorProto[] 
local  FileDescriptorSet  = {}
---@class pbcmessage.FileOptions @   to automatically assign option numbers.
--- 
---   // Sets the Java package where classes generated from this .proto will be
---   // placed.  By default, the proto package is used, but this is often
---   // inappropriate because proto packages do not normally start with backwards
---   // domain names.
---@field string boolean 
--- 
--- 
---   // Controls the name of the wrapper Java class generated for the .proto file.
---   // That class will always contain the .proto file's getDescriptor() method as
---   // well as any top-level extensions defined in the .proto file.
---   // If java_multiple_files is disabled, then all the other classes from the
---   // .proto file will be nested inside the single wrapper outer class.
---@field string boolean 
--- 
---   // If enabled, then the Java code generator will generate a separate .java
---   // file for each top-level message, enum, and service defined in the .proto
---   // file.  Thus, these types will *not* be nested inside the wrapper class
---   // named by java_outer_classname.  However, the wrapper class will still be
---   // generated to contain the file's getDescriptor() method as well as any
---   // top-level extensions defined in the file.
---@field bool boolean 
--- 
---   // This option does nothing.
---@field bool boolean 
--- 
---   // If set true, then the Java2 code generator will generate code that
---   // throws an exception whenever an attempt is made to assign a non-UTF-8
---   // byte sequence to a string field.
---   // Message reflection will do the same.
---   // However, an extension field still accepts non-UTF-8 byte sequences.
---   // This option has no effect on when used with the lite runtime.
---@field bool boolean 
--- 
--- 
---   // Generated classes can be optimized for speed or code size.
---@field  1 pbcmessage.SPEED 
---                        // etc.
---@field  2 pbcmessage.CODE_SIZE 
---@field  3 pbcmessage.LITE_RUNTIME 
local  FileOptions  = {}
---@class pbcmessage.GeneratedCodeInfo @ source file, but may contain references to different source .proto files.
---   // An Annotation connects some span of text in generated code to an element
---   // of its generating .proto file.
---@field annotation pbcmessage.Annotation[] 
---     // Identifies the element in the original source .proto file. This field
---     // is formatted the same as SourceCodeInfo.Location.path.
---@field path number[] 
--- 
---     // Identifies the filesystem path to the original source .proto.
---@field string boolean 
--- 
---     // Identifies the starting offset in bytes in the generated code
---     // that relates to the identified object.
---@field int32 boolean 
--- 
---     // Identifies the ending offset in bytes in the generated code that
---     // relates to the identified offset. The end offset should be one past
---@field the pbcmessage.// relevant
---@field int32 boolean 
local  GeneratedCodeInfo  = {}
---@class pbcmessage.MessageOptions @   See the documentation for the "Options" section above.
---   // Set true to use the old proto1 MessageSet wire format for extensions.
---   // This is provided for backwards-compatibility with the MessageSet wire
---   // format.  You should not use this for any other reason:  It's less
---   // efficient, has fewer features, and is more complicated.
---   //
---   // The message must be defined exactly as follows:
---@field option pbcmessage.//  true
---   //     extensions 4 to max;
local  MessageOptions  = {}
---@class pbcmessage.MethodDescriptorProto @ Describes a method of a service.
---@field string boolean 
--- 
---   // Input and output type names.  These are resolved in the same way as
---   // FieldDescriptorProto.type_name, but must refer to a message type.
---@field string boolean 
---@field string boolean 
--- 
---@field MethodOptions boolean 
--- 
---   // Identifies if client streams multiple client messages
---@field bool boolean 
---   // Identifies if server streams multiple server messages
---@field bool boolean 
local  MethodDescriptorProto  = {}
---@class pbcmessage.MethodOptions 
--- 
---   // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
---   //   framework.  We apologize for hoarding these numbers to ourselves, but
---   //   we were already using them long before we decided to release Protocol
---   //   Buffers.
--- 
---   // Is this method deprecated?
---   // Depending on the target platform, this can emit Deprecated annotations
---   // for the method, or it will be completely ignored; in the very least,
---   // this is a formalization for deprecating methods.
---@field bool boolean 
--- 
---   // Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
---   // or neither? HTTP based RPC implementation may choose GET verb for safe
---   // methods, and PUT verb for idempotent methods instead of the default POST.
---@field  0 pbcmessage.IDEMPOTENCY_UNKNOWN 
---@field  1 pbcmessage.NO_SIDE_EFFECTS 
---@field  2 pbcmessage.IDEMPOTENT 
local  MethodOptions  = {}
---@class pbcmessage.OneofDescriptorProto @ Describes a oneof.
---@field string boolean 
---@field OneofOptions boolean 
local  OneofDescriptorProto  = {}
---@class pbcmessage.OneofOptions @  reserved 4;   removed jtype
---   // The parser stores options it doesn't recognize here. See above.
---@field uninterpreted_option pbcmessage.UninterpretedOption[] 
--- 
---   // Clients can define custom options in extensions of this message. See above.
---   extensions 1000 to max;
local  OneofOptions  = {}
---@class pbcmessage.ServiceDescriptorProto @ Describes a service.
---@field string boolean 
---@field method pbcmessage.MethodDescriptorProto[] 
--- 
---@field ServiceOptions boolean 
local  ServiceDescriptorProto  = {}
---@class pbcmessage.ServiceOptions 
--- 
---   // Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
---   //   framework.  We apologize for hoarding these numbers to ourselves, but
---   //   we were already using them long before we decided to release Protocol
---   //   Buffers.
--- 
---   // Is this service deprecated?
---   // Depending on the target platform, this can emit Deprecated annotations
---   // for the service, or it will be completely ignored; in the very least,
---   // this is a formalization for deprecating services.
---@field bool boolean 
--- 
---   // The parser stores options it doesn't recognize here. See above.
---@field uninterpreted_option pbcmessage.UninterpretedOption[] 
--- 
---   // Clients can define custom options in extensions of this message. See above.
---   extensions 1000 to max;
local  ServiceOptions  = {}
---@class pbcmessage.SourceCodeInfo @ FileDescriptorProto was generated.
---   // A Location identifies a piece of source code in a .proto file which
---   // corresponds to a particular definition.  This information is intended
---   // to be useful to IDEs, code indexers, documentation generators, and similar
---   // tools.
---   //
---   // For example, say we have a file like:
---@field optional pbcmessage.// foo
local  SourceCodeInfo  = {}
---@class pbcmessage.UninterpretedOption @ in them.
---   // The name of the uninterpreted option.  Each string represents a segment in
---   // a dot-separated name.  is_extension is true iff a segment represents an
---   // extension (denoted with parentheses in options specs in .proto files).
---   // "foo.(bar.baz).qux".
---@field string pbcmessage.required  1
---@field bool pbcmessage.required  2
local  UninterpretedOption  = {}
