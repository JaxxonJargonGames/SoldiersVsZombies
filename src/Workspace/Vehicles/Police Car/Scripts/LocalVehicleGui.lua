local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Gui = script:WaitForChild("VehicleGui")

local LocalPlayer = Players.LocalPlayer
local ScriptsFolder = script.Parent:WaitForChild("ScriptsReference").Value

local PlayerModule = LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
local PlayerControlModule = require(PlayerModule:WaitForChild("ControlModule"))
local Keymap = require(ScriptsFolder.Keymap)
local InputImageLibrary = require(ScriptsFolder.InputImageLibrary)

-- Time from the first tap for it to be considered a double tap
local DOUBLE_TAP_THRESHOLD = 0.3
-- Length of an input to be considered a tap
local SINGLE_TAP_THRESHOLD = 0.2

local VehicleGui = {}
VehicleGui.__index = VehicleGui

local MAX_SPEED = 130

function VehicleGui.new(car, seat)
	local self = setmetatable({}, VehicleGui)

	self.connections = {}
	self.car = car
	self.localSeatModule = require(ScriptsFolder.LocalVehicleSeating)
	self.chassis = car:WaitForChild("Chassis")
	self.seat = self.chassis:WaitForChild("VehicleSeat")
	self.gui = Gui:Clone()
	self.gui.Name = "ActiveGui"
	self.gui.Parent = script
	self.touchFrame = self.gui:WaitForChild("TouchControlFrame")
		self.accelButton = self.touchFrame:WaitForChild("AccelerateButton")
		self.brakeButton = self.touchFrame:WaitForChild("BrakeButton")
		self.exitButton = self.touchFrame:WaitForChild("ExitButton")

	self.speedoFrame = self.gui:WaitForChild("SpeedoFrame")
		self.speedoFrameOff = self.speedoFrame:WaitForChild("OffFrame")
		self.speedoOff = self.speedoFrameOff:WaitForChild("Speedo")
		self.speedoFrameOn = self.speedoFrame:WaitForChild("OnFrame")
		self.speedoOn = self.speedoFrameOn:WaitForChild("Speedo")
		self.speedText = self.speedoFrame:WaitForChild("SpeedText")
		self.unitText = self.speedoFrame:WaitForChild("UnitText")


	return self
end

----Handle the enabling and disabling of the default roblox jump button----
local function getLocalHumanoid()
	if LocalPlayer.Character then
		return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local oldHumanoidJumpPower = 50
local jumpDisabled = false
local function enableJumpButton()
	local humanoid = getLocalHumanoid()
	if jumpDisabled and humanoid then
		humanoid.JumpPower = oldHumanoidJumpPower
		jumpDisabled = false
	end
end

local function disableJumpButton()
	local humanoid = getLocalHumanoid()
	if humanoid then
		oldHumanoidJumpPower = humanoid.JumpPower
		humanoid.JumpPower = 0
		jumpDisabled = true
	end
end

