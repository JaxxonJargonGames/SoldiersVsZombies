local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local STARTING_POINTS = 0

local event = Instance.new("RemoteEvent")
event.Name = "ResetEvent"
event.OnServerEvent:Connect(function(player)
	player.leaderstats.Points.Value = STARTING_POINTS
	WeaponUpgrades.reset()
	player.Character.Humanoid.Health = 0
end)
event.Parent = ReplicatedStorage
