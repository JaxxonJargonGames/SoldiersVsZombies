local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local EXIT_ACTION_NAME = "VehicleChassisExitVehiclePassenger"

local CarValue = script:WaitForChild("CarValue")
local Car = CarValue.Value

local LocalVehicleSeating = require(Car.Scripts.LocalVehicleSeating)
local Keymap = require(Car.Scripts.Keymap)

local VehicleGui = require(script.Parent:WaitForChild("LocalVehicleGui")).new(Car)
VehicleGui:Enable()

local function getLocalHumanoid()
	if LocalPlayer.Character then
		return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function exitVehicle(action, inputState, inputObj)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if script:IsDescendantOf(game) then
		LocalVehicleSeating.ExitSeat()
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

local function onExitSeat(Seat)
	ContextActionService:UnbindAction(EXIT_ACTION_NAME)
	local humanoid = getLocalHumanoid()
	if humanoid then
		Workspace.CurrentCamera.CameraSubject = humanoid
	end
	ProximityPromptService.Enabled = true
	LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
	script.Disabled = true
end
LocalVehicleSeating.OnSeatExitEvent(onExitSeat)

ContextActionService:BindAction(
	EXIT_ACTION_NAME,
	exitVehicle,
	false,
	Keymap.EnterVehicleGamepad,
	Keymap.EnterVehicleKeyboard,
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.Space
)

-- This has to be done so that camera occlusion ignores the vehcile.
local function updateCameraSubject()
	local humanoid = getLocalHumanoid()
	if humanoid and humanoid.SeatPart then
		--Workspace.CurrentCamera.CameraSubject = humanoid.SeatPart	
	end
end
updateCameraSubject()
ProximityPromptService.Enabled = false
