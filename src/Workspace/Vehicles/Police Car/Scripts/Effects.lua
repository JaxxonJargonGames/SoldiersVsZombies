local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Scripts = script.Parent
local Vehicle = Scripts.Parent

-- tween engine sound volume when we start driving
local engineStartTween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)

local Remotes = Vehicle:WaitForChild("Remotes")
local SetThrottleRemote = Remotes:WaitForChild("SetThrottle")
local SetThrottleConnection = nil

local EngineSoundEnabled = true
local TireTrailEnabled = false

local ignitionTime = 1.75 -- seconds

local lastAvgAngularVelocity = 0
local throttleEnabled = false
local lastThrottleUpdate = 0

local enginePower = 0 -- current rpm of the engine
local gainModifier = 1 -- modifier to engine rpm gain (lower if approaching max speed)

-- This parameter determines how long the effects heartbeat loop keeps running after the driver exits
local EFFECTS_GRACE_PERIOD = 0.5

-- This affects how often the client sends engine power updates (frequency: times/second)
local THROTTLE_UPDATE_RATE = 5

-- Engine Sound Parameters
local RPM_CROSSOVER = 250 -- How much more engine power is needed to crossover to the next engine audio track
local ENGINE_GAIN_ACCEL = 0.1 -- Exponent that builds the engine RPM when accelerating (gives the engine sound more oomph the higher the value)
local ENGINE_GAIN_DECCEL = 0.5 -- Exponent that builds the engine RPM when decelerating (braking)
local BASE_RPM = Vehicle:GetAttribute("BaseEngineRPM") or 1500 -- Resting state for the engine
local MAX_RPM = Vehicle:GetAttribute("MaxEngineRPM") or 5000 -- The engine RPM correlating to the highest pitch for engine sounds
local MAX_IDEAL_RPM = MAX_RPM-(MAX_RPM-BASE_RPM)/4 -- engine RPM correlating to normal usage (not under stress)
local MAX_SPEED = 125 -- The rotational velocity a vehicle's wheels would be reaching for the highest pitched engine sounds

-- Tire Effect Parameters
local SLIDE_THRESHOLD = 0.6			-- The threshold at which skid-marks appear
local SLIDE_DEBOUNCE = 0.2			-- The minimum time to display skid-marks for
local SLIDE_MARK_OFFSET = 0.02		-- The studs to offset the skid-marks from the ground by

local defaultAudioData = { -- what to use if no custom sounds are provided
	{
		RPM = BASE_RPM,
		MinRPM = 0,
		MaxRPM = BASE_RPM + RPM_CROSSOVER,
		Volume = 3,
		PitchModification = 1,
		SoundID = "rbxassetid://5257533692",
	},
	{
		RPM = 3000,
		MinRPM = BASE_RPM + RPM_CROSSOVER,
		MaxRPM = 3500,
		Volume = 1,
		PitchModification = 1,
		SoundID = "rbxassetid://5257534962"--"rbxasset://sounds/Medium.ogg",
	},
	{
		RPM = 4000,
		MinRPM = 3500,
		MaxRPM = 9e9,
		Volume = 1,
		PitchModification = 1,
		SoundID = "rbxassetid://5257536258"--"rbxasset://sounds/High.ogg",
	},
}

local audio = {}

local Effects = {}
Effects.__index = Effects

