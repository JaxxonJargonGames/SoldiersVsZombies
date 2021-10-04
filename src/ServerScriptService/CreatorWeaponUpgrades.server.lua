local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

Players.PlayerAdded:Connect(function(player)
	if player.UserId == game.CreatorId then
		print("Creator Weapon Upgrades In Effect!")
		WeaponUpgrades.upgradeAll()
	end
end)
