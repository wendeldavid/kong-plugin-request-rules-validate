local typedefs = require "kong.db.schema.typedefs"
local validate_header_name = require("kong.tools.utils").validate_header_name

local function validate_headers(pair, validate_value)
  local name, value = pair:match("^([^:]+):*(.-)$")
  if validate_header_name(name) == nil then
    return nil, string.format("'%s' is not a valid header", tostring(name))
  end

  if validate_value then
    if validate_header_name(value) == nil then
      return nil, string.format("'%s' is not a valid header", tostring(value))
    end
  end
  return true
end

local colon_header_value_array = {
  type = "array",
  default = {},
  required = true,
  elements = { type = "string", match = "^[^:]+:.*$", custom_validator = validate_headers },
}

local headers_list = {
  type = "array",
  default = {},
  required = false,
  elements = {
    type = "record",
    fields = {
      { name = { type = "string", required = true } },
      { value = { type = "string", required = true } },
  } },
}

return {
  name = "request-rules-validate",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {

          { allow_headers = headers_list },
          { deny_headers = headers_list },

          { permissive_allow = { type = "boolean", required = true, default = true }, },
        }
      },
    },
  },

  entity_checks = {
    { at_least_one_of = { "config.allow_headers", "config.deny_headers" } },
    { custom_entity_check = {
      field_sources = {
        "config.allow_headers", "config.deny_headers"
      },
      fn = function(entity)
          kong.log("================================ testando configs")
          kong.log.inspect(entity.config.allow_headers)
          return true


          -- if entity.config ~= nil and entity.config.allow_headers ~= nil and entity.config.deny_headers ~= nil then
          --   kong.log("================================ entrou no if")
          --   return true
          -- end

          -- -- for name, value in pairs(entity.config.allow_headers) do
          -- --   if (value == ngx.nul) then
          -- --     return nil, ""
          -- --   end
          -- -- end
          -- kong.log("================================ pq choras?")
          -- return false
        end
      }
    },
  },
}

