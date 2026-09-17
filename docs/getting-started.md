# Getting Started

Component Vault is in early development. The current development loop uses Roblox Studio, Git, VS Code, and Rojo.

## Requirements

For development you will need:

- Roblox Studio
- Git
- VS Code or another editor with Luau support
- Rojo CLI
- The Rojo VS Code extension is recommended

## Clone the Repository

```bash
git clone https://github.com/platinumstar523-ops/roblox-component-vault.git
cd roblox-component-vault
```

## Rojo Project

The repository's `default.project.json` maps the `src/` directory into a Roblox Studio plugin. The plugin entry point is `src/init.server.luau`.

Rojo's plugin workflow can build directly to your local Roblox Studio plugins folder:

```bash
rojo build -p "ComponentVault.rbxm"
```

During development, use watch mode so the local plugin is rebuilt when source files change:

```bash
rojo build -p "ComponentVault.rbxm" --watch
```

After the plugin is available to Studio, the **Component Vault** toolbar button should open a dockable Component Vault window.

## Current Development Status

The first plugin shell is implemented. It creates:

- A **Component Vault** Studio toolbar section.
- A toolbar button for opening and closing the plugin.
- A dockable Component Vault window.
- An honest empty state for the not-yet-implemented component library.

The next milestone is detecting the selected `GuiObject` and enabling the first **Save Component** flow.

## v0.1 Development Target

The initial end-to-end workflow is:

1. Select a `GuiObject` in Roblox Studio.
2. Save it as a named component.
3. See it in the Component Vault library.
4. Open another place.
5. Insert a reconstructed copy of that component.

See [architecture.md](architecture.md) for the current technical direction.
