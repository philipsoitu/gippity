local ts_utils = require("nvim-treesitter.ts_utils")

local adapters = {
  lua             = require("llm_context.adapters.lua"),
  python          = require("llm_context.adapters.python"),
  zig             = require("llm_context.adapters.zig"),
  javascript      = require("llm_context.adapters.js"),
  typescript      = require("llm_context.adapters.js"),
  javascriptreact = require("llm_context.adapters.js"),
  typescriptreact = require("llm_context.adapters.js"),
}

local generic = require("llm_context.adapters.generic")

local M = {}

local function get_adapter()
  return adapters[vim.bo.filetype] or generic
end

local function get_node_text(node, bufnr)
  local sr, sc, er, ec = node:range()
  local lines = vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
  return table.concat(lines, "\n")
end

function M.collect_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local adapter = get_adapter()

  local cursor_node = ts_utils.get_node_at_cursor()
  if not cursor_node then
    return nil
  end

  -- find enclosing function
  local fn_node = adapter.get_function_node(cursor_node)
  if not fn_node then
    return nil
  end

  -- leading comments
  local comments = adapter.get_leading_comments(fn_node)

  local parts = {}

  -- comments
  for _, node in ipairs(comments) do
    table.insert(parts, get_node_text(node, bufnr))
  end

  -- function
  table.insert(parts, get_node_text(fn_node, bufnr))

  return table.concat(parts, "\n\n")
end

return M
