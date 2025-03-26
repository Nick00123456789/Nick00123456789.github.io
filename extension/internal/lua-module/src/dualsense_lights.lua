--[[
  Adds support for extra features of DualSense controllers. Sets state with low priority so that other
  apps could override the state.
]]

if next(ac.getDualSenseControllers()) == nil then
  return
end

local settings = Config:mapSection('PS5_DUALSENSE', {
  ENABLED = true,
  SHIFTING_COLORS = 'SMOOTH',
  SESSION_START = true,
  EXTRA_COLORS = true,
  BACKGROUND_COLORS = true,
  MOUSE_PAD = true,
  LOW_BATTERY_WARNING = true,
})

if not settings.ENABLED then
  return
end

local carInfo = {}
local flashing = 0

---@alias CarInfo {state: ac.StateCar, rpmUp: number, rpmDown: number, fuelWarning: number}
---@return CarInfo
local function getCarInfo(carIndex)
  local ret = carInfo[carIndex]
  if not ret then
    local aiIni = ac.INIConfig.carData(carIndex, 'ai.ini')
    local carIni = ac.INIConfig.carData(carIndex, 'car.ini')
    ret = {
      state = ac.getCar(carIndex),
      rpmUp = aiIni:get('GEARS', 'UP', 9000),
      rpmDown = math.max(aiIni:get('GEARS', 'DOWN', 6000), aiIni:get('GEARS', 'UP', 9000) / 2),
      fuelWarning = carIni:get('GRAPHICS', 'FUEL_LIGHT_MIN_LITERS', 0)
    }
    carInfo[carIndex] = ret
  end
  return ret
end

local dualSensePadOverride = ac.connect({
  ac.StructItem.key('dualSensePadOverride'),
  override = ac.StructItem.boolean()
}, false, ac.SharedNamespace.Shared)

local sim = ac.getSim()
local uis = ac.getUI()
local colorBase = rgbm(0, 0, 0, 1)
local colorShifting = rgbm(0, 0, 0, 1)
local drawBatteryIcon = settings.LOW_BATTERY_WARNING and Toggle.DrawUI()

---@param info CarInfo
---@param ds ac.StateDualsenseOutput
local function update(info, ds)
  local car = info.state
  local rpm = (car.rpm - info.rpmDown) / (info.rpmUp - info.rpmDown)

  -- LEDs showing RPM bar
  ds.playerLEDsBrightness = rpm > 0.5 and 0 or rpm > 0.25 and 1 or 2
  ds.playerLEDsFade = false
  for i = 0, 4 do
    ds.playerLEDs[i] = rpm > i / 4
  end

  -- Colors highlighting shifting stage
  if settings.SESSION_START and sim.timeToSessionStart > -1e3 then
    if sim.timeToSessionStart > 0 then
      ds.lightBar = sim.timeToSessionStart < 6.7e3 and rgbm.colors.red or rgbm.colors.transparent
    else
      ds.lightBar = flashing * 3 % 1 > 0.5 and rgbm.colors.green or rgbm.colors.transparent
    end
  elseif settings.EXTRA_COLORS and car.gear == -1 then
    ds.lightBar = rgbm.colors.white
  elseif settings.EXTRA_COLORS and car.engineLifeLeft < 1 or car.hazardLights then
    ds.lightBar = car.turningLightsActivePhase and rgbm.colors.orange or rgbm.colors.transparent
  elseif settings.EXTRA_COLORS and car.fuel < info.fuelWarning then
    ds.lightBar = rgbm(1, 0.15, 0, 1)
  elseif settings.SHIFTING_COLORS ~= '0' then
    if rpm > 0.9 and (flashing * 3 % 1 > 0.5) then
      ds.lightBar = rgbm.colors.transparent
    else
      if car.headlightsActive and settings.EXTRA_COLORS then
        colorBase.rgb:set(car.headlightsColor):scale(car.lowBeams and 0.1 or 0.2)
      elseif colorBase.rgb.r > 0 or colorBase.rgb.g > 0 or colorBase.rgb.b > 0 then
        colorBase.rgb:scale(0)
      end
      local mix = math.saturateN(rpm * 2 + 1)
      if mix > 0 then
        local isSmooth = settings.SHIFTING_COLORS == 'SMOOTH'
        colorShifting.rgb = isSmooth
          and hsv(90 * math.saturateN(1 - rpm), 1, 1):rgb()
          or (rpm > 0.6 and rgb.colors.red or rpm > 0.2 and rgb.colors.yellow or rgb.colors.green)
        if isSmooth then
          ds.lightBar:setLerp(colorBase, colorShifting, mix)
        else
          ds.lightBar:set(colorShifting)
        end
      else
        ds.lightBar:set(colorBase)
      end
    end
  end
end

local minBatteryLevel = 1
local anyPadWasPressed = false

Register('core', function (dt)
  if not sim.isPaused then
    flashing = flashing + dt
    if flashing > 1 then
      flashing = flashing - 1
    end
  end

  minBatteryLevel = 1
  local anyPadPressed = false

  for controllerIndex, carIndex in pairs(ac.getDualSenseControllers()) do
    local state = ac.getDualSense(controllerIndex)
    if state and state.connected then
      if not sim.isReplayActive then
        update(getCarInfo(carIndex), ac.setDualSense(controllerIndex, -1000))
      elseif settings.BACKGROUND_COLORS then
        local sceneColor = sim.skyColor + sim.lightColor
        local sceneColorBrightness = sceneColor:value()
        if sceneColorBrightness > 1 then
          sceneColor:scale(1 / sceneColorBrightness)
        end
        ac.setDualSense(controllerIndex, -1000).lightBar = sceneColor:rgbm(1)
      end

      if drawBatteryIcon then
        if not state.batteryCharging then
          minBatteryLevel = math.min(minBatteryLevel, state.battery)
        end
      end

      -- Pad moves mouse
      if settings.MOUSE_PAD and not dualSensePadOverride.override and uis.mousePos.x >= 0 then
        for i = 0, 1 do
          if state.touches[i].down then
            if i == 0 and state.touches[1].down then
              ac.setMouseWheel((state.touches[0].delta.y + state.touches[1].delta.y) * 50)
            else
              ac.setMousePosition(uis.mousePos + uis.windowSize * state.touches[i].delta * vec2(0.5, 1))
            end
            anyPadPressed = anyPadPressed or ac.isGamepadButtonPressed(controllerIndex, ac.GamepadButton.Pad)
            break
          end
        end
      end
    end
  end

  if anyPadWasPressed ~= anyPadPressed then
    anyPadWasPressed = anyPadPressed
    ac.setMouseLeftButtonDown(anyPadPressed)
  end

  drawBatteryIcon(minBatteryLevel < 0.2)
end)

if settings.LOW_BATTERY_WARNING then
  Register('drawUI', function (dt)
    if minBatteryLevel < 0.2 then
      ui.drawCarIcon('res/controller-battery.png', minBatteryLevel < 0.05 and rgbm.colors.red
        or minBatteryLevel < 0.1 and rgbm.colors.orange or rgbm.colors.yellow)
    end
  end)
end
