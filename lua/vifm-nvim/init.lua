-- lua/vifm-nvim/init.lua
local M = {}

local win, buf, temp_file, cwd_file

local config = {
  base_dir    = vim.fn.stdpath('data') .. '/vifm-nvim',
  vifmrc      = nil,
  small_cols  = 100,
  small_lines = 30,

  -- Color del borde del float.
  border_color = '#faf8f6',
  border_cterm = 7,

  window = {
    width        = 1.0,
    height       = 0.50,
    height_small = 0.75,
    bottom_gap   = 1,
    border       = 'rounded',
    style        = 'minimal',
    -- border_color y border_cterm también se aceptan acá (ver setup)
  },
}

-- ─── Helpers ────────────────────────────────────────────────

local function is_open()
  return win and vim.api.nvim_win_is_valid(win)
end

local function size(val, total)
  if type(val) ~= 'number' then return nil end
  return val <= 1 and math.floor(total * val) or math.floor(val)
end

local function ensure_dirs()
  for _, d in ipairs({
    config.base_dir,
    config.base_dir .. '/config/vifm',
    config.base_dir .. '/data/vifm',
    config.base_dir .. '/cache/vifm',
  }) do vim.fn.mkdir(d, 'p') end
end

local function ensure_vifmrc()
  local path = config.base_dir .. '/config/vifm/vifmrc'
  if vim.fn.filereadable(path) == 1 then return end

  local content = config.vifmrc
  if content == false then return end

  if content == nil then
    content = table.concat({
      '" vifm-nvim',
      'nnoremap w :view<cr>',
      'qnoremap w :view<cr>',
      'set vicmd=nvim',
      'set vixcmd=nvim',
      'nnoremap ,c :write | edit $MYVIFMRC | restart full<cr>',
      '',
      '" Guardar dir actual y salir (Neovim leerá $VIFM_CWD_FILE)',
      'nnoremap <Space>cd :!echo -n %d:p > "$VIFM_CWD_FILE"<cr>',
    }, '\n')
  end

  vim.fn.writefile(vim.split(content, '\n'), path)
end

local function geometry()
  local cols, lines = vim.o.columns, vim.o.lines
  local w = config.window
  local small = cols <= config.small_cols or lines <= config.small_lines

  local height = math.max(8, size(small and w.height_small or w.height, lines) or 15)
  height = math.min(height, lines - 2)

  local width = math.max(40, size(w.width, cols) or cols)
  local gap   = math.max(0, w.bottom_gap or 1)

  return {
    relative = 'editor',
    width    = width,
    height   = height,
    row      = lines - height - gap,
    col      = math.floor((cols - width) / 2),
    style    = w.style  or 'minimal',
    border   = w.border or 'rounded',
  }
end

local function sync_bg()
  local ok, n = pcall(vim.api.nvim_get_hl, 0, { name = 'Normal' })
  if ok and n and n.bg then
    vim.g.terminal_color_background = string.format('#%06x', n.bg)
  end
end

local function apply_hl()
  vim.api.nvim_set_hl(0, 'VifmFloatBorder', {
    fg      = config.border_color,
    ctermfg = config.border_cterm,
    bg      = 'NONE',
    ctermbg = 'NONE',
    default = false,
  })
  vim.api.nvim_set_hl(0, 'VifmFloatNormal', {
    fg = 'NONE', ctermfg = 'NONE',
    bg = 'NONE', ctermbg = 'NONE',
    default = false,
  })
end

M.reload_hl = apply_hl

-- ─── API ────────────────────────────────────────────────────

function M.close()
  if not is_open() then return end

  local to_close = win
  local file, new_cwd
  win, buf = nil, nil

  if temp_file and vim.fn.filereadable(temp_file) == 1 then
    local l = vim.fn.readfile(temp_file)
    if #l > 0 and l[1] ~= '' then file = l[1] end
    vim.fn.delete(temp_file)
  end
  temp_file = nil

  if cwd_file and vim.fn.filereadable(cwd_file) == 1 then
    new_cwd = vim.fn.readfile(cwd_file)[1]
    vim.fn.delete(cwd_file)
  end
  cwd_file = nil

  if vim.api.nvim_win_is_valid(to_close) then
    pcall(vim.api.nvim_win_close, to_close, true)
  end

  if new_cwd and new_cwd ~= '' and vim.fn.isdirectory(new_cwd) == 1 then
    if pcall(vim.cmd, 'cd ' .. vim.fn.fnameescape(new_cwd)) then
      vim.notify('cd → ' .. new_cwd, vim.log.levels.INFO, { title = 'vifm-nvim' })
    else
      vim.notify('No se pudo hacer cd a ' .. new_cwd, vim.log.levels.WARN, { title = 'vifm-nvim' })
    end
  end

  if file then
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
  end
