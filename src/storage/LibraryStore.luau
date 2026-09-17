local HttpService = game:GetService("HttpService")

local LibraryStore = {}
LibraryStore.__index = LibraryStore

local SETTINGS_KEY = "ComponentVault.Library.v1"
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

local function sanitizeLibrary(raw: any)
	if type(raw) ~= "table" or raw.version ~= STORAGE_VERSION or not isArray(raw.components) then
		return {
			version = STORAGE_VERSION,
			components = {},
		}
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

function LibraryStore.new(pluginHandle: Plugin)
	local self = setmetatable({}, LibraryStore)
	self._plugin = pluginHandle
	self._library = sanitizeLibrary(nil)
	self:reload()
	return self
end

function LibraryStore:reload()
	local ok, raw = pcall(function()
		return self._plugin:GetSetting(SETTINGS_KEY)
	end)

	if not ok then
		warn("[Component Vault] Failed to read saved component library:", raw)
		self._library = sanitizeLibrary(nil)
		return self._library.components
	end

	self._library = sanitizeLibrary(raw)
	return self._library.components
end

function LibraryStore:_persist()
	local ok, err = pcall(function()
		self._plugin:SetSetting(SETTINGS_KEY, self._library)
	end)

	if not ok then
		error(string.format("Failed to save Component Vault library: %s", tostring(err)))
	end
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
	self:_persist()
	return component
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
			component.name = newName
			component.updatedAt = os.time()
			self:_persist()
			return component
		end
	end

	error("Component not found")
end

function LibraryStore:delete(id: string): boolean
	for index, component in self._library.components do
		if component.id == id then
			table.remove(self._library.components, index)
			self:_persist()
			return true
		end
	end

	return false
end

return LibraryStore
