﻿--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Api @ detailed terminology.
---   // The fully qualified name of this interface, including package name
---   // followed by the interface's simple name.
---@field name string 
--- 
---   // The methods of this interface, in unspecified order.
---@field methods pbcmessage.Method[] 
--- 
---   // Any metadata attached to the interface.
---@field options pbcmessage.Option[] 
--- 
---   // A version string for this interface. If specified, must have the form
---   // `major-version.minor-version`, as in `1.10`. If the minor version is
---   // omitted, it defaults to zero. If the entire version field is empty, the
---   // major version is derived from the package name, as outlined below. If the
---   // field is not empty, the version in the package name will be verified to be
---   // consistent with what is provided here.
---   //
---   // The versioning schema uses [semantic
---   // versioning](http://semver.org) where the major version number
---   // indicates a breaking change and the minor version an additive,
---   // non-breaking change. Both version numbers are signals to users
---   // what to expect from different versions, and should be carefully
---   // chosen based on the product plan.
---   //
---   // The major version is also reflected in the package name of the
---   // interface, which must end in `v<major-version>`, as in
---   // `google.feature.v1`. For major versions 0 and 1, the suffix can
---   // be omitted. Zero major versions must only be used for
---   // experimental, non-GA interfaces.
---   //
---   //
---@field version string 
--- 
---   // Source context for the protocol buffer service represented by this
---   // message.
---@field source_context pbcmessage.SourceContext 
--- 
---   // Included interfaces. See [Mixin][].
---@field mixins pbcmessage.Mixin[] 
--- 
---   // The source syntax of the service.
---@field syntax pbcmessage.Syntax 
local  Api  = {}
---@class pbcmessage.Method @ Method represents a method of an API interface.
---   // The simple name of this method.
---@field name string 
--- 
---   // A URL of the input message type.
---@field request_type_url string 
--- 
---   // If true, the request is streamed.
---@field request_streaming boolean 
--- 
---   // The URL of the output message type.
---@field response_type_url string 
--- 
---   // If true, the response is streamed.
---@field response_streaming boolean 
--- 
---   // Any metadata attached to the method.
---@field options pbcmessage.Option[] 
--- 
---   // The source syntax of this method.
---@field syntax pbcmessage.Syntax 
local  Method  = {}
---@class pbcmessage.Mixin @     }
---   // The fully qualified name of the interface which is included.
---@field name string 
--- 
---   // If non-empty specifies a path under which inherited HTTP paths
---   // are rooted.
---@field root string 
local  Mixin  = {}
