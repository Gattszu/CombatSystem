local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets", math.huge)
local modules = replicatedStorage:WaitForChild("Modules", math.huge)
local remotes = replicatedStorage:WaitForChild("Remotes", math.huge)

local stateService = require(modules.StateService)
local hitboxes = workspace:FindFirstChild("HitBoxes")

local weaponData = require(modules.WeaponData).GetWeaponData("Fist")

local Fist = {
	hitTypes = {},
}

for i, hitType in script.Parent.Parent.HitTypes:GetChildren() do
	if hitType:IsA("ModuleScript") then
		Fist.hitTypes[hitType.Name] = require(hitType)
	end
end

Fist.Attack = function(character: Model, foundTool: Tool)
	if not character then
		return
	end

	if not foundTool then
		return
	end

	if foundTool.Name ~= script.Name then
		return
	end

	if stateService.CheckState(character, "Attacking", "Blocking", "Stunned") then
		return
	end

	local coreFolder = character:FindFirstChild("Core")
	local animationsModule = require(coreFolder.Animations)

	local configurationFolder = foundTool:FindFirstChild("Configuration")
	if not configurationFolder then
		return
	end

	local swingNumber = configurationFolder:FindFirstChild("SwingNumber")

	local lastSwing = configurationFolder:FindFirstChild("LastSwing")

	local lastCombo = configurationFolder:FindFirstChild("LastCombo")

	if (os.clock() - lastCombo.Value) < weaponData.ComboCooldown then
		return
	end

	if (os.clock() - lastSwing.Value) > weaponData.ComboResetTime then
		swingNumber.Value = 0
	end

	local trueSwingNumber = nil

	swingNumber.Value += 1
	trueSwingNumber = swingNumber.Value

	if swingNumber.Value == 5 then
		swingNumber.Value = 0
		trueSwingNumber = 5

		lastCombo.Value = os.clock()
	end

	lastSwing.Value = os.clock()

	for connectionName, connection in animationsModule.Connections do
		if string.find(connectionName, "Fist.Swings") then
			animationsModule.Connections[connectionName]:Disconnect()
			animationsModule.Connections[connectionName] = nil
		end
	end

	local animationName = "Fist.Swings.L" .. tostring(trueSwingNumber)

	local swingAnim: AnimationTrack = animationsModule.LoadedAnimations[animationName]

	local connection = nil

	swingAnim:Play()

	stateService.AddState(character, "Attacking", swingAnim.Length)

	animationsModule.Connections[animationName] = swingAnim:GetMarkerReachedSignal("Hit"):Once(function()
		local hitboxTemplate = assets.HitBoxTemplate
		if not hitboxTemplate then
			return
		end

		remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = "Fist.Swing." .. tostring(trueSwingNumber),
			["Parent"] = character.HumanoidRootPart,
		})

		local hitboxClone = hitboxTemplate:Clone()
		hitboxClone.Name = "HitBox"

		local weld = Instance.new("WeldConstraint")
		weld.Name = "Weld"
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.Parent = hitboxClone

		hitboxClone.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		hitboxClone.Parent = workspace.HitBoxes

		task.spawn(function()
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character, workspace.HitBoxes }

			local alreadyHit = {}

			while hitboxClone do
				local touchingList = workspace:GetPartsInPart(hitboxClone, params)
				for _, part in touchingList do
					if part.Parent and part.Parent:FindFirstChild("Humanoid") then
						local target = part.Parent
						local targetHumaoid: Humanoid = target:FindFirstChild("Humanoid")
						if targetHumaoid then
							if not alreadyHit[target] then
								alreadyHit[target] = true
								local isBlocking = stateService.CheckState(target, "Blocking")
								if isBlocking then
									if trueSwingNumber == 5 then
										Fist.hitTypes["BlockBreak"](character, target, foundTool.Name, trueSwingNumber)
									else
										Fist.hitTypes["Blocked"](character, target, foundTool.Name, trueSwingNumber)
									end
								else
									Fist.hitTypes["Default"](
										character,
										target,
										foundTool.Name,
										trueSwingNumber,
										trueSwingNumber == 5
									)
								end
							end
						end
					end
				end
				task.wait()
			end
		end)
		debris:AddItem(hitboxClone, 0.1)
	end)
end

return Fist
