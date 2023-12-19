local typedefs = require "kong.db.schema.typedefs"
local validate_header_name = require("kong.tools.utils").validate_header_name

local HEADER_REGEX = "^([^:]+):*(.-)$"

local function validate_headers(pair)local name, value = pair:match(HEADER_REGEX)
  if validate_header_name(name) == nil then
    return nil, string.format("'%s' is not a valid header name", tostring(name))
  end

  if value == nil then
    return nil, string.format("'%s' is not a valid header value", tostring(name))
  end

  return true
end

local colon_header_value_array = {
  type = "array",
  default = {},
  required = false,
  elements = { type = "string", match = "^[^:]+:.*$", custom_validator = validate_headers },
}

return {
  name = "request-rules-validate",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {

          { allow_headers = colon_header_value_array },
          { deny_headers = colon_header_value_array },

          { strict_allow = { type = "boolean", required = true, default = false }, },
        }
      },
    },
  },

  entity_checks = {
    { at_least_one_of = { "config.allow_headers", "config.deny_headers" } },
    { distinct = { "config.allow_headers", "config.deny_headers" } },
    { custom_entity_check = {
      field_sources = { "config.allow_headers", "config.deny_headers" },
      fn = function(entity)
        if entity.config ~= nil and entity.config.allow_headers ~= nil and entity.config.deny_headers ~= nil then

          for allow_k, allow_v in pairs(entity.config.allow_headers) do
            for deny_k, deny_v in pairs(entity.config.deny_headers) do
              if allow_v == deny_v then
                return nil, string.format("Config error: allow header '%s' conflicts with '%s'", allow_v, deny_v)
              end
            end
          end
        end

        return true
      end
    }}
  },
}
