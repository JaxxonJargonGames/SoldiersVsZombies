--[[ 
Start with all the weapons and proximity prompts hidden, 
then reveal the ones that match the name of a backpack weapon.
--]]

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

local function changeTransparency(name, transparency)
	local weapon = workspace.Weapons:FindFirstChild(name)
	if weapon then
		--local children = weapon[name]:GetChildren()
		--for _, child in ipairs(children) do
		--	if child.ClassName == "MeshPart" or child.ClassName == "Part" then
		--		child.Transparency = transparency
		--	end
		--end
		if weapon:FindFirstChild("ProximityPromptPart") then
			if transparency == 0 then
				weapon.ProximityPromptPart.ProximityPrompt.Enabled = true
			else
				weapon.ProximityPromptPart.ProximityPrompt.Enabled = false
			end
		end
	end
end

local function setupWeapons()
	for _, child in ipairs(workspace.Weapons:GetChildren()) do
		changeTransparency(child.Name, 1)
	end
	for _, child in ipairs(backpack:GetChildren()) do
		changeTransparency(child.name, 0)
	end
end

setupWeapons()

backpack.ChildAdded:Connect(function(tool)
	changeTransparency(tool.Name, 0)
end)

backpack.ChildRemoved:Connect(function(tool)
	-- Make sure the weapon got removed and not just equipped to the character.
	if player.Character and not player.Character:FindFirstChild(tool.Name) then
		changeTransparency(tool.Name, 1)
	end
end)
