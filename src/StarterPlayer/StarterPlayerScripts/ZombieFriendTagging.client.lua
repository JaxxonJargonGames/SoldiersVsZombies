local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local event = ReplicatedStorage:WaitForChild("ZombieFriendToggleEvent")
local ACTION_NAME = "ZombieFriendToggle"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.F

local function onZombieFriendToggleEvent(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			event:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onZombieFriendToggleEvent, CREATE_TOUCH_BUTTON, INPUT_TYPES)
