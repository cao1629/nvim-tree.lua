local log = require("nvim-tree.log")
local view = require("nvim-tree.view")
local events = require("nvim-tree.events")

local Class = require("nvim-tree.classic")
local Builder = require("nvim-tree.renderer.builder")

local namespace_highlights_id = vim.api.nvim_create_namespace("NvimTreeHighlights")
local namespace_virtual_lines_id = vim.api.nvim_create_namespace("NvimTreeVirtualLines")

---@alias HighlightRangeArgs { higroup:string, start:integer[], finish:integer[] } named arguments for vim.hl.range

---@class (exact) Renderer: nvim_tree.Class
---@field explorer Explorer
local Renderer = Class:extend()

---@class Renderer
---@overload fun(args: RendererArgs): Renderer

---@class (exact) RendererArgs
---@field explorer Explorer

---@protected
---@param args RendererArgs
function Renderer:new(args)
  self.explorer = args.explorer
end

---@private
---@param bufnr number
---@param lines string[]
---@param hl_range_args HighlightRangeArgs[]
---@param virtual_lines table[] virtual lines for hidden count display
function Renderer:_draw(bufnr, lines, hl_range_args, virtual_lines)
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  self:render_hl(bufnr, hl_range_args)

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

  vim.api.nvim_buf_clear_namespace(bufnr, namespace_virtual_lines_id, 0, -1)
  for line_nr, vlines in pairs(virtual_lines) do
    vim.api.nvim_buf_set_extmark(bufnr, namespace_virtual_lines_id, line_nr, 0, {
      virt_lines         = vlines,
      virt_lines_above   = false,
      virt_lines_leftcol = true,
    })
  end
end

---@private
---@param bufnr integer
---@param hl_range_args HighlightRangeArgs[]
function Renderer:render_hl(bufnr, hl_range_args)
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, namespace_highlights_id, 0, -1)
  for _, args in ipairs(hl_range_args) do
    if vim.fn.has("nvim-0.11") == 1 and vim.hl and vim.hl.range then
      vim.hl.range(bufnr, namespace_highlights_id, args.higroup, args.start, args.finish, {})
    else
      vim.api.nvim_buf_add_highlight(bufnr, namespace_highlights_id, args.higroup, args.start[1], args.start[2], args.finish[2]) ---@diagnostic disable-line: deprecated
    end
  end
end

function Renderer:draw()
  local bufnr = view.get_bufnr()
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local profile = log.profile_start("draw")

  local cursor = vim.api.nvim_win_get_cursor(view.get_winnr() or 0)

  local builder = Builder(self.explorer):build()

  self:_draw(bufnr, builder.lines, builder.hl_range_args, builder.virtual_lines)

  if cursor and #builder.lines >= cursor[1] then
    vim.api.nvim_win_set_cursor(view.get_winnr() or 0, cursor)
  end

  view.grow_from_content()

  log.profile_end(profile)

  events._dispatch_on_tree_rendered(bufnr, view.get_winnr())
end

return Renderer
