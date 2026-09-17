# Serializer format

Component Vault serializes supported Roblox UI instances into plain Luau tables so the data can later be persisted, exported, versioned, and reconstructed.

## Schema version

The current format uses `schemaVersion = 1`.

A serialized component contains:

- `componentName`: the selected root object's name.
- `root`: the recursively serialized UI hierarchy.
- `warnings`: properties or descendants that could not be represented safely.
- `stats`: instance and property counts for diagnostics.

Each node contains:

- `className`
- `name`
- `properties`
- `attributes`
- `children`

Roblox datatypes such as `Color3`, `UDim2`, `Vector2`, enum items, sequences, and fonts are converted into tagged plain-table values. That keeps the format independent of live Studio instances and prepares it for JSON-compatible storage later.

## Initial supported instances

The first serializer pass supports common UI objects and decorators:

- `Frame`
- `TextLabel`, `TextButton`, `TextBox`
- `ImageLabel`, `ImageButton`
- `ScrollingFrame`
- `UICorner`, `UIStroke`, `UIGradient`
- `UIPadding`
- `UIListLayout`, `UIGridLayout`
- `UIAspectRatioConstraint`, `UISizeConstraint`, `UITextSizeConstraint`
- `UIScale`

Unsupported descendants are skipped and reported as warnings instead of silently corrupting the component.

## What comes next

The next milestone is a rebuilder that consumes this schema and recreates the serialized hierarchy as normal Roblox instances. Persistence and the component library will build on the same format.
