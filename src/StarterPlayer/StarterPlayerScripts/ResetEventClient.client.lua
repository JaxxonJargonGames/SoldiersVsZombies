local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local ResetEvent = ReplicatedStorage:WaitForChild("ResetEvent")
local ACTION_NAME = "Reset"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.Delete

local function onReset(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			ResetEvent:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onReset, CREATE_TOUCH_BUTTON, INPUT_TYPES)
