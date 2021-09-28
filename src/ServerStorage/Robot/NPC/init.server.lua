--[[
	Written by meow_pizza
	Last modified: 2019-03-30
]]

local Ragdoll = require(script:WaitForChild("Ragdoll"))
local Maid = require(script:WaitForChild("Maid"))

local function getValueFromConfig(name)
	local configuration = script.Parent:WaitForChild("Configuration")
	local valueObject = configuration and configuration:FindFirstChild(name)
	return valueObject and valueObject.Value
end

--[[
	Configuration
]]

local PATROL_ENABLED = getValueFromConfig("PatrolEnabled")
local PATROL_RADIUS = getValueFromConfig("PatrolRadius")
local DESTROY_ON_DEATH = getValueFromConfig("DestroyOnDeath")
local RAGDOLL_ENABLED = getValueFromConfig("RagdollEnabled")

local DEATH_DESTROY_DELAY = 5
local MIN_REPOSITION_TIME = 2
local MAX_REPOSITION_TIME = 10

--[[
	Instance references
]]

local maid = Maid.new()
maid.instance = script.Parent

maid.humanoid = maid.instance:WaitForChild("Humanoid")
maid.humanoidRootPart = maid.instance:WaitForChild("HumanoidRootPart")

-- Sounds
maid.hurtSound = maid.humanoidRootPart:WaitForChild("Hurt")

local startPosition = maid.instance.PrimaryPart.Position
local previousHealth = maid.humanoid.Health

--[[
	Helper functions
]]

local random = Random.new()

local function getRandomPointInCircle(centerPosition, circleRadius)
	local radius = math.sqrt(random:NextNumber()) * circleRadius
	local angle = random:NextNumber(0, math.pi * 2)
	local x = centerPosition.X + radius * math.cos(angle)
	local z = centerPosition.Z + radius * math.sin(angle)

	local position = Vector3.new(x, centerPosition.Y, z)

	return position
end

--[[
	Implementation
]]

local function isAlive()
	return maid.humanoid.Health > 0 and maid.humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local function moveToRandomPosition()
	local position = getRandomPointInCircle(startPosition, PATROL_RADIUS)
	maid.humanoid:MoveTo(position)

	-- Set any thrusters to look like they moving the robot
	for _, instance in pairs(maid.instance:GetDescendants()) do
		if instance.Name == "ThrusterFire" then
			instance.Speed = NumberRange.new(2)
			instance.SpreadAngle = Vector2.new(5, 5)
		end
	end
end

local function destroy()
	maid:destroy()
end

local function patrol()
	while isAlive() do
		moveToRandomPosition()

		wait(random:NextInteger(MIN_REPOSITION_TIME, MAX_REPOSITION_TIME))
	end
end

--[[
	Event functions
]]

local function died()
	-- Disable any thruster particle emitters
	for _, item in pairs(maid.instance:GetDescendants()) do
		if item.Name == "ThrusterFire" then
			item.Enabled = false
		end
	end

	if RAGDOLL_ENABLED then
		Ragdoll(maid.instance, maid.humanoid)
	end

	if DESTROY_ON_DEATH then
		delay(DEATH_DESTROY_DELAY, function()
			destroy()
		end)
	end
end

local function healthChanged()
	if maid.humanoid.health < previousHealth and not isAlive() then
		-- Move to a new location when damaged
		moveToRandomPosition()

		if not maid.hurtSound.Playing then
			maid.hurtSound:Play()
		end
	end

	previousHealth = maid.humanoid.health
end

local function moveToFinished()
	-- Set any thrusters to an inactive state
	for _, instance in pairs(maid.instance:GetDescendants()) do
		if instance.Name == "ThrusterFire" then
			instance.Speed = NumberRange.new(1)
			instance.SpreadAngle = Vector2.new(10, 10)
		end
	end
end

--[[
	Connections
]]

maid.diedConnection = maid.humanoid.Died:Connect(function()
	died()
end)

maid.healthChangedConnection = maid.humanoid.HealthChanged:Connect(function()
	healthChanged()
end)

maid.humanoid.MoveToFinished:Connect(function()
	moveToFinished()
end)

--[[
	Start
]]

if PATROL_ENABLED then
	coroutine.wrap(function()
		patrol()
	end)()
end
