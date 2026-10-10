local config = require("nvim-tree.config")

local M = {}

local function get_padding_indent_markers(depth, idx, nodes_number, markers, early_stop)
  local padding = ""

  if depth > 0 then
    local icons = config.g.renderer.indent_markers.icons
    local indent = string.rep(" ", config.g.renderer.indent_width - 1)
    markers[depth] = idx ~= nodes_number
    for i = 1, depth - early_stop do
      local glyph
      if idx == nodes_number and i == depth then
        local bottom_width = config.g.renderer.indent_width - 2
        glyph = icons.corner .. string.rep(icons.bottom, bottom_width) .. (config.g.renderer.indent_width > 1 and " " or "")
      elseif markers[i] and i == depth then
        glyph = icons.item .. indent
      elseif markers[i] then
        glyph = icons.edge .. indent
      else
        glyph = icons.none .. indent
      end

      padding = padding .. glyph
    end
  end
  return padding
end

---@param depth integer
---@param idx integer
---@param nodes_number integer
---@param markers table
---@param early_stop integer?
---@return nvim_tree.api.highlighted_string
function M.get_indent_markers(depth, idx, nodes_number, markers, early_stop)
  local str

  if config.g.renderer.indent_markers.enable then
    str = get_padding_indent_markers(depth, idx, nodes_number, markers, early_stop or 0)
  else
    str = string.rep(" ", depth * config.g.renderer.indent_width)
  end

  return { str = str, hl = { "NvimTreeIndentMarker" } }
end

return M
