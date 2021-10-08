local ServerStorage = game:GetService("ServerStorage")

local zombieDiamondsFolder = workspace:WaitForChild("SuperZombie_Diamonds")

local DIAMOND_COOLDOWN = 2
local SUPER_ZOMBIE_COUNT = 100

local function enableSuperDiamonds()
	local clone
	local totalDiamonds = zombieDiamondsFolder:GetChildren()
	for _, zombieDiamond in ipairs(totalDiamonds) do
		local diamond = zombieDiamond.Diamond
		diamond.Color = BrickColor.new("Really red").Color
		diamond:SetAttribute("CloneType", "SuperZombie")
	end
	for count = 1, SUPER_ZOMBIE_COUNT / #totalDiamonds do
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

local function enableOrbs()
	for _, orb in ipairs(workspace.SuperZombie_Orbs:GetChildren()) do
		orb.Transparency = 0
	end
end

local event = Instance.new("BindableEvent")
event.Name = "Stage2Event"
event.Event:Connect(function()
	workspace.Soldier_Diamonds:ClearAllChildren()
	enableOrbs()
	enableSuperDiamonds()
end)
event.Parent = ServerStorage
