local ServerStorage = game:GetService("ServerStorage")

local soldierDiamondsFolder = workspace:WaitForChild("Soldier_Diamonds")
local zombieDiamondsFolder = workspace:WaitForChild("Zombie_Diamonds")

local Stage2Event = ServerStorage:WaitForChild("Stage2Event")

local DIAMOND_COOLDOWN = 10

local function onDiamondTouched(otherPart, diamond)
	local character = otherPart.Parent
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		local name = humanoid.Parent.Name
		if name == "Robot" then
			-- Do nothing.
		elseif name == "Zombie" then
			-- Do nothing.
		elseif name == "Soldier" then
			-- Do nothing.
		else
			diamond.Color = BrickColor.new("Lime green").Color
			diamond.Sound.Playing = false
			diamond.Parent.Parent = soldierDiamondsFolder
		end
	end
end

for _, zombieDiamond in ipairs(zombieDiamondsFolder:GetChildren()) do
	local diamond = zombieDiamond.Diamond
	diamond.Color = BrickColor.new("Really red").Color
	diamond.Touched:Connect(function(otherPart)
		onDiamondTouched(otherPart, diamond)
	end)
end

workspace.Zombies.ChildRemoved:Connect(function(instance)
	if #workspace.Zombie_Diamonds:GetChildren() == 0 and #workspace.Zombies:GetChildren() == 0 then
		Stage2Event:Fire()
	end
end)

local clone
local continue = true

while continue and task.wait(0.1) do
	local totalDiamonds = zombieDiamondsFolder:GetChildren()
	if #totalDiamonds == 0 then
		continue = false
	end
	for _, zombieDiamond in ipairs(totalDiamonds) do
		local diamond = zombieDiamond:FindFirstChild("Diamond")
		if diamond then
			clone = ServerStorage.Zombie:Clone()
			clone.Configuration.AttackDamage.Value = 25
			clone.Configuration.AttackRadius.Value = math.random(50, 100)
			clone.Configuration.PatrolRadius.Value = math.random(20, 4000)
			clone.HumanoidRootPart.Position = diamond.Position
			local folderName = clone.Name .. "s"
			clone.Parent = workspace[folderName]
			task.wait(DIAMOND_COOLDOWN / #totalDiamonds)
		end
	end
end
