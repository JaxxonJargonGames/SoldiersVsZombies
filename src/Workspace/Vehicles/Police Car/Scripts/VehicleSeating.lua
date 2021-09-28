--This is the server sided module for handling this vehicles seating requests
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local DOOR_OPEN_SPEED = 2.15
local DOOR_OPEN_ANGLE = 55
local DOOR_OPEN_TIME = 0.5 --How long the door stays open for when entering/leaving

local MAX_SEATING_DISTANCE = 15
local MIN_FLIP_ANGLE = 70 --degrees from vertical

local PackagedScripts = script.Parent
local PackagedVehicle = PackagedScripts.Parent

local RemotesFolder = nil --Set later in the code by the SetRemotesFolder function
	
--Variables
local SeatInteractionCount = {}

local VehicleSeating = {}

local function getVehicleObject()
	return script.Parent.Parent
end

local function carjackingEnabled(obj)
	return obj:GetAttribute("AllowCarjacking")
end

local function getEffectsFolderFromSeat(seat)
	local parent = seat.Parent
	if parent:IsA("Model") then
		if parent:FindFirstChild("Effects") then
			return parent.Effects
		else
			return getEffectsFolderFromSeat(parent)
		end
	end
	return nil
end

local function playDoorSound(seat, sound)
	local sound = seat:FindFirstChild(sound.."Door")
	if sound then
		sound:Play()
	end
end

--Tell if a seat is flipped
local function isFlipped(Seat)
	local UpVector = Seat.CFrame.upVector
	local Angle = math.deg(math.acos(UpVector:Dot(Vector3.new(0, 1, 0))))
	return Angle >= MIN_FLIP_ANGLE
end

local function Raycast(startPos, direction, range, ignore, inceptNumber)
	if inceptNumber == nil then inceptNumber = 0 end
	inceptNumber = inceptNumber + 1
	local ray = Ray.new(startPos, direction * range)
	local part, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
	if part then
		if part.CanCollide == false and inceptNumber <= 5 then
			--raycast again if we hit a cancollide false brick, put a limit on to prevent an infinite loop
			local rangeLeft = range - (startPos - position).magnitude
			part, position = Raycast(position, direction, rangeLeft, ignore, inceptNumber) --Raycast remaining distance.
		end
	end
	return part, position
end

local function ExitSeat(player, character, seat, weld)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		weld:Destroy()

		if seat:FindFirstChild("DoorHinge") then
			seat.DoorLatchWeld.Enabled = false
			seat.DoorHinge.TargetAngle = DOOR_OPEN_ANGLE
			playDoorSound(seat, "OpenClose")
		end
		--Record the interaction
		SeatInteractionCount[seat] = SeatInteractionCount[seat] and SeatInteractionCount[seat] + 1 or 1

		wait()
		if seat:FindFirstChild("ExitPosition") then --Check if we can move the character to the designated pos.
			--Find vehicle model
			local model
			local newParent = seat
			repeat
				model = newParent
				newParent = model.Parent
			until newParent.ClassName ~= "Model"

			local targetPos = seat.ExitPosition.WorldPosition
			local delta = targetPos - seat.Position
			local dist = delta.magnitude
			local dir = delta.unit
			local part, _ = Raycast(seat.Position, dir, dist, {character, model})

			if not part then --Prevent people being CFramed into walls and stuff
				hrp.CFrame = CFrame.new(targetPos)
			else
				hrp.CFrame = CFrame.new(seat.Position)
				--The CFrame element orients the character up-right, the MoveTo stops the character from clipping into objects
				character:MoveTo(seat.Position+Vector3.new(0,8,0))
			end
		else
			hrp.CFrame = CFrame.new(seat.Position)
			character:MoveTo(seat.Position+Vector3.new(0,8,0))
		end

		if player then
			RemotesFolder.ExitSeat:FireClient(player, true) --Fire this to trigger the client-side anti-trip function
		end

		wait(DOOR_OPEN_TIME)

		SeatInteractionCount[seat] = SeatInteractionCount[seat] > 1 and SeatInteractionCount[seat] - 1 or nil
		if seat:FindFirstChild("DoorHinge") then
			--If nobody else has interactied in this time, close the door.
			if SeatInteractionCount[seat] == nil then
				seat.DoorHinge.TargetAngle = 0
				-- Weld door shut when closed
				while math.abs(seat.DoorHinge.CurrentAngle) > 0.01 do
					wait()
				end
				seat.DoorLatchWeld.Enabled = true
			end
		end
	end
end

local function FlipSeat(Player, Seat)
	if Seat then
		if Seat.Parent then
			if not Seat.Parent.Parent:FindFirstChild("Scripts") then
				warn("Flip Error: Scripts file not found. Please parent seats to the chassis model")
				return
			end
			if not Seat.Parent.Parent.Scripts:FindFirstChild("Chassis") then
				warn("Flip Error: Chassis module not found.")
				return
			end
			local Chassis = require(Seat.Parent.Parent.Scripts.Chassis)
			Chassis.Redress()
		end
	end
end

function VehicleSeating.EjectCharacter(character)
	if character and character.HumanoidRootPart then
		for _, weld in pairs(character.HumanoidRootPart:GetJoints()) do
			if weld.Name == "SeatWeld" then
				ExitSeat(Players:GetPlayerFromCharacter(character), character, weld.Part0, weld)
				break
			end
		end
	end
