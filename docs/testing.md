# Manual testing

Component Vault does not yet have automated Roblox Studio integration tests, so behavior that touches Studio should be verified manually in a dedicated test place.

## Core smoke test

1. Create a `ScreenGui` under `StarterGui`.
2. Add a `Frame` with several descendants such as `TextButton`, `UICorner`, `UIStroke`, `UIGradient`, and a layout object.
3. Select the root `Frame` and save it in Component Vault with a unique name and tags.
4. Confirm the saved card shows a preview, root class, instance/property counts, and tags.
5. Fully close Studio, open another place, and confirm the component is still present.
6. Insert the component and compare the reconstructed hierarchy and visible UI with the original.
7. Use Studio Undo and confirm the inserted hierarchy is removed cleanly.
8. Modify a copy, select it, click **Update** on the saved component, then insert again and confirm the changes were stored.
9. Rename and retag the component and confirm both survive a Studio restart.
10. Verify search, tag filtering, and all sort modes.
11. Export the library from the Transfer panel.
12. Import the same export back into the library and confirm duplicate names receive suffixes rather than overwriting originals.
13. Delete a test component and confirm it stays deleted after restarting Studio.

## Narrow-dock UI check

Resize/dock Component Vault to a narrow width and confirm:

- the search/sort/tag controls remain usable
- previews remain contained inside cards
- component names/details do not overlap controls
- Insert, Update, and Delete remain separated and clickable
- the Transfer panel remains usable

## Proportional placement regression check

1. Save a root component whose `Position` includes pixel offsets in a large Studio viewport.
2. Change Studio to a meaningfully different viewport size and insert the component into an equivalent parent.
3. Confirm the root component stays at the same relative screen position and occupies roughly the same percentage of the destination parent.
4. Repeat with a non-zero `AnchorPoint`.
5. Confirm a root using `AutomaticSize` keeps automatic sizing instead of being forced to a proportional `Size`.
6. Confirm descendants keep their original internal positions and sizes.
7. Repeat with a source or destination parent containing `UIListLayout` or `UIGridLayout`; layout-controlled placement should remain controlled by the layout.
8. Insert a component saved before proportional-placement metadata existed and confirm it still inserts using its original serialized `Position` and `Size`.

## Update notification regression check

1. Start the plugin while the latest stable GitHub release matches the plugin's current version and confirm the header reports **Up to date**.
2. Click the version/update status and confirm a manual re-check does not interrupt normal plugin use.
3. Deny or disable HTTP access and confirm Component Vault still opens and all core library actions remain usable.
4. When testing against a newer release tag, confirm the header changes to an update-available state.
5. Click the update-available state and confirm the panel shows the official `github.com/platinumstar523-ops/roblox-component-vault/releases/tag/...` URL.
6. Restart Studio inside the six-hour cache interval and confirm the updater can reuse cached release metadata.
7. Confirm update checking never modifies or deletes the saved component library.

## Warning behavior

Serializer or preview limitations should produce explicit warnings rather than crashing the plugin or silently corrupting the saved component.

When testing a warning case, check Studio Output and confirm that core library actions still function.

## Persistence regression check

A save should only be reported as successful after the plugin storage write can be read back successfully. Always include a cross-place or full-restart persistence check when changing `LibraryStore.luau`.

## Before release

Run this complete smoke test using the exact build artifact intended for release. Record any known limitations in the release notes instead of hiding them.
