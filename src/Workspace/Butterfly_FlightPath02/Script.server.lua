local animationId = "6409138208"
local char = script.Parent
local animController = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("AnimationController")
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://" .. tostring(animationId)
local animTrack = animController:LoadAnimation(animation)
animTrack:Play(0,1,1)