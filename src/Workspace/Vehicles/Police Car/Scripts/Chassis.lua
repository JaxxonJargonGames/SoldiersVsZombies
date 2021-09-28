local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local PackagedScripts = script.Parent
local PackagedVehicle = PackagedScripts.Parent

local Effects = require(PackagedScripts:WaitForChild("Effects"))

local constraints = PackagedVehicle:WaitForChild("Constraints")

local mphConversion = 0.6263 -- using a 28cm = 1stud conversion rate

--[[ Chassis Variables ]]--
local VehicleParameters = { -- These are default values in the case the package structure is broken
	MaxSpeed = 75/mphConversion,
	ReverseSpeed = 45/mphConversion,
	DrivingTorque = 30000,
	BrakingTorque = 70000,
	StrutSpringStiffnessFront = 28000,
	StrutSpringDampingFront = 1430,
	StrutSpringStiffnessRear = 27000,
	StrutSpringDampingRear = 1400,
	TorsionSpringStiffness = 20000,
	TorsionSpringDamping = 150,
	MaxSteer = 0.55,
	WheelFriction = 2
}

local Chassis = nil
local LimitSteerAtHighVel = true
-- Limits the amount you can steer based on velocity. Helpful for keyboard/non-analog steer inputs
local SteerLimit = 0.2 -- Max amount the steering float (-1 to 1) will be limited by if limitSteerAtHighVel is true

local DoGravityAdjust = true -- Adjust chassis values based on the current gravity setting.
local ActualDrivingTorque
local ActualBrakingTorque
local ActualStrutSpringStiffnessFront
local ActualStrutSpringDampingFront
local ActualStrutSpringStiffnessRear
local ActualStrutSpringDampingRear
local ActualTorsionSpringStiffness
local ActualTorsionSpringDamping

-- Adjust torque and springs based on gravity to keep the car drivable
local function gravityAdjust()
	local defaultGravity = 196.2
	local actualGravity = Workspace.Gravity
	local gravityChange = actualGravity / defaultGravity
	-- Speed is adjusted so that the height of jumps is preserved
	-- So maxSpeed is scaled proportionally to the sqrt of gravity
	ActualDrivingTorque = VehicleParameters.DrivingTorque * gravityChange
	ActualBrakingTorque = VehicleParameters.BrakingTorque * gravityChange

	ActualStrutSpringStiffnessFront = VehicleParameters.StrutSpringStiffnessFront * gravityChange
	ActualStrutSpringDampingFront = VehicleParameters.StrutSpringDampingFront * math.sqrt( gravityChange )
	ActualStrutSpringStiffnessRear = VehicleParameters.StrutSpringStiffnessRear * gravityChange
	ActualStrutSpringDampingRear = VehicleParameters.StrutSpringDampingRear * math.sqrt( gravityChange )

	ActualTorsionSpringStiffness = VehicleParameters.TorsionSpringStiffness * gravityChange
	ActualTorsionSpringDamping = VehicleParameters.TorsionSpringDamping * math.sqrt( gravityChange )
end

local function convertProperty(property, value)
	if property == "MaxSpeed" or property == "ReverseSpeed" then
		-- convert to studs/sec
		return value / mphConversion
	end

	return value
end

local changedAttributesConnection = nil
local function updateFromConfiguration()
	local obj = script.Parent.Parent

	for property, value in pairs(VehicleParameters) do
		local configProp = obj:GetAttribute(property)

		if configProp then
			VehicleParameters[property] = convertProperty(property, configProp)
		end
	end

	-- Handle dynamic changes
	changedAttributesConnection = obj.AttributeChanged:Connect(function(property)
		-- Only handle attributes we're interested in
		if VehicleParameters[property] == nil then
			return
		end

		local value = obj:GetAttribute(property)
		VehicleParameters[property] = convertProperty(property, value)

		if DoGravityAdjust then
			gravityAdjust()
		end

		if Chassis then
			Chassis.InitializeDrivingValues() -- reinitialize chassis so that changes are reflected in the rig
		end
	end)
