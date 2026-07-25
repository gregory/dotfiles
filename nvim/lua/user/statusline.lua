-- Custom statusline modules layered on top of NvChad's default theme.
--
-- Wired in chadrc.lua via `M.ui.statusline.modules` and `M.ui.statusline.order`.
-- Each function returns a %#HighlightGroup#-prefixed string (or ""), so NvChad's
-- generator can concatenate them with the built-in modules.
--
-- Design goals:
--   - silent by default: warnings/indicators only appear when they carry info
--   - reuse existing St_* highlight groups so colors match the NvChad theme
--   - cheap enough to run on every redraw (no shelling out, no file I/O)

local M = {}

local api = vim.api
local fn = vim.fn

local function stbufnr()
  return api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

local function is_active()
  return api.nvim_get_current_win() == vim.g.statusline_winid
end

-- ─── Treesitter context ────────────────────────────────────────────────────
-- Walks up the TS tree from the cursor to the nearest function/method/class
-- and shows its name. Truncates long names to keep the bar tight.
local context_node_types = {
  function_declaration = true,
  function_definition  = true,
  function_item        = true,
  method_declaration   = true,
  method_definition    = true,
  class_declaration    = true,
  class_definition     = true,
  arrow_function       = true,
  local_function       = true,
}

-- Memoised per (buffer, changedtick, cursor row). This runs on EVERY redraw,
-- so without a cache it re-derived the enclosing function on every keystroke
-- once real parsers were installed. Keyed on changedtick so an edit
-- invalidates it, and on the row because that is what can change the answer.
local context_cache = { key = nil, value = "" }

function M.context()
  if not is_active() then return "" end
  if vim.o.columns < 100 then return "" end
  -- A breadcrumb is not worth a reparse mid-keystroke: every insert-mode
  -- keypress invalidates the tree, which is exactly when this is most costly
  -- and least useful.
  if api.nvim_get_mode().mode:find "i" then return context_cache.value end

  local buf = stbufnr()
  local win = vim.g.statusline_winid or 0
  local cursor_ok, cursor = pcall(api.nvim_win_get_cursor, win)
  if not cursor_ok then return "" end
  local row, col = cursor[1] - 1, cursor[2]

  local key = buf .. ":" .. api.nvim_buf_get_changedtick(buf) .. ":" .. row
  if context_cache.key == key then return context_cache.value end
  context_cache.key = key
  context_cache.value = ""

  -- vim.treesitter.get_node uses the already-parsed tree and handles injected
  -- languages; the previous parser:parse() forced a fresh parse each redraw.
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row, col } })
  if not ok or not node then return "" end

  local name
  while node do
    if context_node_types[node:type()] then
      for child in node:iter_children() do
        local t = child:type()
        if t == "identifier" or t == "property_identifier" or t == "name" then
          local ok2, text = pcall(vim.treesitter.get_node_text, child, buf)
          if ok2 and text and text ~= "" then
            name = text
            break
          end
        end
      end
      if name then break end
    end
    node = node:parent()
  end

  if not name then return "" end
  if #name > 30 then name = name:sub(1, 29) .. "…" end
  context_cache.value = "%#St_LspMsg#  " .. name .. " "
  return context_cache.value
end

-- ─── Search count [n/N] ────────────────────────────────────────────────────
function M.search()
  if not is_active() then return "" end
  if vim.v.hlsearch == 0 then return "" end
  local ok, res = pcall(fn.searchcount, { maxcount = 999, timeout = 20 })
  if not ok or not res or not res.total or res.total == 0 then return "" end
  return string.format("%%#St_LspMsg# [%d/%d] ", res.current, res.total)
end

-- ─── Macro recording ───────────────────────────────────────────────────────
function M.macro()
  if not is_active() then return "" end
  local reg = fn.reg_recording()
  if reg == "" then return "" end
  return "%#St_lspError# REC @" .. reg .. " "
end

