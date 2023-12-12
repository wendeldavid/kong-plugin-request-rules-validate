local helpers = require "spec.helpers"

local PLUGIN_NAME = "request-rules-validate"

for _, strategy in helpers.each_strategy() do
    describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
      local client

      lazy_setup(function()

        local bp = helpers.get_db_utils(strategy == "off" or strategy, {
          "routes",
          "services",
          "plugins",
          "consumers",
        }, { PLUGIN_NAME })

        -- Inject a test route. No need to create a service, there is a default
        -- service which will echo the request.
        local route1 = bp.routes:insert({
          paths = { "/request_test1" }
        })
        local route2 = bp.routes:insert({
          paths = { "/request_test2" }
        })

        bp.plugins:insert {
          name = PLUGIN_NAME,
          route = { id = route1.id },
          config = {
            allow_headers = { { name = "Content-Type", value = "application/json" }, { name = "x-header-test", value = "batatinha" } },
            deny_headers = { { name = "Accept-Charset", value = "UTF-8" }, { name = "x-header-fail", value = "batatinha" } },
          },
        }

        -- start kong
        assert(helpers.start_kong({
          -- set the strategy
          database   = strategy,
          -- use the custom test template to create a local mock server
          nginx_conf = "spec/fixtures/custom_nginx.template",
          -- make sure our plugin gets loaded
          plugins = "bundled," .. PLUGIN_NAME,
          -- write & load declarative config, only if 'strategy=off'
          declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
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

      describe("request_1", function()
        it("request with multiples limits", function()
          local r = client:get("/request_test1", {
            headers = {
              ["Content-Type"] = "application/json"
            }
          })
          -- validate that the request succeeded, response status 200
          assert.response(r).has.status(200)
        end)
      end)

      -- describe("request_2", function()
      --   it("request conflict quotas", function()
      --     local r = client:get("/request_test2", {
      --       headers = {
      --         apikey = "key-test"
      --       }
      --     })
      --     -- validate that the request succeeded, response status 200
      --     assert.response(r).has.status(200)

      --     local consumer_header = assert.request(r).has.header("x-consumer-username")
      --     assert.equal("consumer_name", consumer_header)

      --     -- now check the request (as echoed by mockbin) to have the header
      --     local rate_limit_header = assert.response(r).has.header("RateLimit-Limit")
      --     -- validate the value of that header
      --     assert.equal("20", rate_limit_header)

      --     local rate_limit_minute_period_header = assert.response(r).has.header("X-RateLimit-Limit-Minute")
      --     assert.equal("20", rate_limit_minute_period_header)
      --   end)
      -- end)


    end)
end
