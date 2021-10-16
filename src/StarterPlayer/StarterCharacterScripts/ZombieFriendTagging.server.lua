local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

local isFriend = false

print("Not Zombie Friend!")

local event = Instance.new("RemoteEvent")
event.Name = "ZombieFriendToggleEvent"
event.OnServerEvent:Connect(function(player)
	if player.UserId == game.CreatorId then
		isFriend = not isFriend
		if isFriend then
			print("Zombie Friend!")
			CollectionService:AddTag(character, "ZombieFriend")
		else
			print("Not Zombie Friend!")
			CollectionService:RemoveTag(character, "ZombieFriend")
		end
	end
end)
event.Parent = ReplicatedStorage
