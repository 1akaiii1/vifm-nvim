# vifm-nvim

> Un picker de archivos y directorios flotante para Neovim, con toda la potencia de [vifm](https://vifm.info/) adentro.

Un float inferior, ancho completo, estilo fzf. Navegás con vifm.

---

## ✨ Características

- 🪟 **Ventana flotante inferior** — ancho completo, altura proporcional, sin alterar el layout.
- 🎨 **Aspecto coherente con fzf** — mismo borde, mismo fondo, sin franjas de color extrañas.
- 🔀 **Cambio de `cwd` con un atajo** — `<Space>cd` dentro de vifm guarda el directorio actual.
- 📂 **Apertura de archivos** — `Enter` sobre un archivo lo abre en Neovim.
- 🗂 **Modo aislado o compartido** — usá un vifmrc propio del plugin, uno inline, o tu `~/.config/vifm/` real.
- ⌨️ **Comandos de usuario** — `:VifmBuffer` y `:VifmCwd`.
- 🚀 **Sin dependencias** más allá de `vifm`.
- 🎛 **Totalmente configurable** vía `setup{}`.

---

## 📦 Requisitos

- Neovim **≥ 0.8** (usa `nvim_open_win`, `vim.api.nvim_get_hl`).
- [`vifm`](https://vifm.info/).
- `Ubuntu / Debian / Linux Mint: sudo apt install vifm`
- `Fedora: sudo dnf install vifm`
- `Archlinux: sudo pacman -S vifm`

Opcional pero recomendado:
- [`bat`](https://github.com/sharkdp/bat) — para previews de archivos de texto dentro de vifm.
- `wl-copy` (Wayland) o `xclip` (X11) — para los atajos de copiar rutas al portapapeles.
- [`vifm devicon`](https://github.com/thimc/vifm_devicons.git) — iconos requiere nerdfont.


## 🔧 Instalación

### lazy.nvim

```lua
{
  '1akaiii1/vifm-nvim',
  config = function()
    require('vifm-nvim').setup({
      -- opciones (ver abajo)
    })

    vim.keymap.set('n', '<leader>fB', '<cmd>VifmBuffer<cr>', { desc = 'Vifm: dir del buffer' })
    vim.keymap.set('n', '<leader>fb', '<cmd>VifmCwd<cr>',    { desc = 'Vifm: cwd' })
  end,
}
```


### vim-plug

```lua

vim.pack.add{
    "https://github.com/1akaiii1/vifm-nvim",
 }

require('vifm-nvim').setup({
      -- opciones (ver abajo)
    })

vim.keymap.set('n', '<leader>fB', '<cmd>VifmBuffer<cr>',
  { desc = 'Vifm: dir del buffer' })

vim.keymap.set('n', '<leader>fb', '<cmd>VifmCwd<cr>',
  { desc = 'Vifm: cwd' })
```
---

## 🚀 Uso

### Comandos

| Comando | Descripción |
|---|---|
| `:VifmBuffer` | Abre vifm en el directorio del buffer actual (fallback: `cwd`). |
| `:VifmCwd` | Abre vifm en el `cwd` de Neovim. |

### Keymaps recomendados

```lua
vim.keymap.set('n', '<leader>fB', '<cmd>VifmBuffer<cr>', { desc = 'Vifm: dir del buffer' })
vim.keymap.set('n', '<leader>fb', '<cmd>VifmCwd<cr>',    { desc = 'Vifm: cwd' })
```

## ⚙️ Configuración

### Setup completo con todos los defaults

```lua
require('vifm-nvim').setup({
  -- Directorio base para datos aislados
  base_dir = vim.fn.stdpath('data') .. '/vifm-nvim',

  -- nil    → vifmrc por defecto del plugin (recomendado)
  -- false  → usar tu ~/.config/vifm/ real
  -- string → usar este contenido
  vifmrc = nil,

  -- Umbral de pantalla "chica"
  small_cols  = 100,
  small_lines = 30,

  -- Geometría del float
  window = {
    width        = 1.0,       -- 100% del ancho
    height       = 0.50,      -- 50% del alto
    height_small = 0.75,      -- 75% en pantallas chicas
    bottom_gap   = 1,         -- líneas libres entre float y cmdline
    border       = 'rounded',
    style        = 'minimal',
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
| `window.height_small` | fracción o número | `0.75` | Alto en pantalla chica |
| `window.bottom_gap` | number | `1` | Líneas libres debajo del float |
| `window.border` | string | `'rounded'` | Estilo del borde |
| `window.style` | string | `'minimal'` | Estilo de la ventana |

Cada valor numérico de geometría acepta:
- **Fracción** entre `0` y `1` → ej: `0.5` = 50%
- **Valor absoluto** > `1` → ej: `20` = 20 líneas/columnas

### Modos de configuración de vifm

#### Aislado (por defecto)

Config y datos viven en `base_dir`. No toca tu vifm del sistema.
- `base_dir= ~/.local/share/nvim/vifm-nvim/cache/`
          `~/.local/share/nvim/vifm-nvim/config/`
        `  ~/.local/share/nvim/vifm-nvim/data/`
                                    
```lua
require('vifm-nvim').setup()   -- vifmrc = nil
```

#### vifmrc inline

```lua
require('vifm-nvim').setup({
  vifmrc = table.concat({
      'nnoremap w :view<cr>',
      'qnoremap w :view<cr>',
      'set vicmd=nvim',
      'set vixcmd=nvim',
      'nnoremap ,c :write | edit $MYVIFMRC | restart full<cr>',
      '',
      '" Guardar dir actual y salir (Neovim leerá $VIFM_CWD_FILE)',
      'nnoremap <Space>cd :!echo -n %d:p > "$VIFM_CWD_FILE"<cr>',
  }, '\n'),
})
```

#### Usar tu vifm del sistema

```lua
require('vifm-nvim').setup({
  vifmrc = false,
})
```

Con esto, vifm abre con tu `~/.config/vifm/vifmrc` real — bookmarks, colorscheme, handlers, todo.

> **Nota**: el atajo `<Space>cd` para cambiar el `cwd` **no viene mapeado** en tu vifm del sistema. Agregalo manualmente a tu `~/.config/vifm/vifmrc`:
> ```vifm
> nnoremap <Space>cd :!echo -n %d:p > "$VIFM_CWD_FILE"<cr>
> ```

---

## 🎨 Cambiar el `cwd`

Cuando apretás `<Space>cd` dentro de vifm:

1. vifm guarda su directorio actual en `$VIFM_CWD_FILE`.
2. `<Esc>`.
3. Neovim lee el archivo y hace `:cd` al directorio.
4. Recibís una notificación: `cd → /ruta`.

---

## 🧩 API programática

```lua
local vifm = require('vifm-nvim')

-- Abrir en un directorio específico
vifm.toggle({ start_dir = '/tmp' })

-- Cerrar si está abierto
vifm.close()
```

---

## 🩹 Solución de problemas

### El borde del float se ve distinto que el de fzf

El plugin define `VifmFloatBorder` con `ctermfg=8` (gris ANSI). Si tu paleta mapea el color 8 a otro tono, ajustalo en tu config:

```lua
vim.api.nvim_set_hl(0, 'VifmFloatBorder', {
  ctermfg = 8,     -- probá 0, 7, 8, 15
  bg      = 'NONE',
})
```

## 📐 Estructura del proyecto

```
vifm-nvim/
└── lua/
    └── vifm-nvim/
        └── init.lua
```

---


## 🙏 Créditos

- [vifm](https://vifm.info/) — el mejor file manager de terminal.
- [fzf](https://github.com/junegunn/fzf) — inspiración para el estilo del float.
