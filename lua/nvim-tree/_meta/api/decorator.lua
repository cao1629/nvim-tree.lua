---@meta

---@brief
---Highlighting for node names is provided by Decorators, see [nvim-tree-highlighting] for an overview.
---
---Decorators are rendered in [nvim_tree.config.renderer] {decorators} order of additive precedence, with later decorators applying additively over earlier.
---
---You may provide your own in addition to the builtin decorators, see |nvim-tree-class-decorator-example|.
---
---Decorators set a highlight group name for the node name.
---
---To register your decorator:
---- Create a class that extends [nvim_tree.api.Decorator]
---- Register it by adding the class to [nvim_tree.config.renderer] {decorators}
---
---Your decorator will be constructed and executed each time the tree is rendered.
---
---Your class must:
---- [nvim_tree.Class:extend()] the interface [nvim_tree.api.Decorator]
---- Provide a no-arguments constructor [nvim_tree.Class:new()] that sets the mandatory fields:
---   - {enabled}
---   - {highlight_range}
---
---Your class may:
---- Implement [nvim_tree.api.Decorator:highlight_group()] to provide the highlight

local nvim_tree = { api = {} }

local Class = require("nvim-tree.classic")

---
---Text or glyphs with optional highlight group names to apply to it.
---
---@class nvim_tree.api.highlighted_string
---
---One or many glyphs/characters.
---@field str string
---
---Highlight group names to apply in order. Empty table for no highlighting.
---@field hl string[]


---
---Decorator interface
---
---@class nvim_tree.api.Decorator: nvim_tree.Class
---
---Enable this decorator.
---@field enabled boolean
---
---What to highlight: [nvim_tree.config.renderer.highlight]
---@field highlight_range nvim_tree.config.renderer.highlight
---
local Decorator = Class:extend()
nvim_tree.api.Decorator = Decorator

---
---One highlight group that applies additively to the {node} name for {highlight_range}.
---
---Abstract, optional to implement.
---
---@param node nvim_tree.api.Node
---@return string? highlight group name `nil` when no highlighting to apply to the node
function Decorator:highlight_group(node) end

return nvim_tree.api.Decorator
