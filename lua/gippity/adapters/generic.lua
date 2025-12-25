local M = {}

local FUNCTION_LIKE = {
  ["function"] = true,
  ["function_definition"] = true,
  ["function_declaration"] = true,
  ["method_definition"] = true,
  ["function_item"] = true,
}

function M.get_function_node(node)
  while node do
    local t = node:type()
    if FUNCTION_LIKE[t] or t:find("function") then
      return node
    end
    node = node:parent()
  end
end

function M.get_leading_comments(node)
  local comments = {}
  local prev = node and node:prev_sibling()

  while prev and prev:type():find("comment") do
    table.insert(comments, 1, prev)
    prev = prev:prev_sibling()
  end

  return comments
end

return M
