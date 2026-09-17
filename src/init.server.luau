assert(plugin, "Component Vault must run as a Roblox Studio plugin")

local Selection = game:GetService("Selection")

local TOOLBAR_NAME = "Component Vault"
local WIDGET_ID = "ComponentVault.MainWidget"

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local toggleButton = toolbar:CreateButton(
	"ComponentVault.Toggle",
	"Open Component Vault",
	"",
	"Component Vault"
)
toggleButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	360,
	480,
	280,
	260
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
subtitle.Text = "Reusable Roblox UI components across your projects."
subtitle.TextColor3 = Color3.fromRGB(175, 179, 185)
subtitle.TextSize = 16
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
selectionCaption.Position = UDim2.new(0, 18, 0, 122)
selectionCaption.Size = UDim2.new(1, -36, 0, 18)
selectionCaption.Font = Enum.Font.SourceSansSemibold
selectionCaption.Text = "STUDIO SELECTION"
selectionCaption.TextColor3 = Color3.fromRGB(135, 140, 147)
selectionCaption.TextSize = 12
selectionCaption.TextXAlignment = Enum.TextXAlignment.Left
selectionCaption.Parent = root

local selectionCard = Instance.new("Frame")
selectionCard.Name = "SelectionCard"
selectionCard.Position = UDim2.new(0, 18, 0, 146)
selectionCard.Size = UDim2.new(1, -36, 0, 64)
selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
selectionCard.BorderSizePixel = 0
selectionCard.Parent = root

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 6)
selectionCorner.Parent = selectionCard

local selectionName = Instance.new("TextLabel")
selectionName.Name = "SelectionName"
selectionName.BackgroundTransparency = 1
selectionName.Position = UDim2.new(0, 12, 0, 9)
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
selectionClass.Position = UDim2.new(0, 12, 0, 33)
selectionClass.Size = UDim2.new(1, -24, 0, 18)
selectionClass.Font = Enum.Font.SourceSans
selectionClass.Text = "Select a GuiObject in Explorer or the viewport."
selectionClass.TextColor3 = Color3.fromRGB(150, 155, 162)
selectionClass.TextSize = 13
selectionClass.TextTruncate = Enum.TextTruncate.AtEnd
selectionClass.TextXAlignment = Enum.TextXAlignment.Left
selectionClass.Parent = selectionCard

local emptyTitle = Instance.new("TextLabel")
emptyTitle.Name = "EmptyTitle"
emptyTitle.BackgroundTransparency = 1
emptyTitle.Position = UDim2.new(0, 18, 0.5, -12)
emptyTitle.Size = UDim2.new(1, -36, 0, 28)
emptyTitle.Font = Enum.Font.SourceSansSemibold
emptyTitle.Text = "No components saved yet"
emptyTitle.TextColor3 = Color3.fromRGB(230, 232, 235)
emptyTitle.TextSize = 19
emptyTitle.Parent = root

local emptyBody = Instance.new("TextLabel")
emptyBody.Name = "EmptyBody"
emptyBody.BackgroundTransparency = 1
emptyBody.Position = UDim2.new(0, 32, 0.5, 22)
emptyBody.Size = UDim2.new(1, -64, 0, 48)
emptyBody.Font = Enum.Font.SourceSans
emptyBody.Text = "Selection detection is working. Component serialization is the next milestone."
emptyBody.TextColor3 = Color3.fromRGB(155, 160, 167)
emptyBody.TextSize = 15
emptyBody.TextWrapped = true
emptyBody.Parent = root

local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveComponent"
saveButton.AnchorPoint = Vector2.new(0, 1)
saveButton.Position = UDim2.new(0, 18, 1, -18)
saveButton.Size = UDim2.new(1, -36, 0, 38)
saveButton.BackgroundColor3 = Color3.fromRGB(48, 55, 63)
saveButton.BorderSizePixel = 0
saveButton.AutoButtonColor = false
saveButton.Active = false
saveButton.Font = Enum.Font.SourceSansSemibold
saveButton.Text = "Select a GuiObject to continue"
saveButton.TextColor3 = Color3.fromRGB(170, 176, 184)
saveButton.TextSize = 16
saveButton.Parent = root

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = saveButton

local selectedGuiObject: GuiObject? = nil

local function findSelectedGuiObject(): GuiObject?
	for _, instance in Selection:Get() do
		if instance:IsA("GuiObject") then
			return instance
		end
	end

	return nil
end

local function refreshSelection()
	selectedGuiObject = findSelectedGuiObject()

	if selectedGuiObject then
		selectionName.Text = selectedGuiObject.Name
		selectionClass.Text = selectedGuiObject.ClassName
		selectionCard.BackgroundColor3 = Color3.fromRGB(42, 51, 61)
		saveButton.BackgroundColor3 = Color3.fromRGB(54, 95, 140)
		saveButton.TextColor3 = Color3.fromRGB(210, 220, 232)
		saveButton.Text = string.format("Ready to save %s — serializer next", selectedGuiObject.Name)
	else
		selectionName.Text = "No supported UI selected"
		selectionClass.Text = "Select a GuiObject in Explorer or the viewport."
		selectionCard.BackgroundColor3 = Color3.fromRGB(39, 42, 46)
		saveButton.BackgroundColor3 = Color3.fromRGB(48, 55, 63)
		saveButton.TextColor3 = Color3.fromRGB(170, 176, 184)
		saveButton.Text = "Select a GuiObject to continue"
	end
end

local function syncButtonState()
	toggleButton:SetActive(widget.Enabled)
end

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(syncButtonState)
Selection.SelectionChanged:Connect(refreshSelection)

refreshSelection()
syncButtonState()
