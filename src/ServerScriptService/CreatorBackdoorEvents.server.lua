local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local STARTING_POINTS = 0

local event = Instance.new("RemoteEvent")
event.Name = "ResetEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		player.leaderstats.Points.Value = STARTING_POINTS
		WeaponUpgrades.reset()
		player.Character.Humanoid.Health = 0
	end
end)
event.Parent = ReplicatedStorage

local function disableDiamonds(diamonds)
	for _, diamondModel in ipairs(diamonds) do
		diamondModel.Diamond:SetAttribute("CloneType", "None")
		diamondModel.Diamond.Transparency = 1
		diamondModel.Diamond.CanTouch = false
		diamondModel.DiskWithParticles.ParticleEmitter.Enabled = false
		diamondModel.Parent = workspace.Disabled_Diamonds
	end
end

local event = Instance.new("RemoteEvent")
event.Name = "Stage2BackdoorEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		player.leaderstats.Points.Value = 320
		player.Character.Humanoid.Health = 100
		disableDiamonds(workspace.Zombie_Diamonds:GetChildren())
		disableDiamonds(workspace.Soldier_Diamonds:GetChildren())
		task.wait(1)
		for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
			zombie.Humanoid.Health = 0
		end
		end
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "WeaponUpgradesEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		print("Creator Weapon Upgrades In Effect!")
		WeaponUpgrades.upgradeAll(player)
	end
end)
event.Parent = ReplicatedStorage
