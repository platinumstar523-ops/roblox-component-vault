# Component Vault

Component Vault is an open-source Roblox Studio plugin for creating, organizing, and reusing UI components across experiences.

> **Status:** Early development. Component Vault is not yet ready for production use.

## Why Component Vault?

Roblox developers often rebuild or manually copy the same buttons, cards, menus, HUD elements, and full interfaces between projects. Component Vault aims to make those interfaces reusable components that can be saved once, organized into a library, and inserted into other experiences.

## v0.1 Goal

The first milestone is intentionally small:

- Save a selected Roblox UI object as a reusable component.
- Give saved components names.
- Browse saved components in a dockable Studio window.
- Insert a saved component into another place.
- Delete components from the local library.
- Preserve descendants and important UI properties.

More advanced ideas such as themes, design tokens, component versioning, team libraries, and shared libraries are planned for later releases.

## Repository Structure

```text
roblox-component-vault/
├── src/
│   ├── Main.plugin.lua
│   ├── components/
│   ├── storage/
│   ├── ui/
│   └── utils/
├── docs/
│   ├── architecture.md
│   └── getting-started.md
├── examples/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Contributing

The project is in its earliest stage, but issues, suggestions, bug reports, and contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the current contribution guidelines.

## License

Component Vault is licensed under the [MIT License](LICENSE).
