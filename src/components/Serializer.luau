local Serializer = {}

Serializer.SCHEMA_VERSION = 1

local COMMON_GUI_PROPERTIES = {
	"Name",
	"Active",
	"AnchorPoint",
	"AutomaticSize",
	"BackgroundColor3",
	"BackgroundTransparency",
	"BorderColor3",
	"BorderMode",
	"BorderSizePixel",
	"ClipsDescendants",
	"Interactable",
	"LayoutOrder",
	"Position",
	"Rotation",
	"Selectable",
	"SelectionOrder",
	"Size",
	"SizeConstraint",
	"Visible",
	"ZIndex",
}

local CLASS_PROPERTIES = {
	TextLabel = {
		"Font",
		"LineHeight",
		"MaxVisibleGraphemes",
		"RichText",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},
	TextButton = {
		"AutoButtonColor",
		"Font",
		"LineHeight",
		"MaxVisibleGraphemes",
		"Modal",
		"RichText",
		"Text",
		"TextColor3",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},
	TextBox = {
		"ClearTextOnFocus",
		"CursorPosition",
		"Font",
		"LineHeight",
		"MaxVisibleGraphemes",
		"MultiLine",
		"PlaceholderColor3",
		"PlaceholderText",
		"RichText",
		"SelectionStart",
		"ShowNativeInput",
		"Text",
		"TextColor3",
		"TextEditable",
		"TextScaled",
		"TextSize",
		"TextStrokeColor3",
		"TextStrokeTransparency",
		"TextTransparency",
		"TextTruncate",
		"TextWrapped",
		"TextXAlignment",
		"TextYAlignment",
	},
	ImageLabel = {
		"Image",
		"ImageColor3",
		"ImageRectOffset",
		"ImageRectSize",
		"ImageTransparency",
		"ResampleMode",
		"ScaleType",
		"SliceCenter",
		"SliceScale",
		"TileSize",
	},
	ImageButton = {
		"AutoButtonColor",
		"HoverImage",
		"Image",
		"ImageColor3",
		"ImageRectOffset",
		"ImageRectSize",
		"ImageTransparency",
		"Modal",
		"PressedImage",
		"ResampleMode",
		"ScaleType",
		"SliceCenter",
		"SliceScale",
		"TileSize",
	},
	ScrollingFrame = {
		"AutomaticCanvasSize",
		"BottomImage",
		"CanvasPosition",
		"CanvasSize",
		"ElasticBehavior",
		"HorizontalScrollBarInset",
		"MidImage",
		"ScrollBarImageColor3",
		"ScrollBarImageTransparency",
		"ScrollBarThickness",
		"ScrollingDirection",
		"ScrollingEnabled",
		"TopImage",
		"VerticalScrollBarInset",
		"VerticalScrollBarPosition",
	},
	UICorner = { "CornerRadius" },
	UIStroke = { "ApplyStrokeMode", "Color", "Enabled", "LineJoinMode", "Thickness", "Transparency" },
	UIGradient = { "Color", "Enabled", "Offset", "Rotation", "Transparency" },
	UIPadding = { "PaddingBottom", "PaddingLeft", "PaddingRight", "PaddingTop" },
	UIListLayout = {
		"FillDirection",
		"HorizontalAlignment",
		"Padding",
		"SortOrder",
		"VerticalAlignment",
		"Wraps",
	},
	UIGridLayout = {
		"CellPadding",
		"CellSize",
		"FillDirection",
		"FillDirectionMaxCells",
		"HorizontalAlignment",
		"SortOrder",
		"StartCorner",
		"VerticalAlignment",
	},
	UIAspectRatioConstraint = { "AspectRatio", "AspectType", "DominantAxis" },
	UISizeConstraint = { "MaxSize", "MinSize" },
	UITextSizeConstraint = { "MaxTextSize", "MinTextSize" },
	UIScale = { "Scale" },
}

local SUPPORTED_CLASSES = {
	Frame = true,
	TextLabel = true,
	TextButton = true,
	TextBox = true,
	ImageLabel = true,
	ImageButton = true,
	ScrollingFrame = true,
	UICorner = true,
	UIStroke = true,
	UIGradient = true,
	UIPadding = true,
	UIListLayout = true,
	UIGridLayout = true,
	UIAspectRatioConstraint = true,
	UISizeConstraint = true,
	UITextSizeConstraint = true,
	UIScale = true,
}

local function enumTypeName(enumItem: EnumItem): string
	return string.gsub(tostring(enumItem.EnumType), "^Enum%.", "")
end

