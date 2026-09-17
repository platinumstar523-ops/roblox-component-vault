assert(plugin, "Component Vault must run as a Roblox Studio plugin")

local Selection = game:GetService("Selection")
local StarterGui = game:GetService("StarterGui")

local Serializer = require(script.components.Serializer)
local Rebuilder = require(script.components.Rebuilder)
local LibraryStore = require(script.storage.LibraryStore)

local TOOLBAR_NAME = "Component Vault"
local WIDGET_ID = "ComponentVault.MainWidget"

local libraryStore = LibraryStore.new(plugin)

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local toggleButton = toolbar:CreateButton(
	"ComponentVault.Toggle",
	"Open Component Vault",
	"",
	"Component Vault"
)
toggleButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false,
	false,
	420,
	650,
	320,
	420
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(WIDGET_ID, widgetInfo)
widget.Title = "Component Vault"

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(30, 32, 35)
root.BorderSizePixel = 0
root.Parent = widget

local header = Instance.new("TextLabel")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 18, 0, 16)
header.Size = UDim2.new(1, -36, 0, 30)
header.Font = Enum.Font.SourceSansSemibold
header.Text = "Component Vault"
header.TextColor3 = Color3.fromRGB(245, 245, 245)
header.TextSize = 24
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = root

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 18, 0, 50)
subtitle.Size = UDim2.new(1, -36, 0, 44)
subtitle.Font = Enum.Font.SourceSans
subtitle.Text = "Save reusable Roblox UI components and access them from other projects."
subtitle.TextColor3 = Color3.fromRGB(175, 179, 185)
subtitle.TextSize = 15
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.Parent = root

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.BackgroundColor3 = Color3.fromRGB(55, 58, 63)
divider.BorderSizePixel = 0
divider.Position = UDim2.new(0, 18, 0, 104)
divider.Size = UDim2.new(1, -36, 0, 1)
divider.Parent = root

local selectionCaption = Instance.new("TextLabel")
selectionCaption.Name = "SelectionCaption"
selectionCaption.BackgroundTransparency = 1
selectionCaption.Position = UDim2.new(0, 18, 0, 120)
selectionCaption.Size = UDim2.new(1, -36, 0, 18)
selectionCaption.Font = Enum.Font.SourceSansSemibold
selectionCaption.Text = "STUDIO SELECTION"
selectionCaption.TextColor3 = Color3.fromRGB(135, 140, 147)
selectionCaption.TextSize = 12
selectionCaption.TextXAlignment = Enum.TextXAlignment.Left
selectionCaption.Parent = root

local selectionCard = Instance.new("Frame")
selectionCard.Name = "SelectionCard"
selectionCard.Position = UDim2.new(0, 18, 0, 144)
selectionCard.Size = UDim2.new(1, -36, 0, 58)
selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
selectionCard.BorderSizePixel = 0
selectionCard.Parent = root

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 6)
selectionCorner.Parent = selectionCard

local selectionName = Instance.new("TextLabel")
selectionName.Name = "SelectionName"
selectionName.BackgroundTransparency = 1
selectionName.Position = UDim2.new(0, 12, 0, 7)
selectionName.Size = UDim2.new(1, -24, 0, 22)
selectionName.Font = Enum.Font.SourceSansSemibold
selectionName.Text = "No supported UI selected"
selectionName.TextColor3 = Color3.fromRGB(225, 228, 232)
selectionName.TextSize = 16
selectionName.TextTruncate = Enum.TextTruncate.AtEnd
selectionName.TextXAlignment = Enum.TextXAlignment.Left
selectionName.Parent = selectionCard

local selectionClass = Instance.new("TextLabel")
selectionClass.Name = "SelectionClass"
selectionClass.BackgroundTransparency = 1
selectionClass.Position = UDim2.new(0, 12, 0, 31)
selectionClass.Size = UDim2.new(1, -24, 0, 18)
selectionClass.Font = Enum.Font.SourceSans
selectionClass.Text = "Select a GuiObject in Explorer or the viewport."
selectionClass.TextColor3 = Color3.fromRGB(150, 155, 162)
selectionClass.TextSize = 13
selectionClass.TextTruncate = Enum.TextTruncate.AtEnd
selectionClass.TextXAlignment = Enum.TextXAlignment.Left
selectionClass.Parent = selectionCard

