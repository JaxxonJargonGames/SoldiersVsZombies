local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer


-- Pause/Unpause the incrementing of the ClockTime on the server.
local ClockTimePauseToggleEvent = ReplicatedStorage:WaitForChild("ClockTimePauseToggleEvent")
local ACTION_NAME = "ClockTimePauseToggle"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.P

local function onClockTimePauseToggle(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			ClockTimePauseToggleEvent:FireServer()
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onClockTimePauseToggle, CREATE_TOUCH_BUTTON, INPUT_TYPES)


-- Increment the ClockTime on the server by one hour.
local ClockTimeAddHourEvent = ReplicatedStorage:WaitForChild("ClockTimeAddHourEvent")
local ACTION_NAME = "ClockTimeAddHour"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.H

local function onClockTimeAddHour(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			ClockTimeAddHourEvent:FireServer()
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onClockTimeAddHour, CREATE_TOUCH_BUTTON, INPUT_TYPES)


-- Decrement the ClockTime on the server by one hour.
local ClockTimeAddHourEvent = ReplicatedStorage:WaitForChild("ClockTimeSubtractHourEvent")
local ACTION_NAME = "ClockTimeSubtractHour"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.B

local function onClockTimeSubtractHour(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			ClockTimeAddHourEvent:FireServer()
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onClockTimeSubtractHour, CREATE_TOUCH_BUTTON, INPUT_TYPES)


-- Increment the ClockTime on the server by one minute.
local ClockTimeAddMinuteEvent = ReplicatedStorage:WaitForChild("ClockTimeAddMinuteEvent")
local ACTION_NAME = "ClockTimeAddMinute"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.M

local function onClockTimeAddMinute(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			ClockTimeAddMinuteEvent:FireServer()
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onClockTimeAddMinute, CREATE_TOUCH_BUTTON, INPUT_TYPES)
