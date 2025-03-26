ac.debug(">>> Sol weather-controller","v".."[2.52]")

__sol_ctrl__path = "extension\\weather-controllers\\sol2\\"

__SOL_2_STATIC__controller = __SOL_2_STATIC__controller or false

__sun_angle = 0


-- fix of the CM 0.8.2561 bug
local ___file___ = nil
if io.output == nil then
  io.write = function(buffer)
    if ___file___ then
      ___file___:write(buffer)
    end
  end
  io.output = function(file)
    ___file___ = file
  end
end



function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

function _d(v)
    ac.debug("---",v)
    return v
end

function ___reset__Controller___(msg)

    -- set the time of the reset in the backup memeory
    msg = msg or "___reset__Controller___"

    local f=io.open(__sol_ctrl__path.."\\reset_dummy.lua","w+")
    if f~=nil then
        io.output(f)
        io.write(msg)
        io.close(f)
    end 
end

__CSP_version = 0
if ac['getPatchVersionCode'] ~= nil then __CSP_version = ac.getPatchVersionCode() end


dofile (__sol_ctrl__path.."tools.lua")
dofile (__sol_ctrl__path.."utils_LUT.lua")
dofile (__sol_ctrl__path.."sol__interface.lua")
dofile (__sol_ctrl__path.."sol__shared_memory__backup.lua")

-- load athe definition file to control rain for the different weather
dofile (__sol_ctrl__path.."weather_params.lua")
dofile (__sol_ctrl__path.."CM-Drive.lua")


local _l_sun_pos_LUT = {
	{-180.0, 0, 1.00 } ,
	{-108.0, 0, 1.00 } ,
	{ -99.0, 1, 1.00 } ,
	{ -88.0, 2, 1.00 } ,
	{ -78.0, 2, 0.00 } ,
	{   0.0, 2, 0.00 } ,
}
local _l_sun__LUT
local _l_sun_posCPP = LUT:new(_l_sun_pos_LUT, nil)

local _l_day_pos_LUT = {
	{     0, 0 } ,
	{ 28800, 3 } , --8:00
	{ 45000, 4 } , --12:30
	{ 57600, 5 } , --16:00
	{ 68400, 6 } , --19:00
	{ 86400, 6 } ,
}
local _l_day__LUT
local _l_day_posCPP = LUT:new(_l_day_pos_LUT, nil)


local _l_rainV2_scale_LUT = {
--   Planner    rainFX v2
	{0.00, 		0.000 } ,
	{0.01, 		0.001 } ,
	{0.02, 		0.002 } ,
	{0.03, 		0.003 } ,
	{0.04, 		0.004 } ,
	{0.05, 		0.005 } ,
	{0.06, 		0.006 } ,
	{0.07, 		0.007 } ,
	{0.08, 		0.008 } ,
	{0.09, 		0.009 } ,
	{0.10, 		0.010 } ,
	{0.15, 		0.015 } ,
	{0.20, 		0.025 } ,
	{0.30, 		0.050 } ,
	{0.40, 		0.080 } ,
	{0.50, 		0.100 } ,
	{0.60, 		0.125 } ,
	{0.70, 		0.150 } ,
	{0.80, 		0.200 } ,
	{0.90, 		0.400 } ,
	{1.00, 		1.000 } ,
}
local _l_rainV2_scale__LUT
local _l_rainV2_scaleCPP = LUT:new(_l_rainV2_scale_LUT, nil)


local _l_rainV2_unscale_LUT = {
--   rainFX v2  Planner
	{0.000,     0.00 } ,
	{0.001,     0.01 } ,
	{0.002,     0.02 } ,
	{0.003,     0.03 } ,
	{0.004,     0.04 } ,
	{0.005,     0.05 } ,
	{0.006,     0.06 } ,
	{0.007,     0.07 } ,
	{0.008,     0.08 } ,
	{0.009,     0.09 } ,
	{0.010,     0.10 } ,
	{0.015,     0.15 } ,
	{0.025,     0.20 } ,
	{0.050,     0.30 } ,
	{0.080,     0.40 } ,
	{0.100,     0.50 } ,
	{0.125,     0.60 } ,
	{0.150,     0.70 } ,
	{0.200,     0.80 } ,
	{0.400,     0.90 } ,
	{1.000,     1.00 } ,
	}
