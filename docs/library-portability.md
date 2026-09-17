# Library portability

Component Vault stores the working library in Roblox Studio plugin settings for fast cross-place reuse on one machine. The library UI also supports a text-based export/import bundle so developers can back up, move, or share saved UI components without depending on a specific place file.

Export bundles use the `ComponentVaultExport` format with version `1`. Imported component IDs are regenerated locally, duplicate names are renamed with a numeric suffix, and unsupported future component schema versions are skipped.
