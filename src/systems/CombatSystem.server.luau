local UIP = game:GetService("UserInputService")
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:WaitForChild("Remotes", math.huge)
local assets = replicatedStorage:WaitForChild("Assets", math.huge)
local modules = replicatedStorage:WaitForChild("Modules", math.huge)

local stateService = require(modules:WaitForChild("StateService"))
local hitboxes = workspace:FindFirstChild("HitBoxes")

local weaponModules = script.Parent.WeaponModules

local cachedModules = {}
for i, module in weaponModules:GetChildren() do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end

remotes.Attack.OnServerEvent:Connect(function(player: Player)
	if not player then
		return
	end
	local character: Model = player.Character
	if character then
		local humanoid: Humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local foundTool = character:FindFirstChildWhichIsA("Tool")
			if foundTool then
				local foundModule = cachedModules[foundTool.Name]
				if foundModule then
					foundModule.Attack(character, foundTool)
				end
			end
		end
	end
end)

remotes.Block.OnServerEvent:Connect(function(player: Player, request: boolean)
	if not player then
		return
	end

	local character = player.Character
	if not character then
		return
	end
	local coreFolder = character:FindFirstChild("Core")
	if not coreFolder then
		return
	end
	local animationsModule = require(coreFolder:FindFirstChild("Animations"))
	if not animationsModule then
		return
	end

	if request == true then
		if not stateService.CheckState(character, "Blocking", "Attacking", "Stunned", "BlockBreak") then
			local humanoid: Humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				local foundTool = character:FindFirstChildWhichIsA("Tool")
				if foundTool and cachedModules[foundTool.Name] then
					stateService.AddState(character, "Parry", 0.15)
					stateService.AddState(character, "Blocking", nil, {
						["WeaponName"] = foundTool.Name,
					})
				end
			end
		end
	elseif request == false then
		stateService.RemoveState(character, "Blocking")
	end
end)

remotes.Sprint.OnServerEvent:Connect(function(player, request)
	if not player then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	if request then
		if not stateService.CheckState(character, "Sprinting") then
			stateService.AddState(character, "Sprinting")
		end
	else
		stateService.RemoveState(character, "Sprinting")
	end
end)

remotes.Dash.OnServerEvent:Connect(function(player, arguementData)
	if not player then
		return
	end
	if not arguementData then
		return
	end

	remotes.ClientEffects:FireAllClients("Dash", arguementData)
end)