local _l_rainV2_unscale__LUT
local _l_rainV2_unscaleCPP = LUT:new(_l_rainV2_unscale_LUT, nil)


--ac.skipSaneChecks()


-- basic controller, uses selected weather ID to get weather type
local start_time = os.clock()


weatherType = ac.getInputWeatherType()    -- if weather doesn’t have type set, value will be guessed based on weather ID
temperatures = ac.getInputTemperatures()  -- { ambient = 23, road = 15 }
windParams = ac.getInputWind()            -- { direction = 300, speedFrom = 10, speedTo = 15 }
trackState = ac.getInputTrackState()      -- { sessionStart = 95, sessionTransfer = 90, randomness = 2, lapGain = 132 }
startingDate = ac.getInputDate()          -- seconds from 1970 etc.

trackCoordinates = ac.getTrackCoordinates()  -- { x = longitude, y = latitude }
timeZoneOffset = ac.getTimeZoneOffset()      -- { base = -25200, dst = 0 }


local result = ac.ConditionsSet()
result.currentType = weatherType
result.upcomingType = weatherType
result.transition = 0.0
result.humidity = -1
result.variableA = -1
result.variableB = 0.0
if __CSP_version >= 2253 then
	result.variableC = 2.5 --controller version after rainFX change
else
	result.variableC = 2.2 --controller version before rainFX change
end
result.temperatures = temperatures
result.wind = windParams
result.trackState = trackState
ac.setConditionsSet(result)

local export = ac.ConditionsSet()


-- the main intercommunication with the Sol_config App
__plannerAppInterface = Interface:new("plannerAPP", 0.25)
__plannerAppInterface:setOrderExecutorList({
	INIT_VALUE = {call="plannerAPP__execute_order_INITVALUE",},
	SET_VALUE  = {call="plannerAPP__execute_order_SETVALUE",},
	CMD        = {call="plannerAPP__execute_order_CMD",},
})

local _l_clock = os.clock()
local _l_current = 100
local _l_next = 100
local _l_dayPos_Accuracy = 100
local _l_rain_amount = 0
local _l_wetness = -1
local _l_puddles = -1

local temp_wetness = 0
local temp_wetting = 0
local temp_puddle_drain = 0

local _l_rainFX_difficulty = 4
local _l_wetness_exponent	= 1.4
local _l_wetness_multiplier = 1.0

-- if wetness or water is preselected in Drive menu
local _l_predef_wetness = -1
local _l_predef_water = -1

local _l_humidity = 0
local _l_generatedHumidity = 0
local _l_fog = 0
local _l_generatedFog = 0

local _l_newest_transition = 0.0
local _l_last_transition = -1
local _l_transition_dt = 0.0
local _l_time = os.clock()

local function scale(x)
	return _l_rainV2_scaleCPP:get(x)[1]
end

local function unscale(x)
	return _l_rainV2_unscaleCPP:get(x)[1]
end





function plannerAPP__execute_order_INITVALUE(order)
	if order.content then
		if order.content.section and order.content.key and order.content.value~=nil then
			if order.content.section == "current" then
				if order.content.key == "rain" then
					_l_rain_amount = order.content.value
					if result.variableC > 2.3 then
						if _l_rain_amount >= 0 then
							_l_rain_amount = scale(_l_rain_amount)
						end
					end
					result.rainIntensity = _l_rain_amount
				elseif order.content.key == "wetness" then
					_l_wetness = order.content.value
					if result.variableC > 2.3 then
						if _l_wetness >= 0 then
							_l_wetness = scale(_l_wetness)
						end
					end
					if _l_wetness >= 0 then
						result.rainWetness = _l_wetness
					end
				elseif order.content.key == "puddles" then
					_l_puddles = order.content.value
					if _l_puddles >= 0 then
						result.rainWater = _l_puddles
					end
				elseif order.content.key == "humidity" then
					result.humidity = order.content.value
					_l_humidity = order.content.value
				elseif order.content.key == "fog" then
					result.variableA = order.content.value
					_l_fog = order.content.value
					_l_generatedFog = 0
				elseif order.content.key == "transition" then
					result.transition = order.content.value	
					result.currentType = _l_current
					result.upcomingType = _l_next

					_l_newest_transition = tonumber(order.content['CMD4'])
					if _l_last_transition < 0 then _l_last_transition = _l_newest_transition end
					_l_transition_dt = _l_newest_transition - _l_last_transition
					result.transition = _l_newest_transition
					_l_transition_dt = 0.0

					_l_transition_dt = _l_transition_dt / math.max(0.1, os.clock()-_l_time)
					_l_time = os.clock()
					_l_last_transition = _l_newest_transition

				end
			end
		end
	end
