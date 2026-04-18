local util = {}

--- Compare two version strings numerically, segment by segment
--- @param v1 string First version
--- @param v2 string Second version
--- @return number -1 if v1 < v2, 0 if equal, 1 if v1 > v2
function util.compareVersions(v1, v2)
    local function segments(v)
        local t = {}
        for n in v:gmatch("%d+") do t[#t + 1] = tonumber(n) end
        return t
    end
    local s1, s2 = segments(v1), segments(v2)
    for i = 1, math.max(#s1, #s2) do
        local a = s1[i] or 0
        local b = s2[i] or 0
        if a ~= b then
            if a < b then return -1 else return 1 end
        end
    end
    return 0
end

--- Find the highest version matching a prefix among a table keyed by version strings
--- @param versions table Table keyed by version strings
--- @param prefix string Version prefix ("6" matches "6.x.x", "" matches all)
--- @return string|nil The best matching version key, or nil if none found
function util.findBestVersion(versions, prefix)
    local best = nil
    for v, _ in pairs(versions) do
        local rest = v:sub(#prefix + 1)
        if prefix == "" or (v:sub(1, #prefix) == prefix and (rest == "" or rest:sub(1, 1) == ".")) then
            if not best or util.compareVersions(v, best) > 0 then
                best = v
            end
        end
    end
    return best
end

--- Parse .sdkmanrc file content, return value of "grails" key or nil
--- @param content string File content
--- @return string|nil Version string or nil if grails key not found
function util.parseSdkmanrc(content)
    for line in content:gmatch("[^\n]+") do
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed ~= "" and not trimmed:match("^#") then
            local v = trimmed:match("^grails%s*=%s*(.+)$")
            if v then return v end
        end
    end
    return nil
end

--- Parse a simple version file, return first non-blank, non-comment line or nil
--- @param content string File content
--- @return string|nil Version string or nil if no version found
function util.parseVersionFile(content)
    for line in content:gmatch("[^\n]+") do
        local trimmed = line:match("^%s*(.-)%s*$") or ""
        if trimmed ~= "" and not trimmed:match("^#") then
            return trimmed
        end
    end
    return nil
end

return util
