local Players = game:GetService("Players")

player = Players:GetPlayerFromCharacter(script.Parent)

if player.UserId == game.CreatorId then
	print("Zombie Friend!")
	game:GetService("CollectionService"):AddTag(script.Parent, "ZombieFriend")
end