end

updateFromConfiguration()

if DoGravityAdjust then
	gravityAdjust()
end

workspace.Changed:Connect(function(prop)
	if prop == "Gravity" then
		if DoGravityAdjust then
			gravityAdjust()
		end
		if Chassis then
			Chassis.InitializeDrivingValues() -- reinitialize chassis so that changes are reflected in the rig
		end
	end
end)

local Motors
local SteeringPrismatic
local RedressMount

--[[ Private Functions ]]--
local function getVehicleMotors()
	local motors = {}
	for _, c in pairs(constraints:GetChildren()) do
		if c:IsA("CylindricalConstraint") then
			table.insert(motors, c)
        end
    end
	return motors
end

local function getSprings(springType)
	local springs = {}
	local trailer = PackagedVehicle:FindFirstChild("Trailer")
	
	local function search(children)
		local searchStrutSpring = "StrutSpring"
		local searchFrontSpring = "StrutSpringF"
		local searchTorsionSpring = "TorsionBarSpring"
		for _, c in pairs(children) do
			if c:IsA("SpringConstraint") then
				if springType == "StrutFront" then
					if string.find(c.Name, searchFrontSpring) then
						table.insert(springs, c)
					end
				elseif springType == "StrutRear" then
					if (not string.find(c.Name, searchFrontSpring)) and string.find(c.Name, searchStrutSpring) then
						table.insert(springs, c) -- we have option of Mid and Rear for these
					end
				elseif springType == "TorsionBar" then
					if string.find(c.Name, searchTorsionSpring) then
						table.insert(springs, c)
					end
				end
			end
		end
	end

	search(constraints:GetChildren())
	if trailer then
		search(trailer.Constraints:GetChildren())
	end
	
	return springs
end

local function getMotorVelocity(motor)
	return motor.Attachment1.WorldAxis:Dot( motor.Attachment1.Parent.RotVelocity )
end

local function adjustSpring( spring, stiffness, damping )
	spring.Stiffness = stiffness
	spring.Damping = damping
end

local function setMotorTorque(torque)
	for _, motor in pairs(Motors) do		
		motor.MotorMaxTorque = torque
	end
end

local function setMotorTorqueDamped(torque, velocityDirection, accelDirection)
	for _, motor in pairs(Motors) do
		if VehicleParameters.MaxSpeed == 0 then 
			motor.MotorMaxTorque = 0
		else
			local maxSpeed = VehicleParameters.MaxSpeed
			if accelDirection < 0 and velocityDirection < 0 then
				maxSpeed = VehicleParameters.ReverseSpeed
			end
			
			local r = math.abs(Chassis.driverSeat.Velocity.Magnitude / maxSpeed)
			motor.MotorMaxTorque = math.exp( -3 * r * r ) * torque
		end
	end
end

local function setMotorMaxAcceleration(acceleration)
	for _, motor in pairs(Motors) do
		motor.MotorMaxAngularAcceleration = acceleration
	end
end

--[[ Module Functions ]]--
Chassis = {}

Chassis.root = PackagedVehicle:FindFirstChild("Chassis") --the root of the Chassis model
Chassis.driverSeat = Chassis.root:FindFirstChildOfClass("VehicleSeat")
Chassis.passengerSeats = {
		Chassis.root:FindFirstChild("SeatFR"),
		Chassis.root:FindFirstChild("SeatRL"),
		Chassis.root:FindFirstChild("SeatRR")
}

local randomSuspension = Chassis.root:FindFirstChild("SuspensionFL")
local wheelRadius = randomSuspension.Wheel.Size.y/2
Chassis.driverSeat.MaxSpeed = VehicleParameters.MaxSpeed * wheelRadius

