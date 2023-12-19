local typedefs = require "kong.db.schema.typedefs"
local validate_header_name = require("kong.tools.utils").validate_header_name

local HEADER_REGEX = "^([^:]+):*(.-)$"

local function validate_headers(pair, validate_header_value)
  kong.log("=============== validate headers")
  kong.log.inspect(pair)
  kong.log.inspect(pair:match(HEADER_REGEX))

  local name, value = pair:match(HEADER_REGEX)
  if validate_header_name(name) == nil then
    return nil, string.format("'%s' is not a valid header ======= name", tostring(name))
  end

  -- if validate_header_value then
    if value == nil then
      return nil, string.format("'%s' is not a valid header ======= value nil", tostring(name))
    end
    -- if validate_header_name(value) == nil then
    --   return nil, string.format("'%s' is not a valid header ======= invalid or invalid value", tostring(value))
    -- end
  -- end

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
    -- { custom_entity_check = {
    --   field_sources = {
    --     "config.allow_headers", "config.deny_headers"
    --   },
    --   fn = function(entity)
    --       if entity.config == nil or (entity.config.allow_headers == nil and entity.config.deny_headers == nil) then
    --         kong.log("================================ fail fast")
    --         return false
    --       end

    --       for header in pairs(entity.config.allow_headers) do
    --         if not validate_headers(header, true) then
    --           kong.log("================================ deu ruim no check allow")
    --           return false
    --         end
    --         -- local header_name, header_value = header.match(HEADER_REGEX)
    --         -- if header_name == nil or header_value == nil then
    --         --   kong.log("================================ fail header value")
    --         --   return false
    --         -- else
    --         --   local header_value_ok, invalid_header_values = header_value.match(HEADER_REGEX)
    --         --   if not header_value_ok or invalid_header_values then
    --         --     kong.log("================================ fail header invalid value")
    --         --     return false
    --         --   end
    --         -- end
    --       end

    --       for header in pairs(entity.config.deny_headers) do
    --         if not validate_headers(header, true) then
    --           kong.log("================================ deu ruim no check deny")
    --           return false
    --         end
    --       end

    --       kong.log("================================ deu boa")
    --       return true
    --     end
    --   }
    -- },
  },
}

