local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ForceField = require(ServerScriptService.ForceField)
local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local module = {}

local function teleport(promptObject, character, duration, location)
	promptObject.Enabled = false
	ForceField.setupForceField(character, duration)
	task.wait(3)
	character.Humanoid.RootPart.CFrame = location.CFrame + Vector3.new(0, -4, 0)
	promptObject.Enabled = true
end

function module.promptTriggeredActions(promptObject, player)
	local character = player.Character
	if promptObject.Parent.Parent.Name == "TeleportBench_1" then
		teleport(promptObject, character, 20, workspace.Building_1.Spawn)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_2" then
		teleport(promptObject, character, 30, workspace.Building_2.Spawn)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_3" then
		teleport(promptObject, character, 40, workspace.Building_3.Spawn)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_4" then
		teleport(promptObject, character, 50, workspace.Building_4.Spawn)
	else
		local toolName = promptObject.Parent.Parent.Name
		WeaponUpgrades.upgradeTool(player, toolName)
	end
end

return module
