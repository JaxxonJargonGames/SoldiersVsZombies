local textLabel = script.Parent

local function updatePortalCount()
	local portals = workspace.Zombie_Portals:GetChildren()
	textLabel.Text = "Zombie Portals: " .. #portals
end

updatePortalCount()

workspace.Zombie_Portals.ChildAdded:Connect(function()
	updatePortalCount()
end)

workspace.Zombie_Portals.ChildRemoved:Connect(function()
	updatePortalCount()
end)
