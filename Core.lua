return 
{
    class = function()
        local class = {}
        class.__index = class
        class.new = function(...)
            local object = setmetatable({}, class)
            class.init(object, ...)
            return object
        end
        return class
    end
}