function Effects.new(chassis, effectsFolder, topModel)
	local self = setmetatable({},Effects)

	self.ignore = topModel

	self.base = chassis:FindFirstChild("FloorPanel")
	self.attachmentContainer = self.base

	local suspensions = {}
	table.insert(suspensions, chassis:FindFirstChild("SuspensionFL"))
	table.insert(suspensions, chassis:FindFirstChild("SuspensionFR"))
	table.insert(suspensions, chassis:FindFirstChild("SuspensionRL"))
	table.insert(suspensions, chassis:FindFirstChild("SuspensionRR"))

	local function createSound(soundId)
		local sound = Instance.new("Sound")
		sound.Volume = 0
		sound.Looped = true
		sound.SoundId = soundId
		sound.Parent = topModel.PrimaryPart
		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end
		return sound
	end
	
	local function generateAudioInfo(soundId, baseRPM, minRPM, maxRPM, volume, pitchMod)
		return {
			RPM = baseRPM,
			MinRPM = minRPM,
			MaxRPM = maxRPM,
			Volume = volume,
			PitchModification = pitchMod,
			SoundID = soundId,
			Sound = createSound(soundId)
		}
	end
	
	local function createSounds(audioInfo)
		local effects = topModel:FindFirstChild("Effects")
		local engineLowSound
		local engineBaseSound
		local engineHighSound 
		if effects then
			-- idle sound as baseline, Engine sound as next layer, and if there's another sound present, use that as the next higher pitched sound
			engineLowSound = effects:FindFirstChild("Idle")
			engineBaseSound = effects:FindFirstChild("Engine")
			engineHighSound = effects:FindFirstChild("EngineHigh")
		end
		
		if not audio[1] then
			if engineLowSound then
				audio[1] = generateAudioInfo(engineLowSound.SoundId, BASE_RPM, 0, BASE_RPM+RPM_CROSSOVER, engineLowSound.Volume, engineLowSound.PlaybackSpeed)
			else
				audio[1] = generateAudioInfo(defaultAudioData[1].SoundID, BASE_RPM, 0, BASE_RPM+RPM_CROSSOVER, defaultAudioData[1].Volume, defaultAudioData[1].PitchModification)
			end
		end
		
		if not audio[2] then
			if engineBaseSound then
				audio[2] = generateAudioInfo(engineBaseSound.SoundId, 3000, BASE_RPM+RPM_CROSSOVER, 3500, engineBaseSound.Volume, engineBaseSound.PlaybackSpeed)
			else
				audio[2] = generateAudioInfo(defaultAudioData[2].SoundID, 3000, BASE_RPM+RPM_CROSSOVER, 3500, defaultAudioData[2].Volume, defaultAudioData[2].PitchModification)
			end
		end
		
		if not audio[3] then
			if engineHighSound then
				audio[3] = generateAudioInfo(engineHighSound.SoundId, 4000, 3500, 9e9, engineHighSound.Volume, engineHighSound.PlaybackSpeed)
			else
				audio[2].MaxRPM = 9e9
			end
		end
	end

	local function createWheelData(wheelPart)
		local attCenter = Instance.new("Attachment")
		attCenter.Name = "EffectsCenter"
		attCenter.Parent = self.attachmentContainer

		local attRight = Instance.new("Attachment")
		attRight.Name = "EffectsR"
		attRight.Parent = self.attachmentContainer

		local attLeft = Instance.new("Attachment")
		attLeft.Name = "EffectsL"
		attLeft.Parent = self.attachmentContainer

		local trail = nil
		local trailPrototype = effectsFolder:FindFirstChild("TireTrail")
		if trailPrototype and trailPrototype:IsA("Trail") then
			trail = trailPrototype:Clone()
			trail.Parent = self.attachmentContainer
			trail.Attachment0 = attLeft
			trail.Attachment1 = attRight
		end
		
		local wheelData = {
			wheel = wheelPart,
			attCenter = attCenter,
			attRight = attRight,
			attLeft = attLeft,
			trail = trail,
			lastContact = 0,
		}
		
		return wheelData
	end

	self.wheels = {}
	for _, suspension in ipairs(suspensions) do
		local wheelPart = suspension:FindFirstChild("Wheel")
		if wheelPart then
			table.insert(self.wheels, createWheelData(wheelPart))
		end
	end
	
	if #self.wheels == 0 then -- probably two-wheeler
		local children = chassis:GetChildren()
		for i = 1, #children do
			if children[i].Name == "Wheel" then
				table.insert(self.wheels, createWheelData(children[i]))
			end
		end
	end
	
	-- connect remote event
	local vehicleSeat = Vehicle:WaitForChild("Chassis"):WaitForChild("VehicleSeat")
	SetThrottleConnection = SetThrottleRemote.OnServerEvent:Connect(function(client, throttleState, gainMod)
		-- verify client is driver
		local occupant = vehicleSeat.Occupant
		if occupant.Parent == client.Character then
			self:SetThrottleEnabled(throttleState, gainMod)
		end
	end)
	
	-- create sounds based off of what we have in the effects folder
	createSounds()
	
	local ignitionSound = effectsFolder:FindFirstChild("EngineStart")
	if ignitionSound then
		self.ignitionMaxVolume = ignitionSound.Volume
		self.ignitionSound = ignitionSound:Clone()
		self.ignitionSound.Parent = chassis.PrimaryPart
	end
	
	local stopSound = effectsFolder:FindFirstChild("EngineStop")
	if stopSound then
		self.stopSound = stopSound:Clone()
		self.stopSound.Parent = chassis.PrimaryPart
	end
	
	local accelerateSound = effectsFolder:FindFirstChild("Accelerate")
	if accelerateSound then
		self.accelerateSoundVolume = accelerateSound.Volume
		self.accelerateSoundWeight = 0
		self.accelerateSound = accelerateSound:Clone()
		self.accelerateSound.Parent = chassis.PrimaryPart
	end
	self.engineSoundWeight = 1

	self.igniting = false
	self.throttle = 0
	self.slideSpeed = 0
	self.disableTime = 0
	self.active = false

	return self
