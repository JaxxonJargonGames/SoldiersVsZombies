local Spritesheet = {}
Spritesheet.__index = Spritesheet

function Spritesheet.new(texture)
	local newSpritesheet = {}
	setmetatable(newSpritesheet, Spritesheet)
	
	newSpritesheet.Texture = texture
	newSpritesheet.Sprites = {}	
	
	return newSpritesheet
end

function Spritesheet:AddSprite(index, position, size)
	local Sprite = {Position=position,Size=size}
	self.Sprites[index] = Sprite
end

function Spritesheet:GetSprite(instanceType, index)
	if not index then
		warn("Image name cannot be nil")
		return false
	end
	local sprite = self.Sprites[index]
	if not sprite then 
		warn("Could not find sprite for: " .. index) 
		return false
	end
	
	return {ImageRectOffset = sprite.Position, ImageRectSize = sprite.Size, Image = self.Texture}
end

return Spritesheet

