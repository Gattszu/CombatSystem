local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

--> access the effects folder
local assets = replicatedStorage.Assets
local effects = assets.Effects

return function(argumentData: any)
	local character: Model = argumentData.Character
	local direction: string = argumentData.Direction

	if character and direction then
		local foundDashEffect = assets.Effects.DashEffects:FindFirstChild(direction)
		if foundDashEffect then
			local clone = foundDashEffect:Clone()
			clone.Parent = workspace.Effects

			local weld = Instance.new("Weld")
			weld.Part0 = character.HumanoidRootPart
			weld.Part1 = clone
			weld.Parent = clone

			for i, v: ParticleEmitter in clone:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end

			task.delay(0.3, function()
				for _, v: ParticleEmitter in clone:GetDescendants() do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end)
			debris:AddItem(clone, 1.5)
		end
	end
end
