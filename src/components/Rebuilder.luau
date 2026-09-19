local Rebuilder = {}

local SUPPORTED_SCHEMA_VERSION = 1

local SUPPORTED_CLASSES = {
	Frame = true,
	CanvasGroup = true,
	TextLabel = true,
	TextButton = true,
	TextBox = true,
	ImageLabel = true,
	ImageButton = true,
	ScrollingFrame = true,
	ViewportFrame = true,
	VideoFrame = true,
	UICorner = true,
	UIStroke = true,
	UIGradient = true,
	UIPadding = true,
	UIListLayout = true,
	UIGridLayout = true,
	UIPageLayout = true,
	UITableLayout = true,
	UIAspectRatioConstraint = true,
	UISizeConstraint = true,
	UITextSizeConstraint = true,
	UIScale = true,
	UIFlexItem = true,
}

local PROPERTY_PRIORITY = {
	Name = -30,
	Font = -20,
	FontFace = -10,
}

local function decodeValue(value: any): any
	if type(value) ~= "table" or value.__type == nil then
		return value
	end

	local valueType = value.__type
	if valueType == "Color3" then
		return Color3.new(value.r, value.g, value.b)
	elseif valueType == "UDim" then
		return UDim.new(value.scale, value.offset)
	elseif valueType == "UDim2" then
		return UDim2.new(value.x.scale, value.x.offset, value.y.scale, value.y.offset)
	elseif valueType == "Vector2" then
		return Vector2.new(value.x, value.y)
	elseif valueType == "Vector3" then
		return Vector3.new(value.x, value.y, value.z)
	elseif valueType == "Rect" then
		return Rect.new(value.min.x, value.min.y, value.max.x, value.max.y)
	elseif valueType == "NumberRange" then
		return NumberRange.new(value.min, value.max)
	elseif valueType == "EnumItem" then
		local enumType = (Enum :: any)[value.enum]
		assert(enumType, string.format("Unknown enum type '%s'", tostring(value.enum)))
		local enumItem = enumType[value.name]
		assert(enumItem, string.format("Unknown enum item '%s.%s'", tostring(value.enum), tostring(value.name)))
		return enumItem
	elseif valueType == "NumberSequence" then
		local keypoints = {}
		for _, keypoint in value.keypoints or {} do
			table.insert(keypoints, NumberSequenceKeypoint.new(keypoint.time, keypoint.value, keypoint.envelope or 0))
		end
		return NumberSequence.new(keypoints)
	elseif valueType == "ColorSequence" then
		local keypoints = {}
		for _, keypoint in value.keypoints or {} do
			table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.time, decodeValue(keypoint.value)))
		end
		return ColorSequence.new(keypoints)
	elseif valueType == "Font" then
		return Font.new(value.family, decodeValue(value.weight), decodeValue(value.style))
	end

	error(string.format("Unsupported encoded value type '%s'", tostring(valueType)))
end

local function sortedPropertyNames(properties: any): { string }
	local names = {}
	for propertyName in properties do
		table.insert(names, propertyName)
	end

	table.sort(names, function(a, b)
		local aPriority = PROPERTY_PRIORITY[a] or 0
		local bPriority = PROPERTY_PRIORITY[b] or 0
		if aPriority == bPriority then
			return a < b
		end
		return aPriority < bPriority
	end)

	return names
end

local function applyProperties(instance: Instance, properties: any, warnings: { string })
	if type(properties) ~= "table" then
		return
	end

	for _, propertyName in sortedPropertyNames(properties) do
		local encodedValue = properties[propertyName]
		local okDecode, decodedOrError = pcall(function()
			return decodeValue(encodedValue)
		end)

		if not okDecode then
			table.insert(warnings, string.format("Could not decode %s.%s: %s", instance.ClassName, propertyName, tostring(decodedOrError)))
			continue
		end

		local okSet, setError = pcall(function()
			(instance :: any)[propertyName] = decodedOrError
		end)

		if not okSet then
			table.insert(warnings, string.format("Could not restore %s.%s: %s", instance.ClassName, propertyName, tostring(setError)))
		end
	end
