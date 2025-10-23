local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage:WaitForChild("Assets")
local soundsFolder = assets:WaitForChild("Sounds")

local cache = {}

for i, sound in soundsFolder:GetDescendants() do
	if sound:IsA("Sound") then
		fullName = sound:GetFullName()
		fullName = fullName:split("ReplicatedStorage.Assets.Sounds.")[2]
		cache[fullName] = sound
	end
end

return function(argumentData)
	if not argumentData then
		return
	end
	local soundName = argumentData.SoundName
	local parent = argumentData.Parent
	if soundName and parent then
		local sound: Sound = cache[soundName]
		if sound then
			local soundClone = sound:Clone()
			soundClone.Name = soundName
			soundClone.Parent = parent
			soundClone:Play()

			task.delay(sound.TimeLength, function()
				soundClone:Destroy()
			end)
		else
		end
	end
end
