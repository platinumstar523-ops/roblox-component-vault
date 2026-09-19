# Changelog

All notable changes to Component Vault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project intends to use semantic versioning once public releases begin.

## [Unreleased]

### Added

- Responsive viewport metadata so newly saved or updated components can preserve relative placement and scale offset-based UI throughout the saved hierarchy when inserted into a different viewport or parent size.
- In-plugin update checks against the official GitHub latest-release endpoint, with cached checks and an update-available panel containing the official release link.

### Changed

- Component insertion now scales offset-based `UDim`/`UDim2` properties, text sizes, common pixel thicknesses, and relevant pixel vectors throughout the saved hierarchy while preserving scale-based values and `AnchorPoint`.
- Proportional placement is skipped for layout-controlled parents and older components without placement metadata, preserving the previous insertion behavior.
- The Component Vault window now shows its current version and update status without blocking normal plugin use when network or HTTP permission is unavailable.

## [0.1.0] - 2026-09-17

### Added

- Initial open-source project scaffold.
- Documentation structure for development and architecture notes.
- Source folders for plugin UI, component handling, storage, and utilities.
- Rojo plugin project configuration.
- Initial Roblox Studio toolbar button and dockable Component Vault window.
- Live detection of the selected Studio `GuiObject`.
- Versioned UI hierarchy serializer for common Roblox UI objects, decorators, layouts, properties, attributes, and Roblox datatypes.
- Serializer status feedback and explicit warnings for unsupported descendants or properties.
- Persistent local component library backed by Roblox Studio plugin settings.
- Named component saving from the current Studio selection.
- Library cards showing root class and serialized instance/property counts.
- Inline component renaming and deletion.
- Explicit JSON encoding and immediate read-back verification for local library persistence.
- Schema v1 component reconstruction for saved UI hierarchies, properties, attributes, and encoded Roblox datatypes.
- Insert actions for saved components with automatic target selection and fallback `ScreenGui` creation.
- Update actions that replace a saved component from the current Studio selection.
- Component-library search filtering.
- Undo waypoints around component insertion.
- Expanded support for modern font settings, `CanvasGroup`, `ViewportFrame`, `VideoFrame`, additional layouts, and flex items.
- Optional component tags with name/class/tag search.
- Portable text-based library export/import with duplicate-name renaming and regenerated imported IDs.
- Transfer panel for backing up, moving, or sharing Component Vault libraries.
- Best-effort thumbnail previews inside saved-component cards.
- Library sorting by updated time, name, or root class.
- Quick tag filtering alongside text search.
- Responsive card action layout for narrow Studio docks.
- GitHub bug-report, feature-request, and pull-request templates.
- Release checklist, v0.1.0 release notes, and release version marker.

### Changed

- Split the plugin entry point from the main dock-widget implementation so `src/init.server.luau` remains small.
- Refreshed README, getting-started, architecture, testing, and contribution documentation to match the working plugin.

### Fixed

- Hardened cross-place persistence after local-plugin testing showed a saved library could reload as empty.
- Deterministic property restore ordering for settings such as legacy `Font` and modern `FontFace`.
- Explicit duplicate-name handling and future-schema rejection.
- Imported component reconstruction is restricted to supported UI classes instead of arbitrary Instance classes.
- Component-card action buttons no longer overlap at narrow dock widths.
