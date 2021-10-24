local ServerStorage = game:GetService("ServerStorage")

local zombiePortalsFolder = workspace:WaitForChild("SuperZombie_Portals")

local PORTAL_COOLDOWN = 2
local SUPER_ZOMBIE_COUNT = 100

local function enableSuperPortals()
	local clone
	local totalPortals = zombiePortalsFolder:GetChildren()
	for _, zombiePortal in ipairs(totalPortals) do
		local diamond = zombiePortal.Diamond
		diamond.Color = BrickColor.new("Really red").Color
	end
	for count = 1, SUPER_ZOMBIE_COUNT / #totalPortals do
		for _, zombiePortal in ipairs(totalPortals) do
			local diamond = zombiePortal:FindFirstChild("Diamond")
			if diamond then
				clone = ServerStorage.SuperZombie:Clone()
				clone.Configuration.AttackDamage.Value = 35
				clone.Configuration.AttackRadius.Value = math.random(100, 300)
				clone.Configuration.PatrolRadius.Value = math.random(40, 4000)
				clone.HumanoidRootPart.Position = diamond.Position
				local folderName = clone.Name .. "s"
				clone.Parent = workspace[folderName]
				task.wait(PORTAL_COOLDOWN / #totalPortals)
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
	workspace.Soldier_Portals:ClearAllChildren()
	enableOrbs()
	enableSuperPortals()
end)
event.Parent = ServerStorage
