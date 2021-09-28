--[[
	Written by meow_pizza
	Last modified: 2019-03-30
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

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

-- Attack configuration
local ATTACK_MODE = getValueFromConfig("AttackMode")
local ATTACK_RADIUS = getValueFromConfig("AttackRadius")
local ATTACK_DAMAGE = getValueFromConfig("AttackDamage")
local ATTACK_DELAY = getValueFromConfig("AttackDelay")
local RELOAD_DELAY = getValueFromConfig("ReloadDelay")
local CLIP_CAPACITY = getValueFromConfig("ClipCapacity")

-- Patrol configuration
local PATROL_ENABLED = getValueFromConfig("PatrolEnabled")
local PATROL_RADIUS = getValueFromConfig("PatrolRadius")

-- Etc
local DESTROY_ON_DEATH = getValueFromConfig("DestroyOnDeath")
local RAGDOLL_ENABLED = getValueFromConfig("RagdollEnabled")

local DEATH_DESTROY_DELAY = 5
local PATROL_WALKSPEED = 12
local MIN_REPOSITION_TIME = 2
local MAX_REPOSITION_TIME = 10
local MAX_PARTS_PER_HEARTBEAT = 50
local SEARCH_DELAY = 1

--[[
	Instance references
]]

local maid = Maid.new()
maid.instance = script.Parent

maid.humanoid = maid.instance:WaitForChild("Humanoid")
maid.head = maid.instance:WaitForChild("Head")
maid.humanoidRootPart = maid.instance:FindFirstChild("HumanoidRootPart")
maid.alignOrientation = maid.humanoidRootPart:FindFirstChild("AlignOrientation")

-- Sounds
maid.gunFireSound = maid.instance.Weapon.Handle:FindFirstChild("Fire")

--[[
	State
]]

local startPosition = maid.instance.PrimaryPart.Position

-- Attack state
local attacking = false
local searchingForTargets = false

-- Target finding state
local target = nil
local newTarget = nil
local newTargetDistance = nil
local searchIndex = 0
local timeSearchEnded = 0
local searchRegion = nil
local searchParts = nil

--[[
	Instance configuration
]]

-- Create an Attachment in the terrain so the AlignOrientation is world realtive
local worldAttachment = Instance.new("Attachment")
worldAttachment.Name = "SoldierWorldAttachment"
worldAttachment.Parent = Workspace.Terrain

maid.worldAttachment = worldAttachment
maid.humanoidRootPart.AlignOrientation.Attachment1 = worldAttachment

-- Load and configure the animations
local attackIdleAnimation = maid.humanoid:LoadAnimation(maid.instance.Animations.AttackIdleAnimation)
attackIdleAnimation.Looped = true
attackIdleAnimation.Priority = Enum.AnimationPriority.Action
maid.attackIdleAnimation = attackIdleAnimation

local attackAnimation = maid.humanoid:LoadAnimation(maid.instance.Animations.AttackAnimation)
attackAnimation.Looped = false
attackAnimation.Priority = Enum.AnimationPriority.Action
maid.attackAnimation = attackAnimation

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

local function destroy()
	maid:destroy()
end

local function patrol()
	while isAlive() do
		if not attacking then
			local position = getRandomPointInCircle(startPosition, PATROL_RADIUS)
			maid.humanoid.WalkSpeed = PATROL_WALKSPEED
			maid.humanoid:MoveTo(position)
		end

		wait(random:NextInteger(MIN_REPOSITION_TIME, MAX_REPOSITION_TIME))
	end
end

local function isInstaceAttackable(targetInstance)
	local isAttackable = false
	
	local targetHumanoid = targetInstance and targetInstance.Parent and targetInstance.Parent:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return false
	end

	-- Determine if they are attackable, depening on the attack mode
	local isEnemy = false
	if ATTACK_MODE == 1 then
		-- Attack characters with the SoldierEnemy tag
		if
			CollectionService:HasTag(targetInstance.Parent, "SoldierEnemy") and
			not CollectionService:HasTag(targetInstance.Parent, "SoldierFriend") then
			isEnemy = true
		end
	elseif ATTACK_MODE == 2 then
		-- Attack all humanoids without the SoldierFriend tag
		if not CollectionService:HasTag(targetInstance.Parent, "SoldierFriend") then
			isEnemy = true
		end
	elseif ATTACK_MODE == 3 then
		-- Attack all humanoids
		isEnemy = true
	end

	if isEnemy then
		local distance = (maid.humanoidRootPart.Position - targetInstance.Position).Magnitude
	
		if distance <= ATTACK_RADIUS then
			local ray = Ray.new(
				maid.humanoidRootPart.Position,
				(targetInstance.Parent.HumanoidRootPart.Position - maid.humanoidRootPart.Position).Unit * distance
			)
	
			local part = Workspace:FindPartOnRayWithIgnoreList(ray, {
				targetInstance.Parent, maid.instance,
			}, false, true)
	
			if
				targetInstance ~= maid.instance and
				targetInstance:IsDescendantOf(Workspace) and
				targetHumanoid.Health > 0 and
				targetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead and
				not part
			then
				isAttackable = true
			end
		end		
	end

	return isAttackable
end

local function fireGun()
	-- Do damage to the target
	local targetHunanoid = target.Parent:FindFirstChild("Humanoid")
	targetHunanoid:TakeDamage(ATTACK_DAMAGE)

	-- Play the firing animation
	maid.attackAnimation:Play()

	-- Play the firing sound effect
	maid.gunFireSound:Play()

	-- Muzzle flash
	local firingPositionAttachment = maid.instance.Weapon.Handle.FiringPositionAttachment
	firingPositionAttachment.FireEffect:Emit(10)
	firingPositionAttachment.PointLight.Enabled = true

	wait(0.1)

	firingPositionAttachment.PointLight.Enabled = false
end

local function findTargets()
	-- Do a new search region if we are not already searching through an existing search region
	if not searchingForTargets and tick() - timeSearchEnded >= SEARCH_DELAY then
		searchingForTargets = true

		-- Create a new region
		local centerPosition = maid.humanoidRootPart.Position
		local topCornerPosition = centerPosition + Vector3.new(ATTACK_RADIUS, ATTACK_RADIUS, ATTACK_RADIUS)
		local bottomCornerPosition = centerPosition + Vector3.new(-ATTACK_RADIUS, -ATTACK_RADIUS, -ATTACK_RADIUS)

		searchRegion = Region3.new(bottomCornerPosition, topCornerPosition)
		searchParts = Workspace:FindPartsInRegion3(searchRegion, maid.instance, math.huge)

		newTarget = nil
		newTargetDistance = nil

		-- Reset to defaults
		searchIndex = 1
	end

	if searchingForTargets then
		-- Search through our list of parts and find attackable humanoids
		local checkedParts = 0
		while searchingForTargets and searchIndex <= #searchParts and checkedParts < MAX_PARTS_PER_HEARTBEAT do
			local currentPart = searchParts[searchIndex]
			if currentPart and isInstaceAttackable(currentPart) then
				local character = currentPart.Parent
				local distance = (character.HumanoidRootPart.Position - maid.humanoidRootPart.Position).magnitude

				-- Determine if the charater is the closest
				if not newTargetDistance or distance < newTargetDistance then
					newTarget = character.HumanoidRootPart
					newTargetDistance = distance
				end
			end

			searchIndex = searchIndex + 1

			checkedParts = checkedParts + 1
		end

		if searchIndex >= #searchParts then
			target = newTarget
			searchingForTargets = false
			timeSearchEnded = tick()
		end
	end
end

local function attack()
	attacking = true

	local originalWalkSpeed = maid.humanoid.WalkSpeed
	maid.humanoid.WalkSpeed = 0

	maid.attackIdleAnimation:Play()

	local shotsFired = 0
	while attacking and isInstaceAttackable(target) and isAlive() do
		fireGun()

		shotsFired = (shotsFired + 1) % CLIP_CAPACITY

		if shotsFired == CLIP_CAPACITY - 1 then
			wait(RELOAD_DELAY)
		else
			wait(ATTACK_DELAY)
		end
	end

	maid.humanoid.WalkSpeed = originalWalkSpeed

	maid.attackIdleAnimation:Stop()

	attacking = false
end

--[[
	Event functions
]]

local function onHeartbeat()
	if target then
		-- Point towards the enemy
		maid.alignOrientation.Enabled = true
		maid.worldAttachment.CFrame = CFrame.new(maid.humanoidRootPart.Position, target.Position)
	else
		maid.alignOrientation.Enabled = false
	end

	-- Check if the current target no longer exists or is not attackable
	if not target or not isInstaceAttackable(target) then
		findTargets()
	end
end

local function died()
	target = nil
	attacking = false
	newTarget = nil
	searchParts = nil
	searchingForTargets = false

	maid.heartbeatConnection:Disconnect()

	if RAGDOLL_ENABLED then
		Ragdoll(maid.instance, maid.humanoid)
	end

	if DESTROY_ON_DEATH then
		delay(DEATH_DESTROY_DELAY, function()
			destroy()
		end)
	end
end

--[[
	Connections
]]

maid.heartbeatConnection = RunService.Heartbeat:Connect(function()
	onHeartbeat()
end)

maid.diedConnection = maid.humanoid.Died:Connect(function()
	died()
end)

--[[
	Start
]]

if PATROL_ENABLED then
	coroutine.wrap(function()
		patrol()
	end)()
end

coroutine.wrap(function()
	while isAlive() do
		if target and not attacking and isInstaceAttackable(target) then
			attack()
		end

		wait(1)
	end
end)()
