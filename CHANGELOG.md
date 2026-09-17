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
