# vifm-nvim

### vim-plug

```lua

vim.pack.add{
    "https://github.com/1akaiii1/vifm-nvim",
 }

require('vifm-nvim').setup({
      -- opciones (ver abajo)
    })

```
## ⚙️ Configuración


```lua

require('vifm-nvim').setup({
  -- Directorio base del plugin. Aquí se crean config/, data/, cache/ de vifm
  -- y el vifmrc aislado. Por defecto: stdpath('data') .. '/vifm-nvim'
  base_dir = vim.fn.stdpath('data') .. '/vifm-nvim',

  -- Contenido del vifmrc aislado.
  --   nil   -> usa el vifmrc por defecto del plugin (recomendado)
  --   false -> no aísla nada: vifm usa tu ~/.config/vifm real
  --   string-> configuracion basica que se escribe en base_dir(si no hay vifmrc)
  vifmrc = nil,

  -- Umbrales para el layout "small": si las columnas o líneas de Neovim
  -- son menores o iguales a estos valores, se usa height_small.
  small_cols  = 100,
  small_lines = 30,

    -- ═══════════════════════════════════════════════════════════
  --  COLOR DEL BORDE DEL FLOAT
  -- ═══════════════════════════════════════════════════════════
  -- border_color → truecolor (GUI / terminales con truecolor)
  -- border_cterm → ANSI (terminales sin truecolor)
  --
  -- Sugerencias según colorscheme:
  --   One Dark          → '#abb2bf' / 7
  --   Tokyo Night       → '#c0caf5' / 7
  --   Catppuccin Mocha  → '#bac2de' / 7
  --   Catppuccin Frappe → '#c6d0f5' / 7
  --   Dracula           → '#f8f8f2' / 15
  --   Gruvbox           → '#ebdbb2' / 7
  --   Nord              → '#d8dee9' / 7
  --   Kanagawa          → '#dcd7ba' / 7

  border_color = '#c6d0f5',
  border_cterm = 7,

  -- Geometría y estilo de la ventana flotante.
  window = {
    width        = 1.0,      -- 1.0 = 100% del ancho. Números >1 = columnas exactas.
    height       = 0.50,     -- 0.50 = 50% del alto. Números >1 = líneas exactas.
    height_small = 1.0,     -- Alto cuando se cumple small_cols/small_lines.
    bottom_gap   = 1,        -- Líneas entre el borde inferior del float y el statusline.
    border       = 'rounded',-- 'none' | 'single' | 'double' | 'rounded' | 'solid' | 'shadow'
    style        = 'minimal',-- 'minimal' | 'shadow'
  },
})

```

### Opciones

| Opción | Tipo | Default | Descripción |
|---|---|---|---|
| `base_dir` | string | `stdpath('data')/vifm-nvim` | Directorio raíz para datos aislados |
| `vifmrc` | `nil` \| `false` \| string | `nil` | Modo de configuración |
| `small_cols` | number | `100` | Columnas mínimas para pantalla "normal" |
| `small_lines` | number | `30` | Líneas mínimas para pantalla "normal" |
| `window.width` | fracción o número | `1.0` | Ancho del float |
| `window.height` | fracción o número | `0.50` | Alto en pantalla normal |
| `window.height_small` | fracción o número | `1.0` | Alto en pantalla chica |
| `window.bottom_gap` | number | `1` | Líneas libres debajo del float |
| `window.border` | string | `'rounded'` | Estilo del borde |
| `window.style` | string | `'minimal'` | Estilo de la ventana |


#### Aislado (por defecto)

Config y datos viven en `base_dir`. No toca tu vifm del sistema.
-`~/.local/share/nvim/vifm-nvim/cache/`
-`~/.local/share/nvim/vifm-nvim/config/`
-`~/.local/share/nvim/vifm-nvim/data/`

```
---

## 🙏 Créditos

- [vifm](https://vifm.info/) — el mejor file manager de terminal.
- [fzf](https://github.com/junegunn/fzf) — inspiración para el estilo del float.
