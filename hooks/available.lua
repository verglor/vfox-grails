local http = require("http")
local html = require("html")

--- Return all available versions provided by this plugin
--- @param _ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions and accompanying tool descriptions
function PLUGIN:Available(_ctx)
    local url = "https://grails.apache.org/download.html"

    local resp, err = http.get({
        url = url
    })

    if err ~= nil or resp.status_code ~= 200 then
        error("Failed to fetch Grails download page: " .. (err or "status " .. tostring(resp.status_code)))
    end

    local doc = html.parse(resp.body)
    local selector_div = doc:find("div.version-selector")

    if not selector_div then
        error("Could not find version-selector div on Grails download page")
    end

    local versions = {}
    selector_div:find("option"):each(function(_i, option)
        local version = option:text()
        if type(version) == "string" and version ~= "" and version:match("[%d%.]+") then
            table.insert(versions, {version = version, note = ""})
        end
    end)

    return versions
end