end

function VehicleSeating.SetRemotesFolder(remotes)
	RemotesFolder = remotes

	--Detect exit seat requests
	RemotesFolder:FindFirstChild("ExitSeat").OnServerEvent:Connect(function(player)
		if player.Character then
			local character = player.Character
			VehicleSeating.EjectCharacter(character)
		end
	end)

	--Detect force exit seat requests
	RemotesFolder:FindFirstChild("ForceExitSeat").OnServerEvent:Connect(function(seatName)
		local chassis = PackagedVehicle:FindFirstChild("Chassis")
		if chassis then
			local seat = chassis:FindFirstChild(seatName)
			if seat and seat.Occupant then
				local occupantCharacter = seat.Occupant.Parent
				VehicleSeating.EjectCharacter(occupantCharacter)
			end
		end
	end)
end

function VehicleSeating.SetBindableEventsFolder(bindables)
	local BindableEventsFolder = bindables

	--Detect force exit seat requests
	BindableEventsFolder:FindFirstChild("ForceExitSeat").Event:Connect(function(seatName)
		local chassis = PackagedVehicle:FindFirstChild("Chassis")
		if chassis then
			local seat = chassis:FindFirstChild(seatName)
			if seat and seat.Occupant then
				local occupantCharacter = seat.Occupant.Parent
				VehicleSeating.EjectCharacter(occupantCharacter)
			end
		end
	end)
end

function VehicleSeating.AddSeat(seat, enterCallback, exitCallback)
	local promptLocation = seat:FindFirstChild("PromptLocation")
	if promptLocation then
		local proximityPrompt = promptLocation:FindFirstChildWhichIsA("ProximityPrompt")
		if proximityPrompt then
			local vehicleObj = getVehicleObject()

			local function setCarjackPrompt()
				if seat.Occupant and not carjackingEnabled(vehicleObj) then
					proximityPrompt.Enabled = false
				else
					proximityPrompt.Enabled = true
				end
			end

			seat:GetPropertyChangedSignal("Occupant"):connect(setCarjackPrompt)
			vehicleObj:GetAttributeChangedSignal("AllowCarjacking"):Connect(setCarjackPrompt)

			proximityPrompt.Triggered:connect(function(Player)
				if seat then
					if isFlipped(seat) then
						FlipSeat(Player, seat)

					elseif not seat:FindFirstChild("SeatWeld") or carjackingEnabled(vehicleObj) then
						if Player.Character ~= nil then
							local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
							local humanoid = Player.Character:FindFirstChild("Humanoid")

							if HRP then
								local Dist = (HRP.Position - seat.Position).magnitude
								if Dist <= MAX_SEATING_DISTANCE then
									if seat.Occupant then
										local occupantCharacter = seat.Occupant.Parent
										for _, weld in pairs(occupantCharacter.HumanoidRootPart:GetJoints()) do
											if weld.Name == "SeatWeld" then
												ExitSeat(Players:GetPlayerFromCharacter(occupantCharacter), occupantCharacter, weld.Part0, weld)
												break
											end
										end
									end
									seat:Sit(humanoid)
									
									if seat:FindFirstChild("DoorHinge") then
										if seat.DoorHinge.ClassName ~= "HingeConstraint" then warn("Warning, door hinge is not actually a hinge!") end

										--Record that a player is trying to get in the seat
										SeatInteractionCount[seat] = SeatInteractionCount[seat] and SeatInteractionCount[seat] + 1 or 1

										--Activate the hinge
										seat.DoorLatchWeld.Enabled = false
										seat.DoorHinge.TargetAngle = DOOR_OPEN_ANGLE
										seat.DoorHinge.AngularSpeed = DOOR_OPEN_SPEED

										playDoorSound(seat, "OpenClose")

										wait(DOOR_OPEN_TIME)

										--Check if anyone has interacted with the door within this time. If not, close it.
										SeatInteractionCount[seat] = SeatInteractionCount[seat] > 1 and SeatInteractionCount[seat] - 1 or nil
										if SeatInteractionCount[seat] == nil then
											seat.DoorHinge.TargetAngle = 0
											-- Weld door shut when closed
											while math.abs(seat.DoorHinge.CurrentAngle) > 0.01 do
												wait()
											end
											seat.DoorLatchWeld.Enabled = true
										end
									end
								end
							end
						end
					end
				end
			end)
		end
	end

	local effectsFolder = getEffectsFolderFromSeat(seat)
	if effectsFolder then
		-- set open/close Sound
		local openclose = effectsFolder:FindFirstChild("OpenCloseDoor")
		if openclose then
			openclose:Clone().Parent = seat
		end
	end

	local currentOccupant = nil
	local occupantChangedConn = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if seat.Occupant then
			if enterCallback then
				currentOccupant = seat.Occupant
				currentOccupant = Players:GetPlayerFromCharacter(currentOccupant.Parent) or currentOccupant
				enterCallback(currentOccupant, seat)
			end
		elseif exitCallback then
			exitCallback(currentOccupant, seat)
			currentOccupant = nil
		end
	end)

	--Clean up after the seat is destroyed
	seat.AncestryChanged:connect(function()
		if not seat:IsDescendantOf(game) then
			occupantChangedConn:Disconnect()
		end
	end)
end

return VehicleSeating
