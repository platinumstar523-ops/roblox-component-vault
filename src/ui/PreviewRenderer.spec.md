# PreviewRenderer behavior

`PreviewRenderer` rebuilds a saved Component Vault hierarchy into a clipped, non-interactive thumbnail host inside the plugin library.

The saved root is normalized to the thumbnail bounds so previews remain readable regardless of the original screen position. Preview reconstruction warnings are intentionally isolated from insertion warnings; a failed thumbnail must never block saving, searching, updating, deleting, exporting, importing, or inserting the component.
