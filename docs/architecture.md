# Architecture

Component Vault is split into focused modules so the Studio UI, component format, reconstruction logic, and persistence layer can evolve independently.

## Source layout

### `src/init.server.luau`

The Rojo plugin entry point. It keeps startup intentionally small and delegates the actual interface to `ui/MainWidget.luau`.

### `src/components/Serializer.luau`

Converts a supported Roblox UI hierarchy into a plain, versioned data structure. It captures a curated set of common properties, attributes, descendants, and Roblox datatypes.

Unsupported descendants or properties are surfaced as warnings instead of being silently guessed.

### `src/components/Rebuilder.luau`

Reconstructs serialized component data into normal Roblox Instances. It validates the component schema version and restricts reconstruction to Component Vault's supported UI classes.

### `src/storage/LibraryStore.luau`

Owns the local component library. It handles:

- loading and saving through Roblox Studio plugin settings
- stable component IDs
- add/update/rename/delete operations
- tags
- cross-place persistence
- export/import bundles
- duplicate-name handling during import

The local library is JSON-encoded, then stored under a safe plugin-setting key. Writes are read back and verified before being treated as successful.

### `src/ui/MainWidget.luau`

Builds the dockable Studio interface and wires user actions to the serializer, rebuilder, and storage layer. It contains the library browser, search/sort/tag filtering, transfer panel, insertion target selection, and Studio undo integration.

### `src/ui/PreviewRenderer.luau`

Creates a best-effort, non-interactive thumbnail of a saved component for library browsing. Preview problems are isolated from the actual saved component data and must not block insert/update/delete/transfer operations.

## Core data flow

```text
Studio selection
      ↓
Validate supported GuiObject
      ↓
Serialize hierarchy + metadata
      ↓
Persist in local Component Vault library
      ↓
Browse / preview / search / tag
      ↓
Choose insertion target
      ↓
Rebuild normal Roblox UI Instances
```

## Component format

Serialized components use a schema version so future format changes can be rejected or migrated deliberately. Roblox-specific values such as `UDim2`, `Color3`, enum items, sequences, vectors, rectangles, and fonts are encoded into tagged plain tables.

See [serializer-format.md](serializer-format.md) for more detail.

## Persistence and portability

The primary library is local to Roblox Studio and survives switching places. Component Vault also supports text-based export/import for backups and transfer between installations.

Import is intentionally defensive:

- unsupported future export versions are rejected
- unsupported future component schemas are rejected
- imported IDs are regenerated
- duplicate names are renamed instead of overwritten
- reconstruction is limited to the supported UI class allowlist

## Design constraints

The project currently favors predictable behavior over maximum coverage:

- no proprietary runtime UI framework
- no arbitrary Instance reconstruction
- no cloud/team library yet
- curated property coverage instead of attempting every Roblox property
- visible warnings when fidelity cannot be guaranteed

Future work can add themes/design tokens, component version history, broader UI coverage, and shared libraries without replacing the current serializer/store/rebuilder split.
