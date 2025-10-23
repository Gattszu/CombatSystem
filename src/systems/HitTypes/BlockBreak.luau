-- Default HitType
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local modules = replicatedStorage:WaitForChild("Modules")
local assets = replicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")

local stateService = require(modules:WaitForChild("StateService"))
local weaponData = require(modules:WaitForChild("WeaponData"))

local remotes = replicatedStorage:WaitForChild("Remotes")

return function(attacker: Model, target: Model, weaponUsed: string, trueSwingNumber: number)
	local foundWeaponData = weaponData.GetWeaponData(weaponUsed)

	local targetHumanoid: Humanoid = target:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return
	end

	if foundWeaponData then
		remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = "BlockBreak",
			["Parent"] = targetHumanoid,
		})

		remotes.ClientEffects:FireAllClients("BlockBreak", {
			["Target"] = target,
			["WeaponUsed"] = weaponUsed,
			["Duration"] = 1.5,
		})

		if target:FindFirstChild("Core") then
			local animationModule = require(target:FindFirstChild("Core").Animations)
			animationModule.LoadedAnimations["Client.BlockBreak"]:Play()
		else
			--> forece load and play
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local animation = animations.Client.BlockBreak
				local track: AnimationTrack = animator:LoadAnimation(animation)
				track:Play()
			end
		end

		stateService.AddState(target, "Stunned", 1.5)
		stateService.AddState(target, "BlockBroken", 1.5)
		stateService.AddState(target, "NoAttack", 1.5)

		targetHumanoid:TakeDamage(foundWeaponData.BlockedDamage)
	end
end
