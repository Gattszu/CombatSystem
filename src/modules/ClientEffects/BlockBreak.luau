local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

--> access the effects folder
local assets = replicatedStorage.Assets
local effects = assets.Effects

return function(argumentData: any)
	local target: Model = argumentData.Target
	local weaponUsed: string = argumentData.WeaponUsed
	local duration: number = argumentData.Duration

	task.spawn(function()
		if target and weaponUsed and duration then
			local root = target:FindFirstChild("HumanoidRootPart")
			if root then
				local clone = effects.CoreEffects["BlockBreak"]:Clone()
				-- source of the sound is the root part of the target
				clone.Parent = root
				--> loop through the particles and emit them
				for _, v in clone:GetDescendants() do
					if v:IsA("ParticleEmitter") then
						if v:GetAttribute("EmitDelay") and v:GetAttribute("EmitDelay") > 0 then
							task.delay(v:GetAttribute("EmitDelay"), function()
								v:Emit(v:GetAttribute("EmitCount"))
								print("Emitting")
							end)
						else
							v:Emit(v:GetAttribute("EmitCount"))
						end
					end
				end

				debris:AddItem(clone, duration)
			end
		end
	end)

	if target and weaponUsed then
		local clone = effects.DizzyEffect:Clone()

		local weld: Weld = Instance.new("Weld")
		weld.Part0 = target.Head
		weld.Part1 = clone
		weld.Parent = clone
		clone.Parent = target

		task.delay(duration, function()
			for i, eff in clone:GetDescendants() do
				if eff:IsA("ParticleEmitter") then
					eff.Enabled = false
				end
			end
			debris:AddItem(clone, 1, 5)
		end)
	end
end
