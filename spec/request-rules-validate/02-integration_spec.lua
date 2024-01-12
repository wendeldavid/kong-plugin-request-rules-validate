local helpers = require "spec.helpers"

local PLUGIN_NAME = "request-rules-validate"

describe(PLUGIN_NAME .. ": (access)", function()
  local client

  lazy_setup(function()

    local bp = helpers.get_db_utils("postgres", {
      "routes",
      "services",
      "plugins",
      "consumers",
    }, { PLUGIN_NAME })

    -- Inject a test route. No need to create a service, there is a default
    -- service which will echo the request.
    local route_1 = bp.routes:insert({
      paths = { "/request_test_1" }
    })
    bp.plugins:insert {
      name = PLUGIN_NAME,
      route = { id = route_1.id },
      config = {
        strict_allow = false,
        allow_headers = { "Content-Type:application/json", "x-real-ip:0.0.0.0" },
        deny_headers = { "x-header-fail:batatinha" },
      },
    }

    local route_2 = bp.routes:insert({
      paths = { "/request_test_2" }
    })
    bp.plugins:insert {
      name = PLUGIN_NAME,
      route = { id = route_2.id },
      config = {
        strict_allow = true,
        allow_headers = { "Content-Type:application/json", "x-real-ip:0.0.0.0" },
        deny_headers = {},
      },
    }

    -- start kong
    assert(helpers.start_kong({
      -- set the database
      database   = "postgres",
      -- use the custom test template to create a local mock server
      nginx_conf = "spec/fixtures/custom_nginx.template",
      -- make sure our plugin gets loaded
      plugins = "bundled," .. PLUGIN_NAME,
    }))
  end)

  lazy_teardown(function()
    helpers.stop_kong(nil, true)
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function()
    if client then client:close() end
  end)

  -- ROUTE 1
  describe("request_1 : request without headers", function()
    it("returns status code 200", function()
      local r = client:get("/request_test_1", {
        headers = {}
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_1 | request with only one header that was on allow_headers config and the values matches", function()
    it("return status code 200", function()
      local r = client:get("/request_test_1", {
        headers = {
          ["Content-Type"] = "application/json" -- allow header match
        }
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_1 | request with both headers decalred on allow_config and both values not match", function()
    it("return status code 400", function()
      local r = client:get("/request_test_1", {
        headers = {
          ["Content-Type"] = "plain/text", -- allow header not match
          ["X-Batatinha"] = "test" -- allow header not match
        }
      })

      assert.response(r).has.status(400)
    end)
  end)

  describe("request_1 | request with both headers declared on allow_config but only one value matches", function()
    it("return status code 200", function()
      local r = client:get("/request_test_1", {
        headers = {
          ["Content-Type"] = "application/json", -- allow header match
          ["X-Batatinha"] = "test" -- allow header not match
        }
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_1 | request with only one header that was on deny_headers config but the value not matches", function()
    it("return status code 200", function()
      local r = client:get("/request_test_1", {
        headers = {
          ["x-header-fail"] = "not-fail" -- deny header not match
        }
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_1 | request win only one header that was on deny_headers config and the values matches", function()
    it("return status code 400", function()
      local r = client:get("/request_test_1", {
        headers = {
          ["x-header-fail"] = "batatinha" -- deny header match
        }
      })

      assert.response(r).has.status(400)
    end)
  end)

  -- ROUTE 2
  describe("request_2 | request without headers", function()
    it("return status code 200", function()
      local r = client:get("/request_test_1", {
        headers = {}
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_2 | request with both headers was on allow_headers config and both values matches", function()
    it("return status code 200", function()
      local r = client:get("/request_test_2", {
        headers = {
          ["Content-Type"] = "application/json", -- allow header match
          ["x-real-ip"] = "0.0.0.0", -- allow header match
        }
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_2 | request with 3 headers and only 2 was configured on allow_headers and both confiured matches", function()
    it("return status code 200", function()
      local r = client:get("/request_test_2", {
        headers = {
          ["Content-Type"] = "application/json", -- allow header match
          ["x-real-ip"] = "0.0.0.0", -- allow header match
          ["X-Batatinha"] = "test", -- header not configured
        }
      })

      assert.response(r).has.status(200)
    end)
  end)

  describe("request_2 | request with both hreaders was on allow_headers configuration but only one value matches", function()
    it("return status code 400", function()
      local r = client:get("/request_test_2", {
        headers = {
          ["Content-Type"] = "application/json", -- allow header match
          ["X-Batatinha"] = "test", -- allow header not match
        }
      })

      assert.response(r).has.status(400)
    end)
  end)

end)
