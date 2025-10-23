local animations = {}

animations.LoadedAnimations = {}

animations.Connections = {}

animations.LoadAnimations = function(Animator: Animator, animationFolder: Folder)
	for _, animation: Animation in animationFolder:GetDescendants() do
		if animation:IsA("Animation") then
			local fullName = animation:GetFullName()
			fullName = fullName:split("ReplicatedStorage.Assets.Animations.")[2]
			animations.LoadedAnimations[fullName] = Animator:LoadAnimation(animation)
		end
	end
end

return animations
