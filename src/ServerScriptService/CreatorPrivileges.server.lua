local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

Players.PlayerAdded:Connect(function(player)
	if player.UserId == game.CreatorId then
		print("Creator Privileges In Effect!")
		local clone
		for _, weapon in ipairs(StarterPack:GetChildren()) do
			print(weapon.Name)
			if weapon.Name == "Crossbow" then
				WeaponUpgrades.upgradeCrossbow(weapon)
			elseif weapon.Name == "Pistol" then
				WeaponUpgrades.upgradePistol(weapon)
			elseif weapon.Name == "Sniper Rifle" then
				WeaponUpgrades.upgradeSniperRifle(weapon)
			end
		end
		for _, weapon in ipairs(ReplicatedStorage.Weapons:GetChildren()) do
			if not StarterPack:FindFirstChild(weapon.Name) then
				print(weapon.Name)
				clone = weapon:Clone()
				if weapon.Name == "Grenade Launcher" then
					WeaponUpgrades.upgradeGrenadeLauncher(clone)
				end
				clone.Parent = StarterPack
			end
		end
	end
end)
