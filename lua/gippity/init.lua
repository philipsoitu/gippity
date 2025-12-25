local core = require("llm_context.core")

local M = {}

function M.get_context()
  return core.collect_context()
end

return M
