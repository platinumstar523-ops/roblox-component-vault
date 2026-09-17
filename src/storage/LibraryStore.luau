local HttpService = game:GetService("HttpService")
local EncodingService = game:GetService("EncodingService")

local LibraryStore = {}
LibraryStore.__index = LibraryStore

local SETTINGS_KEY = "ComponentVault_Library_v1"
local STORAGE_VERSION = 1
local EXPORT_FORMAT = "ComponentVaultExport"
local EXPORT_VERSION = 1
local MAX_TAGS = 12
local MAX_TAG_LENGTH = 30
local SUPPORTED_COMPONENT_SCHEMA_VERSION = 1

local function isArray(value: any): boolean
	if type(value) ~= "table" then
		return false
	end

	local count = 0
	for key in value do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			return false
		end
		count += 1
	end

	return count == #value
end

local function trim(text: string): string
	return string.match(text, "^%s*(.-)%s*$") or ""
end

local function normalizeTags(input: any): { string }
	local rawTags = {}
	if type(input) == "string" then
		for tag in string.gmatch(input, "[^,]+") do
			table.insert(rawTags, tag)
		end
	elseif isArray(input) then
		for _, tag in input do
			if type(tag) == "string" then
				table.insert(rawTags, tag)
			end
		end
	end

	local tags = {}
	local seen = {}
	for _, rawTag in rawTags do
		local tag = trim(rawTag)
		if tag ~= "" then
			if #tag > MAX_TAG_LENGTH then
				tag = string.sub(tag, 1, MAX_TAG_LENGTH)
			end

			local key = string.lower(tag)
			if not seen[key] then
				seen[key] = true
				table.insert(tags, tag)
				if #tags >= MAX_TAGS then
					break
				end
			end
		end
	end

	return tags
end

local function emptyLibrary()
	return {
		version = STORAGE_VERSION,
		components = {},
	}
end

local function sanitizeComponent(component: any)
	if type(component) ~= "table"
		or type(component.id) ~= "string"
		or type(component.name) ~= "string"
		or type(component.serialized) ~= "table"
	then
		return nil
	end

	local serialized = component.serialized
	if serialized.schemaVersion ~= nil and serialized.schemaVersion > SUPPORTED_COMPONENT_SCHEMA_VERSION then
		return nil
	end

	return {
		id = component.id,
		name = trim(component.name),
		createdAt = tonumber(component.createdAt) or os.time(),
		updatedAt = tonumber(component.updatedAt) or os.time(),
		tags = normalizeTags(component.tags),
		serialized = serialized,
	}
end

local function sanitizeLibrary(raw: any)
	if type(raw) ~= "table" or raw.version ~= STORAGE_VERSION or not isArray(raw.components) then
		return emptyLibrary()
	end

	local components = {}
	for _, component in raw.components do
		local sanitized = sanitizeComponent(component)
		if sanitized and sanitized.name ~= "" then
			table.insert(components, sanitized)
		end
	end

	return {
		version = STORAGE_VERSION,
		components = components,
	}
end

local function encodeLibrary(library: any): string
	local json = HttpService:JSONEncode(library)
	local encodedBuffer = EncodingService:Base64Encode(buffer.fromstring(json))
	return buffer.tostring(encodedBuffer)
end

local function decodeStoredValue(raw: any)
	if type(raw) == "table" then
		return sanitizeLibrary(raw)
	end

	if type(raw) ~= "string" or raw == "" then
		return emptyLibrary()
	end

	local ok, decoded = pcall(function()
		local decodedBuffer = EncodingService:Base64Decode(buffer.fromstring(raw))
		return HttpService:JSONDecode(buffer.tostring(decodedBuffer))
	end)

	if not ok then
		warn("[Component Vault] Could not decode saved library:", decoded)
		return emptyLibrary()
	end

	return sanitizeLibrary(decoded)
end

local function nextAvailableName(components: { any }, wantedName: string): (string, boolean)
	local existing = {}
	for _, component in components do
		existing[string.lower(component.name)] = true
	end

	local base = trim(wantedName)
	if base == "" then
		base = "Imported Component"
	end

	if not existing[string.lower(base)] then
		return base, false
	end

	for suffix = 2, 9999 do
		local candidate = string.format("%s (%d)", base, suffix)
		if not existing[string.lower(candidate)] then
			return candidate, true
		end
	end

	error("Could not generate a unique imported component name")
end

function LibraryStore.new(pluginHandle: Plugin)
	local self = setmetatable({}, LibraryStore)
	self._plugin = pluginHandle
	self._library = emptyLibrary()
	self:reload()
	return self
end

function LibraryStore:reload()
	local ok, raw = pcall(function()
		return self._plugin:GetSetting(SETTINGS_KEY)
	end)

	if not ok then
		warn("[Component Vault] Failed to read saved component library:", raw)
		self._library = emptyLibrary()
		return self._library.components
	end

	self._library = decodeStoredValue(raw)
	return self._library.components
end

function LibraryStore:_persist()
	local okEncode, encodedOrError = pcall(function()
		return encodeLibrary(self._library)
	end)
	if not okEncode then
		error(string.format("Failed to encode Component Vault library: %s", tostring(encodedOrError)))
	end

	local encoded = encodedOrError
	local okSave, saveError = pcall(function()
		self._plugin:SetSetting(SETTINGS_KEY, encoded)
	end)
	if not okSave then
		error(string.format("Failed to save Component Vault library: %s", tostring(saveError)))
	end

	for attempt = 1, 5 do
		local okVerify, storedValue = pcall(function()
			return self._plugin:GetSetting(SETTINGS_KEY)
		end)
		if okVerify and storedValue == encoded then
			return
		end
		if attempt < 5 then
			task.wait(0.1)
		end
	end

	error("Component Vault could not verify that the local library was persisted")
