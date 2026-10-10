local buffers = require("nvim-tree.buffers")

local BuiltinDecorator = require("nvim-tree.renderer.decorator.builtin")
local DirectoryNode = require("nvim-tree.node.directory")

---@class (exact) ModifiedDecorator: BuiltinDecorator
local ModifiedDecorator = BuiltinDecorator:extend()

---@class ModifiedDecorator
---@overload fun(args: BuiltinDecoratorArgs): ModifiedDecorator

---@protected
---@param args BuiltinDecoratorArgs
function ModifiedDecorator:new(args)
  ModifiedDecorator.super.new(self, args)

  self.enabled         = true
  self.highlight_range = self.explorer.opts.renderer.highlight_modified or "none"
end

---Modified highlight: modified.enable, renderer.highlight_modified and node is modified
---@param node Node
---@return string? highlight_group
function ModifiedDecorator:highlight_group(node)
  if self.highlight_range == "none" or not buffers.is_modified(node) then
    return nil
  end

  if node:is(DirectoryNode) then
    return "NvimTreeModifiedFolderHL"
  else
    return "NvimTreeModifiedFileHL"
  end
end

return ModifiedDecorator