end
function plannerAPP__execute_order_SETVALUE(order)
	if order.content then
		if order.content.section and order.content.key and order.content.value~=nil then
			if order.content.section == "current" then
				if order.content.key == "weatherID" then
					--result.currentType = order.content.value
					-- ac.debug("set current", order.content.value)
					_l_current = order.content.value
				elseif order.content.key == "transition" then
					
					_l_newest_transition = order.content.value
					if _l_last_transition < 0 then _l_last_transition = _l_newest_transition end
					_l_transition_dt = _l_newest_transition - _l_last_transition
					_l_transition_dt = _l_transition_dt / math.max(0.1, os.clock()-_l_time)
					_l_time = os.clock()
					_l_last_transition = _l_newest_transition

				elseif order.content.key == "rain" then
					_l_rain_amount = order.content.value
					if result.variableC > 2.3 then
						if _l_rain_amount >= 0 then
							_l_rain_amount = scale(_l_rain_amount)
						end
					end
				elseif order.content.key == "wetness" then
					_l_wetness = order.content.value
					if result.variableC > 2.3 then
						if _l_wetness >= 0 then
							_l_wetness = scale(_l_wetness)
						end
					end
				elseif order.content.key == "puddles" then
					_l_puddles = order.content.value
				elseif order.content.key == "humidity" then
					_l_humidity = order.content.value
				elseif order.content.key == "fog" then
					_l_fog = order.content.value
				elseif order.content.key == "wind_strength" then
					result.wind.speedFrom = order.content.value
					result.wind.speedTo   = order.content.value
				elseif order.content.key == "wind_dir" then
					result.wind.direction = order.content.value
				elseif order.content.key == "temp_ambient" then
					result.temperatures.ambient = order.content.value
				elseif order.content.key == "temp_road" then
					result.temperatures.road = order.content.value
				end
			elseif order.content.section == "next" then
				if order.content.key == "weatherID" then
					--result.upcomingType = order.content.value
					_l_next = order.content.value
				end
			elseif order.content.section == "stellar" then
				if order.content.key == "posAccuracy" then
					_l_dayPos_Accuracy = order.content.value
				end
			elseif order.content.section == "rainFX" then
				if order.content.key == "difficulty" then
					_l_rainFX_difficulty = order.content.value
					if __CSP_version >= 2253 then
						_l_wetness_exponent 	= 1.8 - _l_rainFX_difficulty*0.2
						_l_wetness_multiplier	= 0.25 + _l_rainFX_difficulty*0.1875

						if _l_predef_wetness > 0 then
							-- scale the pre defined wetness if difficulty is set at startup
							local tmp = math.max(0, math.pow(_l_predef_wetness, _l_wetness_exponent))
							tmp = tmp * _l_wetness_multiplier
							_l_wetness = tmp
							if result.variableC > 2.3 then
								tmp = unscale(tmp)
							end
							__plannerAppInterface:add_order("SET_VALUE", {"show", "wetness", tmp, true})
							__plannerAppInterface:add_order("SET_VALUE", {"debug", "wetness", _l_wetness, true})
							
							_l_predef_wetness = -1
						else
							local tmp = math.max(0, math.pow(result.rainIntensity, _l_wetness_exponent))
							temp_wetness = math.min(tmp*_l_wetness_multiplier, temp_wetness)
							result.rainWetness = math.max(0, math.min(result.rainWetness, temp_wetness))
						end

						if _l_predef_water > 0 then
							__plannerAppInterface:add_order("SET_VALUE", {"show",  "puddles", _l_predef_water, true})
							_l_predef_water = -1
						end
					end
				end
			end
		end
	end
end


