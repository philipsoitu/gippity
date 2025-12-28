-- Guard against re-defining the command when re-sourcing
pcall(vim.api.nvim_del_user_command, "GippityStart")
pcall(vim.api.nvim_del_user_command, "GippityOllamaStart")

-- Common function-like nodes across languages
local FUNCTION_NODE_TYPES = {
  function_definition = true,
  function_declaration = true,
  ["function"] = true,
  method_definition = true,
  method_declaration = true,
  arrow_function = true,
  constructor_declaration = true,
}

local function get_function_node_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    vim.notify("No Tree-sitter parser for buffer", vim.log.levels.WARN)
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  local root = tree:root()
  local node = root:named_descendant_for_range(row, col, row, col)

  while node do
    if FUNCTION_NODE_TYPES[node:type()] then
      return node
    end
    node = node:parent()
  end

  return nil
end

vim.api.nvim_create_user_command("GippityStart", function()
  local node = get_function_node_at_cursor()

  if not node then
    vim.notify("No function found at cursor", vim.log.levels.INFO)
    return
  end

  local sr, sc, er, ec = node:range()

  vim.notify(
    string.format(
      "Found %s [%d:%d → %d:%d]",
      node:type(),
      sr + 1,
      sc,
      er + 1,
      ec
    ),
    vim.log.levels.INFO
  )
end, {})




vim.api.nvim_create_user_command("GippityOllamaStart", function()
  local job_id = vim.fn.jobstart(
    { "ollama", "run", "qwen2.5-coder:7b" },
    {
      detach = true,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stderr = function(_, data)
        if data and #data > 0 then
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
        end
      end,
    }
  )

  if job_id <= 0 then
    vim.notify("Failed to start Ollama", vim.log.levels.ERROR)
    return
  end

  vim.notify(
    "Ollama started in background (qwen2.5-coder:7b)",
    vim.log.levels.INFO
  )
end, {})
