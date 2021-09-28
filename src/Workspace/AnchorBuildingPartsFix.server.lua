-- Some building parts are not anchored (but should be) and this script anchors them.

buildingNames = {"Building_1", "Building_2", "Building_3", "Building_4"}

for _, buildingName in ipairs(buildingNames) do
	buildingFolder = workspace:FindFirstChild(buildingName)
	for _, level in ipairs(buildingFolder:GetChildren()) do
		if level:IsA("Model") then
			for _, child in ipairs(level:GetChildren()) do
				if child:IsA("Part") then
					child.Anchored = true
				end
			end
		end
	end
end
