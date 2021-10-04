local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Stage2Event = ReplicatedStorage:WaitForChild("Stage2Event")
local ACTION_NAME = "Stage2"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.Insert

local function onStage2(actionName, inputState, inputObject)
	if player.UserId == game.CreatorId then
		if inputState == Enum.UserInputState.Begin then
			if actionName == ACTION_NAME then
				Stage2Event:FireServer(player)
			end
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onStage2, CREATE_TOUCH_BUTTON, INPUT_TYPES)
