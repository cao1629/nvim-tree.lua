---@meta
error("Cannot require a meta file")



---Integrate with [lsp] or COC diagnostics.
---
---See [nvim-tree-highlighting].
---
---@class nvim_tree.config.diagnostics
---
---(default: `false`)
---@field enable? boolean
---
---Idle milliseconds between diagnostic event and tree update.
---(default: `500`)
---@field debounce_delay? integer
---
---Show diagnostics of children on parent directories.
---(default: `false`)
---@field show_on_dirs? boolean
---
---Show diagnostics of children on directories that are open. Requires {show_on_dirs}.
---(default: `true`)
---@field show_on_open_dirs? boolean
---
---Global [vim.diagnostic.Opts] overrides {severity}
---(default: `false`)
---@field diagnostic_opts? boolean
---
---@field severity? nvim_tree.config.diagnostics.severity



---[nvim_tree.config.diagnostics.severity]()
---@class nvim_tree.config.diagnostics.severity
---@inlinedoc
---
---[vim.diagnostic.severity]
---(default: HINT)
---@field min? vim.diagnostic.Severity
---
---[vim.diagnostic.severity]
---(default: ERROR)
---@field max? vim.diagnostic.Severity
