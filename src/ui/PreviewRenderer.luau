local Rebuilder = require(script.Parent.Parent.components.Rebuilder)

local PreviewRenderer = {}

local function makePlaceholder(host: GuiObject, text: string)
	local label = Instance.new("TextLabel")
	label.Name = "PreviewPlaceholder"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.SourceSans
	label.Text = text
	label.TextColor3 = Color3.fromRGB(126, 132, 140)
	label.TextSize = 12
	label.TextWrapped = true
	label.Parent = host
end

local function disableInteraction(root: Instance)
	local instances = { root }
	for _, descendant in root:GetDescendants() do
		table.insert(instances, descendant)
	end

	for _, instance in instances do
		if instance:IsA("GuiObject") then
			pcall(function()
				instance.Active = false
			end)
			pcall(function()
				instance.Interactable = false
			end)
			pcall(function()
				instance.Selectable = false
			end)
		end

		if instance:IsA("TextBox") then
			pcall(function()
				instance.TextEditable = false
			end)
		elseif instance:IsA("ScrollingFrame") then
			instance.ScrollingEnabled = false
		elseif instance:IsA("VideoFrame") then
			instance.Playing = false
		end
	end
end

function PreviewRenderer.render(serialized: any, host: GuiObject): ({ string }, Instance?)
	for _, child in host:GetChildren() do
		child:Destroy()
	end

	local ok, rootOrError, warningsOrNil = pcall(function()
		return Rebuilder.rebuild(serialized, host)
	end)

	if not ok then
		makePlaceholder(host, "Preview unavailable")
		return { tostring(rootOrError) }, nil
	end

	local rebuiltRoot = rootOrError :: Instance
	local warnings = warningsOrNil or {}

	if not rebuiltRoot:IsA("GuiObject") then
		rebuiltRoot:Destroy()
		makePlaceholder(host, "Preview unavailable")
		return warnings, nil
	end

	-- A thumbnail is a visual summary rather than a pixel-perfect viewport.
	-- Normalize the saved root so its hierarchy is visible inside the card.
	pcall(function()
		rebuiltRoot.AnchorPoint = Vector2.zero
		rebuiltRoot.Position = UDim2.fromScale(0, 0)
		rebuiltRoot.Size = UDim2.fromScale(1, 1)
		rebuiltRoot.AutomaticSize = Enum.AutomaticSize.None
		rebuiltRoot.Rotation = 0
	end)

	disableInteraction(rebuiltRoot)
	return warnings, rebuiltRoot
end

return PreviewRenderer
