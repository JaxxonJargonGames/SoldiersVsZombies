local textLabel = script.Parent

local function updateCloneCount()
	local clones = workspace.Zombies:GetChildren()
	textLabel.Text = "Zombies: " .. #clones
end

updateCloneCount()

workspace.Zombies.ChildAdded:Connect(function()
	updateCloneCount()
end)

workspace.Zombies.ChildRemoved:Connect(function()
	updateCloneCount()
end)
