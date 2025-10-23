local UIP = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local remotes = replicatedStorage:WaitForChild("Remotes", math.huge)
local modules = replicatedStorage:WaitForChild("Modules", math.huge)
local assets = replicatedStorage:WaitForChild("Assets", math.huge)
local stateService = require(modules.StateService)

local player: Player = game:GetService("Players").LocalPlayer
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:FindFirstChild("Humanoid")
local animator: Animator = humanoid:FindFirstChild("Animator")

local StatusFolder = character:FindFirstChild("Status")

local coreFolder = character:FindFirstChild("Core")
local animationsModule = require(coreFolder.Animations)
local weaponDataModule = require(modules.WeaponData)

animationsModule.LoadAnimations(animator, assets.Animations.Client)

local currentRun = Instance.new("StringValue")
currentRun.Name = "Current Run"
currentRun.Value = "Client.Runs.Default"
currentRun.Parent = StatusFolder

local currentIdle = Instance.new("StringValue")
currentIdle.Name = "Current Idle"
currentIdle.Value = "Client.Idle.Default"
currentIdle.Parent = StatusFolder

local isTyping = nil

local function isMoving()
	if humanoid.MoveDirection.Magnitude > 0 then
		return true
	else
		return false
	end
end

local function changeRun()
	local tool = character:FindFirstChildWhichIsA("Tool")
	if tool and weaponDataModule.GetWeaponData(tool.Name) then
		if currentRun.Value ~= "Client.Runs." .. tool.Name then
			currentRun.Value = "Client.Runs." .. tool.Name
		end
	else
		if currentRun.Value ~= "Client.Runs.Default" then
			currentRun.Value = "Client.Runs.Default"
		end
	end
end

local function changIdle()
	local tool = character:FindFirstChildWhichIsA("Tool")
	if tool and weaponDataModule.GetWeaponData(tool.Name) then
		if currentIdle.Value ~= "Client.Idle." .. tool.Name then
			currentIdle.Value = "Client.Idle." .. tool.Name
		end
	else
		if currentIdle.Value ~= "Client.Idle.Default" then
			currentIdle.Value = "Client.Idle.Default"
		end
	end
end

local function stopAnimations(category)
	if not category then
		print("no category found")
		return
	end

	if category == "Runs" then
		for name, anim: AnimationTrack in animationsModule.LoadedAnimations do
			if string.find(name, "Client.Runs") then
				if anim.IsPlaying then
					anim:Stop()
				end
			end
		end
	end

	if category == "Idle" then
		for name, anim: AnimationTrack in animationsModule.LoadedAnimations do
			if string.find(name, "Client.Idle") then
				if anim.IsPlaying then
					anim:Stop()
				end
			end
		end
	end
end

local function getDashDirection()
	local keysPressed = UIP:GetKeysPressed()
	local direction = nil

	for i, key in keysPressed do
		if key.KeyCode == Enum.KeyCode.W then
			direction = "Forward"
			return direction
		elseif key.KeyCode == Enum.KeyCode.A then
			direction = "Left"
			return direction
		elseif key.KeyCode == Enum.KeyCode.S then
			direction = "Back"
			return direction
		elseif key.KeyCode == Enum.KeyCode.D then
			direction = "Right"
			return direction
		end
	end

	return "Forward"
end

local function dash()
	local direction = getDashDirection()
	if not direction then
		return
	end

	if not stateService.CheckState(character, "Dashing", "Attacking", "Stunned", "DashDelay") then
		--> play the animation
		local dashAnim: AnimationTrack = animationsModule.LoadedAnimations["Client.Dashes.Dash" .. direction]
		if dashAnim then
			dashAnim:Play()

			--> dash state management (Client sided)
			local dashing = Instance.new("Folder")
			dashing.Name = "Dashing"
			dashing.Parent = StatusFolder

			local dashDelay = Instance.new("Folder")
			dashDelay.Name = "DashDelay"
			dashDelay.Parent = StatusFolder

			task.spawn(function()
				debris:AddItem(dashing, dashAnim.Length)
				debris:AddItem(dashing, dashAnim.Length + 0.5)
			end)
			----------------------------------------

			task.spawn(function()
				remotes.Dash:FireServer({
					["Character"] = character,
					["Direction"] = direction,
				})
			end)

			------------> Dash Movement <------------
			local dashVelocity = Instance.new("BodyVelocity")
			dashVelocity.Name = "DashVelocity"
			dashVelocity.MaxForce = Vector3.new(100000, 0, 100000)
			dashVelocity.Parent = character.HumanoidRootPart

			debris:AddItem(dashVelocity, 0.3)

			local connection: RBXScriptConnection = nil

			connection = runService.RenderStepped:Connect(function()
				if not dashVelocity.Parent then
					connection:Disconnect()
					connection = nil
				else
					if direction == "Forward" then
						dashVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 70
					elseif direction == "Back" then
						dashVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * -70
					elseif direction == "Right" then
						dashVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * 70
					elseif direction == "Left" then
						dashVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * -70
					end
				end
			end)
		end
	end
