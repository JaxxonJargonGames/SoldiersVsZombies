local ProximityPromptService = game:GetService("ProximityPromptService")
local screenGui = script.Parent
local CarValue = script:WaitForChild("CarValue")
local Car = CarValue.Value
local Keymap = require(Car.Scripts.Keymap)
local InputImageLibrary = require(Car.Scripts.InputImageLibrary)

local MIN_FLIP_ANGLE = 70 --degrees from vertical

--Tell if a seat is flipped
local function isFlipped(Seat)
	local UpVector = Seat.CFrame.upVector
	local Angle = math.deg(math.acos(UpVector:Dot(Vector3.new(0, 1, 0))))
	return Angle >= MIN_FLIP_ANGLE
end

local function createPrompt(prompt, inputType)
	local seat = prompt.Parent.Parent
	local buttonGui = script:WaitForChild("ButtonGuiPrototype")
	local promptUI = buttonGui:Clone()
	promptUI.Name = "ButtonGui"
	promptUI.Enabled = true
	promptUI.Adornee = prompt.Parent
	
	
	local EnterImageButton = promptUI:WaitForChild("ButtonImage")
	local FlipImageButton = promptUI:WaitForChild("FlipImage")
	local BackgroundDesktop = promptUI:WaitForChild("BackgroundDesktop")
	local BackgroundConsole = promptUI:WaitForChild("BackgroundConsole")
	local ButtonPrompt = promptUI:WaitForChild("ButtonPrompt")

	--Switch button type
	local DriverButtonId
	local DriverButtonPressedId
	local PassengerButtonId
	local PassengerButtonPressedId
	if inputType == Enum.ProximityPromptInputType.Keyboard then
		DriverButtonId = "rbxassetid://2848250902"
		DriverButtonPressedId = "rbxassetid://2848250902"
		PassengerButtonId = "rbxassetid://2848251564"
		PassengerButtonPressedId = "rbxassetid://2848251564"
		EnterImageButton.Size = UDim2.new(0, 36, 0, 36)
		FlipImageButton.Image = "rbxassetid://2848307983"
		FlipImageButton:WaitForChild("Pressed").Image = "rbxassetid://2848307983"
		FlipImageButton.Size = UDim2.new(0, 44, 0, 44)

		BackgroundConsole.Visible = false
		BackgroundDesktop.Visible = true
		BackgroundDesktop.Size =  UDim2.new(0, 97, 0, 46)
		BackgroundDesktop.Position = UDim2.new(0.5, 28, 0.5, 0)

		ButtonPrompt.Visible = true
		ButtonPrompt.Image = "rbxassetid://2935912536"
		ButtonPrompt.Size = UDim2.new(0, 36, 0, 36)
		ButtonPrompt.Position = UDim2.new(0.5, -46, 0.5, 0)
		ButtonPrompt.TextLabel.Visible = true

		--Display the correct key
		ButtonPrompt.TextLabel.Text = Keymap.EnterVehicleKeyboard.Name

	elseif inputType == Enum.ProximityPromptInputType.Gamepad then
		DriverButtonId = "rbxassetid://2848635029"
		DriverButtonPressedId = "rbxassetid://2848635029"
		PassengerButtonId = "rbxassetid://2848636545"
		PassengerButtonPressedId = "rbxassetid://2848636545"
		EnterImageButton.Size = UDim2.new(0, 60, 0, 60)
		FlipImageButton.Image = "rbxassetid://2848307983"
		FlipImageButton:WaitForChild("Pressed").Image = "rbxassetid://2848307983"
		FlipImageButton.Size = UDim2.new(0, 44, 0, 44)

		BackgroundDesktop.Visible = false
		BackgroundConsole.Visible = true
		BackgroundConsole.Size =  UDim2.new(0, 136, 0, 66)
		BackgroundConsole.Position = UDim2.new(0.5, 40, 0.5, 0)

		ButtonPrompt.Visible = true
		--ButtonPrompt.Image = "rbxassetid://408462759"
		ButtonPrompt.Size = UDim2.new(0, 46, 0, 46)
		ButtonPrompt.Position = UDim2.new(0.5, -63, 0.5, 0)
		ButtonPrompt.ImageRectSize = Vector2.new(71, 71)
		ButtonPrompt.ImageRectOffset = Vector2.new(512, 600)
		ButtonPrompt.TextLabel.Visible = false

		--Set the correct image for the gamepad button prompt
		local template = InputImageLibrary:GetImageLabel(Keymap.EnterVehicleGamepad, "Light")
		ButtonPrompt.Image = template.Image
		ButtonPrompt.ImageRectOffset = template.ImageRectOffset
		ButtonPrompt.ImageRectSize = template.ImageRectSize
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		BackgroundDesktop.Visible = false
		BackgroundConsole.Visible = false
		ButtonPrompt.Visible = false

		DriverButtonId = "rbxassetid://2847898200"
		DriverButtonPressedId = "rbxassetid://2847898354"
		PassengerButtonId = "rbxassetid://2848217831"
		PassengerButtonPressedId = "rbxassetid://2848218107"
		EnterImageButton.Size = UDim2.new(0, 44, 0, 44)
		FlipImageButton.Image = "rbxassetid://2848187559"
		FlipImageButton:WaitForChild("Pressed").Image = "rbxassetid://2848187982"
		FlipImageButton.Size = UDim2.new(0, 44, 0, 44)
		
		EnterImageButton.InputBegan:Connect(function(input)
			prompt:InputHoldBegin()
		end)
		EnterImageButton.InputEnded:Connect(function(input)
			prompt:InputHoldEnd()
		end)
		FlipImageButton.InputBegan:Connect(function(input)
			prompt:InputHoldBegin()
		end)
		FlipImageButton.InputEnded:Connect(function(input)
			prompt:InputHoldEnd()
		end)

		promptUI.Active = true
	end
	
	if isFlipped(seat) then
		FlipImageButton.Visible = true
		EnterImageButton.Visible = false
	else
		FlipImageButton.Visible = false
		EnterImageButton.Visible = true
	end
	if seat.Name == "VehicleSeat" then
		EnterImageButton.Image = DriverButtonId
		EnterImageButton.Pressed.Image = DriverButtonPressedId
	else
		EnterImageButton.Image = PassengerButtonId
		EnterImageButton.Pressed.Image = PassengerButtonPressedId
	end

	return promptUI
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Name == "EndorsedVehicleProximityPromptV1" then
		local promptUI = createPrompt(prompt, inputType)
		promptUI.Parent = screenGui
		prompt.PromptHidden:Wait()
		promptUI.Parent = nil
	end
end)
