-- Copyright (C) Kong Inc.
local kong = kong
local pairs = pairs

local RequestRulesValidateHandler = {
  VERSION = "0.0.1",
  PRIORITY = 999,
}

local function fail_invalid(header_name)
  kong.response.exit(400, { message = "Invalid header "..header_name.." value" })
end

local function fail_missing(header_name)
  kong.response.exit(400, { message = "Missing header "..header_name })
end

local function check_deny(conf)
  local deny_headers = conf.deny_headers
  for deny_header_idx in pairs(deny_headers) do
    local deny_header = deny_headers[deny_header_idx]

    kong.log("============== deny header")
    kong.log.inspect(deny_header)

    local request_header_value = kong.request.get_header(deny_header.name)
    if request_header_value ~= nil and deny_header.value == request_header_value then
      kong.log("============== fail deny")
      kong.log.inspect(request_header_value)
      fail_invalid(deny_header.name)
    end
  end
end

local function check_allow(conf)
  local allow_headers = conf.allow_headers
  for allow_header_idx in pairs(allow_headers) do
    local allow_header = allow_headers[allow_header_idx]

    kong.log("============== allow header")
    kong.log.inspect(allow_header)

    local request_header_value = kong.request.get_header(allow_header.name)

    if conf.permissive_allow then
      if request_header_value ~= nil and allow_header.value ~= request_header_value then
        kong.log("============== fail allow")
        kong.log.inspect(request_header_value)
        fail_invalid(allow_header.name)
      end
    end
  end
end

function RequestRulesValidateHandler:access(conf)
  -- kong.log("============== conf")
  -- kong.log.inspect(conf)

  kong.log("============== request headers")
  kong.log.inspect(kong.request.get_headers())

  kong.log("============== check deny")
  check_deny(conf)

  kong.log("============== check allow")
  check_allow(conf)

end

return RequestRulesValidateHandler