end

function Effects:Enable()
	self.active = true
	if #self.wheels > 0 then
		self.disableTime = 0
		if self.heartbeatConn then
			self.heartbeatConn:Disconnect()
		end
		self.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			self:OnHeartbeat(dt)
		end)
		
		if self.ignitionSound and not self.igniting then
			self.igniting = true
			coroutine.wrap(function()
				if EngineSoundEnabled then
					self.ignitionSound.Volume = self.ignitionMaxVolume
					self.ignitionSound:Play()
					repeat
						RunService.Stepped:Wait()
					until not (self.igniting and self.ignitionSound.IsPlaying)
				end
				self.igniting = false
			end)()
		end
		
		for i = 1, #audio do
			audio[i].Sound:Play()
		end
	end
end

function Effects:DisableInternal()
	self.active = false
	if self.heartbeatConn then
		self.heartbeatConn:Disconnect()
	end
	self.heartbeatConn = nil

	-- Disable sounds
	for i = 1, #audio do
		if audio[i].Sound then
			audio[i].Sound:Stop()
		end
	end
	
	if self.stopSound then self.stopSound:Play() end

	if #self.wheels > 0 then
		for _,wheelData in ipairs(self.wheels) do
			wheelData.trail.Enabled = false
		end
	end

	self.disableTime = 0
end

function Effects:Disable()
	-- Request effects to be disabled soon (upon driver exiting vehicle)
	if self.disableTime == 0 then
		self.disableTime = tick() + EFFECTS_GRACE_PERIOD
	end
end

function Effects:SetThrottleEnabled(toggle, gainMod)
	if not EngineSoundEnabled then return end
	
	-- sets whether RPM is building up or not for the engine. Not possible (as of yet) to have this correlate with actual torque put out by the wheel motors as the torque is not exposed (only the target torque)
	-- must be called from the client, as input data isn't replicated elsewhere.
	
	gainMod = gainMod or 1
	gainModifier = gainMod
	
	if RunService:IsClient() then
		-- keep track of throttle state as to not spam the server with events
		if toggle ~= throttleEnabled or tick()-lastThrottleUpdate > 1/THROTTLE_UPDATE_RATE then
			lastThrottleUpdate = tick()
			SetThrottleRemote:FireServer(toggle, gainMod)
			throttleEnabled = toggle
		end	
	else
		if self.active then
			throttleEnabled = toggle
		else
			throttleEnabled = false
		end
	end
