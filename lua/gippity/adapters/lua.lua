local generic = require("llm_context.adapters.generic")

local M = {}

local FUNCTION_NODES = {
  function_declaration = true,
  function_definition  = true,
}

function M.get_function_node(node)
  while node do
    if FUNCTION_NODES[node:type()] then
      return node
    end
    node = node:parent()
  end
end

function M.get_leading_comments(node)
  return generic.get_leading_comments(node)
end

return M
