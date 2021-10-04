local Debris = game:GetService("Debris")
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

local function setupForcefield(player, duration)
	local character = player.Character
	if character then
		local forceField = Instance.new("ForceField")
		forceField.Visible = true
		forceField.Parent = character
		if duration then
			Debris:AddItem(forceField, duration)
		end
	end
end

function module.promptTriggeredActions(promptObject, player)
	if promptObject.Parent.Parent.Name == "TeleportBench_1" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_1.Spawn.CFrame + Vector3.new(0, -4, 0)
		setupForcefield(player, 10)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_2" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_2.Spawn.CFrame + Vector3.new(0, -4, 0)
		setupForcefield(player, 20)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_3" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_3.Spawn.CFrame + Vector3.new(0, -4, 0)
		setupForcefield(player, 30)
	elseif promptObject.Parent.Parent.Name == "TeleportBench_4" then
		player.Character.Humanoid.RootPart.CFrame = workspace.Building_4.Spawn.CFrame + Vector3.new(0, -4, 0)
		setupForcefield(player, 40)
	else
		local toolName = promptObject.Parent.Parent.Name
		WeaponUpgrades.upgradeTool(player, toolName)
	end
end

return module
