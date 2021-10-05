local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Stage2BackdoorEvent = ReplicatedStorage:WaitForChild("Stage2BackdoorEvent")
local ACTION_NAME = "Stage2Backdoor"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.Insert

local function onStage2Backdoor(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			Stage2BackdoorEvent:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onStage2Backdoor, CREATE_TOUCH_BUTTON, INPUT_TYPES)
