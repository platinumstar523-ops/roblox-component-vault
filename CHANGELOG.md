# Changelog

All notable changes to Component Vault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project intends to use semantic versioning once public releases begin.

## [Unreleased]

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
- Expanded support for modern font settings, CanvasGroup, ViewportFrame, VideoFrame, additional layouts, and flex items.
- Optional component tags with name/class/tag search.
- Portable text-based library export/import with duplicate-name renaming and regenerated imported IDs.
- Transfer panel for backing up, moving, or sharing Component Vault libraries.

### Fixed

- Hardened cross-place persistence after local-plugin testing showed a saved library could reload as empty.
- Deterministic property restore ordering for settings such as legacy `Font` and modern `FontFace`.
- Explicit duplicate-name handling and future-schema rejection.
- Imported component reconstruction is restricted to supported UI classes instead of arbitrary Instance classes.
