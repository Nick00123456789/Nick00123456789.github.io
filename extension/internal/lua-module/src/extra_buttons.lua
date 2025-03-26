--[[
  Adds extra hotkeys (currently only for pausing).
]]

local btnPause ---@type ac.ControlButton

local function refreshButtons()
  btnPause = ac.ControlButton('__EXT_SIM_PAUSE', ac.GamepadButton.Start, { gamepad = true }):setAlwaysActive(true)
end

refreshButtons()
ac.onControlSettingsChanged(refreshButtons)

local sim = ac.getSim()
Register('core', function (dt)
  if btnPause:pressed() then
    if sim.isInMainMenu then
      ac.tryToStart()
    else
      ac.tryToPause(not sim.isPaused)
    end
  end
end)
