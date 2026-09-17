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
	440,
	760,
	340,
	500
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(WIDGET_ID, widgetInfo)
widget.Title = "Component Vault"

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(30, 32, 35)
root.BorderSizePixel = 0
root.Parent = widget

local function addCorner(gui: GuiObject, radius: number?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = gui
end

local function addHorizontalPadding(gui: GuiObject, amount: number?)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, amount or 10)
	padding.PaddingRight = UDim.new(0, amount or 10)
	padding.Parent = gui
end

local function makeLabel(
	parent: Instance,
	name: string,
	text: string,
	position: UDim2,
	size: UDim2,
	textSize: number,
	color: Color3,
	bold: boolean?
)
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
	label.Parent = parent
	return label
end

local function makeTextBox(parent: Instance, name: string, placeholder: string, position: UDim2, size: UDim2)
	local box = Instance.new("TextBox")
	box.Name = name
	box.Position = position
	box.Size = size
	box.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.PlaceholderText = placeholder
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(235, 238, 242)
	box.PlaceholderColor3 = Color3.fromRGB(120, 125, 132)
	box.TextSize = 14
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = parent
	addCorner(box)
	addHorizontalPadding(box)
	return box
end

local function makeButton(
	parent: Instance,
	name: string,
	text: string,
	position: UDim2,
	size: UDim2,
	background: Color3,
	textColor: Color3
)
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

local header = makeLabel(
	root,
	"Header",
	"Component Vault",
	UDim2.new(0, 18, 0, 16),
	UDim2.new(1, -120, 0, 30),
	24,
	Color3.fromRGB(245, 245, 245),
	true
)
header.TextTruncate = Enum.TextTruncate.AtEnd

local transferButton = makeButton(
	root,
	"Transfer",
	"Transfer",
	UDim2.new(1, -92, 0, 18),
	UDim2.fromOffset(74, 26),
	Color3.fromRGB(52, 58, 66),
	Color3.fromRGB(224, 228, 233)
)

makeLabel(
	root,
	"Subtitle",
	"Save reusable Roblox UI components and access them from other projects.",
	UDim2.new(0, 18, 0, 50),
	UDim2.new(1, -36, 0, 40),
	15,
	Color3.fromRGB(175, 179, 185),
	false
)

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.BackgroundColor3 = Color3.fromRGB(55, 58, 63)
divider.BorderSizePixel = 0
divider.Position = UDim2.new(0, 18, 0, 100)
divider.Size = UDim2.new(1, -36, 0, 1)
divider.Parent = root

makeLabel(root, "SelectionCaption", "STUDIO SELECTION", UDim2.new(0, 18, 0, 114), UDim2.new(1, -36, 0, 18), 12, Color3.fromRGB(135, 140, 147), true)

local selectionCard = Instance.new("Frame")
selectionCard.Name = "SelectionCard"
selectionCard.Position = UDim2.new(0, 18, 0, 136)
selectionCard.Size = UDim2.new(1, -36, 0, 58)
selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
selectionCard.BorderSizePixel = 0
selectionCard.Parent = root
addCorner(selectionCard)

local selectionName = makeLabel(selectionCard, "SelectionName", "No supported UI selected", UDim2.new(0, 12, 0, 7), UDim2.new(1, -24, 0, 22), 16, Color3.fromRGB(225, 228, 232), true)
selectionName.TextTruncate = Enum.TextTruncate.AtEnd

local selectionClass = makeLabel(selectionCard, "SelectionClass", "Select a GuiObject in Explorer or the viewport.", UDim2.new(0, 12, 0, 31), UDim2.new(1, -24, 0, 18), 13, Color3.fromRGB(150, 155, 162), false)
selectionClass.TextTruncate = Enum.TextTruncate.AtEnd