end

function Effects:OnHeartbeat(dt)
	if self.ignore.Parent == nil then
		return
	end
	
	if self.disableTime > 0 and tick() > self.disableTime then
		self:DisableInternal()
		return
	end
	
	local hasGroundContact = true -- assume ground contact 
	
	if TireTrailEnabled then
		for _, wheelData in ipairs(self.wheels) do
			
			local wheel = wheelData.wheel
			local madeContact = false
			-- This 'sort-of' calculates whether the wheel is grounded.
			for _, basePart in ipairs(wheel:GetTouchingParts()) do
				if not basePart:IsDescendantOf(self.ignore) then
					wheelData.lastContact = tick()
					madeContact = true
					break
				end
			end
			
			hasGroundContact = madeContact

			if tick() - wheelData.lastContact <= SLIDE_DEBOUNCE then

				local radius = wheel.Size.Y / 2
				local width = wheel.Size.X / 2
				
				local wheelLeftCFrame = wheel.CFrame * CFrame.new(width, 0, 0) - Vector3.new(0, radius - SLIDE_MARK_OFFSET, 0)
				local wheelRightCFrame = wheel.CFrame * CFrame.new(-width, 0, 0) - Vector3.new(0, radius - SLIDE_MARK_OFFSET, 0)
				
				wheelData.attRight.WorldPosition = wheelRightCFrame.p
				wheelData.attLeft.WorldPosition =  wheelLeftCFrame.p
				
				-- RotationalVelocity: Speed at the edge of the wheel from it rotating
				-- HorizontalVelocity: Speed the wheel is actually moving at
				-- SlideSpeed: The speed at which the wheel is sliding relative to its rotational velocity
				local rotationalVelocity = radius * (self.base.CFrame:VectorToObjectSpace(wheel.RotVelocity)).X
				local horizontalVelocity = self.base.CFrame:VectorToObjectSpace(wheel.Velocity).Z
				local slideSpeed = math.abs(rotationalVelocity - horizontalVelocity)
				
				local slipValue = slideSpeed / math.abs(rotationalVelocity)
				local sliding = slipValue >= SLIDE_THRESHOLD

				wheelData.trail.Enabled = sliding

			else
				wheelData.trail.Enabled = false
			end
			
		end
	end
	
	--Engine Sounds
	if EngineSoundEnabled then
		local constraints = self.ignore.Constraints:GetChildren()
		local main = self.ignore.PrimaryPart
		if not main then return end -- car probably fell off the map
		
		local function getAvgAngularSpeed() 
			-- use the average angular speed of the wheels to guess how much torque is being generated by the engine
			-- note: cannot get actual motor torque as a limitation of the roblox engine, thus this can't be completely accurate
			-- when car is going uphill, there will be a noticeable difference.
			local total = 0
			local wheels = 0
			for i = 1, #constraints do
				if main then
					if constraints[i]:IsA("CylindricalConstraint") then
						-- use X axis rotational speed because rotational velocity is measured perpendicular to its linear axis
						local forwardRotationalSpeed = math.abs(main.CFrame:vectorToObjectSpace(constraints[i].Attachment1.Parent.RotVelocity).X)
						wheels = wheels+1
						total = total+forwardRotationalSpeed
					end
				end
			end
			return total/wheels
		end

		if throttleEnabled and self.igniting then
			self.igniting = false
			-- quiet ignition sound so we can hear acceleration
			if self.ignitionSound then
				local tween = TweenService:Create(self.ignitionSound, engineStartTween, {Volume = 1})
				tween:Play()
			end
		end
		
		-- try to figure out a good weight for accleration sound
		local weight = 1
		if throttleEnabled then
			--print("enginePower", enginePower)
			if enginePower <= BASE_RPM+100 then
				if not self.accelerateSound.Playing then
					-- TODO: Determine why/how this is getting stuck on :RS
					-- self.accelerateSound:Play()
				end
			end

			if self.accelerateSound.Playing then
				local baseThreshold = BASE_RPM+400
				local blendThreshold = BASE_RPM+600

				if enginePower <= baseThreshold then
					weight = 0
					self.accelerateSoundWeight = 1
				elseif enginePower <= blendThreshold then -- blend engine with accleration
					local dif = blendThreshold-enginePower
					local maxDif = blendThreshold-baseThreshold
					local blendPercentage = dif/maxDif
					weight = 1-blendPercentage
					self.accelerateSoundWeight = blendPercentage
					--print(weight, self.accelerateSoundWeight)
				else -- end sound
					self.accelerateSoundWeight = 0
					if self.accelerateSound.Playing then
						self.accelerateSound:Stop()
					end
				end
			end
		end

		self.accelerateSound.Volume = self.accelerateSoundVolume*self.accelerateSoundWeight
		self.engineSoundWeight = weight

		local targetAngularSpeed = math.abs(self.ignore.Constraints.MotorFL.AngularVelocity)
		local currentAngularSpeed = getAvgAngularSpeed()
		
		local forwardVector = main.CFrame.LookVector
		local forwardFlatVector = Vector3.new(forwardVector.x, 0, forwardVector.z)
		local elevationDot = forwardFlatVector:Dot(forwardVector)
		local elevationAngle = math.acos(math.clamp(elevationDot, -1, 1)) -- not sure how that went over 1
		
		-- add to the engine power by a factor of the sine of the elevation angle to make going uphill require more power
		local movingAgainstGravity = main.Velocity.Y > 0
		local gravityEffect = movingAgainstGravity and math.sin(2*math.min(elevationAngle,math.pi/4)) or 0
		
		local accelerating = throttleEnabled
		
		local maxDif = MAX_RPM-MAX_IDEAL_RPM
		
		local baseRPMFromThrottle = (accelerating and BASE_RPM+(BASE_RPM*math.min(currentAngularSpeed/MAX_SPEED,1.5) + gravityEffect*maxDif) or BASE_RPM) 
		local maxRPM = math.clamp(MAX_IDEAL_RPM + gravityEffect*maxDif, MAX_IDEAL_RPM, MAX_RPM)
		local targetRPM = accelerating and baseRPMFromThrottle + gainModifier*(maxRPM-baseRPMFromThrottle) or baseRPMFromThrottle

		local dif = targetRPM-enginePower

		local inclineGainEffect = gravityEffect*ENGINE_GAIN_ACCEL*3
		local currentRPM = enginePower + dif*(accelerating and ENGINE_GAIN_ACCEL+inclineGainEffect or ENGINE_GAIN_DECCEL)*dt
		enginePower = math.clamp(currentRPM, math.min(BASE_RPM,maxRPM), maxRPM)

		for i = 1, #audio do
			
			local audioInfo = audio[i]
			local sound = audioInfo.Sound
			
			local baseRPM, minRPM, maxRPM = audioInfo.RPM, audioInfo.MinRPM, audioInfo.MaxRPM
			local volume
			
			if currentRPM >= minRPM and currentRPM <= maxRPM then
				volume = 1
			elseif currentRPM < minRPM then
				volume = 1 - ((minRPM - currentRPM) / (audioInfo.Crossover or RPM_CROSSOVER))
			else
				volume = 1 - ((currentRPM - maxRPM) / (audioInfo.Crossover or RPM_CROSSOVER))
			end
			volume = volume*self.engineSoundWeight
			
			local playbackSpeed = (currentRPM / baseRPM) * audioInfo.PitchModification
			
			sound.Volume = volume*audioInfo.Volume
			sound.PlaybackSpeed = playbackSpeed
		end
	end
end

return Effects
