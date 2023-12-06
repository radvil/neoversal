local useTabs = true
local blacklist = {
  -- popups
  "TelescopeResults",
  "TelescopePrompt",
  "neo-tree-popup",
  "DressingInput",
  "flash_prompt",
  "cmp_menu",
  "WhichKey",
  "incline",
  "notify",
  "prompt",
  "notify",
  "noice",

  -- windows
  "DiffviewFiles",
  "checkhealth",
  "dashboard",
  "NvimTree",
  "neo-tree",
  "Outline",
  "prompt",
  "oil",
  "qf",
}

---@param styles? ("bold" | "italic")[]
local function get_custom_catppuccin_hls(styles)
  return function()
    local ctp = require("catppuccin")
    local C = require("catppuccin.palettes").get_palette()
    --stylua: ignore                              
    if not C then return {} end
    local O = ctp.options
    local active_bg = C.surface0
    local inactive_bg = C.mantle
    local separator_fg = C.crust
    local fill_bg = C.crust
    if vim.g.neo_transparent == true then
      active_bg = C.none
      inactive_bg = require("neoverse.config").palette.dark
      separator_fg = C.surface1
      fill_bg = C.crust
    end
    local highlights = {
      fill = { bg = fill_bg },
      background = { bg = inactive_bg },
      buffer_visible = { fg = C.surface1, bg = inactive_bg },
      buffer_selected = { fg = C.text, bg = active_bg, style = styles }, -- current
      duplicate_selected = { fg = C.text, bg = active_bg, style = styles },
      duplicate_visible = { fg = C.surface1, bg = inactive_bg, style = styles },
      duplicate = { fg = C.surface1, bg = inactive_bg, style = styles },
      tab = { fg = C.surface1, bg = inactive_bg },
      tab_selected = { fg = C.sky, bg = active_bg, bold = true },
      tab_separator = { fg = separator_fg, bg = inactive_bg },
      tab_separator_selected = { fg = separator_fg, bg = active_bg },
      tab_close = { fg = C.red, bg = inactive_bg },
      indicator_selected = { fg = C.peach, bg = active_bg, style = styles },
      separator = { fg = separator_fg, bg = inactive_bg },
      separator_visible = { fg = separator_fg, bg = inactive_bg },
      separator_selected = { fg = separator_fg, bg = active_bg },
      offset_separator = { fg = separator_fg, bg = C.base },
      close_button = { fg = C.surface1, bg = inactive_bg },
      close_button_visible = { fg = C.surface1, bg = inactive_bg },
      close_button_selected = { fg = C.red, bg = active_bg },
      numbers = { fg = C.subtext0, bg = inactive_bg },
      numbers_visible = { fg = C.subtext0, bg = inactive_bg },
      numbers_selected = { fg = C.subtext0, bg = active_bg, style = styles },
      error = { fg = C.red, bg = inactive_bg },
      error_visible = { fg = C.red, bg = inactive_bg },
      error_selected = { fg = C.red, bg = active_bg, style = styles },
      error_diagnostic = { fg = C.red, bg = inactive_bg },
      error_diagnostic_visible = { fg = C.red, bg = inactive_bg },
      error_diagnostic_selected = { fg = C.red, bg = active_bg },
      warning = { fg = C.yellow, bg = inactive_bg },
      warning_visible = { fg = C.yellow, bg = inactive_bg },
      warning_selected = { fg = C.yellow, bg = active_bg, style = styles },
      warning_diagnostic = { fg = C.yellow, bg = inactive_bg },
      warning_diagnostic_visible = { fg = C.yellow, bg = inactive_bg },
      warning_diagnostic_selected = { fg = C.yellow, bg = active_bg },
      info = { fg = C.sky, bg = inactive_bg },
      info_visible = { fg = C.sky, bg = inactive_bg },
      info_selected = { fg = C.sky, bg = active_bg, style = styles },
      info_diagnostic = { fg = C.sky, bg = inactive_bg },
      info_diagnostic_visible = { fg = C.sky, bg = inactive_bg },
      info_diagnostic_selected = { fg = C.sky, bg = active_bg },
      hint = { fg = C.teal, bg = inactive_bg },
      hint_visible = { fg = C.teal, bg = inactive_bg },
      hint_selected = { fg = C.teal, bg = active_bg, style = styles },
      hint_diagnostic = { fg = C.teal, bg = inactive_bg },
      hint_diagnostic_visible = { fg = C.teal, bg = inactive_bg },
      hint_diagnostic_selected = { fg = C.teal, bg = active_bg },
      diagnostic = { fg = C.subtext0, bg = inactive_bg },
      diagnostic_visible = { fg = C.subtext0, bg = inactive_bg },
      diagnostic_selected = { fg = C.subtext0, bg = active_bg, style = styles },
      modified = { fg = C.peach, bg = inactive_bg },
      modified_selected = { fg = C.peach, bg = active_bg },
    }
    for _, color in pairs(highlights) do
      -- Because default is gui=bold,italic
      color.italic = false
      color.bold = false
      if color.style then
        for _, style in pairs(color.style) do
          color[style] = true
          if O.no_italic and style == "italic" then
            color[style] = false
          end
          if O.no_bold and style == "bold" then
            color[style] = false
          end
        end
      end
      color.style = nil
    end
    return highlights
  end
