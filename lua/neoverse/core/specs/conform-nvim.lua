local M = {}

local Utils = require("neoverse.utils")

M.keys = {
  {
    "<leader>cF",
    function()
      require("conform").format({ formatters = { "injected" } })
    end,
    mode = { "n", "v" },
    desc = "Code » Format Injected Langs",
  },
}

M.init = function()
  -- Install the conform formatter on VeryLazy
  Utils.on_very_lazy(function()
    Utils.format.register({
      name = "conform.nvim",
      priority = 100,
      primary = true,
      format = function(buf)
        local plugin = require("lazy.core.config").plugins["conform.nvim"]
        local Plugin = require("lazy.core.plugin")
        local opts = Plugin.values(plugin, "opts", false)
        require("conform").format(Utils.merge(opts.format, { bufnr = buf }))
      end,
      sources = function(buf)
        local ret = require("conform").list_formatters(buf)
        ---@param v conform.FormatterInfo
        return vim.tbl_map(function(v)
          return v.name
        end, ret)
      end,
    })
  end)
end

M.opts = function()
  local plugin = require("lazy.core.config").plugins["conform.nvim"]
  if plugin.config ~= M.config then
    Utils.error({
      "Don't set `plugin.config` for `conform.nvim`.\n",
      "This will break **NeoVerse** formatting.\n",
    }, { title = "NeoVerse" })
  end
  ---@class ConformOpts
  local opts = {
    -- NeoVerse will use these options when formatting with the conform.nvim formatter
    format = {
      timeout_ms = 3000,
      async = false, -- not recommended to change
      quiet = false, -- not recommended to change
    },
    ---@type table<string, conform.FormatterUnit[]>
    formatters_by_ft = {
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
    },
    -- The options you set here will be merged with the builtin formatters.
    -- You can also define any custom formatters here.
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      injected = { options = { ignore_errors = true } },
      -- # Example of using dprint only when a dprint.json file is present
      -- dprint = {
      --   condition = function(ctx)
      --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
      --   end,
      -- },
      --
      -- # Example of using shfmt with extra args
      -- shfmt = {
      --   prepend_args = { "-i", "2", "-ci" },
      -- },
    },
  }
  return opts
end

---@param opts ConformOpts
function M.config(_, opts)
  require("conform").setup(opts)
end

return M
