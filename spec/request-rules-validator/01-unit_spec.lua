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
      allow_headers = { { name = "Content-Type", value = "application/json" } },
    }
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one deny headers", function()
    local conf = {
      deny_headers = { { name = "Accept-Charset", value = "UTF-8" } },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one allow and one deny headers", function()
    local conf = {
      allow_headers = { { name = "Content-Type", value = "application/json" } },
      deny_headers = { { name = "Accept-Charset", value = "UTF-8" } },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test many allow and many deny headers", function()
    local conf = {
      allow_headers = { { name = "Content-Type", value = "application/json" }, { name = "x-header-test", value = "batatinha" } },
      deny_headers = { { name = "Accept-Charset", value = "UTF-8" }, { name = "x-header-fail", value = "batatinha" } },
    }
    kong.log.inspect(conf)
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

end)
