--[[
We begin with all the diamonds in the Zombie_Diamonds folder, all set to clone zombies.
When a diamond is converted to a different type it is also moved to a different folder.
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local zombieDiamondsFolder = workspace:WaitForChild("Zombie_Diamonds")
local totalDiamonds = zombieDiamondsFolder:GetChildren()

local Stage2Event = ServerStorage:WaitForChild("Stage2Event")

local DIAMOND_COOLDOWN = 10

local function onDiamondTouched(otherPart, diamond)
	local character = otherPart.Parent
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local clone
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
			diamond:SetAttribute("CloneType", "Soldier")
			diamond.Sound.Playing = false
			diamond.Parent.Parent = workspace.Soldier_Diamonds
		end
	end
end

for _, zombieDiamond in ipairs(totalDiamonds) do
	local diamond = zombieDiamond.Diamond
	diamond.Color = BrickColor.new("Really red").Color
	diamond:SetAttribute("CloneType", "Zombie")
	diamond.Touched:Connect(function(otherPart)
		onDiamondTouched(otherPart, diamond)
	end)
end

local clone
local continue = true

workspace.Zombies.ChildRemoved:Connect(function(instance)
	if #workspace.Zombie_Diamonds:GetChildren() == 0 and #workspace.Zombies:GetChildren() == 0 then
		Stage2Event:Fire()
	end
end)

while continue do
	for _, zombieDiamond in ipairs(totalDiamonds) do
		local diamond = zombieDiamond:FindFirstChild("Diamond")
		if diamond then
			local cloneType = diamond:GetAttribute("CloneType")
			local cooldown
			if cloneType == "Zombie" then
				clone = ServerStorage.Zombie:Clone()
				clone.Configuration.AttackDamage.Value = 25
				clone.Configuration.AttackRadius.Value = math.random(50, 100)
				clone.Configuration.PatrolRadius.Value = math.random(20, 4000)
				cooldown = DIAMOND_COOLDOWN
			elseif cloneType == "Soldier" then
				clone = ServerStorage.Soldier:Clone()
				clone.Configuration.AttackDamage.Value = math.random(5, 20)
				clone.Configuration.AttackDelay.Value = 1
				clone.Configuration.AttackRadius.Value = 50
				clone.Configuration.ClipCapacity.Value = 8
				clone.Configuration.PatrolRadius.Value = math.random(200, 400)
				clone.Configuration.ReloadDelay.Value = 3
				cooldown = DIAMOND_COOLDOWN * 2
			elseif cloneType == "None" then
				continue = false
				break
			end
			clone.HumanoidRootPart.Position = diamond.Position
			local folderName = clone.Name .. "s"
			clone.Parent = workspace[folderName]
			task.wait(cooldown / #totalDiamonds)
		end
	end
end
