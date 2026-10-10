local BuiltinDecorator = require("nvim-tree.renderer.decorator.builtin")
local DirectoryNode = require("nvim-tree.node.directory")

---@class (exact) HiddenDecorator: BuiltinDecorator
local HiddenDecorator = BuiltinDecorator:extend()

---@class HiddenDecorator
---@overload fun(args: BuiltinDecoratorArgs): HiddenDecorator

---@protected
---@param args BuiltinDecoratorArgs
function HiddenDecorator:new(args)
  HiddenDecorator.super.new(self, args)

  self.enabled         = true
  self.highlight_range = self.explorer.opts.renderer.highlight_hidden or "none"
end

---Hidden highlight: renderer.highlight_hidden and node starts with `.` (dotfile).
---@param node Node
---@return string? highlight_group
function HiddenDecorator:highlight_group(node)
  if self.highlight_range == "none" or not node:is_dotfile() then
    return nil
  end

  if node:is(DirectoryNode) then
    return "NvimTreeHiddenFolderHL"
  else
    return "NvimTreeHiddenFileHL"
  end
end

return HiddenDecorator
