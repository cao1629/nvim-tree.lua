local M = {}

---@class HighlightGroup
---@field group string
---@field link string|nil
---@field def string|nil

---@type HighlightGroup[]
-- All highlight groups: linked or directly defined.
-- Please add new groups to help and preserve order.
-- Please avoid directly defined groups to preserve accessibility for TUI.
M.HIGHLIGHT_GROUPS = {

  -- Standard
  { group = "NvimTreeNormal",                  link = "Normal" },
  { group = "NvimTreeNormalFloat",             link = "NormalFloat" },
  { group = "NvimTreeNormalFloatBorder",       link = "FloatBorder" },
  { group = "NvimTreeNormalNC",                link = "NvimTreeNormal" },

  { group = "NvimTreeLineNr",                  link = "LineNr" },
  { group = "NvimTreeWinSeparator",            link = "WinSeparator" },
  { group = "NvimTreeEndOfBuffer",             link = "EndOfBuffer" },
  { group = "NvimTreePopup",                   link = "Normal" },
  { group = "NvimTreeSignColumn",              link = "NvimTreeNormal" },

  { group = "NvimTreeCursorColumn",            link = "CursorColumn" },
  { group = "NvimTreeCursorLine",              link = "CursorLine" },
  { group = "NvimTreeCursorLineNr",            link = "CursorLineNr" },

  { group = "NvimTreeStatusLine",              link = "StatusLine" },
  { group = "NvimTreeStatusLineNC",            link = "StatusLineNC" },

  -- File Text
  { group = "NvimTreeExecFile",                link = "Question" },
  { group = "NvimTreeImageFile",               link = "Question" },
  { group = "NvimTreeSpecialFile",             link = "Title" },
  { group = "NvimTreeSymlink",                 link = "Underlined" },

  -- Folder Text
  { group = "NvimTreeRootFolder",              link = "Title" },
  { group = "NvimTreeFolderName",              link = "Directory" },
  { group = "NvimTreeEmptyFolderName",         link = "Directory" },
  { group = "NvimTreeOpenedFolderName",        link = "Directory" },
  { group = "NvimTreeSymlinkFolderName",       link = "Directory" },

  -- Indent
  { group = "NvimTreeIndentMarker",            def = "guifg=#8094b4 ctermfg=Blue" },

  -- Picker
  { group = "NvimTreeWindowPicker",            def = "guifg=#ededed guibg=#4493c8 gui=bold ctermfg=White ctermbg=DarkBlue" },

  -- LiveFilter
  { group = "NvimTreeLiveFilterPrefix",        link = "PreProc" },
  { group = "NvimTreeLiveFilterValue",         link = "ModeMsg" },

  -- Clipboard
  { group = "NvimTreeCutHL",                   link = "SpellBad" },
  { group = "NvimTreeCopiedHL",                link = "SpellRare" },

  -- Bookmark
  { group = "NvimTreeBookmarkHL",              link = "SpellLocal" },

  -- Modified
  { group = "NvimTreeModifiedFileHL",          link = "Type" },
  { group = "NvimTreeModifiedFolderHL",        link = "NvimTreeModifiedFileHL" },

  -- Hidden
  { group = "NvimTreeHiddenFileHL",            link = "Conceal" },
  { group = "NvimTreeHiddenFolderHL",          link = "NvimTreeHiddenFileHL" },

  -- Hidden Display
  { group = "NvimTreeHiddenDisplay",           link = "Conceal" },

  -- Opened
  { group = "NvimTreeOpenedHL",                link = "Special" },

  -- Git File Highlight
  { group = "NvimTreeGitFileDeletedHL",        link = "Statement" },
  { group = "NvimTreeGitFileDirtyHL",          link = "Statement" },
  { group = "NvimTreeGitFileIgnoredHL",        link = "Comment" },
  { group = "NvimTreeGitFileMergeHL",          link = "Constant" },
  { group = "NvimTreeGitFileNewHL",            link = "PreProc" },
  { group = "NvimTreeGitFileRenamedHL",        link = "PreProc" },
  { group = "NvimTreeGitFileStagedHL",         link = "Constant" },

  -- Git Folder Highlight
  { group = "NvimTreeGitFolderDeletedHL",      link = "NvimTreeGitFileDeletedHL" },
  { group = "NvimTreeGitFolderDirtyHL",        link = "NvimTreeGitFileDirtyHL" },
  { group = "NvimTreeGitFolderIgnoredHL",      link = "NvimTreeGitFileIgnoredHL" },
  { group = "NvimTreeGitFolderMergeHL",        link = "NvimTreeGitFileMergeHL" },
  { group = "NvimTreeGitFolderNewHL",          link = "NvimTreeGitFileNewHL" },
  { group = "NvimTreeGitFolderRenamedHL",      link = "NvimTreeGitFileRenamedHL" },
  { group = "NvimTreeGitFolderStagedHL",       link = "NvimTreeGitFileStagedHL" },

  -- Diagnostics File Highlight
  { group = "NvimTreeDiagnosticErrorFileHL",   link = "DiagnosticUnderlineError" },
  { group = "NvimTreeDiagnosticWarnFileHL",    link = "DiagnosticUnderlineWarn" },
  { group = "NvimTreeDiagnosticInfoFileHL",    link = "DiagnosticUnderlineInfo" },
  { group = "NvimTreeDiagnosticHintFileHL",    link = "DiagnosticUnderlineHint" },

  -- Diagnostics Folder Highlight
  { group = "NvimTreeDiagnosticErrorFolderHL", link = "NvimTreeDiagnosticErrorFileHL" },
  { group = "NvimTreeDiagnosticWarnFolderHL",  link = "NvimTreeDiagnosticWarnFileHL" },
  { group = "NvimTreeDiagnosticInfoFolderHL",  link = "NvimTreeDiagnosticInfoFileHL" },
  { group = "NvimTreeDiagnosticHintFolderHL",  link = "NvimTreeDiagnosticHintFileHL" },
}

