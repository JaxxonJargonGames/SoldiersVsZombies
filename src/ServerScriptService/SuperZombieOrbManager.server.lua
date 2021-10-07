local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ForceField = require(ServerScriptService.ForceField)

local superZombieOrbsFolder = workspace:WaitForChild("SuperZombie_Orbs")
local totalOrbs = superZombieOrbsFolder:GetChildren()

local isTouched = false

local function onOrbTouched(otherPart, orb)
    if not isTouched then
        isTouched = true
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
            elseif name == "SuperZombie" then
                ForceField.setupForceField(character, 15)
            else
                -- Do nothing.
            end
            task.wait(0.1)
        end
        isTouched = false
    end
end

for _, orb in ipairs(totalOrbs) do
	orb.Touched:Connect(function(otherPart)
		onOrbTouched(otherPart, orb)
	end)
end
