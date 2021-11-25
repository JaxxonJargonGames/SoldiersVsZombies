local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local STARTING_POINTS = 0

local event = Instance.new("RemoteEvent")
event.Name = "ResetEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		player.leaderstats.Points.Value = STARTING_POINTS
		WeaponUpgrades.reset(player)
		player.Character.Humanoid.Health = 0
	end
end)
event.Parent = ReplicatedStorage

local function setupAllWeaponsAndUpgrades(player)
	print("Creator Weapon Upgrades In Effect!")
	player.leaderstats.Points.Value = 160
	player.Character.Humanoid.Health = 100
	WeaponUpgrades.upgradeAll(player)
end

local event = Instance.new("RemoteEvent")
event.Name = "Stage2BackdoorEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		setupAllWeaponsAndUpgrades(player)
		workspace.Zombie_Portals:ClearAllChildren()
		workspace.Zombies:ClearAllChildren()
	end
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "WeaponUpgradesEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		setupAllWeaponsAndUpgrades(player)
	end
end)
event.Parent = ReplicatedStorage
