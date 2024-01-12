local kong = kong
local pairs = pairs

local _M = {}

local function get_header(header)
    local name, value = header:match("^([^:]+):*(.-)$")
    return { name = name, value = value }
end

local function is_empty(table)
  return next(table) == nil
end

local function fail_invalid(header_name)
  local message = "Invalid header set"
  if header_name ~= nil then
    message = "Invalid header "..header_name.." value"
  end
  kong.response.exit(400, { message  = message } )
end

local function fail_missing(header_name)
  kong.response.exit(400, { message = "Missing header "..header_name })
end

local function check_deny(conf)
  local deny_headers = conf.deny_headers
  if deny_headers == nil or is_empty(deny_headers) then
    return
  end
  for deny_header_idx in pairs(deny_headers) do
    local deny_header = deny_headers[deny_header_idx]

    local header = get_header(deny_header)

    local request_header_value = kong.request.get_header(header.name)
    if request_header_value ~= nil and request_header_value == header.value then
      fail_invalid(header.name)
    end
  end
end

local function check_allow(conf)
  local allow_headers = conf.allow_headers
  if allow_headers == nil or is_empty(allow_headers)then
    return
  end

  local all_failed = true
  local missing_header = nil
  local match_failed = nil

  for allow_header_idx in pairs(allow_headers) do
    local allow_header = allow_headers[allow_header_idx]

    local header = get_header(allow_header)

    local request_header_value = kong.request.get_header(header.name)

    if request_header_value == nil then
      missing_header = header.name
    else
      if request_header_value ~= header.value then
        match_failed = header.name
      end
      if conf.strict_allow then
        if match_failed then
          fail_invalid(header.name)
        else
          all_failed = false
        end
      end
    end
  end

  if conf.strict_allow then
    if missing_header ~= nil then
      fail_missing(missing_header)
    end
    if all_failed then
      fail_invalid()
    end
  else
    if match_failed ~= nil then
      fail_invalid(match_failed)
    end
  end
end

function _M.execute(conf)

    check_deny(conf)

    check_allow(conf)
end

return _M