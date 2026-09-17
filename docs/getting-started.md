# Getting Started

Component Vault is currently a pre-release Roblox Studio plugin. The core save, persist, preview, transfer, and insert workflow is working, but there is not a tagged public release yet.

## Requirements

For development or source installation you need:

- Roblox Studio
- Git
- Rojo CLI
- VS Code or another editor with Luau support is recommended

## Clone and build

```bash
git clone https://github.com/platinumstar523-ops/roblox-component-vault.git
cd roblox-component-vault
rojo build -p "ComponentVault.rbxm"
```

If Rojo is installed with Aftman on Windows and is not available on `PATH`:

```powershell
& "$HOME\.aftman\bin\rojo.exe" build -p "ComponentVault.rbxm"
```

The build creates `ComponentVault.rbxm` in the repository root.

## Install as a local Studio plugin

1. In Roblox Studio, open the local **Plugins Folder** from the Plugins tab.
2. Copy the built `ComponentVault.rbxm` into that folder.
3. Fully restart Roblox Studio after replacing the file.
4. Use the **Component Vault** toolbar button to open the dockable window.

For active source development, rebuild after pulling or changing source files and restart/reload Studio as needed.

## First-use workflow

1. Create or open a place with a `ScreenGui` under `StarterGui`.
2. Select a supported `GuiObject`, such as a `Frame` or `TextButton`.
3. Open Component Vault.
4. Enter a component name and optional comma-separated tags.
5. Click **Save Component**.
6. Confirm the component appears in the library with a preview.
7. Open another place and confirm the component is still present.
8. Click **Insert** to reconstruct it into the current UI target.

The plugin chooses an insertion target from the current Studio selection when possible. If no usable UI target is selected, it falls back to a `ScreenGui` under `StarterGui`.

## Library controls

Each saved component can be:

- Inserted
- Updated from the current Studio selection
- Renamed
- Retagged
- Deleted

The library also supports text search, tag filtering, and sorting by recently updated, name, or root class.

## Transfer between installations

Click **Transfer** to export the local library as text. Copy that export text somewhere safe. On another Studio installation, paste it into the Transfer panel and click **Import**.

Imports do not overwrite existing components. Duplicate names receive numeric suffixes, and imported components receive new IDs.

## Testing changes

Before considering a change complete, run the manual smoke test in [testing.md](testing.md). Visible UI changes should also be checked at narrow dock widths.

See [architecture.md](architecture.md) for the implementation structure and [release-checklist.md](release-checklist.md) for the first-release gate.