function VehicleGui:Enable()
	self.gui.Enabled = true

	self:EnableKeyboardUI()
	self:ConfigureButtons()
	local function UpdateInputType(inputType)
		if inputType == Enum.UserInputType.Touch then
			self:EnableTouchUI()
			self:ConfigureButtons()
		elseif inputType.Value >= Enum.UserInputType.Gamepad1.Value and
			inputType.Value <= Enum.UserInputType.Gamepad8.Value then
			self:EnableGamepadUI()
			self:ConfigureButtons()
		elseif inputType == Enum.UserInputType.Keyboard then
			self:EnableKeyboardUI()
			self:ConfigureButtons()
		end
	end
	self.connections[#self.connections + 1] = UserInputService.LastInputTypeChanged:Connect(UpdateInputType)
	UpdateInputType(UserInputService:GetLastInputType())

	--Destroy when player gets out of vehicle
	function self.OnExit(Seat)
		self:Destroy()
	end
	self.localSeatModule.OnSeatExitEvent(self.OnExit)

	--Destroy if the gui has been destroyed
	self.connections[#self.connections + 1] = self.gui.AncestryChanged:Connect(function()
		if not self.gui:IsDescendantOf(game) then
			self:Destroy()
		end
	end)

	--Destroy if vehicle is no longer in workspace
	self.connections[#self.connections + 1] = self.chassis.AncestryChanged:Connect(function()
		if not self.chassis:IsDescendantOf(Workspace) then
			self:Destroy()
		end
	end)

	--Connect the exit seat button
	self.connections[#self.connections + 1] = self.exitButton.Activated:Connect(function()
		enableJumpButton()
		self:Destroy()
		self.localSeatModule.ExitSeat()
	end)
	self.connections[#self.connections + 1] = self.exitButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.exitButton.ImageTransparency = 1
			self.exitButton.Pressed.ImageTransparency = 0
		end
	end)
	self.connections[#self.connections + 1] = self.exitButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.exitButton.ImageTransparency = 0
			self.exitButton.Pressed.ImageTransparency = 1
		end
	end)

	self.connections[#self.connections + 1] = RunService.RenderStepped:Connect(function()
		--Update the speedo
		local vel = self.seat.Velocity
		local mphConversion = 0.6263 -- using a 28cm = 1stud conversion rate
		local speed = vel.Magnitude*mphConversion
		
		local speedFraction = math.min(speed/MAX_SPEED, 1)
		local onSize = math.floor(self.speedoFrame.AbsoluteSize.X * speedFraction + 0.5)
		self.speedoFrameOn.Size = UDim2.new(0, onSize, 1, 0)
		self.speedText.Text = tostring(math.floor(speed + 0.5))

		--Update the steering input if touch controls are enabled
		if self.touchEnabled then
			self.steeringInput = -PlayerControlModule:GetMoveVector().X
		end
	end)
end

function VehicleGui:Destroy()
	self.localSeatModule.DisconnectFromSeatExitEvent(self.OnExit)
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	if self.gui then
		self.gui:Destroy()
	end
	enableJumpButton()
end

function VehicleGui:ConfigureButtons()
	--Position Accelerate Button
	self.accelButton.Image = "rbxassetid://2847847852"
	self.accelButton.Pressed.Image = "rbxassetid://2847847961"
	self.accelButton.Size = UDim2.new(0, 70, 0, 70)
	self.accelButton.AnchorPoint = Vector2.new(1, 1)
	self.accelButton.Position = UDim2.new(1, -24, 1, -20)


	--Position Brake Button
	self.brakeButton.Size = UDim2.new(0, 44, 0, 44)
	self.brakeButton.AnchorPoint = Vector2.new(1, 1)
	self.brakeButton.Position = UDim2.new(1, -(24 + self.accelButton.Size.X.Offset + 20), 1, -20)
	self.brakeButton.Image = "rbxassetid://2847848304"
	self.brakeButton.Pressed.Image = "rbxassetid://2847848400"

	--Position Exit Button
	self.exitButton.Image = "rbxassetid://2847857948"
	self.exitButton.Pressed.Image = "rbxassetid://2847858038"
	self.exitButton.KeyImage.ImageRectSize = Vector2.new(0, 0)
	self.exitButton.KeyImage.ImageRectOffset = Vector2.new(0, 0)
	self.exitButton.KeyImage.ButtonText.Visible = false

	local inputType = UserInputService:GetLastInputType()
	if inputType == Enum.UserInputType.Touch then
		self.exitButton.Size = UDim2.new(0, 44, 0, 44)
		self.exitButton.AnchorPoint = Vector2.new(1, 1)
		self.exitButton.Position = UDim2.new(1, -24, 1, -(20 + self.accelButton.Size.Y.Offset + 20))
		self.exitButton.KeyImage.Image = ""
	else
		self.exitButton.Size = UDim2.new(0, 72, 0, 72)
		self.exitButton.AnchorPoint = Vector2.new(1, 1)
		self.exitButton.Position = UDim2.new(1, -24, 1, -(20 + self.accelButton.Size.Y.Offset + 20))

		if inputType.Value >= Enum.UserInputType.Gamepad1.Value and
			inputType.Value <= Enum.UserInputType.Gamepad8.Value then
			--Set the correct image for the gamepad button prompt
			local template = InputImageLibrary:GetImageLabel(Keymap.EnterVehicleGamepad, "Light")
			self.exitButton.KeyImage.Image = template.Image
			self.exitButton.KeyImage.ImageRectOffset = template.ImageRectOffset
			self.exitButton.KeyImage.ImageRectSize = template.ImageRectSize
		else
			self.exitButton.KeyImage.Image = "rbxassetid://2935912536"
			self.exitButton.KeyImage.ButtonText.Visible = true
			self.exitButton.KeyImage.ButtonText.Text = Keymap.EnterVehicleKeyboard.Name
		end
	end
end

--If both DriverControls are enabled and touch controls are enabled then the accelerate and brake buttons will appear.
function VehicleGui:EnableDriverControls()
	self.driverControlsEnabled = true

	if self.touchEnabled then
		self:DisplayTouchDriveControls()
	end
end

function VehicleGui:EnableSpeedo()
	self.speedoFrame.Visible = true
end

function VehicleGui:DisableSpeedo()
	self.speedoFrame.Visible = false
end

function VehicleGui:DisplayTouchDriveControls()
	self.brakeButton.Visible = true
	self.accelButton.Visible = true

	--Read button inputs
	local ADown = false
	local BDown = false
	local HDown = false
	local function ProcessTouchThrottle()
		if (ADown and BDown) or (not ADown and not BDown) then
			self.throttleInput = 0
		elseif ADown then
			self.throttleInput = 1
		elseif BDown then
			self.throttleInput = -1
		end
		if HDown then
			self.handBrakeInput = 1
		else
			self.handBrakeInput = 0
		end
	end
	--Accel
	self.accelButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			ADown = true
			self.accelButton.ImageTransparency = 1
			self.accelButton.Pressed.ImageTransparency = 0
			ProcessTouchThrottle()
		end
	end)
	self.accelButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			ADown = false
			self.accelButton.ImageTransparency = 0
			self.accelButton.Pressed.ImageTransparency = 1
			ProcessTouchThrottle()
		end
	end)
	--Brake
	local lastBrakeTapTime = 0
	local brakeLastInputBegan = 0
	self.brakeButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if tick() - lastBrakeTapTime <= DOUBLE_TAP_THRESHOLD then
				HDown = true
			else
				brakeLastInputBegan = tick()
				BDown = true
			end
			self.brakeButton.ImageTransparency = 1
			self.brakeButton.Pressed.ImageTransparency = 0
			ProcessTouchThrottle()
		end
	end)
	self.brakeButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if not HDown then
				if tick() - brakeLastInputBegan <= SINGLE_TAP_THRESHOLD then
					lastBrakeTapTime = tick()
				end
			end
			brakeLastInputBegan = 0
			HDown = false
			BDown = false
			self.brakeButton.ImageTransparency = 0
			self.brakeButton.Pressed.ImageTransparency = 1
			ProcessTouchThrottle()
		end
	end)
