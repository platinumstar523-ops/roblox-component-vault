local HttpService = game:GetService("HttpService")
local EncodingService = game:GetService("EncodingService")

local LibraryStore = {}
LibraryStore.__index = LibraryStore

-- Roblox warns that periods in plugin setting keys can corrupt settings files.
-- Keep this key limited to safe characters.
local SETTINGS_KEY = "ComponentVault_Library_v1"
local STORAGE_VERSION = 1

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

local function emptyLibrary()
	return {
		version = STORAGE_VERSION,
		components = {},
	}
end

local function sanitizeLibrary(raw: any)
	if type(raw) ~= "table" or raw.version ~= STORAGE_VERSION or not isArray(raw.components) then
		return emptyLibrary()
	end

	local components = {}
	for _, component in raw.components do
		if type(component) == "table"
			and type(component.id) == "string"
			and type(component.name) == "string"
			and type(component.serialized) == "table"
		then
			table.insert(components, component)
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
	-- Accept the earliest development format if Studio happens to have retained it.
	if type(raw) == "table" then
		return sanitizeLibrary(raw)
	end

	if type(raw) ~= "string" or raw == "" then
		return emptyLibrary()
	end

	local ok, decoded = pcall(function()
		local decodedBuffer = EncodingService:Base64Decode(buffer.fromstring(raw))
		local json = buffer.tostring(decodedBuffer)
		return HttpService:JSONDecode(json)
	end)

	if not ok then
		warn("[Component Vault] Could not decode saved library:", decoded)
		return emptyLibrary()
	end

	return sanitizeLibrary(decoded)
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

	-- GetSetting can briefly return nil during Studio/plugin races, so retry
	-- instead of treating the first read as a hard persistence failure.
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
	local wanted = string.lower(name)
	for _, component in self._library.components do
		if string.lower(component.name) == wanted then
			return component
		end
	end
	return nil
end

function LibraryStore:add(name: string, serialized: any)
	name = string.match(name, "^%s*(.-)%s*$") or ""
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

function LibraryStore:rename(id: string, newName: string)
	newName = string.match(newName, "^%s*(.-)%s*$") or ""
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

return LibraryStore
