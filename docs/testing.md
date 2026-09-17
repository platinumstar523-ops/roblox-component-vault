# Manual testing

Until automated Studio tests are added, new plugin behavior should be verified in a dedicated Roblox Studio test place.

For serializer changes:

1. Create a `ScreenGui` under `StarterGui`.
2. Add a `Frame` with a few common descendants such as `UICorner`, `UIStroke`, `TextButton`, and `UIGradient`.
3. Select the root `Frame` in Explorer.
4. Open Component Vault.
5. Click **Serialize Component**.
6. Confirm the panel reports a successful serialization with non-zero instance/property counts.
7. Confirm Studio Output contains the serialized component summary and any explicit warnings.

Unsupported descendants should produce visible warnings rather than causing the whole serialization to fail silently.
