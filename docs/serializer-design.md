# Serializer design notes

The serializer is intentionally data-only: it converts supported Roblox UI instances into a versioned plain-table representation without mutating Studio objects. This separation keeps persistence and reconstruction independent and makes future migration/versioning possible.
