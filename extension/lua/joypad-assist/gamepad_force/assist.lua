local modes = {
  require('modes/race'),
  require('modes/drift')
}

local function isDriftCar()
  return ac.getCarID(0):regfind('drift', nil, true)
    or ac.getCarName(0):regfind('drift', nil, true)
    or table.some(ac.getCarTags(0) or {}, function (tag) return tag:regfind('drift', nil, true) end)
end

local storageKey = 'mode:'..ac.getCarID(0)
local currentMode = modes[tonumber(ac.storage[storageKey])] or modes[isDriftCar() and 2 or 1]
local wasPressed = false
local switchButton = ac.INIConfig.cspModule(ac.CSPModuleID.JoypadAssist):get('TWEAKS', 'MODE_SWITCH_BUTTON', ac.GamepadButton.Y)

function script.update(dt)
  currentMode.update(dt)

  if ac.isGamepadButtonPressed(__gamepadIndex, switchButton) ~= wasPressed then
    wasPressed = not wasPressed
    if wasPressed then
      local newModeIndex = table.indexOf(modes, currentMode) % #modes + 1
      ac.storage[storageKey] = newModeIndex
      local newMode = modes[newModeIndex]
      newMode.sync(currentMode)
      currentMode = newMode
      ac.setSystemMessage('Gamepad mode', 'Switched to '..currentMode.name)
    end
  end
end

