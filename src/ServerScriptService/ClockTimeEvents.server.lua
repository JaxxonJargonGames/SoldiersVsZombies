local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClockTimeModule = require(ReplicatedStorage:WaitForChild("ClockTimeModule"))

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimePauseToggleEvent"
event.OnServerEvent:Connect(function(player)
	ClockTimeModule.ClockTimePaused = not ClockTimeModule.ClockTimePaused
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeAddHourEvent"
event.OnServerEvent:Connect(function(player)
	local time = game.Lighting.ClockTime + ClockTimeModule.ONE_HOUR
	if time > 24 then
		time -= 24
	end
	game.Lighting.ClockTime = time
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeSubtractHourEvent"
event.OnServerEvent:Connect(function(player)
	local time = game.Lighting.ClockTime - ClockTimeModule.ONE_HOUR
	if time < 0 then
		time += 24
	end
	game.Lighting.ClockTime = time
end)
event.Parent = ReplicatedStorage

local event = Instance.new("RemoteEvent")
event.Name = "ClockTimeAddMinuteEvent"
event.OnServerEvent:Connect(function(player)
	local time = game.Lighting.ClockTime + ClockTimeModule.ONE_MINUTE
	if time > 24 then
		time -= 24
	end
	game.Lighting.ClockTime = time
end)
event.Parent = ReplicatedStorage
