local animations = {
	"507770677", -- cheer
	"616156119", -- climb
	"507771019", -- dance A1
	"507776043", -- dance B1
	"507777268", -- dance C1
	"507770818", -- laugh
	"507770453", -- point
	"885545458", -- pose
	"3489173414", -- run
	"507770239", -- wave
}

local humanoid
local animator
local index
local id
local cooldown

local function animate(id)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. id
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack.Looped = false
	animationTrack:Play()
end

while true do
	for _, zombie in ipairs(workspace["Zombies"]:GetChildren()) do
		humanoid = zombie:FindFirstChild("Humanoid")
		if humanoid then
			animator = humanoid:WaitForChild("Animator")
			index = math.random(1, #animations)
			id = animations[index]
			animate(id)
			cooldown = math.random()
			task.wait(cooldown)
		end
	end
	task.wait(0.1)
end
