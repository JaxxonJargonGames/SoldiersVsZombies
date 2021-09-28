local Players = game:GetService("Players")

local player = Players.LocalPlayer
local textLabel = script.Parent

local function updateDiamondCount()
	local diamonds = workspace.Zombie_Diamonds:GetChildren()
	textLabel.Text = "Zombie Diamonds: " .. #diamonds
end

updateDiamondCount()

workspace.Zombie_Diamonds.ChildAdded:Connect(function()
	updateDiamondCount()
end)

workspace.Zombie_Diamonds.ChildRemoved:Connect(function()
	updateDiamondCount()
end)
