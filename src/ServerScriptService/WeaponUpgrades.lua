local ServerScriptService = game:GetService("ServerScriptService")

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

return module
