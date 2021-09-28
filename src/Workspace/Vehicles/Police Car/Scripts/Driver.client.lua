local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local CarValue = script:WaitForChild("CarValue")
local Car = CarValue.Value

local RAW_INPUT_ACTION_NAME = "VehicleChassisRawInput"
local EXIT_ACTION_NAME = "VehicleChassisExitVehicle"

--Get modules

--Initialize Chassis
local ScriptsFolder = Car:FindFirstChild("Scripts")
local Chassis = require(ScriptsFolder:WaitForChild("Chassis"))
Chassis.InitializeDrivingValues()
Chassis.Reset()

--Set up gui - has its own class
local VehicleGui = require(script.Parent:WaitForChild("LocalVehicleGui")).new(Car)
VehicleGui:Enable()
VehicleGui:EnableDriverControls()
VehicleGui:EnableSpeedo()

local Keymap = require(ScriptsFolder.Keymap)
local _rawInput = Keymap.newInputTable()
local LocalVehicleSeating = require(ScriptsFolder.LocalVehicleSeating)

local function _clearInput()
	for k, v in pairs(_rawInput) do
		_rawInput[k] = 0
	end
end

--Objects
local DriverSeat = Chassis.driverSeat

local function unbindActions()
	ContextActionService:UnbindAction(RAW_INPUT_ACTION_NAME)
	ContextActionService:UnbindAction(EXIT_ACTION_NAME)
end

local function onExitSeat(Seat)
	unbindActions()
	_clearInput()
	ProximityPromptService.Enabled = true
	LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
	script.Disabled = true
end
LocalVehicleSeating.OnSeatExitEvent(onExitSeat)

--Disable script if car is removed from workspace
Car.AncestryChanged:Connect(function()
	if not Car:IsDescendantOf(Workspace) then
		unbindActions()

		LocalVehicleSeating.ExitSeat()
		LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
		-- stop seated anim
		--print("car removed from workspace")

		script.Disabled = true
		ProximityPromptService.Enabled = true
	end
end)

local function exitVehicle(action, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		LocalVehicleSeating.ExitSeat()
		-- stop seated anim
	end
end

local function _updateRawInput(_, inputState, inputObj)
	local key = inputObj.KeyCode
	local data = Keymap.getData(key)
	
	if not data then 
		return
	end
	
	local axis = data.Axis
	local val = 0
	
	if axis then
		val = inputObj.Position:Dot(axis)
	else
		val = (inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.Change) and 1 or 0
	end
	
	val = val * (data.Sign or 1)
	
	_rawInput[key] = val
	
	if data.Pass then
		return Enum.ContextActionResult.Pass
	end
end

local function _calculateInput(action)
	-- Loop through all mappings for this action and calculate a resultant value from the raw input
	local mappings = Keymap[action]
	local val = 0
	local absVal = val
	
	for _, data in ipairs(mappings) do
		local thisVal = _rawInput[data.KeyCode]
		if math.abs(thisVal) > absVal then
			val = thisVal
			absVal = math.abs(val)
		end
	end
	
	return val
end

ContextActionService:BindAction(
	EXIT_ACTION_NAME,
	exitVehicle,
	false,
	Keymap.EnterVehicleGamepad,
	Keymap.EnterVehicleKeyboard
)

ContextActionService:BindActionAtPriority(
	RAW_INPUT_ACTION_NAME,
	_updateRawInput,
	false,
	Enum.ContextActionPriority.High.Value,
	unpack(Keymap.allKeys()))

--Interpret input
local function getInputValues()
	if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
		---Let the control module handle all none-touch controls
		script.Throttle.Value = _calculateInput("Throttle") - _calculateInput("Brake")
		script.Steering.Value = _calculateInput("SteerLeft") + _calculateInput("SteerRight")
		script.HandBrake.Value = _calculateInput("Handbrake")

	else --The vehicle gui handles all the touch controls
		script.Throttle.Value = VehicleGui.throttleInput
		script.Steering.Value = VehicleGui.steeringInput
		script.HandBrake.Value = VehicleGui.handBrakeInput
	end
end

ProximityPromptService.Enabled = false

-- Driver Input Loop --
while script.Parent ~= nil do
	--Update throttle, steer, handbrake
	getInputValues()

	local currentVel = Chassis.GetAverageVelocity()

	local steer = script.Steering.Value
	Chassis.UpdateSteering(steer, currentVel)

	-- Taking care of throttling
	local throttle = script.Throttle.Value
	script.AngularMotorVelocity.Value = currentVel
	script.ForwardVelocity.Value = DriverSeat.CFrame.LookVector:Dot(DriverSeat.Velocity)
	Chassis.UpdateThrottle(currentVel, throttle)

	-- Taking care of handbrake
	if script.HandBrake.Value > 0 then
		Chassis.EnableHandbrake()
	end
	wait()
end
