local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ForceField = require(ServerScriptService.ForceField)
local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local module = {}

function module.promptTriggeredActions(promptObject, player)
	if promptObject.Parent.Parent.Name == "TeleportBench_1" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_1.Spawn.CFrame + Vector3.new(0, -4, 0)
		ForceField.setupForceField(player, 10)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_2" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_2.Spawn.CFrame + Vector3.new(0, -4, 0)
		ForceField.setupForceField(player, 20)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_3" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_3.Spawn.CFrame + Vector3.new(0, -4, 0)
		ForceField.setupForceField(player, 30)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_4" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_4.Spawn.CFrame + Vector3.new(0, -4, 0)
		ForceField.setupForceField(player, 40)
	else
		local toolName = promptObject.Parent.Parent.Name
		WeaponUpgrades.upgradeTool(player, toolName)
	end
end

return module
