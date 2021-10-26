local textLabel = script.Parent

local substitutions = {
	["00"] = {"12", "AM"},
	["01"] = {"1", "AM"},
	["02"] = {"2", "AM"},
	["03"] = {"3", "AM"},
	["04"] = {"4", "AM"},
	["05"] = {"5", "AM"},
	["06"] = {"6", "AM"},
	["07"] = {"7", "AM"},
	["08"] = {"8", "AM"},
	["09"] = {"9", "AM"},
	["10"] = {"10", "AM"},
	["11"] = {"11", "AM"},
	["12"] = {"12", "PM"},
	["13"] = {"1", "PM"},
	["14"] = {"2", "PM"},
	["15"] = {"3", "PM"},
	["16"] = {"4", "PM"},
	["17"] = {"5", "PM"},
	["18"] = {"6", "PM"},
	["19"] = {"7", "PM"},
	["20"] = {"8", "PM"},
	["21"] = {"9", "PM"},
	["22"] = {"10", "PM"},
	["23"] = {"11", "PM"},
}

while task.wait(0.1) do
	-- Display the HH:MM AM/PM of the time of day (truncate the seconds).
	local timeOfDay = game.Lighting.TimeOfDay
	local hour = string.sub(timeOfDay, 1, 2)
	local minutes = string.sub(timeOfDay, 4, 5)
	local newHour = substitutions[hour][1]
	local period = substitutions[hour][2]
	local text = newHour .. ":" .. minutes .. " " .. period
	textLabel.Text = text
end