end

return {
  "akinsho/bufferline.nvim",
  dependencies = "mini.bufremove",
  event = "LazyFile",
  keys = function()
    local Kmap = function(lhs, cmd, desc)
      cmd = string.format("<cmd>BufferLine%s<cr>", cmd)
      desc = string.format("bufferline » %s", desc)
      return { lhs, cmd, desc = desc }
    end
    local keys = {
      Kmap("<a-b>", "Pick", "pick & enter"),
      Kmap("<a-q>", "PickClose", "pick & close"),
      Kmap("<leader>bx", "PickClose", "pick & close"),
      Kmap("<a-[>", "CyclePrev", "switch prev"),
      Kmap("<a-]>", "CycleNext", "switch next"),
      Kmap("<a-1>", "GoToBuffer 1", "switch 1st"),
      Kmap("<a-2>", "GoToBuffer 2", "switch 2nd"),
      Kmap("<a-3>", "GoToBuffer 3", "switch 3rd"),
      Kmap("<a-4>", "GoToBuffer 4", "switch 4th"),
      Kmap("<a-5>", "GoToBuffer 5", "switch 5th"),
      Kmap("<leader>bB", "CloseLeft", "close left"),
      Kmap("<leader>bW", "CloseRight", "close right"),
      Kmap("<leader>bC", "CloseOthers", "close others"),
    }
    if not useTabs then
      vim.list_extend(keys, {
        Kmap("<a-.>", "MoveNext", "shift right"),
        Kmap("<a-,>", "MovePrev", "shift left"),
        Kmap("<leader>bS", "SortByTabs", "sort by tabs"),
        Kmap("<leader>bs", "SortByDirectory", "sort by directory"),
        Kmap("<leader>bp", "TogglePin", "toggle pin"),
      })
    end
    return keys
  end,

  opts = {
    options = {
      offsets = {},
      mode = "tabs",
      diagnostics = "nvim_lsp",
      show_close_icon = false,
      move_wraps_at_ends = false,
      show_buffer_icons = true,
      show_tab_indicators = false,
      always_show_bufferline = false,
      ---@type "thin" | "padded_slant" | "slant" | "thick" | "none"
      separator_style = "thin",
      close_command = function(n)
        require("mini.bufremove").delete(n, false)
      end,
      right_mouse_command = function(n)
        require("mini.bufremove").delete(n, false)
      end,
      indicator = {
        ---@type "icon" | "underline" | "none"
        style = "icon",
      },
      hover = {
        enabled = true,
        reveal = { "close" },
        delay = 100,
      },
      custom_filter = function(bufnr)
        return not vim.tbl_contains(blacklist, vim.bo[bufnr].filetype)
      end,
    },
  },

  config = function(_, opts)
    if not useTabs then
      ---@type "insert_after_current" | "insert_at_end" | "id" | "extension" | "relative_directory" | "directory" | "tabs"
      opts.sort_by = "insert_after_current"
      opts.move_wraps_at_ends = true
      opts.show_tab_indicators = true
    end

    local Utils = require("neoverse.utils")
    -- TODO: set this to catppuccin instead here...
    if Utils.lazy_has("catppuccin") and string.match(vim.g.colors_name, "catppuccin") then
      opts.highlights = get_custom_catppuccin_hls()
    end

    require("bufferline").setup(opts)
  end,

  init = function()
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd("BufAdd", {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}
