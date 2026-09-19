local HttpService = game:GetService("HttpService")

local UpdateChecker = {}

UpdateChecker.CURRENT_VERSION = "0.1.0"

local LATEST_RELEASE_API = "https://api.github.com/repos/platinumstar523-ops/roblox-component-vault/releases/latest"
local RELEASE_BASE_URL = "https://github.com/platinumstar523-ops/roblox-component-vault/releases/tag/"
local CHECK_INTERVAL_SECONDS = 6 * 60 * 60

local LAST_CHECK_KEY = "ComponentVault_Update_LastCheck_v1"
local CACHED_TAG_KEY = "ComponentVault_Update_CachedTag_v1"

local function parseVersion(version: string)
	local major, minor, patch = string.match(version, "^v?(%d+)%.(%d+)%.(%d+)")
	if not major or not minor or not patch then
		return nil
	end

	return {
		major = tonumber(major),
		minor = tonumber(minor),
		patch = tonumber(patch),
	}
end

local function isNewerVersion(candidate: string, current: string): boolean
	local candidateVersion = parseVersion(candidate)
	local currentVersion = parseVersion(current)
	if not candidateVersion or not currentVersion then
		return false
	end

	if candidateVersion.major ~= currentVersion.major then
		return candidateVersion.major > currentVersion.major
	end
	if candidateVersion.minor ~= currentVersion.minor then
		return candidateVersion.minor > currentVersion.minor
	end
	return candidateVersion.patch > currentVersion.patch
end

local function releaseUrlForTag(tag: string): string?
	if not string.match(tag, "^v?%d+%.%d+%.%d+[%w%._%-]*$") then
		return nil
	end
	return RELEASE_BASE_URL .. tag
end

local function buildResult(tag: string, source: string)
	local releaseUrl = releaseUrlForTag(tag)
	if not releaseUrl or not parseVersion(tag) then
		return {
			ok = false,
			currentVersion = UpdateChecker.CURRENT_VERSION,
			error = "Latest release returned an invalid version tag.",
			source = source,
		}
	end

	return {
		ok = true,
		currentVersion = UpdateChecker.CURRENT_VERSION,
		latestVersion = string.gsub(tag, "^v", ""),
		tag = tag,
		releaseUrl = releaseUrl,
		updateAvailable = isNewerVersion(tag, UpdateChecker.CURRENT_VERSION),
		source = source,
	}
end

local function readSetting(pluginHandle: Plugin, key: string)
	local ok, value = pcall(function()
		return pluginHandle:GetSetting(key)
	end)
	if ok then
		return value
	end
	return nil
end

local function writeSetting(pluginHandle: Plugin, key: string, value: any)
	pcall(function()
		pluginHandle:SetSetting(key, value)
	end)
end

local function cachedResult(pluginHandle: Plugin)
	local tag = readSetting(pluginHandle, CACHED_TAG_KEY)
	if type(tag) ~= "string" or tag == "" then
		return nil
	end
	return buildResult(tag, "cache")
end

function UpdateChecker.check(pluginHandle: Plugin, force: boolean?)
	if not force then
		local lastCheck = tonumber(readSetting(pluginHandle, LAST_CHECK_KEY))
		if lastCheck and os.time() - lastCheck < CHECK_INTERVAL_SECONDS then
			local cached = cachedResult(pluginHandle)
			if cached then
				return cached
			end
		end
	end

	local okRequest, responseOrError = pcall(function()
		return HttpService:RequestAsync({
			Url = LATEST_RELEASE_API,
			Method = "GET",
			Headers = {
				Accept = "application/vnd.github+json",
				["X-GitHub-Api-Version"] = "2022-11-28",
			},
		})
	end)

	if not okRequest then
		local cached = cachedResult(pluginHandle)
		if cached then
			cached.source = "stale-cache"
			cached.error = tostring(responseOrError)
			return cached
		end

		return {
			ok = false,
			currentVersion = UpdateChecker.CURRENT_VERSION,
			error = tostring(responseOrError),
			source = "network",
		}
	end

	local response = responseOrError
	if not response.Success then
		local cached = cachedResult(pluginHandle)
		if cached then
			cached.source = "stale-cache"
			cached.error = string.format("GitHub returned HTTP %s", tostring(response.StatusCode))
			return cached
		end

		return {
			ok = false,
			currentVersion = UpdateChecker.CURRENT_VERSION,
			error = string.format("GitHub returned HTTP %s", tostring(response.StatusCode)),
			source = "network",
		}
	end

	local okDecode, decodedOrError = pcall(function()
		return HttpService:JSONDecode(response.Body)
	end)
	if not okDecode or type(decodedOrError) ~= "table" then
		return {
			ok = false,
			currentVersion = UpdateChecker.CURRENT_VERSION,
			error = "Could not decode the latest GitHub release.",
			source = "network",
		}
	end

	local tag = decodedOrError.tag_name
	if type(tag) ~= "string" then
		return {
			ok = false,
			currentVersion = UpdateChecker.CURRENT_VERSION,
			error = "Latest GitHub release is missing a version tag.",
			source = "network",
		}
	end

	local result = buildResult(tag, "network")
	if result.ok then
		writeSetting(pluginHandle, LAST_CHECK_KEY, os.time())
		writeSetting(pluginHandle, CACHED_TAG_KEY, tag)
	end
	return result
end

return UpdateChecker