end

local function applyAttributes(instance: Instance, attributes: any, warnings: { string })
	if type(attributes) ~= "table" then
		return
	end

	for attributeName, encodedValue in attributes do
		local okDecode, decodedOrError = pcall(function()
			return decodeValue(encodedValue)
		end)

		if not okDecode then
			table.insert(warnings, string.format("Could not decode attribute %s on %s", attributeName, instance.Name))
			continue
		end

		local okSet, setError = pcall(function()
			instance:SetAttribute(attributeName, decodedOrError)
		end)

		if not okSet then
			table.insert(warnings, string.format("Could not restore attribute %s on %s: %s", attributeName, instance.Name, tostring(setError)))
		end
	end
end

local function hasLayoutController(parent: Instance): boolean
	return parent:FindFirstChildWhichIsA("UIGridStyleLayout") ~= nil
end

local function applyRootPlacement(root: Instance, parent: Instance, serialized: any, warnings: { string })
	if not root:IsA("GuiObject") or hasLayoutController(parent) then
		return
	end

	local placement = serialized.placement
	if type(placement) ~= "table" or placement.mode ~= "NormalizedAnchor" then
		return
	end

	local guiRoot = root :: GuiObject
	local x = tonumber(placement.x)
	local y = tonumber(placement.y)
	if x == nil or y == nil then
		table.insert(warnings, "Could not restore proportional root position: invalid placement metadata")
	else
		local okPosition, positionError = pcall(function()
			guiRoot.Position = UDim2.fromScale(x, y)
		end)
		if not okPosition then
			table.insert(warnings, string.format("Could not restore proportional root position: %s", tostring(positionError)))
		end
	end

	local width = tonumber(placement.width)
	local height = tonumber(placement.height)
	if width ~= nil and height ~= nil and guiRoot.AutomaticSize == Enum.AutomaticSize.None then
		local okSize, sizeError = pcall(function()
			guiRoot.Size = UDim2.fromScale(width, height)
		end)
		if not okSize then
			table.insert(warnings, string.format("Could not restore proportional root size: %s", tostring(sizeError)))
		end
	end
end

local function rebuildNode(node: any, parent: Instance?, warnings: { string }, stats: any): Instance
	assert(type(node) == "table", "Invalid serialized node")
	assert(type(node.className) == "string", "Serialized node is missing className")
	assert(SUPPORTED_CLASSES[node.className] == true, string.format("Unsupported component class '%s'", tostring(node.className)))

	local instance = Instance.new(node.className)
	instance.Name = type(node.name) == "string" and node.name or node.className
	applyProperties(instance, node.properties, warnings)
	applyAttributes(instance, node.attributes, warnings)

	if parent then
		instance.Parent = parent
	end

	stats.instanceCount += 1

	if type(node.children) == "table" then
		for _, childNode in node.children do
			local okChild, childError = pcall(function()
				rebuildNode(childNode, instance, warnings, stats)
			end)
			if not okChild then
				table.insert(warnings, string.format("Could not rebuild child of %s: %s", instance.Name, tostring(childError)))
			end
		end
	end

	return instance
end

function Rebuilder.rebuild(serialized: any, parent: Instance): (Instance, { string }, any)
	assert(type(serialized) == "table", "Serialized component data is required")
	assert(type(serialized.root) == "table", "Serialized component is missing its root node")
	assert(parent ~= nil, "A parent is required for insertion")
	assert(
		serialized.schemaVersion == nil or serialized.schemaVersion <= SUPPORTED_SCHEMA_VERSION,
		string.format("Unsupported component schema version %s", tostring(serialized.schemaVersion))
	)

	local warnings = {}
	local stats = { instanceCount = 0 }
	local root = rebuildNode(serialized.root, nil, warnings, stats)
	root.Parent = parent
	applyRootPlacement(root, parent, serialized, warnings)

	return root, warnings, stats
end

return Rebuilder
