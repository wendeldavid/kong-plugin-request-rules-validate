local access = require("kong.plugins.request-rules-validate.access")

local RequestRulesValidateHandler = {
  VERSION = "0.0.1",
  PRIORITY = 999,
}

function RequestRulesValidateHandler:access(conf)
  access.execute(conf)
end

return RequestRulesValidateHandler
