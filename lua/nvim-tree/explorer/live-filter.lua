local view = require("nvim-tree.view")
local utils = require("nvim-tree.utils")
local config = require("nvim-tree.config")

local Class = require("nvim-tree.classic")
local Iterator = require("nvim-tree.iterators.node-iterator")
local DirectoryNode = require("nvim-tree.node.directory")

---@class (exact) LiveFilter: nvim_tree.Class
---@field explorer Explorer
---@field prefix string
---@field always_show_folders boolean
---@field fuzzy boolean
---@field regex_mode boolean
---@field expand_folders boolean
---@field filter string
---@field prev_focused_node? Node
---@field open_folders? table<string, boolean>
local LiveFilter = Class:extend()

---@class LiveFilter
---@overload fun(args: LiveFilterArgs): LiveFilter

---@class (exact) LiveFilterArgs
---@field explorer Explorer

---@protected
---@param args LiveFilterArgs
function LiveFilter:new(args)
  self.explorer = args.explorer
  self.prefix = self.explorer.opts.live_filter.prefix
  self.always_show_folders = self.explorer.opts.live_filter.always_show_folders
  self.fuzzy = self.explorer.opts.live_filter.fuzzy
  self.regex_mode = not self.fuzzy
  self.expand_folders = self.explorer.opts.live_filter.expand_folders
  self.filter = nil
  self.prev_focused_node = nil
  self.open_folders = nil
end

---@param nodes Node[]
---@param fn fun(dir: DirectoryNode)
local function for_each_folder(nodes, fn)
  Iterator.builder(nodes)
    :hidden()
    :applier(function(node)
      local dir = node:as(DirectoryNode)
      if dir then
        fn(dir)
      end
    end)
    :recursor(function(node)
      return node.group_next and { node.group_next } or node.nodes
    end)
    :iterate()
end

---@param node_ Node?
local function reset_filter(self, node_)
  node_ = node_ or self.explorer

  if node_ == nil then
    return
  end

  local dir_ = node_:as(DirectoryNode)
  if dir_ then
    dir_.hidden_stats = vim.tbl_deep_extend("force", dir_.hidden_stats or {}, { live_filter = 0, })
  end

  Iterator.builder(node_.nodes)
    :hidden()
    :applier(function(node)
      node.hidden = false
      local dir = node:as(DirectoryNode)
      if dir then
        dir.hidden_stats = vim.tbl_deep_extend("force", dir.hidden_stats or {}, { live_filter = 0, })
      end
    end)
    :iterate()
end

---@param filter string
---@return string
local function fuzzy_pattern(filter)
  local terms = {}
  for term in filter:gmatch("%S+") do
    local chars = vim.tbl_map(function(char)
      return vim.fn.escape(char, [[\.*~[]^$]])
    end, vim.fn.split(term, [[\zs]]))
    table.insert(terms, ".*" .. table.concat(chars, [[.\{-}]]))
  end
  return [[\c]] .. table.concat(terms, [[\&]])
end

---@return vim.regex?
local function filter_regex(self)
  local pattern = self.regex_mode and self.filter or fuzzy_pattern(self.filter)
  local ok, regex = pcall(vim.regex, pattern)
  if ok then
    return regex
  end
end

---@param node Node
---@param regex vim.regex?
---@return boolean
local function matches(self, node, regex)
  if not self.explorer.filters.enabled then
    return true
  end

  if not regex then
    return false
  end

  local path = node.absolute_path
  local name = vim.fn.fnamemodify(path, ":t")
  return regex:match_str(name) ~= nil
end

---@param node Node
---@param regex vim.regex?
---@return boolean
local function ancestor_matches(self, node, regex)
  local ancestor = node.parent
  while ancestor and ancestor.parent do
    if matches(self, ancestor, regex) then
      return true
    end
    ancestor = ancestor.parent
  end
  return false
end

