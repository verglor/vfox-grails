local http = require("http")
local html = require("html")

--- Fetch SHA512 checksum from Apache mirrors
--- @param download_url string The download URL
--- @return string|nil The checksum or nil if not available
local function fetchApacheChecksum(download_url)
    -- Extract the path from the Apache URL
    local version, filename = download_url:match("/grails/core/([%d%.]+)/distribution/([^%?]+)")
    if not version or not filename then
        return nil
    end
    
    local checksum_url = "https://downloads.apache.org/grails/core/" .. version .. "/distribution/" .. filename .. ".sha512"
    local resp, err = http.get({
        url = checksum_url
    })
    
    if err == nil and resp.status_code == 200 then
        -- SHA512 file format: "checksum  filename"
        local checksum = resp.body:match("^(%S+)")
        return checksum
    end
    
    return nil
end

--- Returns some pre-installed information, such as version number, download address, local files, etc.
--- If checksum is provided, vfox will automatically check it for you.
--- @param ctx table Context with ctx.version string (user-input version)
--- @return table Version information
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    
    -- Fetch the download page to get the URL for this specific version
    local url = "https://grails.apache.org/download.html"
    local resp, err = http.get({
        url = url
    })
    
    if err ~= nil or resp.status_code ~= 200 then
        error("Failed to fetch Grails download page: " .. (err or "status " .. tostring(resp.status_code)))
    end
    
    -- Parse HTML and find the version-selector div
    local doc = html.parse(resp.body)
    local selector_div = doc:find("div.version-selector")
    
    if not selector_div then
        error("Could not find version-selector div on Grails download page")
    end
    
    -- Find the option with the matching version
    local download_url = nil
    selector_div:find("option"):each(function(_i, option)
        local opt_version = option:text()
        if opt_version == version then
            download_url = option:attr("value")
        end
    end)
    
    if not download_url then
        error("Could not find download URL for Grails version: " .. version)
    end
    
    local result = {
        version = version,
        url = download_url,
    }
    
    -- Try to fetch checksum for Apache-hosted downloads (versions 7.x)
    if download_url and download_url:find("apache%.org") then
        local checksum = fetchApacheChecksum(download_url)
        if checksum then
            result.sha512 = checksum
        end
    end
    
    return result
end