function plannerAPP__execute_order_CMD(order)
	if order.content['CMD1'] then

		if order.content['CMD1'] == "ResetToDefaults" then
		--config_manager__reset_to_defaults()
		elseif order.content['CMD1'] == "SaveStandard" then
		--config_manager__store_standard_config_file(false)
		elseif order.content['CMD1'] == "LoadStandard" then
		--config_manager__load_standard_config_file()
		elseif order.content['CMD1'] == "TransisionInit" then
			if order.content['CMD2'] and
				order.content['CMD3'] and
				order.content['CMD4'] then

				--result.transition = tonumber(order.content['CMD4'])
				_l_newest_transition = tonumber(order.content['CMD4'])
				if _l_last_transition < 0 then _l_last_transition = _l_newest_transition end
				_l_transition_dt = _l_newest_transition - _l_last_transition
				result.transition = _l_newest_transition

				_l_transition_dt = _l_transition_dt / math.max(0.1, os.clock()-_l_time)
				_l_time = os.clock()
				_l_last_transition = _l_newest_transition

				_l_current = tonumber(order.content['CMD2'])
				result.currentType = _l_current
				_l_next = tonumber(order.content['CMD3'])
				result.upcomingType = _l_next

				--_l_lerp_transition = result.transition
				--_l_lerp_transition_last = result.transition
				--[[
				_l_lerp_transition_time = 0
				_l_lerp_transition_speed = 0
				_l_lerp_transition_speed_backup = 0
				]]
			end
		elseif order.content['CMD1'] == "system" then
			if order.content['CMD2'] == "check_version" then
				__plannerAppInterface:add_order("INIT_VALUE", {"system","version",result.variableC})
			end
			if order.content['CMD2'] == "INIT_CONTROLLER" then
				___reset__Controller___()
			end
		end
	end
end






