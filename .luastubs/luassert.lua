---@meta

---@class luassert.modifier
---@field equal fun(expected: any, actual: any, msg?: string)
---@field same fun(expected: any, actual: any, msg?: string)
---@field near fun(expected: number, actual: number, tolerance: number, msg?: string)
---@field matches fun(pattern: string, actual: string, msg?: string)
---@field errors fun(fn: fun(), msg?: string)

---@class luassert: fun(...: any): any
---@field are luassert.modifier
---@field is luassert.modifier
---@field is_false fun(value: any, msg?: string)
---@field is_true fun(value: any, msg?: string)
---@field is_nil fun(value: any, msg?: string)
---@field is_not_nil fun(value: any, msg?: string)
---@field truthy fun(value: any, msg?: string)
---@field falsy fun(value: any, msg?: string)
---@field has_error fun(fn: fun(), msg?: string)
---@field has_no_error fun(fn: fun(), msg?: string)
---@field equal fun(expected: any, actual: any, msg?: string)
---@field same fun(expected: any, actual: any, msg?: string)

---@type luassert
assert = assert