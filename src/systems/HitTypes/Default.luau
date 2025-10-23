-- Default HitType
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local modules = replicatedStorage:WaitForChild("Modules")
local assets = replicatedStorage:WaitForChild("Assets")
local animations = assets:WaitForChild("Animations")

local stateService = require(modules:WaitForChild("StateService"))
local weaponData = require(modules:WaitForChild("WeaponData"))

local remotes = replicatedStorage:WaitForChild("Remotes")

return function(attacker: Model, target: Model, weaponUsed: string, trueSwingNumber: number, lastHit: boolean)
	local foundWeaponData = weaponData.GetWeaponData(weaponUsed)

	local targetHumanoid: Humanoid = target:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return
	end

	if foundWeaponData then
		remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = weaponUsed .. ".Hit." .. trueSwingNumber,
			["Parent"] = targetHumanoid,
		})

		remotes.ClientEffects:FireAllClients("DefaultHit", {
			["Target"] = target,
			["WeaponUsed"] = weaponUsed,
		})

		if target:FindFirstChild("Core") then
			local animationModule = require(target:FindFirstChild("Core").Animations)
			animationModule.LoadedAnimations["Client.HitReactions." .. tostring(trueSwingNumber)]:Play()
			print("Normal")
		else
			--> forece load and play
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local animation = animations.Client.HitReactions[tostring(trueSwingNumber)]
				local track: AnimationTrack = animator:LoadAnimation(animation)
				track:Play()
			end
			print("Forced")
		end

		if lastHit then
			local knockBackVelocity = Instance.new("BodyVelocity")
			knockBackVelocity.MaxForce = Vector3.new(4e4, 0, 4e4)
			knockBackVelocity.Velocity = attacker.HumanoidRootPart.CFrame.LookVector * 40
			knockBackVelocity.Parent = target.HumanoidRootPart
			game.Debris:AddItem(knockBackVelocity, 0.15)
		else
			local knockBackVelocity = Instance.new("BodyVelocity")
			knockBackVelocity.MaxForce = Vector3.new(4e4, 0, 4e4)
			knockBackVelocity.Velocity = attacker.HumanoidRootPart.CFrame.LookVector * 12
			knockBackVelocity.Parent = target.HumanoidRootPart
			game.Debris:AddItem(knockBackVelocity, 0.15)

			local pullVelocity = Instance.new("BodyVelocity")
			pullVelocity.MaxForce = Vector3.new(4e4, 0, 4e4)
			pullVelocity.Velocity = attacker.HumanoidRootPart.CFrame.LookVector * 9
			pullVelocity.Parent = attacker.HumanoidRootPart
			game.Debris:AddItem(pullVelocity, 0.13)
		end

		stateService.AddState(target, "Stunned", 0.1)
		targetHumanoid:TakeDamage(foundWeaponData.DefaultDamage)
	end
end
