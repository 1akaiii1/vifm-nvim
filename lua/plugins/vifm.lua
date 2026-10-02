-- lua/plugins/vifm.lua
require('vifm-nvim').setup({

  -- ─── Almacenamiento aislado ──────────────────────────────────
  -- Directorio base donde el plugin guarda todo lo suyo:
  --   <base_dir>/config/vifm/   → vifmrc, vifminfo.json
  --   <base_dir>/data/vifm/     → trash, marcadores persistentes
  --   <base_dir>/cache/vifm/    → cache
  -- Por defecto:
  -- base_dir = vim.fn.stdpath('data') .. '/vifm-nvim',

  -- ─── Contenido del vifmrc ────────────────────────────────────
  -- nil    → usa el vifmrc por defecto del plugin (recomendado)
  -- false  → no escribe ningún vifmrc (usa los defaults de vifm)
  -- string → usa este contenido tal cual
  -- ⚠ Solo se aplica si el archivo NO existe todavía.
  --    Para regenerarlo: rm <base_dir>/config/vifm/vifmrc
  vifmrc = nil,

  -- ─── Umbral de "pantalla chica" ──────────────────────────────
  -- Si cols <= small_cols O lines <= small_lines, se usa
  -- window.height_small en lugar de window.height.
  small_cols  = 100,
  small_lines = 30,

  -- ─── Geometría de la ventana flotante ────────────────────────
  -- Cada valor numérico puede ser:
  --   * fracción entre 0 y 1  → ej: 0.5 = 50%
  --   * valor absoluto > 1    → ej: 20 = 20 líneas/columnas
  window = {
    width        = 1.0,    -- ancho (1.0 = todo el ancho)
    height       = 0.57,   -- alto en pantalla normal (50%)
    height_small = 1.0,   -- alto en pantalla chica (75%)
    bottom_gap   = 4,      -- líneas libres entre el float y la cmdline
    border       = 'rounded',   -- 'none' | 'single' | 'double' | 'rounded' | 'solid' | 'shadow'
    style        = 'minimal',   -- 'minimal' | 'full'
  },
})

-- ─── Keymaps ──────────────────────────────────────────────────

-- Toggle genérico (usa el dir del buffer si hay archivo, si no el cwd)
vim.keymap.set('n', '<leader>fm', function()
  require('vifm-nvim').toggle()
end, { desc = 'Vifm: toggle' })

-- Abrir en el directorio del buffer actual
vim.keymap.set('n', '<leader>fB', '<cmd>VifmBuffer<cr>',
  { desc = 'Vifm: dir del buffer' })

-- Abrir en el cwd de Neovim
vim.keymap.set('n', '<leader>fb', '<cmd>VifmCwd<cr>',
  { desc = 'Vifm: cwd' })