-- ─── Visual selection stats ────────────────────────────────────────────────
function M.vsel()
  if not is_active() then return "" end
  local m = api.nvim_get_mode().mode
  if m ~= "v" and m ~= "V" and m ~= "\22" then return "" end

  local s_line, s_col = fn.line("v"), fn.col("v")
  local e_line, e_col = fn.line("."), fn.col(".")
  if s_line > e_line or (s_line == e_line and s_col > e_col) then
    s_line, e_line = e_line, s_line
    s_col, e_col = e_col, s_col
  end

  local lines = e_line - s_line + 1
  local chars, words
  if m == "V" then
    chars = 0
    for i = s_line, e_line do
      chars = chars + #fn.getline(i) + 1
    end
    words = fn.wordcount().visual_words or 0
  else
    local wc = fn.wordcount()
    chars = wc.visual_chars or 0
    words = wc.visual_words or 0
  end

  return string.format("%%#St_LspMsg# %dL %dW %dC ", lines, words, chars)
end

-- ─── Buffer warnings (mixed indent, trailing ws, crlf, non-utf8) ───────────
-- Results are cached per buffer and invalidated on BufWritePost / TextChanged.
local warn_cache = {}

local function compute_warnings(buf)
  if not api.nvim_buf_is_valid(buf) then return "" end
  if vim.bo[buf].buftype ~= "" then return "" end

  local parts = {}

  -- File encoding: only show if not utf-8
  local enc = vim.bo[buf].fileencoding
  if enc ~= "" and enc ~= "utf-8" then
    table.insert(parts, enc)
  end

  -- Line endings: only if not LF
  local ff = vim.bo[buf].fileformat
  if ff ~= "" and ff ~= "unix" then
    table.insert(parts, ff == "dos" and "CRLF" or "CR")
  end

  -- Mixed indent / trailing whitespace: scan up to 2000 lines
  local lines = api.nvim_buf_get_lines(buf, 0, 2000, false)
  local has_tab_indent, has_space_indent, has_trailing = false, false, false
  for _, line in ipairs(lines) do
    if line:match("^\t") then has_tab_indent = true end
    if line:match("^  ") then has_space_indent = true end
    if line:match("[ \t]+$") then has_trailing = true end
    if has_tab_indent and has_space_indent and has_trailing then break end
  end
  if has_tab_indent and has_space_indent then
    table.insert(parts, "mixed-indent")
  end
  if has_trailing then
    table.insert(parts, "trail-ws")
  end

  if #parts == 0 then return "" end
  return "%#St_lspWarning#  " .. table.concat(parts, " ") .. " "
end

function M.warnings()
  if not is_active() then return "" end
  local buf = stbufnr()
  local cached = warn_cache[buf]
  if cached ~= nil then return cached end
  local result = compute_warnings(buf)
  warn_cache[buf] = result
  return result
end

-- ─── Coc status ────────────────────────────────────────────────────────────
function M.coc_status()
  if not is_active() then return "" end
  if vim.o.columns < 120 then return "" end
  local s = vim.g.coc_status
  if not s or s == "" then return "" end
  return "%#St_Lsp# " .. s .. " "
end

-- ─── Indent info (only when non-default) ───────────────────────────────────
function M.indent()
  if not is_active() then return "" end
  local buf = stbufnr()
  local bo = vim.bo[buf]
  local sw = bo.shiftwidth
  if bo.expandtab then
    if sw == 2 then return "" end
    return "%#St_pos_text# spaces:" .. sw .. " "
  else
    return "%#St_pos_text# tabs:" .. sw .. " "
  end
end

-- ─── Unsaved buffer count (excluding current) ──────────────────────────────
function M.unsaved()
  if not is_active() then return "" end
  local current = stbufnr()
  local count = 0
  for _, b in ipairs(api.nvim_list_bufs()) do
    if b ~= current and api.nvim_buf_is_loaded(b)
       and vim.bo[b].modified and vim.bo[b].buftype == "" then
      count = count + 1
    end
  end
  if count == 0 then return "" end
  return "%#St_lspWarning#  " .. count .. " "
end

-- ─── Setup: wire cache invalidation autocmds ───────────────────────────────
function M.setup()
  local group = api.nvim_create_augroup("UserStatuslineCache", { clear = true })
  api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufNewFile", "TextChanged", "InsertLeave" }, {
    group = group,
    callback = function(args)
      warn_cache[args.buf] = nil
    end,
  })
  api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      warn_cache[args.buf] = nil
    end,
  })
  -- Redraw statusline when macro recording starts/stops and on hlsearch toggle.
  api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = group,
    callback = function() vim.cmd("redrawstatus") end,
  })
end

return M
