ac.debug(">>> Sol weather-controller","v".."[2.0]")

__sol_ctrl__path = "extension\\weather-controllers\\sol\\"


function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

dofile (__sol_ctrl__path.."tools.lua")
dofile (__sol_ctrl__path.."sol__sequenzer.lua")
dofile (__sol_ctrl__path.."sol__weather_changer.lua")
__SOL_WEATHER_PLAN = WEATHER_PLAN:new()
--[[
if file_exists(__sol_ctrl__path.."last_weather.sol") then
	dofile (__sol_ctrl__path.."last_weather.sol")
end]]

-- load athe definition file to control rain for the different weather
dofile (__sol_ctrl__path.."weather_params.lua")

dofile (__sol_ctrl__path.."ctrl_config.lua")
weather__set_rain_automatically = weather__set_rain_automatically or false
weather__set_rain_amount = math.min(1, math.max(0, weather__set_rain_amount)) or 0



__CSP_version = 0
if ac['getPatchVersionCode'] ~= nil then __CSP_version = ac.getPatchVersionCode() end


-- basic controller, uses selected weather ID to get weather type
local start_time = os.clock()


weatherType = ac.getInputWeatherType()    -- if weather doesn’t have type set, value will be guessed based on weather ID
temperatures = ac.getInputTemperatures()  -- { ambient = 23, road = 15 }
windParams = ac.getInputWind()            -- { direction = 300, speedFrom = 10, speedTo = 15 }
trackState = ac.getInputTrackState()      -- { sessionStart = 95, sessionTransfer = 90, randomness = 2, lapGain = 132 }
startingDate = ac.getInputDate()          -- seconds from 1970 etc.

trackCoordinates = ac.getTrackCoordinates()  -- { x = longitude, y = latitude }
timeZoneOffset = ac.getTimeZoneOffset()      -- { base = -25200, dst = 0 }

result = ac.ConditionsSet()
result.currentType = weatherType
result.upcomingType = weatherType
result.transition = 0.0
result.variableA = 0.0
result.variableB = 0.0
result.variableC = 2.0 --controller version
result.temperatures = temperatures
result.wind = windParams
result.trackState = trackState
ac.setConditionsSet(result)

totalTime = 0

local time_multi = ac.getTimeMultiplier()
local timeK = 0.001 --* time_multi
local day_curve = 1


function SOL__WEATHER__get__rain_amount(weather_name)
	local rain = 0
	for k,v in pairs(__weather_params) do
		if v and v[1] == weather_name then
			rain = v[2]
			break
		end
	end
	return rain
end

dofile (__sol_ctrl__path.."SOL__WEATHER_PLAN.lua")

--##############################################################################
-- Rain, Wetness and Puddles controlling
-- A wetting variable is calculated out of ambient temp., road temp., sunlight, humidity andd rain strength
-- Drying means wettings is smaller 0
-- Wetness will get bigger, if wetting is greater 0
-- Wetness will get smaller, if wetting is smaller 0
-- Puddles will get bigger if Wetness is bigger then 1 and wetting is greater 0
-- Puddles will get smaller if Wetness is smaller then 1

local temp_wetness = 0
local temp_wetting = 0
local temp_puddle_drain = 0

local wetness_drying_airtempK    = 1.0  --multiplier of wetness is forced to dry by air temperature
local wetness_drying_airtempMin  = 8    --minimum air temperature of dry process
local wetness_drying_roadtempK   = 1.0  --multiplier of wetness is forced to dry by road temperature 
local wetness_drying_roadtempMin = 12   --minimum road temperature of dry process
local wetness_drying_sunK        = 3.0  --multiplier of wetness is forced to dry by sun
local wetness_rain_wettingK      = 75.0 --multiplier of wetness gains by rain
local wetness_humidity_wettingK  = 1.00 --multiplier of wetness gains by humidity

local puddles_dryingK            = 1.00  --multiplier of puddles are forced to dry
local puddles_rain_wettingK      = 6.00  --multiplier of puddles gaining by rain
local puddles_constant_drain	 = 0.25  --multiplier of puddles constantly draining

function calc_water(condition, sun, humidity, dt)

	local drying_force = math.max(0, wetness_drying_airtempK  * temp_interpol(condition.temperatures.ambient, wetness_drying_airtempMin, -1, 2))
					   + math.max(0, wetness_drying_roadtempK * temp_interpol(condition.temperatures.road, wetness_drying_roadtempMin, -1, 2))
					   + (wetness_drying_sunK * sun * day_curve)

	-- calculate the variable for the whole process 
	temp_wetting  = dt * timeK * (

					- drying_force
					+ (wetness_rain_wettingK * math.pow(condition.rainIntensity, 1.7))
					+ math.max(0, wetness_humidity_wettingK * humidity * temp_interpol(condition.temperatures.ambient, wetness_drying_airtempMin, 1, -1))

					)

	-- update internal wetness
	temp_wetness  		= temp_wetness + temp_wetting

	-- water from puddles is constantly draining dependent of road temperature
	temp_puddle_drain 	= puddles_constant_drain * temp_interpol(condition.temperatures.road, wetness_drying_roadtempMin, 0, 3)

	if temp_wetting > 0 then
		if temp_wetness >= 1.00 then 
			condition.rainWater   = math.min(1, math.max(0, condition.rainWater +
									dt * timeK * puddles_rain_wettingK * (temp_wetness - 1) * condition.rainIntensity * math.min(1, math.max(0, math.pow(1.0*math.max(0, condition.rainIntensity - condition.rainWater), 3-2*math.pow(condition.rainIntensity, 4))))
									))
		end
		condition.rainWater   = math.min(1, math.max(0, condition.rainWater - dt * timeK * temp_puddle_drain))
	elseif temp_wetting < 0 then
		condition.rainWater   = math.min(1, math.max(0, condition.rainWater +
								dt * timeK * (
									puddles_dryingK * (temp_wetness - 1)
									- temp_puddle_drain
									)
								))
	end

	condition.rainWetness = math.min(1, math.max(0, temp_wetness + math.min(0.1, condition.rainWater * 5))) 

	-- internal wetness is limited to 0..300%
	temp_wetness = math.min(3, math.max(0, temp_wetness))

	-- if drying, set internal wetness to 1, to have the right value for drying processes
	if temp_wetting < 0 and temp_wetness >= 1 then temp_wetness = 1 end

	ac.debug("RainFX ", string.format('intensity: %.2f, wetness: %.2f, puddles: %.2f', condition.rainIntensity, condition.rainWetness, condition.rainWater))
	ac.debug("Ground ", string.format('wetting: %.2f, puddles drain: %.2f', temp_wetting*1000, temp_puddle_drain))
	return condition
