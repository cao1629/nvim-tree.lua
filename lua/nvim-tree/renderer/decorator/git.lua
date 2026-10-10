local BuiltinDecorator = require("nvim-tree.renderer.decorator.builtin")
local DirectoryNode = require("nvim-tree.node.directory")

---@class (exact) GitDecorator: BuiltinDecorator
---@field private file_hl_by_xy table<nvim_tree.git.XY, string>?
---@field private folder_hl_by_xy table<nvim_tree.git.XY, string>?
local GitDecorator = BuiltinDecorator:extend()

---@class GitDecorator
---@overload fun(args: BuiltinDecoratorArgs): GitDecorator

---@protected
---@param args BuiltinDecoratorArgs
function GitDecorator:new(args)
  GitDecorator.super.new(self, args)

  self.enabled         = self.explorer.opts.git.enable
  self.highlight_range = self.explorer.opts.renderer.highlight_git or "none"

  if not self.enabled then
    return
  end

  if self.highlight_range ~= "none" then
    self:build_file_folder_hl_by_xy()
  end
end

function GitDecorator:build_file_folder_hl_by_xy()
  self.file_hl_by_xy = {
    ["M "] = "NvimTreeGitFileStagedHL",
    ["C "] = "NvimTreeGitFileStagedHL",
    ["AA"] = "NvimTreeGitFileStagedHL",
    ["AD"] = "NvimTreeGitFileStagedHL",
    ["MD"] = "NvimTreeGitFileStagedHL",
    ["T "] = "NvimTreeGitFileStagedHL",
    ["TT"] = "NvimTreeGitFileStagedHL",
    [" M"] = "NvimTreeGitFileDirtyHL",
    ["CM"] = "NvimTreeGitFileDirtyHL",
    [" C"] = "NvimTreeGitFileDirtyHL",
    [" T"] = "NvimTreeGitFileDirtyHL",
    ["MM"] = "NvimTreeGitFileDirtyHL",
    ["AM"] = "NvimTreeGitFileDirtyHL",
    dirty  = "NvimTreeGitFileDirtyHL",
    ["A "] = "NvimTreeGitFileStagedHL",
    ["??"] = "NvimTreeGitFileNewHL",
    ["AU"] = "NvimTreeGitFileMergeHL",
    ["UU"] = "NvimTreeGitFileMergeHL",
    ["UD"] = "NvimTreeGitFileMergeHL",
    ["DU"] = "NvimTreeGitFileMergeHL",
    ["UA"] = "NvimTreeGitFileMergeHL",
    [" D"] = "NvimTreeGitFileDeletedHL",
    ["DD"] = "NvimTreeGitFileDeletedHL",
    ["RD"] = "NvimTreeGitFileDeletedHL",
    ["D "] = "NvimTreeGitFileDeletedHL",
    ["R "] = "NvimTreeGitFileRenamedHL",
    ["RM"] = "NvimTreeGitFileRenamedHL",
    [" R"] = "NvimTreeGitFileRenamedHL",
    ["!!"] = "NvimTreeGitFileIgnoredHL",
    [" A"] = "NvimTreeGitFileNewHL",
  }

  self.folder_hl_by_xy = {}
  for k, v in pairs(self.file_hl_by_xy) do
    self.folder_hl_by_xy[k] = v:gsub("File", "Folder")
  end
end

---Git highlight: git.enable, renderer.highlight_git and node has status
---@param node Node
---@return string? highlight_group
function GitDecorator:highlight_group(node)
  if self.highlight_range == "none" then
    return nil
  end

  local git_xy = node:get_git_xy()
  if not git_xy then
    return nil
  end

  if node:is(DirectoryNode) then
    return self.folder_hl_by_xy[git_xy[1]]
  else
    return self.file_hl_by_xy[git_xy[1]]
  end
end

return GitDecorator
