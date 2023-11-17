local M = {}

-- stylua: ignore
M.keys = {
  {
    "<Leader>fe",
    function() require("oil").open() end,
    desc = "file explorer » open",
  },
  {
    "<Leader>fE",
    function() require("oil").open(vim.loop.cwd()) end,
    desc = "file explorer » open [cwd]",
  },
}

M.opts = {
  prompt_save_on_select_new_entry = true,
  skip_confirm_for_simple_edits = false,
  default_file_explorer = true,
  use_default_keymaps = false,
  restore_win_options = true,
  delete_to_trash = true,
  cleanup_delay_ms = 500,
  view_options = {
    show_hidden = true,
  },
  buf_options = {
    buflisted = true,
  },
  keymaps = {
    ["q"] = "actions.close",
    ["g?"] = "actions.show_help",
    ["<cr>"] = "actions.select",
    ["^"] = "actions.open_cwd",
    ["H"] = "actions.toggle_hidden",
    ["gx"] = "actions.select_vsplit",
    ["gy"] = "actions.select_split",
    ["-"] = "actions.parent",
    ["K"] = "actions.preview",
    ["<leader>r"] = "actions.refresh",
  },
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "n",
  },
  float = {
    padding = 2,
    max_width = 96,
    max_height = 45,
    border = "single",
    win_options = { winblend = 0 },
  },
}

return M