function Chassis.InitializeDrivingValues()
	-- Constraint tables always ordered FL, FR, RL, RR
	Motors = getVehicleMotors()
	
	local strutSpringsFront = getSprings("StrutFront")
	local strutSpringsRear = getSprings("StrutRear")
	local torsionSprings = getSprings("TorsionBar")

	RedressMount = Chassis.root:WaitForChild("RedressMount")
	
	SteeringPrismatic = constraints:FindFirstChild("SteeringPrismatic")
	SteeringPrismatic.UpperLimit = VehicleParameters.MaxSteer
	SteeringPrismatic.LowerLimit = -VehicleParameters.MaxSteer

	for _,s in pairs(strutSpringsFront) do
		adjustSpring(s, ActualStrutSpringStiffnessFront, ActualStrutSpringDampingFront)
	end
	for _,s in pairs(strutSpringsRear) do
		adjustSpring(s, ActualStrutSpringStiffnessRear, ActualStrutSpringDampingRear)
	end
	for _,s in pairs(torsionSprings) do
		adjustSpring(s, ActualTorsionSpringStiffness, ActualTorsionSpringDamping)
	end
	
	local chassisChildren = Chassis.root:GetChildren()
	for i = 1, #chassisChildren do
		local model = chassisChildren[i]
		if model:IsA("Model") then
			local wheel = model:FindFirstChild("Wheel")
			if wheel then
				local old = wheel.CustomPhysicalProperties
				local new = PhysicalProperties.new(old.Density, VehicleParameters.WheelFriction, old.Elasticity, old.FrictionWeight, old.ElasticityWeight)
				wheel.CustomPhysicalProperties = new
			end
		end
	end

	setMotorTorque(10000)
end

function Chassis.GetDriverSeat()
	return Chassis.driverSeat
end

function Chassis.GetPassengerSeats()
	return Chassis.passengerSeats
end

function Chassis.GetBase()
	return Chassis.root.PrimaryPart or Chassis.root:FindFirstChild("FloorPanel")
end

--Set target angular velocity for all 4 wheels.
function Chassis.SetMotorVelocity(vel)
	for _, motor in pairs(Motors) do
		motor.AngularVelocity = vel
	end
end