local function focus_first_match(self)
  local regex = filter_regex(self)
  local line = require("nvim-tree.core").get_nodes_starting_line()
  local nodes_by_line = self.explorer:get_nodes_by_line(line)
  while nodes_by_line[line] do
    if matches(self, nodes_by_line[line], regex) then
      view.set_cursor({ line, 0 })
      return
    end
    line = line + 1
  end
end

---@param line integer
---@return boolean
local function is_node_line(self, line)
  local first_line = require("nvim-tree.core").get_nodes_starting_line()
  return self.explorer:get_nodes_by_line(first_line)[line] ~= nil
end

---@param delta integer
local function move_cursor(self, delta)
  local winnr = view.get_winnr()
  if not winnr then
    return
  end

  local line = vim.api.nvim_win_get_cursor(winnr)[1] + delta
  if is_node_line(self, line) then
    view.set_cursor({ line, 0 })
  end
end

local overlay_bufnr = 0
local overlay_winnr = 0
local overlay_ns = vim.api.nvim_create_namespace("NvimTreeLiveFilterMode")

local function remove_overlay(self)
  if config.g.view.float.enable and config.g.view.float.quit_on_focus_loss then
    -- return to normal nvim-tree float behaviour when filter window is closed
    vim.api.nvim_create_autocmd("WinLeave", {
      pattern = "NvimTree_*",
      group = vim.api.nvim_create_augroup("NvimTree", { clear = false }),
      callback = function()
        if utils.is_nvim_tree_buf(0) then
          view.close()
        end
      end,
    })
  end

  vim.api.nvim_win_close(overlay_winnr, true)
  vim.api.nvim_buf_delete(overlay_bufnr, { force = true })
  overlay_bufnr = 0
  overlay_winnr = 0

  if self.filter == "" then
    self:clear_filter()
    return
  end

  local winnr = view.get_winnr()
  if not (winnr and is_node_line(self, vim.api.nvim_win_get_cursor(winnr)[1])) then
    focus_first_match(self)
  end
end

