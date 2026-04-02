# nvim-dotfiles

My portable Neovim/LazyVim setup.

## Included

- LazyVim-based config with locked plugin versions via `lazy-lock.json`
- Custom plugins and keymaps under `lua/plugins`
- Automatic Mason tool installation for the language servers and formatters used in this setup
- Cross-platform restore scripts for Linux, macOS, and Windows

## Restore On A New Machine

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
2. Backs up any existing Neovim config.
3. Clones or updates this repo into the correct config directory.
4. Runs `Lazy sync` so plugins are installed.
5. Lets Mason restore the configured LSP/formatter/tooling set automatically.

## Notes

- Linux and macOS install to `~/.config/nvim`
- Windows installs to `%LOCALAPPDATA%\nvim`
- Existing configs are backed up with a timestamp before replacement
- AI tools such as Copilot, Claude Code, and OpenCode may still require their own login/API setup after restore
