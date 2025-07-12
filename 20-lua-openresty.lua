-- Lua with OpenResty
local json = require "cjson"
local ngx = ngx

-- Set SSE headers
ngx.header["Content-Type"] = "text/event-stream"
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Connection"] = "keep-alive"
ngx.header["Access-Control-Allow-Origin"] = "*"

-- Send initial message
ngx.say("data: Connected to Lua OpenResty SSE")
ngx.say("")
ngx.flush(true)

-- Function to send SSE message
local function send_sse_message(data)
    ngx.say("data: " .. json.encode(data))
    ngx.say("")
    ngx.flush(true)
end

-- Send periodic messages
local start_time = ngx.time()
while true do
    -- Check if client disconnected
    if ngx.var.remote_addr == nil then
        break
    end
    
    local message = {
        message = "Hello from Lua OpenResty",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        uptime = ngx.time() - start_time
    }
    
    send_sse_message(message)
    
    -- Sleep for 2 seconds
    ngx.sleep(2)
    
    -- Prevent infinite execution (5 minutes max)
    if (ngx.time() - start_time) > 300 then
        break
    end
end

-- nginx.conf configuration for this would be:
--[[
server {
    listen 3020;
    
    location /events {
        content_by_lua_file /path/to/this/file.lua;
    }
}
--]]