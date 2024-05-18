---@diagnostic disable: undefined-doc-name, undefined-field
---@class neoverse.utils.lsp
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}

---@param opts? lsp.Client.filter
function M.get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

---@param from string
---@param to string
function M.on_rename(from, to)
  local clients = M.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      ---@diagnostic disable-next-line: invisible
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

---@return _.lspconfig.options
function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

---@param server string
---@param cond fun( root_dir, config): boolean
function M.disable(server, cond)
  local util = require("lspconfig.util")
  local def = M.get_config(server)
  ---@diagnostic disable-next-line: undefined-field
  def.document_config.on_new_config = util.add_hook_before(def.document_config.on_new_config, function(config, root_dir)
    if cond(root_dir, config) then
      config.enabled = false
    end
  end)
end

---@param opts? NeoFormatter| {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter
  ---@cast filter lsp.Client.filter
  ---@type NeoFormatter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format(Lonard.merge({}, filter, { bufnr = buf }))
    end,
    sources = function(buf)
      local clients = M.get_clients(Lonard.merge({}, filter, { bufnr = buf }))
      ---@param client lsp.Client
      local ret = vim.tbl_filter(function(client)
        return client.supports_method("textDocument/formatting")
          or client.supports_method("textDocument/rangeFormatting")
      end, clients)
      ---@param client lsp.Client
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  }
  return Lonard.merge(ret, opts) --[[@as NeoFormatter]]
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

---@param opts? lsp.Client.format
function M.format(opts)
  opts = vim.tbl_deep_extend("force", {}, opts or {}, Lonard.opts("nvim-lspconfig").format or {})
  local ok, conform = pcall(require, "conform")
  -- use conform for formatting with LSP when available,
  -- since it has better format diffing
  if ok then
    opts.formatters = {}
    opts.lsp_fallback = true
    conform.format(opts)
  else
    vim.lsp.buf.format(opts)
  end
end

-- TODO: LspConfig with bunx
-- may be do not need mason to handle servers installation
function M.has_bun_installed()
  local bunx = vim.fn.executable("bunx")
  if bunx == 0 then
    return false
  end
  return true
end

function M.get_global_bun_modules()
  return os.getenv("BUN_INSTALL") .. "/global/node_modules"
end

function M.get_local_node_modules()
  return vim.fn.getcwd() .. "/node_modules"
end

---@alias LspWord {from:{[1]:number, [2]:number}, to:{[1]:number, [2]:number}, current?:boolean} 1-0 indexed
M.words = {}
M.words.ns = vim.api.nvim_create_namespace("vim_lsp_references")

---@param opts? {enabled?: boolean}
function M.words.setup(opts)
  opts = opts or {}
  if not opts.enabled then
    return
  end
  local handler = vim.lsp.handlers["textDocument/documentHighlight"]
  vim.lsp.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      return
    end
    return handler(err, result, ctx, config)
  end

  M.on_attach(function(client, buf)
    if client.supports_method("textDocument/documentHighlight") then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
        group = vim.api.nvim_create_augroup("lsp_word_" .. buf, { clear = true }),
        buffer = buf,
        callback = function(ev)
          if not M.words.at() then
            if ev.event:find("CursorMoved") then
              vim.lsp.buf.clear_references()
            else
              vim.lsp.buf.document_highlight()
            end
          end
        end,
      })
    end
  end)
end

---@return LspWord[]
function M.words.get()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return vim.tbl_map(function(extmark)
    local ret = {
      from = { extmark[2] + 1, extmark[3] },
      to = { extmark[4].end_row + 1, extmark[4].end_col },
    }
    if cursor[1] >= ret.from[1] and cursor[1] <= ret.to[1] and cursor[2] >= ret.from[2] and cursor[2] <= ret.to[2] then
      ret.current = true
    end
    return ret
  end, vim.api.nvim_buf_get_extmarks(0, M.words.ns, 0, -1, { details = true }))
end

---@param words? LspWord[]
---@return LspWord?, number?
function M.words.at(words)
  for idx, word in ipairs(words or M.words.get()) do
    if word.current then
      return word, idx
    end
  end
end

function M.words.jump(count)
  local words = M.words.get()
  local _, idx = M.words.at(words)
  if not idx then
    return
  end
  local target = words[idx + count]
  if target then
    vim.api.nvim_win_set_cursor(0, target.from)
  end
end

return M