end

function VehicleGui:EnableTouchControls()
	if self.touchEnabled then return end
	self.touchEnabled = true

	disableJumpButton()

	self:ConfigureButtons()

	if self.driverControlsEnabled then
		self:DisplayTouchDriveControls()
	end
end

function VehicleGui:DisableTouchControls()
	if not self.touchEnabled  then return end
	self.touchEnabled = false

	enableJumpButton()

	self.brakeButton.Visible = false
	self.accelButton.Visible = false
end

function VehicleGui:EnableKeyboardUI()
	self.speedoFrame.Size = UDim2.new(0, 400, 0, 90)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -40)
	self.speedoOn.Image = "rbxassetid://2848312414"
	self.speedoOff.Image = "rbxassetid://2848312878"
	self.speedText.TextSize = 40
	self.speedText.Size = UDim2.new(0, 60, 0, 40)
	self.speedText.Position = UDim2.new(0, 215, 0, 94)
	self.unitText.TextSize = 20
	self.unitText.Size = UDim2.new(0, 30, 0, 20)
	self.unitText.Position = UDim2.new(0, 225, 0, 90)

	self:DisableTouchControls()
end

function VehicleGui:EnableTouchUI()
	self.speedoFrame.Size = UDim2.new(0, 240, 0, 54)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -20)
	self.speedoOn.Image = "rbxassetid://2847843718"
	self.speedoOff.Image = "rbxassetid://2847843839"
	self.speedText.TextSize = 24
	self.speedText.Size = UDim2.new(0, 24*3*0.5, 0, 24)
	self.speedText.Position = UDim2.new(0, 120, 0, 54)
	self.unitText.TextSize = 12
	self.unitText.Size = UDim2.new(0, 12*3*0.5, 0, 12)
	self.unitText.Position = UDim2.new(0, 125, 0, 54)

	self:EnableTouchControls()
end

function VehicleGui:EnableGamepadUI()
	self.speedoFrame.Size = UDim2.new(0, 600, 0, 135)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -40)
	self.speedoOn.Image = "rbxassetid://2836208803"
	self.speedoOff.Image = "rbxassetid://2836208488"
	self.speedText.TextSize = 60
	self.speedText.Size = UDim2.new(0, 90, 0, 60)
	self.speedText.Position = UDim2.new(0, 315, 0, 140)
	self.unitText.TextSize = 30
	self.unitText.Size = UDim2.new(0, 45, 0, 30)
	self.unitText.Position = UDim2.new(0, 325, 0, 135)

	self:DisableTouchControls()
end

return VehicleGui
