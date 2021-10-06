local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Event = ReplicatedStorage:WaitForChild("ResetEvent")
local ACTION_NAME = "Reset"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.Delete

local function onEvent(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			Event:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onEvent, CREATE_TOUCH_BUTTON, INPUT_TYPES)

local Event = ReplicatedStorage:WaitForChild("Stage2BackdoorEvent")
local ACTION_NAME = "Stage2Backdoor"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.Insert

local function onEvent(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			Event:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onEvent, CREATE_TOUCH_BUTTON, INPUT_TYPES)

local Event = ReplicatedStorage:WaitForChild("WeaponUpgradesEvent")
local ACTION_NAME = "WeaponUpgrades"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.U

local function onEvent(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			Event:FireServer(player)
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onEvent, CREATE_TOUCH_BUTTON, INPUT_TYPES)
