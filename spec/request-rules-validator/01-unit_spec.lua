local PLUGIN_NAME = "request-rules-validate"

-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  it("without values", function()
    local ok, err = validate({})
    assert.is_nil(ok)
    assert.is_table(err)
    assert.equals("at least one of these fields must be non-empty: 'config.allow_headers', 'config.deny_headers'", err["@entity"][1])
  end)

  it("test only one allow headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json" },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one deny headers", function()
    local conf = {
      deny_headers = { "Accept-Charset:UTF-8" },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one allow and one deny headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json" },
      deny_headers = { "Accept-Charset:UTF-8" },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)


  it("test many allow and many deny headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json", "x-header-test:batatinha" },
      deny_headers = { "Accept-Charset:UTF-8", "x-header-fail:batatinha" },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  -- it("test many deny headers", function()
  --   local ok, err = validate({
  --     deny_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     }, {
  --       header_name = "Content-Type",
  --       header_value = "application/json;CHARSET=UTF-8"
  --     }
  --   })
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)

  -- it("test only one allow headers", function()
  --   local ok, err = validate({
  --     allow_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     }
  --   })
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)

  -- it("test many allow headers", function()
  --   local ok, err = validate({
  --     allow_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     }, {
  --       header_name = "Content-Type",
  --       header_value = "application/json;CHARSET=UTF-8"
  --     }
  --   })
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)

  -- it("test only one deny headers and one allow headers", function()
  --   local ok, err = validate({
  --     deny_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     },
  --     allow_headers = {
  --       header_name = "Content-Type",
  --       header_value = "application/json;CHARSET=UTF-8"
  --     }
  --   })
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)

  -- it("test many deny headers and many allow headers", function()
  --   local ok, err = validate({
  --     deny_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     }, {
  --       header_name = "Content-Type",
  --       header_value = "application/json;CHARSET=UTF-8"
  --     },
  --     allow_headers = {
  --       header_name = "Accept-Charset",
  --       header_value = "UTF-8"
  --     }, {
  --       header_name = "Content-Type",
  --       header_value = "application/json;CHARSET=UTF-8"
  --     }
  --   })
  --   assert.is_nil(err)
  --   assert.is_truthy(ok)
  -- end)

end)
