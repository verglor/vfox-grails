package.path = package.path .. ";lib/?.lua"

_G.PLUGIN = {}
_G.RUNTIME = { osType = "linux" }

dofile("hooks/env_keys.lua")

local function result_map(ctx)
    local t = {}
    for _, e in ipairs(PLUGIN:EnvKeys(ctx)) do
        t[e.key] = e.value
    end
    return t
end

describe("PLUGIN:EnvKeys", function()
    it("sets GRAILS_HOME to the sdk path", function()
        local env = result_map({ path = "/opt/grails/6.2.3" })
        assert.are.equal("/opt/grails/6.2.3", env.GRAILS_HOME)
    end)

    it("adds bin/ subdir to PATH", function()
        local env = result_map({ path = "/opt/grails/6.2.3" })
        assert.are.equal("/opt/grails/6.2.3/bin", env.PATH)
    end)

    it("returns exactly two entries", function()
        local result = PLUGIN:EnvKeys({ path = "/opt/grails/7.1.0" })
        assert.are.equal(2, #result)
    end)
end)
