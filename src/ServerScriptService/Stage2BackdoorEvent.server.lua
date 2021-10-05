local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	player.leaderstats.Points.Value = 320
	player.Character.Humanoid.Health = 100
	disableDiamonds(workspace.Zombie_Diamonds:GetChildren())
	disableDiamonds(workspace.Soldier_Diamonds:GetChildren())
	task.wait(1)
	for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
		zombie.Humanoid.Health = 0
	end
end)
event.Parent = ReplicatedStorage
