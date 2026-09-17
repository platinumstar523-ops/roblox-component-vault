# Getting Started

Component Vault is currently in early development. This guide will expand as the plugin gains a stable development and installation workflow.

## Requirements

For development you will need:

- Roblox Studio
- Git
- A code editor with Luau support recommended

## Clone the Repository

```bash
git clone https://github.com/platinumstar523-ops/roblox-component-vault.git
cd roblox-component-vault
```

## Current Development Status

The repository is being scaffolded before the first functional plugin milestone. The next implementation step is the Studio plugin shell: a toolbar button and dockable Component Vault window.

A repeatable build/install workflow will be documented here once the project chooses its development tooling.

## v0.1 Development Target

The initial end-to-end workflow is:

1. Select a `GuiObject` in Roblox Studio.
2. Save it as a named component.
3. See it in the Component Vault library.
4. Open another place.
5. Insert a reconstructed copy of that component.

See [architecture.md](architecture.md) for the current technical direction.