if __CSP_version >= 2253 then
	-- RainFX v2

	local wetness_drying_airtempK    = 0.1  --multiplier of wetness is forced to dry by air temperature
	local wetness_drying_airtempMin  = 15    --minimum air temperature of dry process
	local wetness_drying_roadtempK   = 0.1  --multiplier of wetness is forced to dry by road temperature 
	local wetness_drying_roadtempMin = 15   --minimum road temperature of dry process
	local wetness_drying_sunK        = 0.3  --multiplier of wetness is forced to dry by sun
	local wetness_rain_wettingK      = 7.5 --multiplier of wetness gains by rain
	local wetness_humidity_wettingK  = 0.10 --multiplier of wetness gains by humidity

	local puddles_dryingK            = 1.00  --multiplier of puddles are forced to dry
	local puddles_rain_wettingK      = 50.00  --multiplier of puddles gaining by rain
	local puddles_constant_drain	 = 1.00  --multiplier of puddles constantly draining


	local timeK = 0.001 --* time_multi
	local day_curve = 1

	function calc_water(condition, sun, dt)

		local humidity = condition.humidity

		local drying_force = math.max(0, wetness_drying_airtempK  * temp_interpol(condition.temperatures.ambient, wetness_drying_airtempMin, -1, 2))
						+ math.max(0, wetness_drying_roadtempK * temp_interpol(condition.temperatures.road, wetness_drying_roadtempMin, -1, 2))
						+ (wetness_drying_sunK * sun * day_curve)

		local wetness_damper = math.max(0, math.pow(condition.rainIntensity, _l_wetness_exponent) - temp_wetness)
		-- calculate the variable for the whole process 
		local wetting_last = temp_wetting
		temp_wetting  = (

						- 0.034 * drying_force
						-- limit wetness adding to the amount of rain and the wetness itself. It should rise slower with low wetness
						+ 10 * (wetness_rain_wettingK * math.max(0, math.pow(math.max(0, temp_wetting) + 0.1, 0.1) * wetness_damper))
						+ 10 * wetness_humidity_wettingK * (humidity - 0.4) * temp_interpol(condition.temperatures.ambient, wetness_drying_airtempMin, 1, -1) * wetness_damper

						)

		-- update internal wetness
		temp_wetness 		= temp_wetness + temp_wetting * dt * timeK

		-- water from puddles is constantly draining dependent of road temperature
		temp_puddle_drain 	= puddles_constant_drain * temp_interpol(condition.temperatures.road, wetness_drying_roadtempMin, 0, 3)

		if temp_wetting > 0 then
			
			condition.rainWater   = math.saturate(condition.rainWater +
										dt * timeK * (
											puddles_rain_wettingK * condition.rainIntensity * ((condition.rainWetness - 0.0085) * 50)
											- temp_puddle_drain
										))
		elseif temp_wetting < 0 then
			condition.rainWater   = math.min(1, math.max(0, condition.rainWater +
									0.1 * dt * timeK * (
										puddles_dryingK
										- temp_puddle_drain
										)
									))
		end

		if _l_puddles >= 0 then
			condition.rainWater = _l_puddles
		end

		if _l_wetness >= 0 then
			condition.rainWetness = _l_wetness
			temp_wetness = condition.rainWetness
			temp_wetting = 0
			temp_puddle_drain = 0
		else
			local final_wetness = math.max(0, temp_wetness * _l_wetness_multiplier)
			
			local damp = math.min(1, (math.abs(1-100*condition.rainWetness) + 0.05))
			damp = 100 * timeK * damp * dt

			if wetting_last > 0 and temp_wetting < 0 then
				-- If it starts to try, neutralize the calculated wetness to the current condition wetness
				temp_wetness = condition.rainWetness
			else
				condition.rainWetness = math.saturate(condition.rainWetness * (1 - damp) + final_wetness * damp)
			end
		end


		ac.debug("RainFX ", string.format('intensity: %.3f, wetness: %.3f, puddles: %.3f', condition.rainIntensity, condition.rainWetness, condition.rainWater))
		ac.debug("Ground ", string.format('wetting: %.5f, puddles drain: %.5f', temp_wetting, temp_puddle_drain))
		

		local fast_wetting = (math.max(0, temp_wetting*-1 - 0.01))

		-- humidity
		local humid_raise_force = math.max(0, 
								  fast_wetting
								* (math.pow(math.max(0, drying_force-0.13), 3))
								* condition.rainWetness
								* (1-condition.humidity)
								* 3
							)
		local humid_fall_force = 1
		_l_generatedHumidity = condition.humidity +
						( humid_raise_force
						- humid_fall_force) * dt * timeK
		condition.humidity = math.max(_l_humidity, _l_generatedHumidity)

		-- fog
		local fog_raise_force = math.max(0, 
							  	fast_wetting
							  * condition.rainWetness
							  * (math.pow(math.max(0, condition.humidity*2), 2)-2)
							  * (1 - condition.variableA)
							  * 200
							)
		local fog_fall_force  = 1
		_l_generatedFog = math.saturate(
							_l_generatedFog +
							( fog_raise_force - fog_fall_force) * dt * timeK
						)

		condition.variableA = math.lerp(condition.variableA, math.max(_l_fog, _l_generatedFog), dt)
		if condition.variableA < 0.001 then
			condition.variableA = 0
		end
		

		local tmp1 = condition.rainIntensity
		local tmp2 = condition.rainWetness
		if result.variableC > 2.3 then
			tmp1 = unscale(tmp1)
			tmp2 = unscale(tmp2)
		end
		__plannerAppInterface:add_order("SET_VALUE", {"show", "rain", tmp1, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "wetness", tmp2, true})
		__plannerAppInterface:add_order("SET_VALUE", {"debug", "rain", condition.rainIntensity, true})
		__plannerAppInterface:add_order("SET_VALUE", {"debug", "wetness", condition.rainWetness, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "puddles", condition.rainWater, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "humidity", condition.humidity, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "fog", condition.variableA, true})
	end
