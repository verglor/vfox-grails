package.path = package.path .. ";lib/?.lua"

local util = require("util")

describe("util.compareVersions", function()
    it("returns -1 when v1 < v2", function()
        assert.are.equal(-1, util.compareVersions("1.0.0", "2.0.0"))
    end)

    it("returns 0 when versions are equal", function()
        assert.are.equal(0, util.compareVersions("6.2.3", "6.2.3"))
    end)

    it("returns 1 when v1 > v2", function()
        assert.are.equal(1, util.compareVersions("7.1.0", "6.2.3"))
    end)

    it("compares segments numerically (1.10 > 1.9)", function()
        assert.are.equal(1, util.compareVersions("1.10.0", "1.9.0"))
    end)

    it("treats missing segments as 0 (1.0 == 1.0.0)", function()
        assert.are.equal(0, util.compareVersions("1.0", "1.0.0"))
    end)
end)

describe("util.findBestVersion", function()
    local versions = {
        ["3.3.9"]  = "url-3",
        ["6.1.0"]  = "url-6.1",
        ["6.2.3"]  = "url-6.2",
        ["7.1.0"]  = "url-7",
    }

    it("finds the best match for a major prefix", function()
        assert.are.equal("6.2.3", util.findBestVersion(versions, "6"))
    end)

    it("finds the best match for a major.minor prefix", function()
        assert.are.equal("6.2.3", util.findBestVersion(versions, "6.2"))
    end)

    it("finds the highest version for empty prefix (latest)", function()
        assert.are.equal("7.1.0", util.findBestVersion(versions, ""))
    end)

    it("exact version returns that version", function()
        assert.are.equal("3.3.9", util.findBestVersion(versions, "3.3.9"))
    end)

    it("returns nil when no version matches", function()
        assert.is_nil(util.findBestVersion(versions, "99"))
    end)

    it("returns nil for empty table", function()
        assert.is_nil(util.findBestVersion({}, "6"))
    end)

    it("does not match 3 when only 3.3.9 present (no false major match on 30.x)", function()
        local v = { ["3.3.9"] = true, ["30.0.0"] = true }
        assert.are.equal("3.3.9", util.findBestVersion(v, "3"))
    end)
end)
