local http = require("resty.http")
local cjson = require("cjson.safe")

-- Extract request URI
local uri = ngx.var.uri
local parts = {}

for part in string.gmatch(uri, "[^/]+") do
    table.insert(parts, part)
end

-- Expect: /api/v1/space_name/client/api/version
if #parts < 6 then
    ngx.status = 400
    ngx.say("Invalid request format")
    return
end

local space, client, api, version = parts[4], parts[5], parts[6], parts[7]

-- Read from env
local AUTH_HOST = os.getenv("AUTH_HOST") or "http://auth-server"
local MAIN_PROCESS_HOST = os.getenv("MAIN_PROCESS_HOST") or "http://main-process"
local BACKUP_SERVER_HOST = os.getenv("BACKUP_SERVER_HOST") or "http://backup-server"

-- Validate
local httpc = http.new()
local validate_url = string.format("%s/validate?name=%s&client=%s&target_api=%s&version=%s",
  AUTH_HOST, space, client, api, version)

local res, err = httpc:request_uri(validate_url, { method = "GET" })

if not res or res.status ~= 200 then
    ngx.status = 403
    ngx.say("Unauthorized")
    return
end

-- Forward to main process
local forward_path = string.format("/%s/%s/%s/%s", space, client, api, version)
local backend_url = MAIN_PROCESS_HOST .. forward_path

local res2, err2 = httpc:request_uri(backend_url, {
    method = ngx.req.get_method(),
    body = ngx.req.get_body_data(),
    headers = {
        ["Content-Type"] = ngx.req.get_headers()["Content-Type"]
    }
})

if not res2 then
    ngx.status = 502
    ngx.say("Backend error: ", err2)
    return
end

-- Parse response, modify, and send back
local data = cjson.decode(res2.body) or {}
local filtered = {
    space = data.space,
    client = data.client,
    version = data.version,
    message = data.message
}

ngx.header.content_type = "application/json"
ngx.say(cjson.encode(filtered))

-- Async backup
ngx.timer.at(0, function()
    local httpc2 = http.new()
    httpc2:request_uri(BACKUP_SERVER_HOST .. "/store", {
        method = "POST",
        body = res2.body,
        headers = {
            ["Content-Type"] = "application/json"
        }
    })
end)
