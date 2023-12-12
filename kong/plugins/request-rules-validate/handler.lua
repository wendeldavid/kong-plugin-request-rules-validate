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

function RequestRulesValidateHandler:access(conf)
  -- kong.log("============== conf")
  -- kong.log.inspect(conf)

  kong.log("============== request headers")
    kong.log.inspect(kong.request.get_headers())

  local deny_headers = conf.deny_headers
  for deny_header_idx in pairs(deny_headers) do
    local deny_header = deny_headers[deny_header_idx]

    kong.log("============== deny header")
    kong.log.inspect(deny_header)

    local request_header_value = kong.request.get_header(deny_header.name)
    if request_header_value ~= nil and deny_header.value == request_header_value then
      kong.log("============== why deny fails?")
      kong.log.inspect(request_header_value)
      fail_invalid(deny_header.name)
    end
  end

  local allow_headers = conf.deny_headers
  for allow_header_idx in pairs(allow_headers) do
    local allow_header = allow_headers[allow_header_idx]

    kong.log("============== allow header")
    kong.log.inspect(allow_header)

    local request_header_value = kong.request.get_header(allow_header.name)

    -- TODO testar o allow ser permissivo com apenas 1 header
    if request_header_value ~= nil and allow_header.value ~= request_header_value then
      kong.log("============== why allow fails?")
      kong.log.inspect(request_header_value)
      fail_invalid(allow_header.name)
    end
  end

end

return RequestRulesValidateHandler
