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
	if promptObject.Parent.Parent.Name == "TeleportBench_1" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_1.Spawn.CFrame
	elseif promptObject.Parent.Parent.Name == "TeleportBench_2" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_2.Spawn.CFrame
	elseif promptObject.Parent.Parent.Name == "TeleportBench_3" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_3.Spawn.CFrame
	elseif promptObject.Parent.Parent.Name == "TeleportBench_4" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_4.Spawn.CFrame
	else
		local toolName = promptObject.Parent.Parent.Name
		-- print("ProximityPromptActions - promptTriggeredActions:", toolName)
		-- print("    promptObject.Enabled:", promptObject.Enabled)
		WeaponUpgrades.upgradeTool(player, toolName)
		promptObject.Enabled = false
	end
end

return module
