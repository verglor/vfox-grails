package.path = package.path .. ";lib/?.lua"

_G.PLUGIN = {}
_G.RUNTIME = { osType = "linux" }

dofile("hooks/parse_legacy_file.lua")

local util = require("util")

describe("util.parseSdkmanrc", function()
    it("simple grails entry", function()
        assert.are.equal("7.0.0", util.parseSdkmanrc("grails=7.0.0\n"))
    end)

    it("grails among multiple SDKs", function()
        local content = "# SDKMAN config\ngradle=7.4.2\ngrails=6.2.3\njava=11.0.12-open\n"
        assert.are.equal("6.2.3", util.parseSdkmanrc(content))
    end)

    it("whitespace around equals", function()
        assert.are.equal("7.1.0", util.parseSdkmanrc("grails = 7.1.0\n"))
    end)

    it("no grails key returns nil", function()
        assert.is_nil(util.parseSdkmanrc("gradle=7.4.2\njava=11.0.12\n"))
    end)

    it("comment-only file returns nil", function()
        assert.is_nil(util.parseSdkmanrc("# just a comment\n"))
    end)

    it("empty file returns nil", function()
        assert.is_nil(util.parseSdkmanrc(""))
    end)
end)

describe("util.parseVersionFile", function()
    it("plain version string", function()
        assert.are.equal("7.0.0", util.parseVersionFile("7.0.0\n"))
    end)

    it("comment then version", function()
        assert.are.equal("6.2.3", util.parseVersionFile("# pinned version\n6.2.3\n"))
    end)

    it("leading/trailing whitespace trimmed", function()
        assert.are.equal("3.3.9", util.parseVersionFile("  3.3.9  \n"))
    end)

    it("empty file returns nil", function()
        assert.is_nil(util.parseVersionFile(""))
    end)

    it("all comments returns nil", function()
        assert.is_nil(util.parseVersionFile("# no version here\n"))
    end)
end)

describe("PLUGIN:ParseLegacyFile", function()
    local function with_tmpfile(content, fn)
        local path = os.tmpname()
        local f = io.open(path, "w")
        f:write(content)
        f:close()
        local ok, err = pcall(fn, path)
        os.remove(path)
        if not ok then error(err, 2) end
    end

    it(".sdkmanrc extracts grails version", function()
        with_tmpfile("grails=7.1.0\n", function(path)
            local result = PLUGIN:ParseLegacyFile({ filename = ".sdkmanrc", filepath = path })
            assert.are.equal("7.1.0", result.version)
        end)
    end)

    it(".grails-version extracts version", function()
        with_tmpfile("6.2.3\n", function(path)
            local result = PLUGIN:ParseLegacyFile({ filename = ".grails-version", filepath = path })
            assert.are.equal("6.2.3", result.version)
        end)
    end)

    it(".sdkmanrc without grails key errors", function()
        with_tmpfile("gradle=7.4.2\n", function(path)
            local ok, err = pcall(PLUGIN.ParseLegacyFile, PLUGIN, { filename = ".sdkmanrc", filepath = path })
            assert.is_false(ok)
            assert.truthy(err:find("no grails key"))
        end)
    end)

    it(".grails-version empty file errors", function()
        with_tmpfile("", function(path)
            assert.is_false((pcall(PLUGIN.ParseLegacyFile, PLUGIN, { filename = ".grails-version", filepath = path })))
        end)
    end)
end)