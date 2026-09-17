# Component Vault

Component Vault is an open-source Roblox Studio plugin for saving, organizing, and reusing UI components across experiences.

> **Status: pre-release.** The core workflow works, but there is not a tagged public release yet. Expect format and UI changes before v0.1.0.

## What works today

- Save a selected `GuiObject` and its supported UI descendants as a named component.
- Persist the local component library across Roblox Studio places.
- Insert saved components back into Studio as normal Roblox Instances.
- Update, rename, tag, search, sort, filter, and delete saved components.
- Preview saved components directly in the library.
- Use Studio undo after insertion.
- Export the full library as text and import it on another machine or account.
- Safely rename duplicate imports instead of silently overwriting existing components.

Component Vault does not require a runtime framework. Inserted components are ordinary Roblox UI Instances.

## Typical workflow

1. Select a supported UI object in Explorer or the viewport.
2. Give it a name and optional tags, then click **Save Component**.
3. Open another place and find the component in Component Vault.
4. Click **Insert** to reconstruct it in the selected UI container or a fallback `ScreenGui`.

Saved components remain available across Studio places on the same local Studio installation.

## Build and install from source

Requirements:

- Roblox Studio
- Git
- [Rojo](https://rojo.space/)

```bash
git clone https://github.com/platinumstar523-ops/roblox-component-vault.git
cd roblox-component-vault
rojo build -p "ComponentVault.rbxm"
```

Then open Roblox Studio's local **Plugins Folder**, copy `ComponentVault.rbxm` into it, and restart Studio. The **Component Vault** toolbar button should open the dockable plugin window.

If Rojo is installed through Aftman on Windows and is not on `PATH`, the equivalent command is:

```powershell
& "$HOME\.aftman\bin\rojo.exe" build -p "ComponentVault.rbxm"
```

See [docs/getting-started.md](docs/getting-started.md) for the full development and testing workflow.

## Current limitations

Component Vault is intentionally conservative before its first release:

- The saved library is local to the Studio installation; there is no cloud or team sync yet.
- Serialization covers a curated set of common Roblox UI classes and properties, not every possible Instance or property.
- Unsupported descendants/properties are reported as warnings rather than being guessed.
- Thumbnail previews are best-effort and may not perfectly reproduce every supported component.
- Import/export is text-based JSON rather than a hosted sharing service.
- Component version history, design tokens/themes, and team/shared libraries are not implemented yet.

## Repository structure

```text
roblox-component-vault/
├── src/
│   ├── init.server.luau
│   ├── components/
│   │   ├── Serializer.luau
│   │   └── Rebuilder.luau
│   ├── storage/
│   │   └── LibraryStore.luau
│   └── ui/
│       ├── MainWidget.luau
│       └── PreviewRenderer.luau
├── docs/
├── examples/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Documentation

- [Getting started](docs/getting-started.md)
- [Architecture](docs/architecture.md)
- [Manual testing](docs/testing.md)
- [Serializer format](docs/serializer-format.md)
- [Library portability](docs/library-portability.md)
- [Release checklist](docs/release-checklist.md)

## Contributing

Bug reports, focused feature ideas, documentation improvements, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Component Vault is licensed under the [MIT License](LICENSE).
