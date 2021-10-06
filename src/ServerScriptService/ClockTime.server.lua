local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClockTime = require(ReplicatedStorage:WaitForChild("ClockTime"))

-- Begin at sunset/moonrise.
local SIX_OCLOCK_PM = 18
game.Lighting.ClockTime = SIX_OCLOCK_PM

-- Increment the game clock by one minute for every second (approximately) that goes by.
while true do
	task.wait(0.1)
	if not ClockTime.ClockTimePaused then
		game.Lighting.ClockTime += ClockTime.ONE_MINUTE / 10
	end
end
