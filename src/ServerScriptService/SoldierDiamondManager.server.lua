local ServerStorage = game:GetService("ServerStorage")

local soldierDiamondsFolder = workspace:WaitForChild("Soldier_Diamonds")

local DIAMOND_COOLDOWN = 20

while task.wait(0.1) do
	local totalDiamonds = soldierDiamondsFolder:GetChildren()
	for _, soldierDiamond in ipairs(totalDiamonds) do
		local diamond = soldierDiamond:FindFirstChild("Diamond")
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
            task.wait(DIAMOND_COOLDOWN / #totalDiamonds)
		end
	end
end