else
	-- RainFX v1


	--##############################################################################
	-- Rain, Wetness and Puddles controlling
	-- A wetting variable is calculated out of ambient temp., road temp., sunlight, humidity andd rain strength
	-- Drying means wettings is smaller 0
	-- Wetness will get bigger, if wetting is greater 0
	-- Wetness will get smaller, if wetting is smaller 0
	-- Puddles will get bigger if Wetness is bigger then 1 and wetting is greater 0
	-- Puddles will get smaller if Wetness is smaller then 1

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




	local timeK = 0.001 --* time_multi
	local day_curve = 1

	function calc_water(condition, sun, dt)

		local humidity = condition.humidity

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

		if _l_puddles >= 0 then
			condition.rainWater = _l_puddles
		end

		if _l_wetness >= 0 then
			condition.rainWetness = _l_wetness
			temp_wetness = math.min(1, math.max(0, _l_wetness - math.min(0.1, condition.rainWater * 5)))
			temp_wetting = 0
			temp_puddle_drain = 0
		else
			condition.rainWetness = math.min(1, math.max(0, temp_wetness + math.min(0.1, condition.rainWater * 5))) 
		end

		-- internal wetness is limited to 0..300%
		temp_wetness = math.min(3, math.max(0, temp_wetness))

		-- if drying, set internal wetness to 1, to have the right value for drying processes
		if temp_wetting < 0 and temp_wetness >= 1 then temp_wetness = 1 end

		ac.debug("RainFX ", string.format('intensity: %.2f, wetness: %.2f, puddles: %.2f', condition.rainIntensity, condition.rainWetness, condition.rainWater))
		ac.debug("Ground ", string.format('wetting: %.2f, puddles drain: %.2f', temp_wetting*1000, temp_puddle_drain))
		


		-- humidity
		local humid_raise_force = (math.max(0, (temp_wetting*-1)) + (math.pow(math.max(0, drying_force-4), 3) * timeK * dt))
								* math.pow(condition.rainWetness * 1.1, 3)
								* (1-condition.humidity)
		local humid_fall_force = dt * timeK 
		_l_generatedHumidity = condition.humidity +
						( humid_raise_force
						- humid_fall_force) * 10
		condition.humidity = math.max(_l_humidity, _l_generatedHumidity)


		-- fog
		_l_generatedFog = math.max(0, 
							_l_generatedFog +
							(   (math.max(0, temp_wetting*-1)) * condition.rainWetness * (math.pow(condition.humidity*2, 2)-2) * (1 - condition.variableA)
							- (2 * dt * timeK)
							) 
						)
		
		condition.variableA = math.lerp(condition.variableA, math.max(_l_fog, _l_generatedFog), dt)
		if condition.variableA < 0.001 then
			condition.variableA = 0
		end
		
		__plannerAppInterface:add_order("SET_VALUE", {"show", "rain", condition.rainIntensity, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "wetness", condition.rainWetness, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "puddles", condition.rainWater, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "humidity", condition.humidity, true})
		__plannerAppInterface:add_order("SET_VALUE", {"show", "fog", condition.variableA, true})
	end
end

local angles = {0,0}


local last_dayPos = 0
function calc_DayPosition()

	sunDir  = ac.getSunDirection()
	vec32sphereTo(angles, sunDir)
	__sun_angle = angles[2]

	local AC_TIME = ac.getDaySeconds()

	_l_sun__LUT = _l_sun_posCPP:get()
	_l_day__LUT = _l_day_posCPP:get(AC_TIME)

	local pos = 0
	--pos = math.lerp( math.lerp( math.lerp( pos, 5, afternoon ), 4, noon ), 3, morning )
	if AC_TIME < 43200 then
		pos = math.lerp( _l_day__LUT[1], _l_sun__LUT[1], _l_sun__LUT[2])
	else
		pos = math.lerp( _l_day__LUT[1], 9-_l_sun__LUT[1], _l_sun__LUT[2])
	end

	pos = math.floor(pos*_l_dayPos_Accuracy)/_l_dayPos_Accuracy
	if pos ~= last_dayPos then
		__plannerAppInterface:add_order("INIT_VALUE", {"stellar", "dayPos", pos})
		last_dayPos = pos
	end
end









--ac.debug("###", trackCoordinates.x..","..trackCoordinates.y..","..timeZoneOffset)
--ac.getDaySeconds()
--ac.getDayOfTheYear()





calc_DayPosition()
__plannerAppInterface:add_order("INIT_VALUE", {"base","weatherID",result.currentType})
__plannerAppInterface:add_order("INIT_VALUE", {"base","rain",result.rainIntensity})
__plannerAppInterface:add_order("INIT_VALUE", {"base","humidity",result.humidity})
__plannerAppInterface:add_order("INIT_VALUE", {"base","fog",result.variableA})
__plannerAppInterface:add_order("INIT_VALUE", {"base","wind_strength",(result.wind.speedFrom + result.wind.speedTo)*0.5 })
__plannerAppInterface:add_order("INIT_VALUE", {"base","wind_dir",result.wind.direction})
__plannerAppInterface:add_order("INIT_VALUE", {"base","temp_ambient",result.temperatures.ambient})
__plannerAppInterface:add_order("INIT_VALUE", {"base","temp_road",result.temperatures.road})