local nameCaption = Instance.new("TextLabel")
nameCaption.Name = "NameCaption"
nameCaption.BackgroundTransparency = 1
nameCaption.Position = UDim2.new(0, 18, 0, 218)
nameCaption.Size = UDim2.new(1, -36, 0, 18)
nameCaption.Font = Enum.Font.SourceSansSemibold
nameCaption.Text = "COMPONENT NAME"
nameCaption.TextColor3 = Color3.fromRGB(135, 140, 147)
nameCaption.TextSize = 12
nameCaption.TextXAlignment = Enum.TextXAlignment.Left
nameCaption.Parent = root

local nameInput = Instance.new("TextBox")
nameInput.Name = "ComponentName"
nameInput.Position = UDim2.new(0, 18, 0, 242)
nameInput.Size = UDim2.new(1, -36, 0, 36)
nameInput.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
nameInput.BorderSizePixel = 0
nameInput.ClearTextOnFocus = false
nameInput.Font = Enum.Font.SourceSans
nameInput.PlaceholderText = "Select UI first"
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(235, 238, 242)
nameInput.PlaceholderColor3 = Color3.fromRGB(120, 125, 132)
nameInput.TextSize = 15
nameInput.TextXAlignment = Enum.TextXAlignment.Left
nameInput.Parent = root

local namePadding = Instance.new("UIPadding")
namePadding.PaddingLeft = UDim.new(0, 10)
namePadding.PaddingRight = UDim.new(0, 10)
namePadding.Parent = nameInput

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 6)
nameCorner.Parent = nameInput

local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveComponent"
saveButton.Position = UDim2.new(0, 18, 0, 288)
saveButton.Size = UDim2.new(1, -36, 0, 38)
saveButton.BackgroundColor3 = Color3.fromRGB(48, 55, 63)
saveButton.BorderSizePixel = 0
saveButton.AutoButtonColor = false
saveButton.Active = false
saveButton.Font = Enum.Font.SourceSansSemibold
saveButton.Text = "Select a supported GuiObject"
saveButton.TextColor3 = Color3.fromRGB(170, 176, 184)
saveButton.TextSize = 16
saveButton.Parent = root

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 18, 0, 334)
statusLabel.Size = UDim2.new(1, -36, 0, 42)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Text = "Saved components are stored locally by the plugin and are available across Studio places."
statusLabel.TextColor3 = Color3.fromRGB(145, 150, 158)
statusLabel.TextSize = 13
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = root

local libraryCaption = Instance.new("TextLabel")
libraryCaption.Name = "LibraryCaption"
libraryCaption.BackgroundTransparency = 1
libraryCaption.Position = UDim2.new(0, 18, 0, 388)
libraryCaption.Size = UDim2.new(1, -36, 0, 18)
libraryCaption.Font = Enum.Font.SourceSansSemibold
libraryCaption.Text = "MY COMPONENTS"
libraryCaption.TextColor3 = Color3.fromRGB(135, 140, 147)
libraryCaption.TextSize = 12
libraryCaption.TextXAlignment = Enum.TextXAlignment.Left
libraryCaption.Parent = root

local libraryList = Instance.new("ScrollingFrame")
libraryList.Name = "LibraryList"
libraryList.Position = UDim2.new(0, 18, 0, 412)
libraryList.Size = UDim2.new(1, -36, 1, -430)
libraryList.BackgroundTransparency = 1
libraryList.BorderSizePixel = 0
libraryList.ScrollBarThickness = 5
libraryList.ScrollBarImageColor3 = Color3.fromRGB(92, 98, 106)
libraryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
libraryList.CanvasSize = UDim2.new()
libraryList.Parent = root

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = libraryList

local selectedGuiObject: GuiObject? = nil
local renderLibrary

local function setStatus(message: string, isError: boolean?)
	statusLabel.Text = message
	statusLabel.TextColor3 = isError and Color3.fromRGB(225, 135, 125) or Color3.fromRGB(145, 150, 158)
end

local function findSelectedGuiObject(): GuiObject?
	for _, instance in Selection:Get() do
		if instance:IsA("GuiObject") then
			return instance
		end
	end
	return nil
end

local function findInsertParent(): Instance
	for _, instance in Selection:Get() do
		if instance:IsA("LayerCollector") then
			return instance
		end

		if instance:IsA("GuiObject") then
			local parent = instance.Parent
			if parent and (parent:IsA("GuiObject") or parent:IsA("LayerCollector")) then
				return parent
			end
		end
	end

	local existingScreenGui = StarterGui:FindFirstChildWhichIsA("ScreenGui")
	if existingScreenGui then
		return existingScreenGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ComponentVaultGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = StarterGui
	return screenGui
end

