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

  it("test allow invalid header", function()
    local conf = {
      allow_headers = { "INVALID" },
    }
    local ok, err = validate(conf)
    assert.is_nil(ok)
    assert.is_truthy(err)
  end)

  it("test deny invalid header", function()
    local conf = {
      deny_headers = { "INVALID" },
    }
    local ok, err = validate(conf)
    assert.is_nil(ok)
    assert.is_truthy(err)
  end)

  it("test only one allow headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json" },
    }
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one deny headers", function()
    local conf = {
      deny_headers = { "Accept-Charset:UTF-8" },
    }
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test only one allow and one deny headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json" },
      deny_headers = {  "Accept-Charset:UTF-8" },
    }
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test many allow and many deny headers", function()
    local conf = {
      allow_headers = { "Content-Type:application/json","x-header-test:batatinha" },
      deny_headers = { "Accept-Charset:UTF-8", "x-header-fail:batatinha" },
    }
    local ok, err = validate(conf)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("test allow and deny with conflict", function()
    local conf = {
      allow_headers = { "Content-Type:application/json" },
      deny_headers = { "Content-Type:application/json" },
    }
    local ok, err = validate(conf)
    assert.is_nil(ok)
    assert.is_truthy(err)
  end)

end)