__plannerAppInterface:add_order("INIT_VALUE", {"stellar","TrackCoordinatesLong",trackCoordinates.x})
__plannerAppInterface:add_order("INIT_VALUE", {"stellar","TrackCoordinatesLat",trackCoordinates.y})

__plannerAppInterface:add_order("INIT_VALUE", {"system","version",result.variableC})

local lastDayOfYear
local lastDaySeconds = 0
local lastOsSeconds = os.clock()
function send_sun_related()
	lastDayOfYear = ac.getDayOfTheYear()
	__plannerAppInterface:add_order("INIT_VALUE", {"stellar","DayOfTheYear",lastDayOfYear})
	__plannerAppInterface:add_order("INIT_VALUE", {"stellar","TimeZoneOffset",ac.getTimeZoneOffset()})
	__plannerAppInterface:add_order("INIT_VALUE", {"stellar","moonphase",ac.getMoonFraction()})
end
send_sun_related()

-- trigger rainFX to avoid stutter
--result.rainWater = 0.02
ac.setConditionsSet(result)



local _l_dry = { 15, 16, 17, 18, 19, 21, 23, 25, 31 }
local _l_wet = { 3, 4, 5, 6, 7, 26 }
local _l_bad = { 2, 5, 8, 11, 14, 20, 27, 28 }
local function get_random_from_list(list)
	if list~=nil and #list>0 then
		local tmp = #list
		math.randomseed(os.clock())
		tmp = math.floor(math.random()*tmp) + 1
		return list[tmp]
	end
	return -1
end

if __CSP_version >= 2363 then --0.1.80p218

	SOL2_CM_DRIVE__buildMenu()

	if not __SOL_2_STATIC__controller then

		local cfg = SOL2_CM_DRIVE__readSettings()

		if SOL2_CM_DRIVE__getWeatherRealId(cfg.START_WEATHER) < 44 then

			result.currentType  = SOL2_CM_DRIVE__getWeatherRealId(cfg.START_WEATHER)

			if result.currentType == 40 then
				result.currentType = get_random_from_list(_l_dry)
			elseif result.currentType == 41 then
				result.currentType = get_random_from_list(_l_wet)
			elseif result.currentType == 42 then
				result.currentType = get_random_from_list(_l_bad)
			elseif result.currentType == 43 then
				math.randomseed(os.clock())
				repeat
					result.currentType = math.floor(math.random()*30) + 1
				until result.currentType~=29 and result.currentType~=30 -- not used in Sol Planner
			end
		end

		result.upcomingType = result.currentType

		__plannerAppInterface:add_order("INIT_VALUE", {"base","weatherID",result.currentType})

		local tmp = cfg.START_WETNESS
		if tmp < 2 then
			-- Auto
			_l_wetness = __weather_params[result.currentType][3]
		elseif tmp < 3 then
		elseif tmp < 4 then
			_l_wetness = 0.005
		elseif tmp < 5 then
			_l_wetness = 0.01
		elseif tmp < 6 then
			_l_wetness = 0.05
		elseif tmp < 7 then
			_l_wetness = 0.25
		end

		result.rainWetness = _l_wetness
		_l_predef_wetness = _l_wetness

		local tmp = cfg.START_PUDDLES
		if tmp < 2 then
			-- Auto
			_l_puddles = __weather_params[result.currentType][4]
		elseif tmp < 3 then
		elseif tmp < 4 then
			_l_puddles = 0.25
		elseif tmp < 5 then
			_l_puddles = 0.50
		elseif tmp < 6 then
			_l_puddles = 1.00
		end

		result.rainWater = _l_puddles
		_l_predef_water = _l_puddles
	end
else

end





