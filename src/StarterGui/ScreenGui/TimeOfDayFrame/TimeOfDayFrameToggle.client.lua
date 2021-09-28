--[[
Toggle the display of the time of day.
--]]

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local ACTION_NAME = "ToggleTimeOfDay"
local CREATE_TOUCH_BUTTON = false
local INPUT_TYPES = Enum.KeyCode.T

local function onToggleTimeOfDay(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		if actionName == ACTION_NAME then
			local frame = script.Parent
			if frame.Visible then
				frame.Visible = false
			else
				frame.Visible = true
			end
		end
	end
end

ContextActionService:BindAction(ACTION_NAME, onToggleTimeOfDay, CREATE_TOUCH_BUTTON, INPUT_TYPES)
