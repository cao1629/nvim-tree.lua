local DecoratorInterface = require("nvim-tree._meta.api.decorator")

---
---Abstract decorator
---
---@class (exact) Decorator: nvim_tree.api.Decorator
local Decorator = DecoratorInterface:extend()

---Maybe highlight group for the name
---@param node nvim_tree.api.Node
---@return string? name highlight group
function Decorator:highlight_group_name(node)
  if self.enabled and self.highlight_range == "name" then
    return self:highlight_group(node)
  end
end

---@type Decorator
return Decorator