end

local rain_bug_fix = false

if use_dynamic_weather_plan == true then
	__SOL_WEATHER_PLAN:reset()
	rain_bug_fix = __SOL_WEATHER_PLAN:check_for_rain()
end	

local init = true
local start = os.clock()
if __CSP_version < 1239 then rain_bug_fix = false end

function update(dt)

	update__basic__vars()

	day_curve = __IntD(0, 1.5, 0.8)

	if use_dynamic_weather_plan == true then
		
		if rain_bug_fix then
			if os.clock()-start < 1 then
				result.rainWetness = 0.1
				result.rainIntensity = 0.1
			else
				result.rainWetness = 0
				result.rainIntensity = 0
				rain_bug_fix = false
			end
		else

			local plan = __SOL_WEATHER_PLAN:update()

			if plan ~= nil then

				result.currentType  = plan.current
				result.upcomingType = plan.upcoming
				result.transition   = plan.transition

				---ac.debug("ctlr: ", plan.current..", "..plan.upcoming)

				result.temperatures.ambient = plan.temperature_ambient
				result.temperatures.road    = plan.temperature_road

				result.wind.direction = plan.wind_direction
				result.wind.speedFrom = plan.wind_speed
				result.wind.speedTo   = plan.wind_speed

				
				if __CSP_version >= 1239 then --CSP 1.67p7

					if init then
						init = false

						if plan.rain_amount >= 0 then

							result.rainIntensity = plan.rain_amount 
						else
							if weather__set_rain_automatically then
								result.rainIntensity 	= math.max(0, __weather_params[result.currentType][2])
								result.rainWetness 		= __weather_params[result.currentType][3]
								temp_wetness			= result.rainWetness
								result.rainWater 		= __weather_params[result.currentType][4]
							else
								result.rainIntensity 	= weather__set_rain_amount
								result.rainWetness 		= math.min(1, math.pow(weather__set_rain_amount * 1.25, 1.5))
								temp_wetness			= result.rainWetness * 2
								result.rainWater 		= weather__set_rain_amount * 0.5
							end
						end
					else
						if plan.rain_amount >= 0 then

							result.rainIntensity = plan.rain_amount 
						else
							if weather__set_rain_automatically then
								local rain_span = math.max(1, __weather_params[plan.upcoming][2]*4)/math.max(1, __weather_params[plan.current][2]*4)
								result.rainIntensity = math.lerp(__weather_params[plan.current][2], __weather_params[plan.upcoming][2], math.pow(plan.transition, rain_span))
							end
						end

						result = calc_water(result,
											math.lerp(__weather_params[plan.current][5], __weather_params[plan.upcoming][5], plan.transition), -- sun
											math.lerp(__weather_params[plan.current][6], __weather_params[plan.upcoming][6], plan.transition), -- humidity
											dt)
						
					end
				end
			end
		end
	else	

		result.currentType  = ac.getInputWeatherType()
		result.upcomingType = result.currentType

		result.transition   = 0.0

		--result.temperatures.ambient = 20

		--result.wind.direction = 0
		--result.wind.speedFrom = 0
		--result.wind.speedTo = result.wind.speedFrom

		if __CSP_version >= 1239 then --CSP 1.67p7
			
			if init then
				init = false

				if weather__set_rain_automatically then
					result.rainIntensity 	= math.min(1, math.max(0, __weather_params[result.currentType][2]))
					result.rainWetness 		= math.min(1, math.max(0, __weather_params[result.currentType][3])) 
					temp_wetness			= result.rainWetness
					result.rainWater 		= math.min(1, math.max(0, __weather_params[result.currentType][4]))
				else
					result.rainIntensity 	= weather__set_rain_amount
					result.rainWetness 		= math.min(1, math.pow(weather__set_rain_amount * 1.25, 1.5))
					temp_wetness			= result.rainWetness * 2
					result.rainWater 		= weather__set_rain_amount * 0.5
				end
			else
				result = calc_water(result,
									__weather_params[result.currentType][5], -- sun
									__weather_params[result.currentType][6], -- humidity
									dt)
			end
		end
	end
--[[
	if __CSP_version >= 1239 then --CSP 1.67p7
		if rain_bug_fix then
			if ac.isInteriorView() then
				result.rainWetness = math.max(0.0075, result.rainWetness)
			else
				result.rainWetness = math.max(0.01, result.rainWetness)
			end
		end
	end
]]


	last_use_dynamic_weather_plan = use_dynamic_weather_plan

	ac.setConditionsSet(result)
end