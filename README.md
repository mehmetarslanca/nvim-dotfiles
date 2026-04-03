# nvim-dotfiles

My portable Neovim/LazyVim setup.

## Included

- LazyVim-based config with locked plugin versions via `lazy-lock.json`
- Custom plugins and keymaps under `lua/plugins`
- Automatic Mason tool installation for the language servers and formatters used in this setup
- Automatic external `opencode` CLI installation during setup
- Cross-platform install scripts for Linux, macOS, and Windows

## Install On A New Machine

### Linux / macOS

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mehmetarslanca/nvim-dotfiles/main/install.sh)"
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/mehmetarslanca/nvim-dotfiles/main/install.ps1 | iex
```

### Windows CMD

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/mehmetarslanca/nvim-dotfiles/main/install.ps1 | iex"
```

## What The Installer Does

1. Installs core dependencies when a supported package manager is available.
2. Installs the external `opencode` CLI needed by `opencode.nvim` and the `99` provider.
3. Backs up any existing Neovim config.
4. Clones or updates this repo into the correct config directory.
5. Runs `Lazy sync` so plugins are installed.
6. Lets Mason install the configured LSP/formatter/tooling set automatically.

## Custom Keymaps

`<leader>` is `Space`.

- `opencode.nvim`: `<leader>oc` opens/closes the OpenCode panel
- `opencode.nvim`: `<C-a>` asks OpenCode about the current cursor position or visual selection
- `opencode.nvim`: `<C-x>` opens the OpenCode action picker
- `opencode.nvim`: `go` + motion sends a range to OpenCode
- `opencode.nvim`: `goo` sends the current line to OpenCode
- `99.nvim`: in visual mode, `<leader>9v` prompts with the highlighted selection
- `99.nvim`: `<leader>9s` runs project search into quickfix
- `99.nvim`: `<leader>9x` stops all active `99` requests
- `GitHub Copilot` via `zbirenbaum/copilot.lua`: `<M-l>` accepts the inline autocomplete suggestion
- `GitHub Copilot` via `zbirenbaum/copilot.lua`: `<M-]>` selects the next suggestion
- `GitHub Copilot` via `zbirenbaum/copilot.lua`: `<M-[>` selects the previous suggestion
- `GitHub Copilot` via `zbirenbaum/copilot.lua`: `<C-]>` dismisses the current suggestion

## Authentication After Install

- `opencode.nvim` and `99.nvim` both depend on the external `opencode` CLI.
- Install scripts add `opencode` automatically, but you still need to authenticate on the new machine.
- Run `opencode` and use `/connect`, or run `opencode auth login`.
- Inline autocomplete comes from `zbirenbaum/copilot.lua`.
- To enable Copilot suggestions, run `:Copilot auth` inside Neovim.
- Auth credentials stay on the local machine and are not stored in this repo.

## Credential Safety

- This repo contains only the Neovim config and setup scripts.
- It does not include your local OpenCode auth files, Copilot auth files, shell environment files, or machine-specific tokens.
- Anyone cloning this repo must authenticate their own `opencode` and Copilot sessions locally.
- Cloning this repo does not give another user access to your accounts.

## Notes

- Linux and macOS install to `~/.config/nvim`
- Windows installs to `%LOCALAPPDATA%\nvim`
- OpenCode works best on Windows through WSL, even though the PowerShell installer is included here
- Existing configs are backed up with a timestamp before replacement
- If `opencode` is not found immediately after install, open a new terminal session
- AI tools such as Copilot, Claude Code, and OpenCode still require their own local login/API setup after install
