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
		local randomNum = math.random(1, 4)
		remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = weaponUsed .. ".Blocked." .. tostring(trueSwingNumber),
			["Parent"] = targetHumanoid,
		})

		remotes.ClientEffects:FireAllClients("Blocked", {
			["Target"] = target,
			["WeaponUsed"] = weaponUsed,
		})

		local randomShrug = math.random(1, 2)
		if target:FindFirstChild("Core") then
			local animationModule = require(target:FindFirstChild("Core").Animations)
			animationModule.LoadedAnimations["Client.BlockReactions.Shrug" .. tostring(randomShrug)]:Play()
		else
			--> forece load and play
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local animation = animations.Client.BlockReactions["shrug" .. tostring(randomShrug)]
				local track: AnimationTrack = animator:LoadAnimation(animation)
				track:Play()
			end
		end

		targetHumanoid:TakeDamage(foundWeaponData.BlockedDamage)
	end
end