-- nvim-tree highlight groups to legacy
M.LEGACY_LINKS = {
  NvimTreeOpenedHL = "NvimTreeOpenedFile",

  NvimTreeGitFileDeletedHL = "NvimTreeFileDeleted",
  NvimTreeGitFileDirtyHL = "NvimTreeFileDirty",
  NvimTreeGitFileIgnoredHL = "NvimTreeFileIgnored",
  NvimTreeGitFileMergeHL = "NvimTreeFileMerge",
  NvimTreeGitFileNewHL = "NvimTreeFileNew",
  NvimTreeGitFileRenamedHL = "NvimTreeFileRenamed",
  NvimTreeGitFileStagedHL = "NvimTreeFileStaged",

  NvimTreeGitFolderDeletedHL = "NvimTreeFolderDeleted",
  NvimTreeGitFolderDirtyHL = "NvimTreeFolderDirty",
  NvimTreeGitFolderIgnoredHL = "NvimTreeFolderIgnored",
  NvimTreeGitFolderMergeHL = "NvimTreeFolderMerge",
  NvimTreeGitFolderNewHL = "NvimTreeFolderNew",
  NvimTreeGitFolderRenamedHL = "NvimTreeFolderRenamed",
  NvimTreeGitFolderStagedHL = "NvimTreeFolderStaged",

  NvimTreeDiagnosticErrorFileHL = "NvimTreeLspDiagnosticsErrorText",
  NvimTreeDiagnosticWarnFileHL = "NvimTreeLspDiagnosticsWarningText",
  NvimTreeDiagnosticInfoFileHL = "NvimTreeLspDiagnosticsInformationText",
  NvimTreeDiagnosticHintFileHL = "NvimTreeLspDiagnosticsHintText",

  NvimTreeDiagnosticErrorFolderHL = "NvimTreeLspDiagnosticsErrorFolderText",
  NvimTreeDiagnosticWarnFolderHL = "NvimTreeLspDiagnosticsWarningFolderText",
  NvimTreeDiagnosticInfoFolderHL = "NvimTreeLspDiagnosticsInformationFolderText",
  NvimTreeDiagnosticHintFolderHL = "NvimTreeLspDiagnosticsHintFolderText",
}

---Create all highlight groups and links. Idempotent.
function M.highlight()
  -- non-linked
  for _, g in ipairs(M.HIGHLIGHT_GROUPS) do
    if g.def then
      vim.api.nvim_command("hi def " .. g.group .. " " .. g.def)
    end
  end

  -- hard link override when legacy only is present
  for from, to in pairs(M.LEGACY_LINKS) do
    local hl_from = vim.api.nvim_get_hl(0, { name = from })
    local hl_to = vim.api.nvim_get_hl(0, { name = to })
    if vim.tbl_isempty(hl_from) and not vim.tbl_isempty(hl_to) then
      vim.api.nvim_command("hi link " .. from .. " " .. to)
    end
  end

  -- default links
  for _, g in ipairs(M.HIGHLIGHT_GROUPS) do
    if g.link then
      vim.api.nvim_command("hi def link " .. g.group .. " " .. g.link)
    end
  end
end

return M
