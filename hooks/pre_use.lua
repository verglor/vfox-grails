local util = require("util")

--- When user invoke `use` command, this function will be called to get the
--- valid version information.
--- @param ctx table Context information
function PLUGIN:PreUse(ctx)
    local version = ctx.version

    -- Fallback: if no version given, use previously active version
    if not version or version == "" then
        version = ctx.previousVersion
        if not version or version == "" then
            error("No Grails version specified and no previously active version")
        end
    end

    -- "latest" → pick the highest installed version
    if version == "latest" then
        version = ""
    end

    -- Exact match
    if version ~= "" and ctx.installedSdks[version] then
        return { version = version }
    end

    -- Prefix/alias resolution: "7" → latest 7.x, "7.0" → latest 7.0.x, "" → overall latest
    local best = util.findBestVersion(ctx.installedSdks, version)
    if best then
        return { version = best }
    end

    error("Grails " .. version .. " is not installed. Run: vfox install grails@" .. version)
end
