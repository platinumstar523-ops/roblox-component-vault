# Components domain

This folder contains Component Vault's component-domain logic.

- `Serializer.luau` converts supported Roblox UI hierarchies into a versioned plain-data representation.
- A future `Rebuilder.luau` will recreate normal Roblox instances from the same representation.

Keeping this logic separate from the plugin window and persistence layer makes the component format testable and reusable.
