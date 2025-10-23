local stateService = {}

stateService.CheckState = function(character: Model, ...)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then
		return
	end

	local statesToCheck = { ... }

	for i, stateName in statesToCheck do
		if statusFolder:FindFirstChild(stateName) then
			return true
		end
		return false
	end
end

stateService.AddState = function(character: Model, stateName: string, duration: number, attributes: any)
	if not character then
		return
	end

	if not stateName then
		return
	end

	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then
		return
	end

	local newState = Instance.new("Folder")
	newState.Name = stateName
	newState.Parent = statusFolder

	newState.Destroying:Connect(function() end)

	if attributes then
		for name, value in attributes do
			newState:SetAttribute(name, value)
		end
	end

	if duration then
		task.delay(duration, function()
			newState:Destroy()
		end)
	end
end

stateService.RemoveState = function(character, stateName)
	if not character then
		return
	end
	if not stateName then
		return
	end

	local statusFolder: Folder = character:FindFirstChild("Status")
	if not statusFolder then
		return
	end

	for i, state in statusFolder:GetChildren() do
		if state.Name == stateName then
			state:Destroy()
		end
	end
end

return stateService
