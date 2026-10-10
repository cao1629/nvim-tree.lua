local diagnostics = require("nvim-tree.diagnostics")

local BuiltinDecorator = require("nvim-tree.renderer.decorator.builtin")
local DirectoryNode = require("nvim-tree.node.directory")

-- highlight groups by severity
local HG_FILE = {
  [vim.diagnostic.severity.ERROR] = "NvimTreeDiagnosticErrorFileHL",
  [vim.diagnostic.severity.WARN] = "NvimTreeDiagnosticWarnFileHL",
  [vim.diagnostic.severity.INFO] = "NvimTreeDiagnosticInfoFileHL",
  [vim.diagnostic.severity.HINT] = "NvimTreeDiagnosticHintFileHL",
}
local HG_FOLDER = {
  [vim.diagnostic.severity.ERROR] = "NvimTreeDiagnosticErrorFolderHL",
  [vim.diagnostic.severity.WARN] = "NvimTreeDiagnosticWarnFolderHL",
  [vim.diagnostic.severity.INFO] = "NvimTreeDiagnosticInfoFolderHL",
  [vim.diagnostic.severity.HINT] = "NvimTreeDiagnosticHintFolderHL",
}

---@class (exact) DiagnosticsDecorator: BuiltinDecorator
local DiagnosticsDecorator = BuiltinDecorator:extend()

---@class DiagnosticsDecorator
---@overload fun(args: BuiltinDecoratorArgs): DiagnosticsDecorator

---@protected
---@param args BuiltinDecoratorArgs
function DiagnosticsDecorator:new(args)
  DiagnosticsDecorator.super.new(self, args)

  self.enabled         = true
  self.highlight_range = self.explorer.opts.renderer.highlight_diagnostics or "none"
end

---Diagnostic highlight: diagnostics.enable, renderer.highlight_diagnostics and node has status
---@param node Node
---@return string? highlight_group
function DiagnosticsDecorator:highlight_group(node)
  if self.highlight_range == "none" then
    return nil
  end

  local diag_status = diagnostics.get_diag_status(node)
  local diag_value = diag_status and diag_status.value

  if not diag_value then
    return nil
  end

  local group
  if node:is(DirectoryNode) then
    group = HG_FOLDER[diag_value]
  else
    group = HG_FILE[diag_value]
  end

  if group then
    return group
  else
    return nil
  end
end

return DiagnosticsDecorator
