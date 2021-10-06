local Debris = game:GetService("Debris")

local module = {}

function module.setupForceField(player, duration)
	local character = player.Character
	if character then
		local forceField = Instance.new("ForceField")
		forceField.Visible = true
		forceField.Parent = character
		if duration then
			Debris:AddItem(forceField, duration)
		end
	end
end

return module
