local BuiltinDecorator = require("nvim-tree.renderer.decorator.builtin")

---@class (exact) BookmarkDecorator: BuiltinDecorator
local BookmarkDecorator = BuiltinDecorator:extend()

---@class BookmarkDecorator
---@overload fun(args: BuiltinDecoratorArgs): BookmarkDecorator

---@protected
---@param args BuiltinDecoratorArgs
function BookmarkDecorator:new(args)
  BookmarkDecorator.super.new(self, args)

  self.enabled         = true
  self.highlight_range = self.explorer.opts.renderer.highlight_bookmarks or "none"
end

---Bookmark highlight: renderer.highlight_bookmarks and node is marked
---@param node Node
---@return string? highlight_group
function BookmarkDecorator:highlight_group(node)
  if self.highlight_range ~= "none" and self.explorer.marks:get(node) then
    return "NvimTreeBookmarkHL"
  end
end

return BookmarkDecorator
