package.path = package.path .. ";lib/?.lua"

local http_mock = {}
local html_mock = {}
package.loaded["http"] = http_mock
package.loaded["html"] = html_mock

_G.PLUGIN = {}
_G.RUNTIME = { osType = "linux" }

dofile("hooks/pre_install.lua")

local APACHE_URL   = "https://downloads.apache.org/grails/core/7.0.7/distribution/grails-7.0.7-bin.zip"
local NON_APACHE_URL = "https://github.com/grails/grails-core/releases/download/v6.1.2/grails-6.1.2.zip"
local FAKE_SHA512  = "abc123deadbeef"

-- Build a mock html document whose version-selector has options with text + value attr
local function make_doc(versions)
    local opts = {}
    for ver, url in pairs(versions) do
        table.insert(opts, {
            text = function() return ver end,
            attr = function(_, key) if key == "value" then return url end end,
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

local VERSIONS = {
    ["3.3.13"] = NON_APACHE_URL:gsub("6.1.2", "3.3.13"),
    ["6.1.0"]  = NON_APACHE_URL:gsub("6.1.2", "6.1.0"),
    ["6.1.2"]  = NON_APACHE_URL,
    ["7.0.7"]  = APACHE_URL,
}

local function setup_page(versions)
    http_mock.get = function(opts)
        if opts.url:find("sha512") then
            return { status_code = 200, body = FAKE_SHA512 .. "  grails-dist.zip" }, nil
        end
        return { status_code = 200, body = "" }, nil
    end
    html_mock.parse = function() return make_doc(versions) end
end

describe("PLUGIN:PreInstall", function()
    before_each(function() setup_page(VERSIONS) end)

    it("resolves an exact version", function()
        local r = PLUGIN:PreInstall({ version = "6.1.2" })
        assert.are.equal("6.1.2", r.version)
        assert.are.equal(NON_APACHE_URL, r.url)
    end)

    it("resolves a major prefix to the latest in that series", function()
        local r = PLUGIN:PreInstall({ version = "6" })
        assert.are.equal("6.1.2", r.version)
    end)

    it("resolves a major.minor prefix", function()
        local r = PLUGIN:PreInstall({ version = "6.1" })
        assert.are.equal("6.1.2", r.version)
    end)

    it("resolves latest to the highest available version", function()
        local r = PLUGIN:PreInstall({ version = "latest" })
        assert.are.equal("7.0.7", r.version)
    end)

    it("includes sha512 for Apache-hosted downloads", function()
        local r = PLUGIN:PreInstall({ version = "7.0.7" })
        assert.are.equal(FAKE_SHA512, r.sha512)
    end)

    it("omits sha512 for non-Apache downloads", function()
        local r = PLUGIN:PreInstall({ version = "6.1.2" })
        assert.is_nil(r.sha512)
    end)

    it("omits sha512 when checksum fetch fails", function()
        http_mock.get = function(opts)
            if opts.url:find("sha512") then
                return { status_code = 404, body = "" }, nil
            end
            return { status_code = 200, body = "" }, nil
        end
        local r = PLUGIN:PreInstall({ version = "7.0.7" })
        assert.is_nil(r.sha512)
    end)

    it("errors when version is not found", function()
        assert.has_error(function() PLUGIN:PreInstall({ version = "99" }) end)
    end)

    it("errors on HTTP failure fetching download page", function()
        http_mock.get = function() return nil, "timeout" end
        assert.has_error(function() PLUGIN:PreInstall({ version = "6.1.2" }) end)
    end)

    it("errors on non-200 response from download page", function()
        http_mock.get = function(opts)
            if not opts.url:find("sha512") then
                return { status_code = 500, body = "" }, nil
            end
        end
        assert.has_error(function() PLUGIN:PreInstall({ version = "6.1.2" }) end)
    end)
end)