end

UIP.InputBegan:Connect(function(input, gameProcessedEvent)
	if
		gameProcessedEvent
		or input.KeyCode == Enum.KeyCode.LeftControl
		or input.KeyCode == Enum.KeyCode.RightControl
	then
		isTyping = true
	end

	if input.KeyCode == Enum.KeyCode.Q then
		dash()
	end
end)

print(animationsModule.LoadedAnimations)

runService.RenderStepped:Connect(function()
	---> STATE HANDLER <-----
	task.spawn(function()
		local finalWalkspeed = 16
		local finalJumpPower = 50

		if stateService.CheckState(character, "Sprinting") then
			finalWalkspeed = 30
			finalJumpPower = 50
		end

		if stateService.CheckState(character, "Blocking") then
			finalWalkspeed = 5
			finalJumpPower = 0
		end

		if stateService.CheckState(character, "Stunned") then
			finalWalkspeed = 9
			finalJumpPower = 0
		end

		if stateService.CheckState(character, "BlockBreak") then
			finalWalkspeed = 2
			finalJumpPower = 0
		end

		if stateService.CheckState(character, "Attacking") then
			finalWalkspeed = 9
			finalJumpPower = 0
		end

		humanoid.WalkSpeed = finalWalkspeed
		humanoid.JumpPower = finalJumpPower

		if humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping) or finalJumpPower == 0 then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end)

	----> Animation HANDLER <----
	task.spawn(function()
		if isMoving() then
			stopAnimations("Idle")
		else
			stopAnimations("Runs")
			changIdle()

			for name, anim: AnimationTrack in animationsModule.LoadedAnimations do
				if string.find(name, "Client.Idle") then
					if name ~= currentIdle.Value then
						if anim.IsPlaying then
							anim:Stop(0.2)
						end
					else
						if not anim.IsPlaying then
							anim:Play(0.2)
						end
					end
				end
			end
		end

		if isMoving() and stateService.CheckState(character, "Sprinting") then
			stopAnimations("Idle")
			changeRun()

			for name, anim: AnimationTrack in animationsModule.LoadedAnimations do
				if string.find(name, "Client.Runs") then
					if name ~= currentRun.Value then
						if anim.IsPlaying then
							anim:Stop(0.2)
						end
					else
						if not anim.IsPlaying then
							anim:Play()
						end
					end
				end
			end
		else
			stopAnimations("Runs")
		end
	end)

	-----------------------------

	-----> INPUT HANDLER <-----

	----> Sprinting <----
	task.spawn(function()
		if UIP:IsKeyDown(Enum.KeyCode.LeftShift) or UIP:IsKeyDown(Enum.KeyCode.RightShift) and not isTyping then
			if not stateService.CheckState(character, "Sprinting") then
				remotes.Sprint:FireServer(true)
			end
		else
			if stateService.CheckState(character, "Sprinting") then
				remotes.Sprint:FireServer(false)
			end
		end
	end)
	--------------------

	----> ATTACKING <----
	task.spawn(function()
		if UIP:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			if not stateService.CheckState(character, "Attacking") then
				remotes.Attack:FireServer()
			end
		end
	end)
	----------------------

	---> Blocking <----
	task.spawn(function()
		if UIP:IsKeyDown(Enum.KeyCode.F) and not isTyping then
			if not stateService.CheckState(character, "Blocking") then
				remotes.Block:FireServer(true)
			end
		else
			if stateService.CheckState(character, "Blocking") then
				remotes.Block:FireServer(false)
			end
		end
	end)
	--------------------
end)