local function setSaveEnabled(enabled: boolean)
	saveButton.Active = enabled
	saveButton.AutoButtonColor = enabled
	nameInput.TextEditable = enabled

	if enabled then
		saveButton.BackgroundColor3 = Color3.fromRGB(54, 95, 140)
		saveButton.TextColor3 = Color3.fromRGB(235, 241, 248)
		saveButton.Text = "Save Component"
	else
		saveButton.BackgroundColor3 = Color3.fromRGB(48, 55, 63)
		saveButton.TextColor3 = Color3.fromRGB(170, 176, 184)
		saveButton.Text = "Select a supported GuiObject"
	end
end

local function refreshSelection()
	selectedGuiObject = findSelectedGuiObject()

	if selectedGuiObject and Serializer.isSupported(selectedGuiObject) then
		selectionName.Text = selectedGuiObject.Name
		selectionClass.Text = selectedGuiObject.ClassName
		selectionCard.BackgroundColor3 = Color3.fromRGB(42, 51, 61)
		nameInput.PlaceholderText = "Component name"
		nameInput.Text = selectedGuiObject.Name
		setSaveEnabled(true)
		setStatus("Ready to save this UI hierarchy.", false)
	elseif selectedGuiObject then
		selectionName.Text = selectedGuiObject.Name
		selectionClass.Text = string.format("%s — unsupported as a root component", selectedGuiObject.ClassName)
		selectionCard.BackgroundColor3 = Color3.fromRGB(58, 45, 43)
		nameInput.Text = ""
		nameInput.PlaceholderText = "Unsupported selection"
		setSaveEnabled(false)
		setStatus("This class cannot be saved as a root component yet.", true)
	else
		selectionName.Text = "No supported UI selected"
		selectionClass.Text = "Select a GuiObject in Explorer or the viewport."
		selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
		nameInput.Text = ""
		nameInput.PlaceholderText = "Select UI first"
		setSaveEnabled(false)
		setStatus("Saved components are available across Studio places.", false)
	end
end