local function encodeValue(value: any): any
	local valueType = typeof(value)

	if valueType == "nil" or valueType == "boolean" or valueType == "number" or valueType == "string" then
		return value
	elseif valueType == "Color3" then
		return { __type = "Color3", r = value.R, g = value.G, b = value.B }
	elseif valueType == "UDim" then
		return { __type = "UDim", scale = value.Scale, offset = value.Offset }
	elseif valueType == "UDim2" then
		return {
			__type = "UDim2",
			x = { scale = value.X.Scale, offset = value.X.Offset },
			y = { scale = value.Y.Scale, offset = value.Y.Offset },
		}
	elseif valueType == "Vector2" then
		return { __type = "Vector2", x = value.X, y = value.Y }
	elseif valueType == "Vector3" then
		return { __type = "Vector3", x = value.X, y = value.Y, z = value.Z }
	elseif valueType == "Rect" then
		return {
			__type = "Rect",
			min = { x = value.Min.X, y = value.Min.Y },
			max = { x = value.Max.X, y = value.Max.Y },
		}
	elseif valueType == "NumberRange" then
		return { __type = "NumberRange", min = value.Min, max = value.Max }
	elseif valueType == "EnumItem" then
		return { __type = "EnumItem", enum = enumTypeName(value), name = value.Name }
	elseif valueType == "NumberSequence" then
		local keypoints = {}
		for _, keypoint in value.Keypoints do
			table.insert(keypoints, {
				time = keypoint.Time,
				value = keypoint.Value,
				envelope = keypoint.Envelope,
			})
		end
		return { __type = "NumberSequence", keypoints = keypoints }
	elseif valueType == "ColorSequence" then
		local keypoints = {}
		for _, keypoint in value.Keypoints do
			table.insert(keypoints, {
				time = keypoint.Time,
				value = encodeValue(keypoint.Value),
			})
		end
		return { __type = "ColorSequence", keypoints = keypoints }
	elseif valueType == "Font" then
		return {
			__type = "Font",
			family = value.Family,
			weight = encodeValue(value.Weight),
			style = encodeValue(value.Style),
		}
	end

	return nil
end

local function collectPropertyNames(instance: Instance): { string }
	local names = {}
	local seen = {}

	if instance:IsA("GuiObject") then
		for _, propertyName in COMMON_GUI_PROPERTIES do
			seen[propertyName] = true
			table.insert(names, propertyName)
		end
	end

	local classProperties = CLASS_PROPERTIES[instance.ClassName]
	if classProperties then
		for _, propertyName in classProperties do
			if not seen[propertyName] then
				seen[propertyName] = true
				table.insert(names, propertyName)
			end
		end
	end

	return names
end

local function readEncodedProperty(instance: Instance, propertyName: string): (boolean, any)
	local ok, value = pcall(function()
		return (instance :: any)[propertyName]
	end)

	if not ok then
		return false, nil
	end

	local encoded = encodeValue(value)
	if encoded == nil and value ~= nil then
		return false, nil
	end

	return true, encoded
end

local function encodeAttributes(instance: Instance, warnings: { string }): { [string]: any }
	local encodedAttributes = {}

	for name, value in instance:GetAttributes() do
		local encoded = encodeValue(value)
		if encoded ~= nil or value == nil then
			encodedAttributes[name] = encoded
		else
			table.insert(warnings, string.format("Skipped unsupported attribute %s on %s", name, instance:GetFullName()))
		end
	end

	return encodedAttributes
end

local function serializeNode(instance: Instance, warnings: { string }, stats: { instanceCount: number, propertyCount: number }): any
	if not SUPPORTED_CLASSES[instance.ClassName] then
		table.insert(warnings, string.format("Skipped unsupported descendant %s (%s)", instance:GetFullName(), instance.ClassName))
		return nil
	end

	local properties = {}
	for _, propertyName in collectPropertyNames(instance) do
		local ok, encoded = readEncodedProperty(instance, propertyName)
		if ok then
			properties[propertyName] = encoded
		else
			table.insert(warnings, string.format("Skipped property %s.%s", instance.ClassName, propertyName))
		end
	end

	local children = {}
	for _, child in instance:GetChildren() do
		local serializedChild = serializeNode(child, warnings, stats)
		if serializedChild then
			table.insert(children, serializedChild)
		end
	end

	stats.instanceCount += 1
	for _ in properties do
		stats.propertyCount += 1
	end

	return {
		className = instance.ClassName,
		name = instance.Name,
		properties = properties,
		attributes = encodeAttributes(instance, warnings),
		children = children,
	}
end

function Serializer.isSupported(instance: Instance): boolean
	return SUPPORTED_CLASSES[instance.ClassName] == true
end

function Serializer.serialize(root: GuiObject)
	assert(root:IsA("GuiObject"), "Serializer.serialize expects a GuiObject")

	local warnings = {}
	local stats = {
		instanceCount = 0,
		propertyCount = 0,
	}

	local rootNode = serializeNode(root, warnings, stats)
	assert(rootNode, "Selected GuiObject is not supported by Component Vault")

	return {
		schemaVersion = Serializer.SCHEMA_VERSION,
		componentName = root.Name,
		root = rootNode,
		warnings = warnings,
		stats = stats,
	}
end

return Serializer
