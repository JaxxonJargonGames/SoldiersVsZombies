local Debris = game:GetService("Debris")

local module = {}

function module.setupForceField(character, duration)
	local forceField = Instance.new("ForceField")
	forceField.Visible = true
	forceField.Parent = character
	if duration then
		Debris:AddItem(forceField, duration)
	end
end

return module
