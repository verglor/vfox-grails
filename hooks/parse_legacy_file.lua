local util = require("util")

--- Called by vfox when a legacy version file is found in the current directory tree.
--- @param ctx table Context with ctx.filename and ctx.filepath
function PLUGIN:ParseLegacyFile(ctx)
    local f = io.open(ctx.filepath, "r")
    if not f then error("cannot open " .. ctx.filepath) end
    local content = f:read("*a")
    f:close()

    local version
    if ctx.filename == ".sdkmanrc" then
        version = util.parseSdkmanrc(content)
        if not version then
            error("no grails key found in " .. ctx.filepath)
        end
    elseif ctx.filename == ".grails-version" then
        version = util.parseVersionFile(content)
        if not version then
            error("empty or missing version in " .. ctx.filepath)
        end
    end

    return { version = version }
end
