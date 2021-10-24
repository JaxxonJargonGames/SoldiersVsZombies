local ServerStorage = game:GetService("ServerStorage")

local soldierPortalsFolder = workspace:WaitForChild("Soldier_Portals")

local PORTAL_COOLDOWN = 20

while task.wait(0.1) do
	local totalPortals = soldierPortalsFolder:GetChildren()
	for _, soldierPortal in ipairs(totalPortals) do
		local diamond = soldierPortal:FindFirstChild("Diamond")
		if diamond then
			local clone = ServerStorage.Soldier:Clone()
			clone.Configuration.AttackDamage.Value = math.random(5, 20)
			clone.Configuration.AttackDelay.Value = 1
			clone.Configuration.AttackRadius.Value = 50
			clone.Configuration.ClipCapacity.Value = 8
			clone.Configuration.PatrolRadius.Value = math.random(200, 400)
			clone.Configuration.ReloadDelay.Value = 3
			clone.HumanoidRootPart.Position = diamond.Position
			local folderName = clone.Name .. "s"
			clone.Parent = workspace[folderName]
            task.wait(PORTAL_COOLDOWN / #totalPortals)
		end
	end
end