makeLabel(root, "NameCaption", "COMPONENT NAME", UDim2.new(0, 18, 0, 208), UDim2.new(1, -36, 0, 18), 12, Color3.fromRGB(135, 140, 147), true)
local nameInput = makeTextBox(root, "ComponentName", "Select UI first", UDim2.new(0, 18, 0, 230), UDim2.new(1, -36, 0, 34))
nameInput.TextSize = 15

makeLabel(root, "TagsCaption", "TAGS (OPTIONAL)", UDim2.new(0, 18, 0, 272), UDim2.new(1, -36, 0, 18), 12, Color3.fromRGB(135, 140, 147), true)
local tagsInput = makeTextBox(root, "ComponentTags", "button, shop, primary", UDim2.new(0, 18, 0, 294), UDim2.new(1, -36, 0, 32))

local saveButton = makeButton(root, "SaveComponent", "Select a supported GuiObject", UDim2.new(0, 18, 0, 336), UDim2.new(1, -36, 0, 38), Color3.fromRGB(48, 55, 63), Color3.fromRGB(170, 176, 184))
saveButton.TextSize = 16
saveButton.AutoButtonColor = false
saveButton.Active = false

local statusLabel = makeLabel(root, "Status", "Saved components are available across Studio places.", UDim2.new(0, 18, 0, 382), UDim2.new(1, -36, 0, 40), 13, Color3.fromRGB(145, 150, 158), false)

local libraryCaption = makeLabel(root, "LibraryCaption", "MY COMPONENTS", UDim2.new(0, 18, 0, 430), UDim2.new(1, -36, 0, 18), 12, Color3.fromRGB(135, 140, 147), true)
local searchInput = makeTextBox(root, "Search", "Search names, classes, or tags...", UDim2.new(0, 18, 0, 454), UDim2.new(1, -36, 0, 32))

local libraryList = Instance.new("ScrollingFrame")
libraryList.Name = "LibraryList"
libraryList.Position = UDim2.new(0, 18, 0, 496)
libraryList.Size = UDim2.new(1, -36, 1, -514)
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

-- Transfer overlay. Export text can be copied manually; import text can be pasted here.
local transferPanel = Instance.new("Frame")
transferPanel.Name = "TransferPanel"
transferPanel.Position = UDim2.new(0, 12, 0, 70)
transferPanel.Size = UDim2.new(1, -24, 1, -84)
transferPanel.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
transferPanel.BorderSizePixel = 0
transferPanel.Visible = false
transferPanel.ZIndex = 20
transferPanel.Parent = root
addCorner(transferPanel, 8)

local transferStroke = Instance.new("UIStroke")
transferStroke.Color = Color3.fromRGB(68, 72, 78)
transferStroke.Thickness = 1
transferStroke.Parent = transferPanel

local transferTitle = makeLabel(transferPanel, "Title", "Library Transfer", UDim2.new(0, 16, 0, 14), UDim2.new(1, -100, 0, 28), 20, Color3.fromRGB(242, 244, 247), true)
transferTitle.ZIndex = 21

local closeTransferButton = makeButton(transferPanel, "Close", "Close", UDim2.new(1, -70, 0, 14), UDim2.fromOffset(54, 26), Color3.fromRGB(57, 60, 65), Color3.fromRGB(225, 228, 232))
closeTransferButton.ZIndex = 21

local transferHelp = makeLabel(transferPanel, "Help", "Export fills the box below. Use Ctrl+A / Ctrl+C to copy it. To import, paste Component Vault export JSON into the box and click Import.", UDim2.new(0, 16, 0, 52), UDim2.new(1, -32, 0, 58), 13, Color3.fromRGB(165, 170, 177), false)
transferHelp.ZIndex = 21

