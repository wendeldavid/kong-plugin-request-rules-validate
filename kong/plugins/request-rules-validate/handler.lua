-- Copyright (C) Kong Inc.
local kong = kong
local pairs = pairs

local RequestRulesValidateHandler = {
  VERSION = "0.0.1",
  PRIORITY = 999,
}

local function fail_deny(header_name)
  kong.response.exit(400, { message = "Invalid header "..header_name.." value" })
end

local function fail_allow(header_name)
  kong.response.exit(400, { message = "Missing header "..header_name })
end

function RequestRulesValidateHandler:access(conf)
  -- kong.log.inspect(conf)

  local deny_headers = conf.deny_headers
  for deny_header_name, deny_header_value in pairs(deny_headers) do
    local request_header_value = kong.request.get_header(deny_header_name)
    if request_header_value ~= nil and deny_header_value == request_header_value then
      fail_deny(deny_header_name)
    end
  end

  local allow_headers = conf.allow_headers
  for allow_header_name, allow_header_value in pairs(allow_headers) do
    local request_header_value = kong.request.get_header(allow_header_name)
    if request_header_value == nil or allow_header_value ~= request_header_value then
      fail_allow(allow_header_name)
    end
  end

end

return RequestRulesValidateHandler