end

function LibraryStore:list()
	return self._library.components
end

function LibraryStore:findByName(name: string)
	local wanted = string.lower(trim(name))
	for _, component in self._library.components do
		if string.lower(component.name) == wanted then
			return component
		end
	end
	return nil
end

function LibraryStore:add(name: string, serialized: any, tags: any?)
	name = trim(name)
	assert(name ~= "", "Component name cannot be empty")
	assert(#name <= 80, "Component name must be 80 characters or fewer")
	assert(type(serialized) == "table", "Serialized component data is required")
	assert(not self:findByName(name), string.format("A component named '%s' already exists", name))

	local now = os.time()
	local component = {
		id = HttpService:GenerateGUID(false),
		name = name,
		createdAt = now,
		updatedAt = now,
		tags = normalizeTags(tags),
		serialized = serialized,
	}

	table.insert(self._library.components, component)
	local ok, err = pcall(function()
		self:_persist()
	end)
	if not ok then
		table.remove(self._library.components, #self._library.components)
		error(err)
	end

	return component
end

function LibraryStore:update(id: string, serialized: any)
	assert(type(serialized) == "table", "Serialized component data is required")

	for _, component in self._library.components do
		if component.id == id then
			local oldSerialized = component.serialized
			local oldUpdatedAt = component.updatedAt
			component.serialized = serialized
			component.updatedAt = os.time()

			local ok, err = pcall(function()
				self:_persist()
			end)
			if not ok then
				component.serialized = oldSerialized
				component.updatedAt = oldUpdatedAt
				error(err)
			end
			return component
		end
	end

	error("Component not found")
end

function LibraryStore:setTags(id: string, tags: any)
	for _, component in self._library.components do
		if component.id == id then
			local oldTags = component.tags
			local oldUpdatedAt = component.updatedAt
			component.tags = normalizeTags(tags)
			component.updatedAt = os.time()

			local ok, err = pcall(function()
				self:_persist()
			end)
			if not ok then
				component.tags = oldTags
				component.updatedAt = oldUpdatedAt
				error(err)
			end
			return component
		end
	end

	error("Component not found")
end

function LibraryStore:rename(id: string, newName: string)
	newName = trim(newName)
	assert(newName ~= "", "Component name cannot be empty")
	assert(#newName <= 80, "Component name must be 80 characters or fewer")

	local duplicate = self:findByName(newName)
	if duplicate and duplicate.id ~= id then
		error(string.format("A component named '%s' already exists", newName))
	end

	for _, component in self._library.components do
		if component.id == id then
			local oldName = component.name
			local oldUpdatedAt = component.updatedAt
			component.name = newName
			component.updatedAt = os.time()

			local ok, err = pcall(function()
				self:_persist()
			end)
			if not ok then
				component.name = oldName
				component.updatedAt = oldUpdatedAt
				error(err)
			end
			return component
		end
	end

	error("Component not found")
end

function LibraryStore:delete(id: string): boolean
	for index, component in self._library.components do
		if component.id == id then
			table.remove(self._library.components, index)
			local ok, err = pcall(function()
				self:_persist()
			end)
			if not ok then
				table.insert(self._library.components, index, component)
				error(err)
			end
			return true
		end
	end
	return false
end

function LibraryStore:exportBundle(): string
	return HttpService:JSONEncode({
		format = EXPORT_FORMAT,
		version = EXPORT_VERSION,
		exportedAt = os.time(),
		components = self._library.components,
	})
end

function LibraryStore:importBundle(text: string)
	assert(type(text) == "string" and trim(text) ~= "", "Paste Component Vault export data first")

	local okDecode, decodedOrError = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	assert(okDecode, string.format("Import data is not valid JSON: %s", tostring(decodedOrError)))

	local bundle = decodedOrError
	assert(type(bundle) == "table", "Import data must be a Component Vault export object")
	assert(bundle.format == EXPORT_FORMAT, "Import data is not a Component Vault export")
	assert(bundle.version == EXPORT_VERSION, string.format("Unsupported export version %s", tostring(bundle.version)))
	assert(isArray(bundle.components), "Import bundle has an invalid component list")

	local startLength = #self._library.components
	local importedCount = 0
	local renamedCount = 0
	local skippedCount = 0

	for _, rawComponent in bundle.components do
		local sanitized = sanitizeComponent(rawComponent)
		if not sanitized then
			skippedCount += 1
			continue
		end

		local uniqueName, renamed = nextAvailableName(self._library.components, sanitized.name)
		local now = os.time()
		table.insert(self._library.components, {
			id = HttpService:GenerateGUID(false),
			name = uniqueName,
			createdAt = now,
			updatedAt = now,
			tags = normalizeTags(sanitized.tags),
			serialized = sanitized.serialized,
		})
		importedCount += 1
		if renamed then
			renamedCount += 1
		end
	end

	if importedCount > 0 then
		local okPersist, persistError = pcall(function()
			self:_persist()
		end)
		if not okPersist then
			while #self._library.components > startLength do
				table.remove(self._library.components)
			end
			error(persistError)
		end
	end

	return {
		importedCount = importedCount,
		renamedCount = renamedCount,
		skippedCount = skippedCount,
	}
end

return LibraryStore
