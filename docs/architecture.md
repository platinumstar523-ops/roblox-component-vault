# Architecture

This document records the initial architecture direction for Component Vault. It describes planned responsibilities rather than a finished API.

## Design Goals

- Keep saved components as close as possible to normal Roblox UI Instances.
- Avoid requiring developers to adopt a custom runtime UI framework.
- Separate serialization, storage, and plugin interface concerns.
- Make future import/export and component versioning possible without redesigning the core format.

## Planned Source Layout

### `src/Main.plugin.lua`

Plugin entry point. Responsible for bootstrapping the toolbar, dock widget, and top-level services.

### `src/components/`

Component-domain logic, including serialization, validation, reconstruction, and metadata.

### `src/storage/`

Persistence for saved component libraries. The first version will focus on local plugin storage before more advanced sharing workflows are considered.

### `src/ui/`

The Studio plugin interface: library browsing, save dialogs, empty states, component previews, and related UI.

### `src/utils/`

Small shared helpers that do not belong to one domain.

## Core Data Flow

The intended first workflow is:

```text
Studio selection
      ↓
Validate selected GuiObject
      ↓
Serialize Instance hierarchy
      ↓
Store component data + metadata
      ↓
Display component in library
      ↓
Reconstruct hierarchy when inserted
```

## Early Constraints

The first release should prioritize reliable preservation of common Roblox UI objects and properties over supporting every possible Instance type immediately. Unsupported behavior should fail clearly rather than silently producing broken components.

Architectural decisions will be updated here as implementation begins.
