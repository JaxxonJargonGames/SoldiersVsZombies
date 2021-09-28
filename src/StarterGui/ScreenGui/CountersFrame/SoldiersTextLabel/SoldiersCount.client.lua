local textLabel = script.Parent

local function updateCloneCount()
	local clones = workspace.Soldiers:GetChildren()
	textLabel.Text = "Soldiers: " .. #clones
end

updateCloneCount()

workspace.Soldiers.ChildAdded:Connect(function()
	updateCloneCount()
end)

workspace.Soldiers.ChildRemoved:Connect(function()
	updateCloneCount()
end)