---@param node_ DirectoryNode?
function LiveFilter:apply_filter(node_)
  if not self.filter or self.filter == "" then
    reset_filter(self, node_)
    return
  end

  local regex = filter_regex(self)

  if node_ and ancestor_matches(self, node_, regex) then
    reset_filter(self, node_)
    return
  end

  -- this iterator cannot yet be refactored with the Iterator module
  -- since the node mapper is based on its children
  local function iterate(node)
    local filtered_nodes = 0
    local nodes = node.group_next and { node.group_next } or node.nodes

    node.hidden_stats = vim.tbl_deep_extend("force", node.hidden_stats or {}, {
      live_filter = 0,
    })

    if nodes then
      for _, n in pairs(nodes) do
        iterate(n)
        if n.hidden then
          filtered_nodes = filtered_nodes + 1
        end
      end
    end

    node.hidden_stats.live_filter = filtered_nodes

    local has_nodes = nodes and (self.always_show_folders or #nodes > filtered_nodes)
    local is_match = matches(self, node, regex)
    if is_match and nodes and node.parent then
      reset_filter(self, node)
    end
    node.hidden = not (has_nodes or is_match)
  end

  iterate(node_ or self.explorer)
end

local function record_char(self)
  vim.schedule(function()
    self.filter = vim.api.nvim_buf_get_lines(overlay_bufnr, 0, -1, false)[1]
    self:apply_filter()
    self.explorer.renderer:draw()
    focus_first_match(self)
  end)
end

local function show_mode(self)
  if overlay_bufnr == 0 or not vim.api.nvim_buf_is_valid(overlay_bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(overlay_bufnr, overlay_ns, 0, -1)
  vim.api.nvim_buf_set_extmark(overlay_bufnr, overlay_ns, 0, 0, {
    virt_text     = { { self.regex_mode and "regex" or "fuzzy", "NvimTreeLiveFilterPrefix" } },
    virt_text_pos = "right_align",
  })
end

local function toggle_mode(self)
  self.regex_mode = not self.regex_mode
  self:apply_filter()
  self.explorer.renderer:draw()
  focus_first_match(self)
  show_mode(self)
end

local function configure_buffer_overlay(self)
  overlay_bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_attach(overlay_bufnr, true, {
    on_lines = function()
      return record_char(self)
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      return remove_overlay(self)
    end,
    once = true,
  })

  vim.api.nvim_buf_set_keymap(overlay_bufnr, "i", "<CR>", "<cmd>stopinsert<CR>", {})
  vim.api.nvim_buf_set_keymap(overlay_bufnr, "i", "<C-c>", "<cmd>stopinsert<CR>", {})

  vim.keymap.set("i", "<C-g>", function()
    toggle_mode(self)
  end, { buffer = overlay_bufnr })

  for key, delta in pairs({ ["<Down>"] = 1, ["<C-n>"] = 1, ["<Up>"] = -1, ["<C-p>"] = -1 }) do
    vim.keymap.set("i", key, function()
      move_cursor(self, delta)
    end, { buffer = overlay_bufnr })
  end
end

---@return integer
local function calculate_overlay_win_width(self)
  local wininfo = vim.fn.getwininfo(view.get_winnr())[1]

  if wininfo then
    return wininfo.width - wininfo.textoff - #self.prefix
  end

  return 20
end

local function create_overlay(self)
  if config.g.view.float.enable then
    -- don't close nvim-tree float when focus is changed to filter window
    vim.api.nvim_clear_autocmds({
      event   = "WinLeave",
      pattern = "NvimTree_*",
      group   = vim.api.nvim_create_augroup("NvimTree", { clear = false }),
    })
  end

  configure_buffer_overlay(self)
  overlay_winnr = vim.api.nvim_open_win(overlay_bufnr, true, {
    col      = 1,
    row      = 0,
    relative = "cursor",
    width    = calculate_overlay_win_width(self),
    height   = 1,
    border   = "none",
    style    = "minimal",
  })

  vim.api.nvim_set_option_value("modifiable", true,             { buf = overlay_bufnr })
  vim.api.nvim_set_option_value("filetype",   "NvimTreeFilter", { buf = overlay_bufnr })

  vim.api.nvim_buf_set_lines(overlay_bufnr, 0, -1, false, { self.filter })
  show_mode(self)
  vim.cmd("startinsert")
  vim.api.nvim_win_set_cursor(overlay_winnr, { 1, #self.filter + 1 })
end

function LiveFilter:start_filtering()
  self.prev_focused_node = self.explorer:get_node_at_cursor()

  if not self.filter then
    self.regex_mode = not self.fuzzy
  end

  if self.expand_folders and not self.filter then
    self.open_folders = {}
    for_each_folder(self.explorer.nodes, function(dir)
      if dir.open then
        self.open_folders[dir.absolute_path] = true
      end
    end)
    self.explorer:expand_all()
  end

  self.filter = self.filter or ""

  self.explorer.renderer:draw()
  local row = require("nvim-tree.core").get_nodes_starting_line() - 1
  local col = #self.prefix > 0 and #self.prefix - 1 or 1
  view.set_cursor({ row, col })
  -- needs scheduling to let the cursor move before initializing the window
  vim.schedule(function()
    return create_overlay(self)
  end)
end

function LiveFilter:clear_filter()
  local node = self.explorer:get_node_at_cursor()

  self.filter = nil
  reset_filter(self)

  if self.open_folders then
    local keep_open = {}
    local focused = node or self.prev_focused_node
    local ancestor = focused and focused.parent
    while ancestor do
      keep_open[ancestor.absolute_path] = true
      ancestor = ancestor.parent
    end
    for_each_folder(self.explorer.nodes, function(dir)
      dir.open = self.open_folders[dir.absolute_path] or keep_open[dir.absolute_path] or false
    end)
    self.open_folders = nil
  end

  self.explorer.renderer:draw()

  if node then
    self.explorer:focus_node_or_parent(node)
  elseif self.prev_focused_node then
    self.explorer:focus_node_or_parent(self.prev_focused_node)
  end
end

return LiveFilter
