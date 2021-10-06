local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")

local module = {}

local upgrades = {}

function module.reset()
	upgrades = {}
end

function module.upgradeCrossbow(weapon)
	weapon.Configuration.HasScope.Value = true
	weapon.Configuration.ZoomFactor.Value = 5
end

function module.upgradeGrenadeLauncher(weapon)
	weapon.Configuration.BulletSpeed.Value *= 2
end

function module.upgradePistol(weapon)
	weapon.Configuration.HitDamage.Value = 35 -- Upgrade from 20.
end

function module.upgradeSniperRifle(weapon)
	weapon.Configuration.HasScope.Value = true
	weapon.Configuration.ZoomFactor.Value = 10
end

function module.getWeapon(player, toolName)
	return player.Character:FindFirstChild(toolName) or player.Backpack:FindFirstChild(toolName)
end

function module.getUpgrades()
	return upgrades
end

function module.upgradeTool(player, toolName)
	local weapon = module.getWeapon(player, toolName)
	if weapon then
		workspace.Weapons[toolName].ProximityPromptPart.ProximityPrompt.Enabled = false
		table.insert(upgrades, toolName)
		local originalParent = weapon.Parent
		weapon.Parent = player.Backpack
		if toolName == "Crossbow" then
			module.upgradeCrossbow(weapon)
		elseif toolName == "Grenade Launcher" then
			module.upgradeGrenadeLauncher(weapon)
		elseif toolName == "Pistol" then
			module.upgradePistol(weapon)
		elseif toolName == "Sniper Rifle" then
			module.upgradeSniperRifle(weapon)
		end
		weapon.Parent = originalParent
	end
end

function module.upgradeAll()
	local clone
	for _, weapon in ipairs(StarterPack:GetChildren()) do
		print(weapon.Name)
		if weapon.Name == "Crossbow" then
			module.upgradeCrossbow(weapon)
		elseif weapon.Name == "Pistol" then
			module.upgradePistol(weapon)
		elseif weapon.Name == "Sniper Rifle" then
			module.upgradeSniperRifle(weapon)
		end
	end
	for _, weapon in ipairs(ReplicatedStorage.Weapons:GetChildren()) do
		if not StarterPack:FindFirstChild(weapon.Name) then
			print(weapon.Name)
			clone = weapon:Clone()
			if weapon.Name == "Grenade Launcher" then
				module.upgradeGrenadeLauncher(clone)
			end
			clone.Parent = StarterPack
		end
	end
end

return module
