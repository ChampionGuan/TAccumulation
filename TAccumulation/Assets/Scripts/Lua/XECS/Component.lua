-- Collection of utilities for handling Components
---用来创建component子类的注册器
---@class XECS.Component
---@field entity Entity
local Component = {}
Component.all = XECS.DT()

---创建一个component子类
---@param name string Component的类名
---@param parent Class
function Component.Create(name, parent)
    local component = XECS.class(name, parent)
    Component._Register(component)

    return component
end

---注册component类
---@param componentClass object component子类
function Component._Register(componentClass)
    Component.all[componentClass.__cname] = componentClass
end

---@param names string[] 类名列表
---@return table[] 类列表，可以用来生成实例
function Component.Load(names)
    local components = {}

    for _, name in ipairs(names) do
        components[#components+1] = Component.all[name]
    end
    return unpack(components)
end

return Component