--Get average angular velocity from all 4 wheels
function Chassis.GetAverageVelocity()
	local t = 0
	for _, motor in pairs(Motors) do
		t = t + getMotorVelocity(motor)
	end
	return t * (1/#Motors)
end

--Set braking torque and stop back 2 wheels
function Chassis.EnableHandbrake()
	setMotorMaxAcceleration(math.huge)
	Motors[3].MotorMaxTorque = ActualBrakingTorque
	Motors[4].MotorMaxTorque = ActualBrakingTorque
	Motors[3].AngularVelocity = 0
	Motors[4].AngularVelocity = 0
end

--Set target steering position based on current velocity
function Chassis.UpdateSteering(steer, currentVel)
	local baseSteer = steer
	local targetSteer = 0
	
	local vehicleSeat = Chassis.GetDriverSeat()
	local maxSpeed = VehicleParameters.MaxSpeed
	local maxSteer = VehicleParameters.MaxSteer
	
	local currentVelocity = vehicleSeat.Velocity
	
	if LimitSteerAtHighVel then
		local c = SteerLimit * (math.abs(currentVel)/VehicleParameters.MaxSpeed) + 1
		--decrease steer value as speed increases to prevent tipping (handbrake cancels this)
		steer = steer/c
	end
	SteeringPrismatic.TargetPosition = steer * steer * steer * maxSteer
end

function Chassis.UpdateThrottle(currentSpeed, throttle)
	local targetVel = 0
	local effectsThrottleState = false
	local gainModifier = 0
	
	if math.abs(throttle) < 0.1 then
		-- Idling
		setMotorMaxAcceleration(math.huge)
		setMotorTorque(2000)
	elseif math.sign(throttle * currentSpeed) > 0 or math.abs(currentSpeed) < 0.5 then
		setMotorMaxAcceleration(math.huge)
		
		local velocity = Chassis.driverSeat.Velocity
		local velocityVector = velocity.Unit
		local directionalVector = Chassis.driverSeat.CFrame.lookVector
		local dotProd = velocityVector:Dot(directionalVector) -- Dot product is a measure of how similar two vectors are; if they're facing the same direction, it is 1, if they are facing opposite directions, it is -1, if perpendicular, it is 0
		
		setMotorTorqueDamped(ActualDrivingTorque * throttle * throttle, dotProd, math.sign(throttle))
		-- Arbitrary large number
		local movingBackwards = dotProd < 0
		local acceleratingBackwards = throttle < 0
		local useReverse = (movingBackwards and acceleratingBackwards)
		
		local maxSpeed = (useReverse and VehicleParameters.ReverseSpeed or VehicleParameters.MaxSpeed)
		targetVel = math.sign(throttle) * maxSpeed
		
		-- if we are approaching max speed, we should take that as an indication of throttling down, even if not from input
		local maxAccelSpeed = targetVel
		local speedPercent = ((maxAccelSpeed-currentSpeed)/maxAccelSpeed) -- 0 if max speed, 1 if stopped
		
		-- lets say we start throttling down after reaching 75% of max speed, then linearly drop to 0
		local function quad(x)
			return math.sign(x)*(x^2)
		end
		
		
		local r = math.abs(velocity.Magnitude / maxSpeed*2.5) -- adding a bit to the max speed so that it sounds better (always trying to rev engines)
		local desiredRPM = math.exp(-3*r*r)
		
		
		gainModifier = desiredRPM
		
		if gainModifier > 0 then
			effectsThrottleState = true
		end
	else
		-- Braking
		setMotorMaxAcceleration(100)
		setMotorTorque(ActualBrakingTorque * throttle * throttle)
		targetVel = math.sign(throttle) * 500
	end
	
	Chassis.SetMotorVelocity(targetVel)
	
	Effects:SetThrottleEnabled(effectsThrottleState, gainModifier)

end

local redressingState = false
local targetAttachment
function Chassis.Redress()
	if redressingState then
		return
	end
	redressingState = true
	local p = Chassis.driverSeat.CFrame.Position + Vector3.new( 0,10,0 )
	local xc = Chassis.driverSeat.CFrame.RightVector
	xc = Vector3.new(xc.x,0,xc.z)
	xc = xc.Unit
	local yc = Vector3.new(0,1,0)

	if not targetAttachment then
		targetAttachment = RedressMount.RedressTarget
	end

	targetAttachment.Parent = Workspace.Terrain
	targetAttachment.Position = p
	targetAttachment.Axis = xc
	targetAttachment.SecondaryAxis = yc
	RedressMount.RedressOrientation.Enabled = true
	RedressMount.RedressPosition.Enabled = true
	wait(1.5)
	RedressMount.RedressOrientation.Enabled = false
	RedressMount.RedressPosition.Enabled = false
	targetAttachment.Parent = RedressMount
	wait(2)
	redressingState = false
end

function Chassis.Reset() --Reset user inputs and redress (For when a player exits the vehicle)
	Chassis.UpdateThrottle(1, 1) --Values must  be changed to replicate to client.
	Chassis.UpdateSteering(1, 0) --i.e. setting vel to 0 when it is 0 wont update to clients
	Chassis.EnableHandbrake()
	setMotorTorque(ActualBrakingTorque)
	Chassis.SetMotorVelocity(0)
	Chassis.UpdateSteering(0, 0)
	RedressMount.RedressOrientation.Enabled = true
	RedressMount.RedressPosition.Enabled = true
	RedressMount.RedressOrientation.Enabled = false
	RedressMount.RedressPosition.Enabled = false
	redressingState = false
end

return Chassis
