---@type LazySpec
return {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPost",
  opts = {
    char = "│",
    show_current_context = false,
    buftype_exclude = { "terminal" },
    show_trailing_blankline_indent = false,
    char_list = { "│", "»", "┊", "»" },
    filetype_exclude = {
      "DiffviewFiles",
      "NeogitStatus",
      "Dashboard",
      "dashboard",
      "MundoDiff",
      "NvimTree",
      "neo-tree",
      "Outline",
      "prompt",
      "Mundo",
      "alpha",
      "help",
      "dbui",
      "edgy",
      "dirbuf",
      "fugitive",
      "fugitiveblame",
      "gitcommit",
      "Trouble",
      "alpha",
      "help",
      "qf",

      -- popup
      "TelescopeResults",
      "TelescopePrompt",
      "neo-tree-popup",
      "DressingInput",
      "flash_prompt",
      "cmp_menu",
      "WhichKey",
      "lspinfo",
      "notify",
      "noice",
      "mason",
      "lazy",
      "oil",
    },
    context_patterns = {
      "class",
      "function",
      "method",
      "^if",
      "^while",
      "^for",
      "^object",
      "^table",
      "^type",
      "^import",
      "block",
      "arguments",
    },
  },
}
