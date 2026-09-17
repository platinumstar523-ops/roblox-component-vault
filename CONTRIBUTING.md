# Contributing to Component Vault

Thanks for your interest in contributing. Component Vault is pre-release, so some APIs and file formats may still change.

## Ways to contribute

- Report bugs with clear reproduction steps.
- Suggest focused workflow or compatibility improvements.
- Improve documentation or examples.
- Submit fixes or features through pull requests.

## Development workflow

1. Fork or clone the repository.
2. Create a branch for one focused change.
3. Keep commits descriptive and scoped to real work.
4. Build the plugin with Rojo.
5. Test Studio-facing changes manually.
6. Open a pull request explaining what changed, why, and how it was tested.

## Code guidelines

- Prefer readable Luau over clever abstractions.
- Keep modules focused on one responsibility.
- Avoid dependencies unless they clearly improve the project.
- Preserve normal Roblox Instance behavior wherever possible.
- Do not silently drop unsupported component data; warn or reject it clearly.
- Keep import/rebuild paths defensive against unsupported schemas and classes.
- Update documentation when user-visible behavior changes.

## Testing

For Studio-facing changes, follow [docs/testing.md](docs/testing.md). Pull requests that change visible plugin UI should include a screenshot or recording when useful and should be checked at narrow dock widths.

Changes to persistence, serialization, reconstruction, or transfer should include the relevant regression steps in the pull-request description.

## Pull requests

A useful pull request includes:

- a concise summary
- the problem it solves
- implementation notes when behavior is non-obvious
- how it was tested
- screenshots/recordings for visible UI changes when useful
- any new limitation or compatibility concern

## Conduct

Be respectful and constructive. Critique code and ideas rather than people.
