local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")

local module = {}

local upgrades = {}

local UPGRADEABLE_TOOLS = {
	"Crossbow",
	"Grenade Launcher",
	"Pistol",
	"Sniper Rifle",
}

local function setupProximityPrompts(player, toolUpgrades)
	for _, toolName in ipairs(UPGRADEABLE_TOOLS) do
		if table.find(toolUpgrades, toolName) then
			workspace.Weapons[toolName].ProximityPromptPart.ProximityPrompt.Enabled = false
		else
			if module.getWeapon(player, toolName) then
				workspace.Weapons[toolName].ProximityPromptPart.ProximityPrompt.Enabled = true
			else
				workspace.Weapons[toolName].ProximityPromptPart.ProximityPrompt.Enabled = false
			end
		end
	end
end

function module.reset(player)
	upgrades = {}
	setupProximityPrompts(player, upgrades)
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
		print("Disabling proximity prompt for tool:", toolName)
		workspace.Weapons[toolName].ProximityPromptPart.ProximityPrompt.Enabled = false
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

function module.upgradeAll(player)
	for _, toolName in ipairs(UPGRADEABLE_TOOLS) do
		module.upgradeTool(player, toolName)
	end
end

function module.processWeaponUpgrades(player, savedUpgrades)
	if savedUpgrades then
		for _, toolName in ipairs(savedUpgrades) do
			module.upgradeTool(player, toolName)
		end
	end
	setupProximityPrompts(player, savedUpgrades)
end

return module
