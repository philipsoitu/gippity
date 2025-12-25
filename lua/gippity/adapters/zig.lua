local generic = require("llm_context.adapters.generic")

local M = {}

local FUNCTION_NODES = {
  function_declaration = true,
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
  local comments = {}
  local prev = node and node:prev_sibling()

  while prev and (
      prev:type() == "line_comment"
      or prev:type() == "doc_comment"
    ) do
    table.insert(comments, 1, prev)
    prev = prev:prev_sibling()
  end

  return comments
end

return M
