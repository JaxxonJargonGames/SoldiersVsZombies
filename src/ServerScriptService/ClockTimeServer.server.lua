local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClockTimeModule = require(ReplicatedStorage:WaitForChild("ClockTimeModule"))

-- Begin at sunset/moonrise.
local SIX_OCLOCK_PM = 18
game.Lighting.ClockTime = SIX_OCLOCK_PM

-- Increment the game clock by one minute for every second (approximately) that goes by.
while true do
	task.wait(0.1)
	if not ClockTimeModule.ClockTimePaused then
		game.Lighting.ClockTime += ClockTimeModule.ONE_MINUTE / 10
	end
end
