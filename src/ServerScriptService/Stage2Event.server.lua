local ServerStorage = game:GetService("ServerStorage")

local zombieDiamondsFolder = workspace:WaitForChild("SuperZombie_Diamonds")
local totalDiamonds = zombieDiamondsFolder:GetChildren()

local DIAMOND_COOLDOWN = 10

local function disableDiamonds(diamonds)
	for _, diamondModel in ipairs(diamonds) do
		diamondModel.Diamond:SetAttribute("CloneType", "None")
		diamondModel.Diamond.Transparency = 1
		diamondModel.Diamond.CanTouch = false
		diamondModel.DiskWithParticles.ParticleEmitter.Enabled = false
		diamondModel.Parent = workspace.Disabled_Diamonds
	end
end

local function enableSuperDiamonds()
	local clone
	for _, zombieDiamond in ipairs(totalDiamonds) do
		local diamond = zombieDiamond.Diamond
		diamond.Color = BrickColor.new("Really red").Color
		diamond:SetAttribute("CloneType", "SuperZombie")
	end
	for count = 1, 20 do
		for _, zombieDiamond in ipairs(totalDiamonds) do
			local diamond = zombieDiamond:FindFirstChild("Diamond")
			if diamond then
				local cloneType = diamond:GetAttribute("CloneType")
				local cooldown
				if cloneType == "SuperZombie" then
					clone = ServerStorage.SuperZombie:Clone()
					clone.Configuration.AttackDamage.Value = 35
					clone.Configuration.AttackRadius.Value = math.random(100, 300)
					clone.Configuration.PatrolRadius.Value = math.random(40, 4000)
					cooldown = DIAMOND_COOLDOWN
				end
				clone.HumanoidRootPart.Position = diamond.Position
				local folderName = clone.Name .. "s"
				clone.Parent = workspace[folderName]
				task.wait(cooldown / #totalDiamonds)
			end
		end
	end
end

local event = Instance.new("BindableEvent")
event.Name = "Stage2Event"
event.Event:Connect(function()
	disableDiamonds(workspace.Zombie_Diamonds:GetChildren())
	disableDiamonds(workspace.Soldier_Diamonds:GetChildren())
	enableSuperDiamonds()
end)
event.Parent = ServerStorage
