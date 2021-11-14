local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")

local PlayerPoints = game:GetService("DataStoreService"):GetDataStore("PlayerPoints")
local Upgrades = game:GetService("DataStoreService"):GetDataStore("Upgrades")

local LevelChangedEvent = ReplicatedStorage:WaitForChild("LevelChangedEvent")
local ZombieKilledEvent = ReplicatedStorage:WaitForChild("ZombieKilledEvent")
local SuperZombieKilledEvent = ReplicatedStorage:WaitForChild("SuperZombieKilledEvent")
local SoldierKilledEvent = ReplicatedStorage:WaitForChild("SoldierKilledEvent")
local WindowShatteredEvent = ReplicatedStorage:WaitForChild("WindowShatteredEvent")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local STARTING_POINTS = 0
local STARTING_LEVEL = 1

local ZOMBIE_KILLED_POINTS = 1
local SUPER_ZOMBIE_KILLED_POINTS = 5
local SOLDIER_KILLED_POINTS = -10
local WINDOW_SHATTERED_POINTS = 1

game.Players.CharacterAutoLoads = false

local function addWeapon(player, weapon)
	if player.Character and not player.Character:FindFirstChild(weapon.Name)  then
		if not player.Backpack:FindFirstChild(weapon.Name) then
			local clone = weapon:Clone()
			clone.Parent = player.Backpack
			if workspace.Weapons:FindFirstChild(weapon.Name) then
				workspace.Weapons[weapon.Name].ProximityPromptPart.ProximityPrompt.Enabled = true
			end
		end
	end
end

local function onPointsChanged(player, newPointsValue, level)
	if newPointsValue < 20 then
		level.Value = 1
	end
	if newPointsValue >= 20 then
		if level.Value < 2 then
			level.Value = 2
		end
	end
	if newPointsValue >= 40 then
		if level.Value < 3 then
			level.Value = 3
		end
	end
	if newPointsValue >= 80 then
		if level.Value < 4 then
			level.Value = 4
		end
	end
	if newPointsValue >= 160 then
		if level.Value < 5 then
			level.Value = 5
		end
	end
end

local function onLevelChanged(player, newLevelValue)
	if newLevelValue >= 2 then
		local weapon = ReplicatedStorage.Weapons["Grenade Launcher"]
		addWeapon(player, weapon)
	end
	if newLevelValue >= 3 then
		local weapon = ReplicatedStorage.Weapons["Automatic Rifle"]
		addWeapon(player, weapon)
	end
	if newLevelValue >= 4 then
		local weapon = ReplicatedStorage.Weapons["Rocket Launcher"]
		addWeapon(player, weapon)
	end
	if newLevelValue >= 5 then
		local weapon = ReplicatedStorage.Weapons["Railgun"]
		addWeapon(player, weapon)
	end
end

local function setupLeaderboard(player)
	local folder = Instance.new("Folder")
	local points = Instance.new("IntValue")
	local level = Instance.new("IntValue")
	points.Value = STARTING_POINTS
	level.Value = STARTING_LEVEL
	folder.Name = "leaderstats"
	folder.Parent = player
	points.Name = "Points"
	points.Changed:Connect(function(newPointsValue)
		onPointsChanged(player, newPointsValue, level)
	end)
	points.Parent = folder
	level.Name = "Level"
	level.Changed:Connect(function(newLevelValue)
		onLevelChanged(player, newLevelValue)
	end)
	level.Parent = folder
	local success, savedPlayerPoints = pcall(function()
		return PlayerPoints:GetAsync(player.UserId)
	end)
	if success then
		if savedPlayerPoints then
			points.Value = savedPlayerPoints
		else
			points.Value = STARTING_POINTS
		end
	end
end

local function setupWeaponUpgrades(player)
	print("setupWeaponUpgrades")
	local success, savedUpgrades = pcall(function()
		return Upgrades:GetAsync(player.UserId)
	end)
	if success then
		WeaponUpgrades.processWeaponUpgrades(player, savedUpgrades)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	print("PlayerAdded")
	local respawn = false
	player.CharacterAdded:Connect(function(character)
		print("CharacterAdded")
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			print("humanoid died")
			respawn = true
			player:LoadCharacter()
		end)
		if respawn then
			print("respawn")
			onLevelChanged(player, player.leaderstats.Level.Value)
			WeaponUpgrades.processWeaponUpgrades(player, WeaponUpgrades.getUpgrades())
		end
	end)
	player:LoadCharacter()
	setupLeaderboard(player)
	setupWeaponUpgrades(player)
end)

local function saveLeaderboard(player)
	print("game.Players.PlayerRemoving saveLeaderboard")
	local success, errorMessage = pcall(function()
		PlayerPoints:SetAsync(player.UserId, player.leaderstats.Points.Value)
	end)
	if not success then
		warn(errorMessage)
	end
end

local function saveUpgrades(player)
	print("game.Players.PlayerRemoving saveUpgrades count", #WeaponUpgrades.getUpgrades())
	local success, errorMessage = pcall(function()
		Upgrades:SetAsync(player.UserId, WeaponUpgrades.getUpgrades())
	end)
	if not success then
		warn(errorMessage)
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	saveUpgrades(player)
	saveLeaderboard(player)
	print("Finished Player Removing")
end)

ZombieKilledEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += ZOMBIE_KILLED_POINTS
end)

SuperZombieKilledEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += SUPER_ZOMBIE_KILLED_POINTS
end)

SoldierKilledEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += SOLDIER_KILLED_POINTS
end)

WindowShatteredEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += WINDOW_SHATTERED_POINTS
end)
