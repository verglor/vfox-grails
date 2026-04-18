package.path = package.path .. ";lib/?.lua"

-- Mocks must be in package.loaded before dofile so the hook captures them
local http_mock = {}
local html_mock = {}
package.loaded["http"] = http_mock
package.loaded["html"] = html_mock

_G.PLUGIN = {}
_G.RUNTIME = { osType = "linux" }

dofile("hooks/available.lua")

-- Build a mock html document whose version-selector contains `versions` (list of strings)
local function make_doc(versions)
    local opts = {}
    for _, v in ipairs(versions) do
        table.insert(opts, {
            text = function() return v end,
        })
    end
    local selector_div = {
        find = function(_, sel)
            assert(sel == "option")
            return { each = function(_, fn) for i, o in ipairs(opts) do fn(i, o) end end }
        end,
    }
    return {
        find = function(_, sel)
            if sel == "div.version-selector" then return selector_div end
        end,
    }
end

local function ok_http()
    http_mock.get = function() return { status_code = 200, body = "" }, nil end
end

describe("PLUGIN:Available", function()
    before_each(function()
        ok_http()
        html_mock.parse = function() return make_doc({ "3.3.13", "6.1.2", "7.0.7" }) end
    end)

    it("returns a list of version objects", function()
        local result = PLUGIN:Available({})
        assert.are.equal(3, #result)
    end)

    it("each entry has a version field", function()
        local result = PLUGIN:Available({})
        local versions = {}
        for _, v in ipairs(result) do versions[v.version] = true end
        assert.is_true(versions["7.0.7"])
        assert.is_true(versions["6.1.2"])
        assert.is_true(versions["3.3.13"])
    end)

    it("filters out empty and non-version strings", function()
        html_mock.parse = function()
            return make_doc({ "", "select a version", "7.0.7", "  " })
        end
        local result = PLUGIN:Available({})
        assert.are.equal(1, #result)
        assert.are.equal("7.0.7", result[1].version)
    end)

    it("errors on HTTP failure", function()
        http_mock.get = function() return nil, "connection refused" end
        assert.has_error(function() PLUGIN:Available({}) end)
    end)

    it("errors on non-200 response", function()
        http_mock.get = function() return { status_code = 503, body = "" }, nil end
        assert.has_error(function() PLUGIN:Available({}) end)
    end)

    it("errors when version-selector div is not found", function()
        html_mock.parse = function()
            return { find = function() return nil end }
        end
        assert.has_error(function() PLUGIN:Available({}) end)
    end)
end)
