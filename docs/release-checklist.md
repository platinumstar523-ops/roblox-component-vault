# Release checklist

Use this checklist before creating the first public Component Vault release.

## Version and repository

- [ ] Confirm `VERSION` matches the intended release version and remove the `-dev` suffix.
- [ ] Confirm `CHANGELOG.md` has a dated section for the release.
- [ ] Confirm the working tree is clean and the release commit is on `main`.
- [ ] Review open issues for release-blocking bugs.
- [ ] Confirm README and documentation match the shipped behavior.

## Build

- [ ] Pull the exact release commit into a clean checkout.
- [ ] Run `rojo build -p "ComponentVault.rbxm"` successfully.
- [ ] Install that exact `.rbxm` as a local Roblox Studio plugin.
- [ ] Restart Studio before testing.

## Studio smoke test

Run the full test in [testing.md](testing.md), including:

- [ ] save a nested UI component
- [ ] restart Studio and verify persistence
- [ ] open another place and verify persistence
- [ ] insert and compare the rebuilt hierarchy
- [ ] verify Studio Undo
- [ ] update an existing saved component
- [ ] rename and retag
- [ ] search, sort, and tag filter
- [ ] preview rendering at normal and narrow dock widths
- [ ] export the library
- [ ] import the export without overwriting existing components
- [ ] delete and restart to confirm deletion persists

## Release notes and artifact

- [ ] Update `docs/releases/v0.1.0.md` from draft wording to final release notes.
- [ ] List known limitations honestly.
- [ ] Add a current screenshot or short GIF to the README if available.
- [ ] Create tag `v0.1.0` only after the smoke test passes.
- [ ] Create the GitHub release from that exact tag.
- [ ] Attach the tested `ComponentVault.rbxm` artifact to the release.
- [ ] Verify the release download installs and opens correctly in Studio.

Do not publish the tag/release if a core save, persistence, insert, update, delete, or import/export regression remains unresolved.
