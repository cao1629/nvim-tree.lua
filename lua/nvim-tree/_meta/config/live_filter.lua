---@meta
error("Cannot require a meta file")



--- Live filter allows you to filter the tree nodes dynamically using [regular-expression] matching.
---
--- When a folder's name matches, everything under it is shown.
---
--- This feature is bound to the `f` key by default. The filter can be cleared with the `F` key by default.
---
---@class nvim_tree.config.live_filter
---
---Prefix of the filter displayed in the buffer.
---(default: `"[FILTER]: "`)
---@field prefix? string
---
---Whether to filter folders or not.
---(default: `true`)
---@field always_show_folders? boolean
---
---Match the filter as a fuzzy pattern instead of a [regular-expression]: its characters must appear in the name in order, case is ignored and space separated terms must all match.
---(default: `false`)
---@field fuzzy? boolean
---
---Expand all folders when filtering starts so that collapsed folders are searched too, limited by [nvim_tree.config.actions.expand_all]. Folders return to their previous state when the filter is cleared, apart from the ancestors of the node under the cursor.
---(default: `false`)
---@field expand_folders? boolean
