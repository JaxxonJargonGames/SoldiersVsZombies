local textLabel = script.Parent

while true do
	task.wait(0.1)
	-- Display the HH:MM of the time of day (truncate the seconds).
	textLabel.Text = "Time of Day: " .. string.sub(game.Lighting.TimeOfDay, 1, 5)
end