local transferBox = Instance.new("TextBox")
transferBox.Name = "TransferData"
transferBox.Position = UDim2.new(0, 16, 0, 118)
transferBox.Size = UDim2.new(1, -32, 1, -180)
transferBox.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
transferBox.BorderSizePixel = 0
transferBox.ClearTextOnFocus = false
transferBox.Font = Enum.Font.Code
transferBox.MultiLine = true
transferBox.PlaceholderText = "Export data appears here, or paste export JSON here to import."
transferBox.Text = ""
transferBox.TextColor3 = Color3.fromRGB(220, 224, 229)
transferBox.PlaceholderColor3 = Color3.fromRGB(115, 120, 126)
transferBox.TextSize = 12
transferBox.TextWrapped = true
transferBox.TextXAlignment = Enum.TextXAlignment.Left
transferBox.TextYAlignment = Enum.TextYAlignment.Top
transferBox.ZIndex = 21
transferBox.Parent = transferPanel
addCorner(transferBox)

local transferBoxPadding = Instance.new("UIPadding")
transferBoxPadding.PaddingTop = UDim.new(0, 8)
transferBoxPadding.PaddingBottom = UDim.new(0, 8)
transferBoxPadding.PaddingLeft = UDim.new(0, 8)
transferBoxPadding.PaddingRight = UDim.new(0, 8)
transferBoxPadding.Parent = transferBox

local exportAllButton = makeButton(transferPanel, "ExportAll", "Export All", UDim2.new(0, 16, 1, -48), UDim2.fromOffset(94, 30), Color3.fromRGB(50, 87, 124), Color3.fromRGB(232, 239, 247))
exportAllButton.ZIndex = 21
local importButton = makeButton(transferPanel, "Import", "Import", UDim2.new(0, 118, 1, -48), UDim2.fromOffset(84, 30), Color3.fromRGB(55, 82, 66), Color3.fromRGB(224, 238, 228))
importButton.ZIndex = 21

local selectedGuiObject: GuiObject? = nil
local renderLibrary

local function trim(text: string): string
	return string.match(text, "^%s*(.-)%s*$") or ""
end

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
	tagsInput.TextEditable = enabled

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

