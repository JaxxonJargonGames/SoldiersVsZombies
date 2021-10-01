local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")

local PlayerPoints = game:GetService("DataStoreService"):GetDataStore("PlayerPoints")
local Upgrades = game:GetService("DataStoreService"):GetDataStore("Upgrades")

local LevelChangedEvent = ReplicatedStorage:WaitForChild("LevelChangedEvent")
local ZombieKilledEvent = ReplicatedStorage:WaitForChild("ZombieKilledEvent")
local SoldierKilledEvent = ReplicatedStorage:WaitForChild("SoldierKilledEvent")
local WindowShatteredEvent = ReplicatedStorage:WaitForChild("WindowShatteredEvent")

local WeaponUpgrades = require(ServerScriptService.WeaponUpgrades)

local STARTING_POINTS = 0
local STARTING_LEVEL = 1

local ZOMBIE_KILLED_POINTS = 1
local SOLDIER_KILLED_POINTS = -10
local WINDOW_SHATTERED_POINTS = 1

game.Players.CharacterAutoLoads = false

local function addWeapon(player, weapon)
	if player.Character and not player.Character:FindFirstChild(weapon.Name)  then
		if not player.Backpack:FindFirstChild(weapon.Name) then
			local clone = weapon:Clone()
			clone.Parent = player.Backpack
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
	if newPointsValue >= 320 then
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
	local success, savedUpgrades = pcall(function()
		return Upgrades:GetAsync(player.UserId)
	end)
	if success then
		if savedUpgrades then
			for _, toolName in ipairs(savedUpgrades) do
				-- print("LeaderboardServerEvents - setupWeaponUpgrades:", toolName)
				WeaponUpgrades.upgradeTool(player, toolName)
			end
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			player:LoadCharacter()
			player.leaderstats.Points.Value = STARTING_POINTS
		end)
	end)
	player:LoadCharacter()
	setupLeaderboard(player)
	setupWeaponUpgrades(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local success, errorMessage = pcall(function()
		PlayerPoints:SetAsync(player.UserId, player.leaderstats.Points.Value)
	end)
	if not success then
		warn(errorMessage)
	end
	local success, errorMessage = pcall(function()
		Upgrades:SetAsync(player.UserId, WeaponUpgrades.getUpgrades())
	end)
	if not success then
		warn(errorMessage)
	end
end)

ZombieKilledEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += ZOMBIE_KILLED_POINTS
end)

SoldierKilledEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += SOLDIER_KILLED_POINTS
end)

WindowShatteredEvent.Event:Connect(function(player)
	player.leaderstats.Points.Value += WINDOW_SHATTERED_POINTS
end)

local event = Instance.new("RemoteEvent")
event.Name = "ResetEvent"
event.OnServerEvent:Connect(function(player)
	player.leaderstats.Points.Value = STARTING_POINTS
	WeaponUpgrades.reset()
	player.Character.Humanoid.Health = 0
end)
event.Parent = ReplicatedStorage
