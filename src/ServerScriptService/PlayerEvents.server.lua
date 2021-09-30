game.Players.CharacterAutoLoads = false

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			player:LoadCharacter()
		end)
	end)
	player:LoadCharacter()
end)
