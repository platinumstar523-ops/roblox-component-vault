assert(plugin, "Component Vault must run as a Roblox Studio plugin")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local StarterGui = game:GetService("StarterGui")

local Serializer = require(script.components.Serializer)
local Rebuilder = require(script.components.Rebuilder)
local LibraryStore = require(script.storage.LibraryStore)

local TOOLBAR_NAME = "Component Vault"
local WIDGET_ID = "ComponentVault.MainWidget"

local libraryStore = LibraryStore.new(plugin)

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local toggleButton = toolbar:CreateButton("ComponentVault.Toggle", "Open Component Vault", "", "Component Vault")
toggleButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false,
	false,
	420,
	700,
	320,
	460
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(WIDGET_ID, widgetInfo)
widget.Title = "Component Vault"

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(30, 32, 35)
root.BorderSizePixel = 0
root.Parent = widget

local function makeLabel(name: string, text: string, position: UDim2, size: UDim2, textSize: number, color: Color3, bold: boolean?)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = bold and Enum.Font.SourceSansSemibold or Enum.Font.SourceSans
	label.Text = text
	label.TextColor3 = color
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = root
	return label
end

local function addCorner(gui: GuiObject, radius: number?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = gui
end

local header = makeLabel(
	"Header",
	"Component Vault",
	UDim2.new(0, 18, 0, 16),
	UDim2.new(1, -36, 0, 30),
	24,
	Color3.fromRGB(245, 245, 245),
	true
)

local subtitle = makeLabel(
	"Subtitle",
	"Save reusable Roblox UI components and access them from other projects.",
	UDim2.new(0, 18, 0, 50),
	UDim2.new(1, -36, 0, 44),
	15,
	Color3.fromRGB(175, 179, 185),
	false
)

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.BackgroundColor3 = Color3.fromRGB(55, 58, 63)
divider.BorderSizePixel = 0
divider.Position = UDim2.new(0, 18, 0, 104)
divider.Size = UDim2.new(1, -36, 0, 1)
divider.Parent = root

makeLabel(
	"SelectionCaption",
	"STUDIO SELECTION",
	UDim2.new(0, 18, 0, 120),
	UDim2.new(1, -36, 0, 18),
	12,
	Color3.fromRGB(135, 140, 147),
	true
)

local selectionCard = Instance.new("Frame")
selectionCard.Name = "SelectionCard"
selectionCard.Position = UDim2.new(0, 18, 0, 144)
selectionCard.Size = UDim2.new(1, -36, 0, 58)
selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
selectionCard.BorderSizePixel = 0
selectionCard.Parent = root
addCorner(selectionCard)

local selectionName = makeLabel(
	"SelectionName",
	"No supported UI selected",
	UDim2.new(0, 30, 0, 151),
	UDim2.new(1, -60, 0, 22),
	16,
	Color3.fromRGB(225, 228, 232),
	true
)
selectionName.TextTruncate = Enum.TextTruncate.AtEnd

local selectionClass = makeLabel(
	"SelectionClass",
	"Select a GuiObject in Explorer or the viewport.",
	UDim2.new(0, 30, 0, 175),
	UDim2.new(1, -60, 0, 18),
	13,
	Color3.fromRGB(150, 155, 162),
	false
)
selectionClass.TextTruncate = Enum.TextTruncate.AtEnd

makeLabel(
	"NameCaption",
	"COMPONENT NAME",
	UDim2.new(0, 18, 0, 218),
	UDim2.new(1, -36, 0, 18),
	12,
	Color3.fromRGB(135, 140, 147),
	true
)

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
addCorner(nameInput)

local namePadding = Instance.new("UIPadding")
namePadding.PaddingLeft = UDim.new(0, 10)
namePadding.PaddingRight = UDim.new(0, 10)
namePadding.Parent = nameInput

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
addCorner(saveButton)

local statusLabel = makeLabel(
	"Status",
	"Saved components are available across Studio places.",
	UDim2.new(0, 18, 0, 334),
	UDim2.new(1, -36, 0, 42),
	13,
	Color3.fromRGB(145, 150, 158),
	false
)

local libraryCaption = makeLabel(
	"LibraryCaption",
	"MY COMPONENTS",
	UDim2.new(0, 18, 0, 388),
	UDim2.new(1, -36, 0, 18),
	12,
	Color3.fromRGB(135, 140, 147),
	true
)

local searchInput = Instance.new("TextBox")
searchInput.Name = "Search"
searchInput.Position = UDim2.new(0, 18, 0, 412)
searchInput.Size = UDim2.new(1, -36, 0, 32)
searchInput.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
searchInput.BorderSizePixel = 0
searchInput.ClearTextOnFocus = false
searchInput.Font = Enum.Font.SourceSans
searchInput.PlaceholderText = "Search components..."
searchInput.Text = ""
searchInput.TextColor3 = Color3.fromRGB(230, 233, 237)
searchInput.PlaceholderColor3 = Color3.fromRGB(120, 125, 132)
searchInput.TextSize = 14
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.Parent = root
addCorner(searchInput)

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 10)
searchPadding.PaddingRight = UDim.new(0, 10)
searchPadding.Parent = searchInput

local libraryList = Instance.new("ScrollingFrame")
libraryList.Name = "LibraryList"
libraryList.Position = UDim2.new(0, 18, 0, 454)
libraryList.Size = UDim2.new(1, -36, 1, -472)
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

local function trim(text: string): string
	return string.match(text, "^%s*(.-)%s*$") or ""
end

local function findSelectedGuiObject(): GuiObject?
	for _, instance in Selection:Get() do
		if instance:IsA("GuiObject") then
			return instance
		end
	end
	return nil
end

