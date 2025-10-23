local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

--> access the effects folder
local assets = replicatedStorage.Assets
local effects = assets.Effects

return function(argumentData: any)
	local target: Model = argumentData.Target
	local weaponUsed: string = argumentData.WeaponUsed

	if target and weaponUsed then
		local root = target:FindFirstChild("HumanoidRootPart")
		if root then
			local clone = effects.CoreEffects.Block:Clone()
			clone.Parent = root

			for _, v in clone:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					if v:GetAttribute("EmitDelay") and v:GetAttribute("EmitDelay") > 0 then
						task.delay(v:GetAttribute("EmitDelay"), function()
							v:Emit(v:GetAttribute("EmitCount"))
						end)
					else
						v:Emit(v:GetAttribute("EmitCount"))
					end
				end
			end

			debris:AddItem(clone, 1.5)
		end
	end
end