function init_controller()

	local config = nil

	if __CSP_version < 2349 then -- 0.1.80p204
		config = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg)..'\\race.ini', ac.INIFormat.Default)
	else
		config = ac.INIConfig.raceConfig()
	end

	if config ~= nil then
		local weather_name = config:get('WEATHER', 'NAME', '')
		if weather_name ~= '' then
			local weather = ac.INIConfig.load(ac.getFolder(ac.FolderID.Root)..'\\content\\weather\\'..weather_name..'\\weather.ini', ac.INIFormat.Default)
			if weather ~= nil then

				local found = false
				for tmp in pairs(weather.sections) do
					if tmp=="RAINFX" then
						found = true
						break
					end
				end

				if found then
					result.rainIntensity 	= weather:get('RAINFX', 'INTENSITY', 0.0)
					result.rainWetness 		= weather:get('RAINFX', 'WETNESS', 0.0)
					result.rainWater 		= weather:get('RAINFX', 'WATER', 0.0)

					local tmp1 = result.rainIntensity
					local tmp2 = result.rainWetness
					if result.variableC > 2.3 then
						tmp1 = unscale(tmp1)
						tmp2 = unscale(tmp2)
					end
					__plannerAppInterface:add_order("INIT_VALUE", {"show",  "rain", tmp1, true})
					__plannerAppInterface:add_order("INIT_VALUE", {"show",  "wetness", tmp2, true})
					__plannerAppInterface:add_order("INIT_VALUE", {"debug", "rain",    result.rainIntensity, true})
					__plannerAppInterface:add_order("INIT_VALUE", {"debug", "wetness", result.rainWetness, true})
					__plannerAppInterface:add_order("INIT_VALUE", {"show",  "puddles", result.rainWater, true})
				end
			end
		end
	end
end
init_controller()






local _l_debug_memory = false
if _l_debug_memory then

	local gcSmooth = 0
	local gcRuns = 0
	local gcLast = 0
	function runGC()
		local before = collectgarbage('count')
		collectgarbage()
		gcSmooth = math.applyLag(gcSmooth, before - collectgarbage('count'), gcRuns < 50 and 0.9 or 0.995, 0.05)
		gcRuns = gcRuns + 1
		gcLast = math.floor(gcSmooth * 100) / 100
	end

	function printGC()
		ac.debug("Runtime | collectgarbage", gcLast .. " KB")
	end
end



local _l_tmp_vec = vec3(0,0,0)



function update(dt)

	ac.getSunDirectionTo(_l_tmp_vec)
	vec32sphereTo(angles, _l_tmp_vec)
    __sun_heading = angles[1]
	__sun_angle   = angles[2]

	ac.getMoonDirectionTo(_l_tmp_vec)
    vec32sphereTo(angles, _l_tmp_vec)
    __moon_heading = angles[1]
	__moon_angle   = angles[2]

	--ac.debug("####", os.date("*t", tonumber(ac.getInputDate())).year )

	if lastDayOfYear ~= ac.getDayOfTheYear() then
		send_sun_related()
	end
	if (lastOsSeconds+1 < os.clock()) or (lastDaySeconds ~= ac.getDaySeconds()) then
		lastDaySeconds = ac.getDaySeconds()
		lastOsSeconds  = os.clock()
		__plannerAppInterface:add_order("INIT_VALUE", {"stellar","DaySeconds", lastDaySeconds})
		__plannerAppInterface:add_order("INIT_VALUE", {"stellar","sunangle", __sun_angle})
		__plannerAppInterface:add_order("INIT_VALUE", {"stellar","moonangle", __moon_angle})
	end

	--calc_DayPosition()
	__plannerAppInterface:update()

	result.rainIntensity = math.lerp(result.rainIntensity, _l_rain_amount, dt*0.25)

	
	--elseif math.abs(result.transition - _l_lerp_transition) > 0.1 then
	--	result.transition = _l_lerp_transition
	--	ac.debug("####","set")
	

	result.transition = math.max(0, math.min(1.0, result.transition + _l_transition_dt * 1.1 * dt))
	if math.abs(result.transition - _l_newest_transition) > 0.1 then 
		result.transition = _l_newest_transition
	end


	if __weather_params[result.currentType] and __weather_params[result.upcomingType] then
		
		local sun = math.lerp(__weather_params[result.currentType][5], __weather_params[result.upcomingType][5], result.transition)
				  * math.pow(1 - result.variableA, 0.67) --fog

		calc_water(result, sun, dt)
	else
		-- double check for first frames of a second, where interace communication is initialized
		result.currentType = 100
		result.upcomingType = 100
	end


	if __CSP_version >= 2253 then
		ac.setConditionsSet2(result)
	else
		ac.setConditionsSet(result)
	end

	if _l_debug_memory then
		runGC()
		printGC()
	end

	
end