local Keymap = {}

local _inputData = {}

Keymap.EnterVehicleKeyboard = Enum.KeyCode.E
Keymap.EnterVehicleGamepad = Enum.KeyCode.ButtonY
	
	--Vehicle
Keymap.Handbrake = {
	{KeyCode = Enum.KeyCode.Space},
	{KeyCode = Enum.KeyCode.ButtonA},
}
	
Keymap.SteerLeft = {
	{KeyCode = Enum.KeyCode.A},
	{KeyCode = Enum.KeyCode.Left},
	{KeyCode = Enum.KeyCode.Thumbstick1, Axis = Vector3.new(-1, 0, 0)},
}
	
Keymap.SteerRight = {
	{KeyCode = Enum.KeyCode.D, Sign = -1},
	{KeyCode = Enum.KeyCode.Right, Sign = -1},
	{KeyCode = Enum.KeyCode.Thumbstick1, Axis = Vector3.new(-1, 0, 0)},
}

Keymap.Throttle = {
	{KeyCode = Enum.KeyCode.W},
	{KeyCode = Enum.KeyCode.Up},
	{KeyCode = Enum.KeyCode.ButtonR2, Axis = Vector3.new(0, 0, 1)},
}
	
Keymap.Brake = {
	{KeyCode = Enum.KeyCode.S},
	{KeyCode = Enum.KeyCode.Down},
	{KeyCode = Enum.KeyCode.ButtonL2, Axis = Vector3.new(0, 0, 1)},
}

-- Create lookup table
for k, v in pairs(Keymap) do
	if type(v) == "table" then
		for _, data in ipairs(v) do
			if type(data) == "table" then
				_inputData[data.KeyCode] = data
			end
		end
	end
end

-- Helpers
function Keymap.KeysForAction(actionName)
	local keys = {}
	for i, keyInfo in ipairs(Keymap[actionName]) do
		keys[i] = keyInfo.KeyCode
	end
	return keys
end

function Keymap.allKeys()
	local tbl = {}
	
	for k, _ in pairs(_inputData) do
		table.insert(tbl, k)
	end
	
	return tbl
end

function Keymap.getData(key)
	return _inputData[key]
end

function Keymap.newInputTable()
	local tbl = {}
	
	for k, _ in pairs(_inputData) do
		tbl[k] = 0
	end
	
	return tbl
end
----

return Keymap