local function insertComponent(component)
	local parent = findInsertParent()
	local ok, rootOrError, warningsOrNil, statsOrNil = pcall(function()
		return Rebuilder.rebuild(component.serialized, parent)
	end)

	if not ok then
		setStatus("Insert failed: " .. tostring(rootOrError), true)
		warn("[Component Vault] Insert failed:", rootOrError)
		return
	end

	local insertedRoot = rootOrError :: Instance
	local warnings = warningsOrNil or {}
	local stats = statsOrNil or { instanceCount = 0 }
	Selection:Set({ insertedRoot })
	setStatus(string.format(
		"Inserted '%s' (%d instance%s, %d warning%s).",
		component.name,
		stats.instanceCount,
		stats.instanceCount == 1 and "" or "s",
		#warnings,
		#warnings == 1 and "" or "s"
	), #warnings > 0)

	for _, warningMessage in warnings do
		warn("[Component Vault]", warningMessage)
	end
end

local function makeCard(component, layoutOrder: number)
	local card = Instance.new("Frame")
	card.Name = "Component_" .. component.id
	card.LayoutOrder = layoutOrder
	card.Size = UDim2.new(1, -2, 0, 98)
	card.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
	card.BorderSizePixel = 0
	card.Parent = libraryList

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = card

	local renameBox = Instance.new("TextBox")
	renameBox.Name = "Name"
	renameBox.BackgroundTransparency = 1
	renameBox.Position = UDim2.new(0, 12, 0, 8)
	renameBox.Size = UDim2.new(1, -24, 0, 22)
	renameBox.ClearTextOnFocus = false
	renameBox.Font = Enum.Font.SourceSansSemibold
	renameBox.Text = component.name
	renameBox.TextColor3 = Color3.fromRGB(232, 235, 239)
	renameBox.TextSize = 16
	renameBox.TextTruncate = Enum.TextTruncate.AtEnd
	renameBox.TextXAlignment = Enum.TextXAlignment.Left
	renameBox.Parent = card

	local serialized = component.serialized or {}
	local rootNode = serialized.root or {}
	local stats = serialized.stats or {}
	local details = Instance.new("TextLabel")
	details.Name = "Details"
	details.BackgroundTransparency = 1
	details.Position = UDim2.new(0, 12, 0, 34)
	details.Size = UDim2.new(1, -24, 0, 18)
	details.Font = Enum.Font.SourceSans
	details.Text = string.format(
		"%s · %d instance%s · %d properties",
		tostring(rootNode.className or "GuiObject"),
		tonumber(stats.instanceCount) or 0,
		(tonumber(stats.instanceCount) or 0) == 1 and "" or "s",
		tonumber(stats.propertyCount) or 0
	)
	details.TextColor3 = Color3.fromRGB(150, 155, 162)
	details.TextSize = 13
	details.TextXAlignment = Enum.TextXAlignment.Left
	details.Parent = card

	local insertButton = Instance.new("TextButton")
	insertButton.Name = "Insert"
	insertButton.Position = UDim2.new(0, 12, 0, 62)
	insertButton.Size = UDim2.fromOffset(70, 26)
	insertButton.BackgroundColor3 = Color3.fromRGB(50, 87, 124)
	insertButton.BorderSizePixel = 0
	insertButton.Font = Enum.Font.SourceSansSemibold
	insertButton.Text = "Insert"
	insertButton.TextColor3 = Color3.fromRGB(230, 238, 247)
	insertButton.TextSize = 12
	insertButton.Parent = card

	local insertCorner = Instance.new("UICorner")
	insertCorner.CornerRadius = UDim.new(0, 5)
	insertCorner.Parent = insertButton

	local deleteButton = Instance.new("TextButton")
	deleteButton.Name = "Delete"
	deleteButton.AnchorPoint = Vector2.new(1, 0)
	deleteButton.Position = UDim2.new(1, -10, 0, 62)
	deleteButton.Size = UDim2.fromOffset(58, 26)
	deleteButton.BackgroundColor3 = Color3.fromRGB(63, 47, 47)
	deleteButton.BorderSizePixel = 0
	deleteButton.Font = Enum.Font.SourceSansSemibold
	deleteButton.Text = "Delete"
	deleteButton.TextColor3 = Color3.fromRGB(224, 177, 172)
	deleteButton.TextSize = 12
	deleteButton.Parent = card

	local deleteCorner = Instance.new("UICorner")
	deleteCorner.CornerRadius = UDim.new(0, 5)
	deleteCorner.Parent = deleteButton

	renameBox.FocusLost:Connect(function()
		if renameBox.Text == component.name then
			return
		end

		local ok, result = pcall(function()
			return libraryStore:rename(component.id, renameBox.Text)
		end)

		if ok then
			setStatus(string.format("Renamed component to '%s'.", result.name), false)
			renderLibrary()
		else
			renameBox.Text = component.name
			setStatus(tostring(result), true)
		end
	end)

	insertButton.Activated:Connect(function()
		insertComponent(component)
	end)

	deleteButton.Activated:Connect(function()
		local ok, result = pcall(function()
			return libraryStore:delete(component.id)
		end)

		if ok and result then
			setStatus(string.format("Deleted '%s'.", component.name), false)
			renderLibrary()
		else
			setStatus("Could not delete the component.", true)
		end
	end)
end

renderLibrary = function()
	for _, child in libraryList:GetChildren() do
		if child ~= listLayout then
			child:Destroy()
		end
	end

	local components = libraryStore:list()
	libraryCaption.Text = string.format("MY COMPONENTS (%d)", #components)

	if #components == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "EmptyLibrary"
		empty.LayoutOrder = 1
		empty.Size = UDim2.new(1, -2, 0, 54)
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.SourceSans
		empty.Text = "No saved components yet.\nSelect a UI object above to create your first one."
		empty.TextColor3 = Color3.fromRGB(135, 140, 147)
		empty.TextSize = 13
		empty.TextWrapped = true
		empty.Parent = libraryList
		return
	end

	for index, component in components do
		makeCard(component, index)
	end
end

local function saveSelection()
	local target = selectedGuiObject
	if not target or not Serializer.isSupported(target) then
		return
	end

	local okSerialize, serializedOrError = pcall(function()
		return Serializer.serialize(target)
	end)

	if not okSerialize then
		setStatus("Serialization failed: " .. tostring(serializedOrError), true)
		warn("[Component Vault] Serialization failed:", serializedOrError)
		return
	end

	local serialized = serializedOrError
	local okSave, savedOrError = pcall(function()
		return libraryStore:add(nameInput.Text, serialized)
	end)

	if not okSave then
		setStatus(tostring(savedOrError), true)
		return
	end

	local saved = savedOrError
	setStatus(string.format(
		"Saved '%s' — %d instance%s, %d properties, %d warning%s.",
		saved.name,
		serialized.stats.instanceCount,
		serialized.stats.instanceCount == 1 and "" or "s",
		serialized.stats.propertyCount,
		#serialized.warnings,
		#serialized.warnings == 1 and "" or "s"
	), false)

	renderLibrary()
end

local function syncButtonState()
	toggleButton:SetActive(widget.Enabled)
end

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

saveButton.Activated:Connect(saveSelection)
widget:GetPropertyChangedSignal("Enabled"):Connect(syncButtonState)
Selection.SelectionChanged:Connect(refreshSelection)

renderLibrary()
refreshSelection()
syncButtonState()