local function makeCard(component, layoutOrder: number)
	local card = Instance.new("Frame")
	card.Name = "Component_" .. component.id
	card.LayoutOrder = layoutOrder
	card.Size = UDim2.new(1, -2, 0, 136)
	card.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
	card.BorderSizePixel = 0
	card.Parent = libraryList
	addCorner(card)

	local renameBox = makeTextBox(card, "Name", "Component name", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 26))
	renameBox.BackgroundTransparency = 1
	renameBox.Text = component.name
	renameBox.Font = Enum.Font.SourceSansSemibold
	renameBox.TextSize = 16

	local serialized = component.serialized or {}
	local rootNode = serialized.root or {}
	local stats = serialized.stats or {}
	local details = makeLabel(
		card,
		"Details",
		string.format(
			"%s · %d instance%s · %d properties",
			tostring(rootNode.className or "GuiObject"),
			tonumber(stats.instanceCount) or 0,
			(tonumber(stats.instanceCount) or 0) == 1 and "" or "s",
			tonumber(stats.propertyCount) or 0
		),
		UDim2.new(0, 12, 0, 36),
		UDim2.new(1, -24, 0, 18),
		13,
		Color3.fromRGB(150, 155, 162),
		false
	)
	details.TextTruncate = Enum.TextTruncate.AtEnd

	local tagBox = makeTextBox(card, "Tags", "Add tags...", UDim2.new(0, 12, 0, 60), UDim2.new(1, -24, 0, 26))
	tagBox.Text = table.concat(component.tags or {}, ", ")
	tagBox.TextSize = 12

	local insertButton = makeButton(card, "Insert", "Insert", UDim2.new(0, 12, 0, 98), UDim2.fromOffset(68, 28), Color3.fromRGB(50, 87, 124), Color3.fromRGB(230, 238, 247))
	local updateButton = makeButton(card, "Update", "Update", UDim2.new(0, 88, 0, 98), UDim2.fromOffset(68, 28), Color3.fromRGB(55, 73, 66), Color3.fromRGB(220, 235, 226))
	local deleteButton = makeButton(card, "Delete", "Delete", UDim2.new(1, -70, 0, 98), UDim2.fromOffset(58, 28), Color3.fromRGB(63, 47, 47), Color3.fromRGB(224, 177, 172))

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

	tagBox.FocusLost:Connect(function()
		local ok, result = pcall(function()
			return libraryStore:setTags(component.id, tagBox.Text)
		end)
		if ok then
			tagBox.Text = table.concat(result.tags or {}, ", ")
			setStatus(string.format("Updated tags for '%s'.", result.name), false)
			renderLibrary()
		else
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

local function componentMatches(component, query: string): boolean
	if query == "" then
		return true
	end

	if string.find(string.lower(component.name), query, 1, true) then
		return true
	end

	local rootNode = component.serialized and component.serialized.root
	if rootNode and type(rootNode.className) == "string" and string.find(string.lower(rootNode.className), query, 1, true) then
		return true
	end

	for _, tag in component.tags or {} do
		if string.find(string.lower(tag), query, 1, true) then
			return true
		end
	end

	return false
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
		if componentMatches(component, query) then
			table.insert(visible, component)
		end
	end

	if query == "" then
		libraryCaption.Text = string.format("MY COMPONENTS (%d)", #components)
	else
		libraryCaption.Text = string.format("MY COMPONENTS (%d/%d)", #visible, #components)
	end

	if #visible == 0 then
		local empty = makeLabel(
			libraryList,
			"EmptyLibrary",
			#components == 0 and "No saved components yet.\nSelect a UI object above to create your first one." or "No components match this search.",
			UDim2.new(),
			UDim2.new(1, -2, 0, 54),
			13,
			Color3.fromRGB(135, 140, 147),
			false
		)
		empty.LayoutOrder = 1
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
		setStatus(string.format("'%s' already exists. Use Update or choose another name.", duplicate.name), true)
		return
	end

	local okSerialize, serializedOrError = pcall(serializeCurrentSelection)
	if not okSerialize then
		setStatus("Serialization failed: " .. tostring(serializedOrError), true)
		return
	end

	local serialized = serializedOrError
	local okSave, savedOrError = pcall(function()
		return libraryStore:add(name, serialized, tagsInput.Text)
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

	tagsInput.Text = ""
	renderLibrary()
end

local function exportLibrary()
	local ok, result = pcall(function()
		return libraryStore:exportBundle()
	end)
	if not ok then
		setStatus("Export failed: " .. tostring(result), true)
		return
	end

	transferBox.Text = result
	transferPanel.Visible = true
	setStatus(string.format("Exported %d component%s to the Transfer panel.", #libraryStore:list(), #libraryStore:list() == 1 and "" or "s"), false)
end

local function importLibrary()
	local ok, result = pcall(function()
		return libraryStore:importBundle(transferBox.Text)
	end)
	if not ok then
		setStatus("Import failed: " .. tostring(result), true)
		return
	end

	renderLibrary()
	setStatus(string.format(
		"Imported %d component%s. %d renamed, %d skipped.",
		result.importedCount,
		result.importedCount == 1 and "" or "s",
		result.renamedCount,
		result.skippedCount
	), result.skippedCount > 0)
end

local function syncButtonState()
	toggleButton:SetActive(widget.Enabled)
end

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

transferButton.Activated:Connect(exportLibrary)
closeTransferButton.Activated:Connect(function()
	transferPanel.Visible = false
end)
exportAllButton.Activated:Connect(exportLibrary)
importButton.Activated:Connect(importLibrary)
saveButton.Activated:Connect(saveSelection)
searchInput:GetPropertyChangedSignal("Text"):Connect(renderLibrary)
widget:GetPropertyChangedSignal("Enabled"):Connect(syncButtonState)
Selection.SelectionChanged:Connect(refreshSelection)

renderLibrary()
refreshSelection()
syncButtonState()
