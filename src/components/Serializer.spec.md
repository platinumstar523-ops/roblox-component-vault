# Serializer acceptance checklist

- Serializes a selected supported `GuiObject` as the root.
- Recursively serializes supported UI descendants.
- Encodes Roblox datatypes as tagged plain tables.
- Preserves supported properties and attributes.
- Reports unsupported descendants/properties as warnings.
- Returns instance/property counts for diagnostics.
- Does not mutate the selected UI hierarchy.
