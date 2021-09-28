local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local module = {}

local function cloneWeaponToBackpack(toolName, player)
	if not player.Character:FindFirstChild(toolName) and not player.Backpack:FindFirstChild(toolName) then
		local clone = ReplicatedStorage.Weapons[toolName]:Clone()
		clone.Parent = player.Backpack
	end
end

function module.promptTriggeredActions(promptObject, player)
	local toolName = promptObject.Parent.Parent.Name
	WeaponUpgrades.upgradeTool(player, toolName)
	promptObject.Enabled = false
end

return module
