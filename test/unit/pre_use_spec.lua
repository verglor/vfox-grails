package.path = package.path .. ";lib/?.lua"

_G.PLUGIN = {}
_G.RUNTIME = { osType = "linux" }

dofile("hooks/pre_use.lua")

local installed = { ["3.3.13"] = true, ["6.1.2"] = true, ["7.0.7"] = true }

local function ctx(version, previousVersion)
    return { version = version, previousVersion = previousVersion or "", installedSdks = installed }
end

describe("PLUGIN:PreUse", function()
    it("exact match", function()
        assert.are.equal("6.1.2", PLUGIN:PreUse(ctx("6.1.2")).version)
    end)

    it("prefix: major only resolves to latest patch", function()
        assert.are.equal("6.1.2", PLUGIN:PreUse(ctx("6")).version)
    end)

    it("prefix: major.minor resolves to latest patch", function()
        assert.are.equal("6.1.2", PLUGIN:PreUse(ctx("6.1")).version)
    end)

    it("prefix: no false match on 3 when 3.3.13 installed", function()
        assert.are.equal("3.3.13", PLUGIN:PreUse(ctx("3")).version)
    end)

    it("latest resolves to highest installed version", function()
        assert.are.equal("7.0.7", PLUGIN:PreUse(ctx("latest")).version)
    end)

    it("fallback to previousVersion when version is empty", function()
        assert.are.equal("6.1.2", PLUGIN:PreUse(ctx("", "6.1.2")).version)
    end)

    it("fallback to previousVersion when version is nil", function()
        assert.are.equal("7.0.7", PLUGIN:PreUse(ctx(nil, "7.0.7")).version)
    end)

    it("error when version not installed", function()
        local ok, err = pcall(PLUGIN.PreUse, PLUGIN, ctx("99"))
        assert.is_false(ok)
        assert.truthy(tostring(err):find("not installed") ~= nil)
    end)

    it("error when no version and no previousVersion", function()
        assert.has_error(function()
            PLUGIN:PreUse(ctx("", ""))
        end)
    end)
end)