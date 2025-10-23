local weaponData = {
	storedData = {},
}

weaponData.GetWeaponData = function(weaponName: string)
	if weaponName then
		for name, data in weaponData.storedData do
			if name == weaponName then
				return data
			end
		end
	end
end

for _, module: ModuleScript in script:GetChildren() do
	weaponData.storedData[module.Name] = require(module)
end

return weaponData