end

function M.toggle(opts)
  opts = opts or {}
  if is_open() then M.close(); return end

  if vim.fn.executable('vifm') == 0 then
    vim.notify('vifm no está en el PATH', vim.log.levels.ERROR)
    return
  end

  local isolate = config.vifmrc ~= false
  if isolate then
    ensure_dirs()
    ensure_vifmrc()
  end

  -- Reaplicar colores justo antes de abrir el float
  sync_bg()
  apply_hl()

  local start_dir = opts.start_dir
  if not start_dir then
    local f = vim.api.nvim_buf_get_name(0)
    start_dir = f ~= '' and vim.fn.fnamemodify(f, ':p:h') or vim.fn.getcwd()
  end

  temp_file = vim.fn.tempname()
  cwd_file  = vim.fn.tempname()

  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  win = vim.api.nvim_open_win(buf, true, geometry())

  vim.wo[win].number         = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn     = 'no'
  vim.wo[win].winblend       = 0
  vim.wo[win].winhighlight   =
    'FloatBorder:VifmFloatBorder,FloatTitle:VifmFloatBorder,' ..
    'NormalFloat:VifmFloatNormal,Normal:VifmFloatNormal'

  local env
  if isolate then
    env = {
      VIFM            = config.base_dir .. '/config/vifm',
      XDG_CONFIG_HOME = config.base_dir .. '/config',
      XDG_DATA_HOME   = config.base_dir .. '/data',
      XDG_CACHE_HOME  = config.base_dir .. '/cache',
      VIFM_CWD_FILE   = cwd_file,
    }
  else
    env = { VIFM_CWD_FILE = cwd_file }
  end

  vim.fn.termopen({ 'vifm', '--choose-files', temp_file, start_dir }, {
    env = env,
    on_exit = function() if is_open() then M.close() end end,
  })

  vim.cmd('startinsert')

  vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>',
    '<C-\\><C-n>:lua require("vifm-nvim").close()<CR>',
    { noremap = true, silent = true })

  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf, once = true,
    callback = function() vim.schedule(function() M.close() end) end,
  })
end

-- ─── Setup ──────────────────────────────────────────────────

function M.setup(opts)
  opts = opts or {}

  if opts.base_dir    then config.base_dir    = opts.base_dir    end
  if opts.small_cols  then config.small_cols  = opts.small_cols  end
  if opts.small_lines then config.small_lines = opts.small_lines end
  if opts.vifmrc ~= nil then config.vifmrc    = opts.vifmrc      end

  -- Aceptar border_color / border_cterm en la raíz...
  if opts.border_color then config.border_color = opts.border_color end
  if opts.border_cterm then config.border_cterm = opts.border_cterm end

  -- ...o dentro de window (más intuitivo junto a border)
  if opts.window then
    config.window = vim.tbl_deep_extend('force', config.window, opts.window)
    if opts.window.border_color then config.border_color = opts.window.border_color end
    if opts.window.border_cterm then config.border_cterm = opts.window.border_cterm end
  end

  -- Aplicar ahora (por si no abrís el float todavía, quede listo)
  apply_hl()

  -- Comandos de usuario
  vim.api.nvim_create_user_command('VifmBuffer', function()
    local f = vim.api.nvim_buf_get_name(0)
    local d = f ~= '' and vim.fn.fnamemodify(f, ':p:h') or vim.fn.getcwd()
    M.toggle({ start_dir = d })
  end, { desc = 'Vifm en el dir del buffer' })

  vim.api.nvim_create_user_command('VifmCwd', function()
    M.toggle({ start_dir = vim.fn.getcwd() })
  end, { desc = 'Vifm en el cwd de Neovim' })

  vim.api.nvim_create_user_command('VifmReloadHL', function()
    apply_hl()
    vim.notify('Vifm highlights recargados', vim.log.levels.INFO)
  end, { desc = 'Reaplicar VifmFloatBorder/VifmFloatNormal' })
end

return M