local function getOrCreateFallbackScreenGui(): ScreenGui
	local existing = StarterGui:FindFirstChild("ComponentVaultGui")
	if existing and existing:IsA("ScreenGui") then
		return existing
	end

	local anyScreenGui = StarterGui:FindFirstChildWhichIsA("ScreenGui")
	if anyScreenGui then
		return anyScreenGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ComponentVaultGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = StarterGui
	return screenGui
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

		if instance == StarterGui then
			return getOrCreateFallbackScreenGui()
		end

		local guiAncestor = instance:FindFirstAncestorWhichIsA("GuiObject")
		if guiAncestor and guiAncestor.Parent then
			local parent = guiAncestor.Parent
			if parent:IsA("GuiObject") or parent:IsA("LayerCollector") then
				return parent
			end
		end
	end

	return getOrCreateFallbackScreenGui()
end

local function setWaypoint(name: string)
	pcall(function()
		ChangeHistoryService:SetWaypoint(name)
	end)
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
		setStatus("Ready to save or update a component.", false)
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

local function serializeCurrentSelection()
	local target = selectedGuiObject
	if not target or not Serializer.isSupported(target) then
		error("Select a supported GuiObject first")
	end
	return Serializer.serialize(target)
end

local function insertComponent(component)
	setWaypoint("Component Vault - Before Insert")
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
	setWaypoint("Component Vault - Insert " .. component.name)

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

local function updateComponent(component)
	local okSerialize, serializedOrError = pcall(serializeCurrentSelection)
	if not okSerialize then
		setStatus(tostring(serializedOrError), true)
		return
	end

	local okUpdate, updatedOrError = pcall(function()
		return libraryStore:update(component.id, serializedOrError)
	end)
	if not okUpdate then
		setStatus(tostring(updatedOrError), true)
		return
	end

	setStatus(string.format("Updated '%s' from the current Studio selection.", updatedOrError.name), false)
	renderLibrary()
end

local function makeButton(parent: Instance, name: string, text: string, position: UDim2, size: UDim2, background: Color3, textColor: Color3)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = background
	button.BorderSizePixel = 0
	button.Font = Enum.Font.SourceSansSemibold
	button.Text = text
	button.TextColor3 = textColor
	button.TextSize = 12
	button.Parent = parent
	addCorner(button, 5)
	return button
end

local function makeCard(component, layoutOrder: number)
	local card = Instance.new("Frame")
	card.Name = "Component_" .. component.id
	card.LayoutOrder = layoutOrder
	card.Size = UDim2.new(1, -2, 0, 110)
	card.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
	card.BorderSizePixel = 0
	card.Parent = libraryList
	addCorner(card)

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

	local insertButton = makeButton(
		card,
		"Insert",
		"Insert",
		UDim2.new(0, 12, 0, 66),
		UDim2.fromOffset(68, 28),
		Color3.fromRGB(50, 87, 124),
		Color3.fromRGB(230, 238, 247)
	)
	local updateButton = makeButton(
		card,
		"Update",
		"Update",
		UDim2.new(0, 88, 0, 66),
		UDim2.fromOffset(68, 28),
		Color3.fromRGB(55, 73, 66),
		Color3.fromRGB(220, 235, 226)
	)
	local deleteButton = makeButton(
		card,
		"Delete",
		"Delete",
		UDim2.new(1, -70, 0, 66),
		UDim2.fromOffset(58, 28),
		Color3.fromRGB(63, 47, 47),
		Color3.fromRGB(224, 177, 172)
	)

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

	updateButton.Activated:Connect(function()
		updateComponent(component)
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
	local query = string.lower(trim(searchInput.Text))
	local visible = {}
	for _, component in components do
		if query == "" or string.find(string.lower(component.name), query, 1, true) then
			table.insert(visible, component)
		end
	end

	if query == "" then
		libraryCaption.Text = string.format("MY COMPONENTS (%d)", #components)
	else
		libraryCaption.Text = string.format("MY COMPONENTS (%d/%d)", #visible, #components)
	end

	if #visible == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "EmptyLibrary"
		empty.LayoutOrder = 1
		empty.Size = UDim2.new(1, -2, 0, 54)
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.SourceSans
		empty.Text = #components == 0
			and "No saved components yet.\nSelect a UI object above to create your first one."
			or "No components match this search."
		empty.TextColor3 = Color3.fromRGB(135, 140, 147)
		empty.TextSize = 13
		empty.TextWrapped = true
		empty.Parent = libraryList
		return
	end

	for index, component in visible do
		makeCard(component, index)
	end
end

local function saveSelection()
	local name = trim(nameInput.Text)
	if name == "" then
		setStatus("Enter a component name first.", true)
		return
	end

	local duplicate = libraryStore:findByName(name)
	if duplicate then
		setStatus(string.format("'%s' already exists. Use Update on that saved component or choose another name.", duplicate.name), true)
		return
	end

	local okSerialize, serializedOrError = pcall(serializeCurrentSelection)
	if not okSerialize then
		setStatus("Serialization failed: " .. tostring(serializedOrError), true)
		return
	end

	local serialized = serializedOrError
	local okSave, savedOrError = pcall(function()
		return libraryStore:add(name, serialized)
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
	), #serialized.warnings > 0)

	for _, warningMessage in serialized.warnings do
		warn("[Component Vault]", warningMessage)
	end

	renderLibrary()
end

local function syncButtonState()
	toggleButton:SetActive(widget.Enabled)
end

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

saveButton.Activated:Connect(saveSelection)
searchInput:GetPropertyChangedSignal("Text"):Connect(renderLibrary)
widget:GetPropertyChangedSignal("Enabled"):Connect(syncButtonState)
Selection.SelectionChanged:Connect(refreshSelection)

renderLibrary()
refreshSelection()
syncButtonState()
