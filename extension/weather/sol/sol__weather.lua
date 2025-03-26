local test_wf = 0


dofile (__sol__path.."gfx\\sol__gfx_tools.lua")

--CUSTOM WEATHER
__CW = {}
__CW["sky"] = {} 
dofile (__sol__path.."custom weather\\sol__custom_weather.lua")
dofile (__sol__path.."custom weather\\sol__custom_weather__interface.lua")


dofile (__sol__path.."sol__weather_definitions.lua")
if sol_custom_weather_definitions ~= nil then sol_custom_weather_definitions() end

local _l_config__clouds__render_method = SOL__config("clouds", "render_method")

dofile (__sol__path.."clouds\\sol__cloud_storage.lua")
if _l_config__clouds__render_method == 0 then
	dofile (__sol__path.."clouds\\2d\\sol__2d_clouds.lua")
elseif _l_config__clouds__render_method == 1 then
	dofile (__sol__path.."clouds\\3d_basemod\\weather_application.lua")
	dofile (__sol__path.."clouds\\3d_basemod\\weather_clouds.lua")
elseif _l_config__clouds__render_method == 2 then
	dofile (__sol__path.."clouds\\sol_skysim.lua")
end


dofile (__sol__path.."gfx\\sol__gfx_sun.lua")
dofile (__sol__path.."gfx\\sol__gfx_ambient.lua")
dofile (__sol__path.."gfx\\sol__gfx_fog.lua")
dofile (__sol__path.."gfx\\sol__gfx_pollution.lua")
dofile (__sol__path.."gfx\\sol__gfx_direct_ambi.lua")

local _l_controller_version = 2.1

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

local cpu_split = 0
local cpu_split_count = 4
local cpu_split_first_cycle = true

__base__plan_past = {}
__base__plan_future = {}

local _l_custom_sky_preset_LUT = {}

__vari = 1.0 + rnd(1.0) --variable value sets in base plans

__PPoff__brightness__regulation = 1.00
__ambient_color = hsv.new(200,0.1,15)
__ambient_color_raw = hsv.new(200,0.1,20)
__sky_color 	= hsv.new(200,0.1,9)
__sky_fog		= 0
__sky_light_bounce = 0
__light_pollution = hsv.new(0,0,0)
__light_pollution__raw = hsv.new(0,0,0)
__sun_color 	= hsv.new( 45,0.1,10)
__fog_color		= hsv.new(200,0.1,1)
__bright_adapt	= 1
__smog 			= 0
__dazzle__interpol = 0

--main sky object
__Sky = nil

__fog_dense = 0.00
__overcast  = 0.00
__humidity = 0.00
__inair_material = { color=hsv.new(0, 1.00, 1.00), dense=1.00, granulation = 0.0 }
__rain = 0.0
__water_on_road = 0.00
__badness = 0.00
__cloud_density = 0.00
__cloud_transition_density = 0.00

__night__effects_multiplier = 0
__night__brightness_adjust = 0

__condition   = ac.getConditionsSet()

__temperature = 20

__wind_direction = 0
__wind_speed = 0

__track__horizont_contour_dynamic_fix = 1
__track__horizont_contour_static_fix  = 1

local start_dim = os.clock()
local replay_force_change = false

function weather__get_fog_dense() return __fog_dense end
function weather__get_humidity() return __humidity end
function weather__get_overcast() return __overcast end
function weather__get_badness() return __badness end
function weather__get_cloud_shadow() 
	local shadow = (1-ac.getCloudsShadow())*(1-0.75*__overcast)

	if SOL__config("debug", "weather_effects") == true then
		ac.debug("Weather FX - Clouds shadow", string.format('%.2f', shadow))
	end
	return shadow
end
function weather__get_cloud_density()
	if _l_config__clouds__render_method < 2 then 
		return __cloud_transition_density
	else
		return __sky_light_bounce --use the light bounce ratio / it is quasi the cloud coverage
	end
end
function weather__get_ambient_brightness() return __ambient_color_raw.v end
function weather__get_rainIntensity() 
	if __condition and __condition.rainIntensity then
		return __condition.rainIntensity
	else
		return 0
	end
end

function weather__get_rainIntensity_Scaled() 
	if __condition and __condition.rainIntensity then
		local tmp = __condition.rainIntensity

		if __CSP_version >= 2253 then
			-- RainFX v2
			if __condition.variableC >= 2.3 then
				tmp = math.pow(math.saturate(_l_rainV2_unscaleCPP:get(tmp)[1]), 0.5)
			end
		end
	
		return tmp
	else
		return 0
	end
end

function weather__get_rainWetness()
	if __condition and __condition.rainWetness then
		return __condition.rainWetness
	else
		return 0
	end
end
function weather__get_rainWater()
	if __condition and __condition.rainWater then
		return __condition.rainWater
	else
		return 0
	end
end

local __altitude__fix = 0
if ac.getAltitude() ~= nil and ac.getAltitude() < 0 then __altitude__fix = __CM__altitude end -- backup altitude from date_location
if SOL__config("debug", "track") == true then
	ac.debug("Track: Altitude", math.floor(ac.getAltitude()).." m")
end







-- blue sky boost
--- 8 ---


local blue_sky_booster = 1.0
local blue_sky_booster__adjustHSV = hsv(1,1,1)
local blue_sky__adjustHSV = hsv(1,1,1)
local blue_sky_horizont_gradient = 1
local blue_sky_horizont_height = 1




-- init WFX - lightning sky_gradient at last / otherwise they are covered!
init__SOL_WFX()


function weather_defs__get__plan(id)

	if __weather_defs[id] ~= nil then

		return base__create_mix(__weather_defs[id]["base"][1], __weather_defs[id]["base"][2], __weather_defs[id]["basemix"])
	else

	end
end


local weather_change_time = 120
local weather_stay_time = 120


-- initial value: performance weather 
__weather_id_past   = 102
__weather_id_future = 102


--__base__plan_past   = weather_defs__get__plan(__weather_id_past)
--__base__plan_future = weather_defs__get__plan(__weather_id_future)

__weather_change_momentum = 0.0 -- force to build first weather

--local current__plan = __base__plan_past


function reset_weather(use_controller)
	-- complete reset of the weather

	--ac.debug("## reset weather", os.clock())

	if use_controller == nil then use_controller = true end

	if use_controller == true then
		__weather_id_past   = __condition.currentType+1
		__weather_id_future = __condition.upcomingType+1
	end

	if __weather_defs[__weather_id_past] == nil then __weather_id_past = 102 end
	if __weather_defs[__weather_id_future] == nil then __weather_id_future = 102 end 

	if SOL__config("debug", "weather_change") == true then ac.debug("Change: Reset:", __weather_defs[__weather_id_past]["name"]) end
	
	if _l_config__clouds__render_method == 0 then
		-- init the current weather
		clouds_set_density(__weather_defs[__weather_id_past]["clouds"][1]+rnd(__weather_defs[__weather_id_past]["clouds"][2]), true)
		-- force cloudset
		init__clouds()
		if SOL__config("debug", "weather_change") == true then ac.debug("Change: Reset:", __weather_defs[__weather_id_past]["name"]) end

		-- prepare weather change / build cloud's change stack
		clouds_set_density(__weather_defs[__weather_id_future]["clouds"][1]+rnd(__weather_defs[__weather_id_future]["clouds"][2]), false)

		-- check clouds for momentum / remove+add the clouds out of the change stack till they reach momentum
		check_momentum()
	elseif _l_config__clouds__render_method == 1 then

	elseif _l_config__clouds__render_method == 2 then
		__Sky:buildWeather(true)
	end

	reset__SOL_WFX()

	--preset water on road
	__water_on_road = __weather_defs[__weather_id_past]["water_on_road"]
end


function weather__change_weather(complete_change, swap)

	--ac.debug("## change weather", os.clock())

	if complete_change == nil then complete_change = true end
	if swap == nil then swap = true end

	if complete_change == true then
		-- only change the current weather with complete changes
		__weather_id_past = __weather_id_future
	end

	__weather_id_future = __condition.upcomingType+1

	if _l_config__clouds__render_method == 0 then
		check__clouds_density()
		clouds_set_density(__weather_defs[__weather_id_future]["clouds"][1], complete_change)
	elseif _l_config__clouds__render_method == 1 then

	elseif _l_config__clouds__render_method == 2 then
		__Sky:buildWeather(swap)
	end
	

	reset__SOL_WFX()
end


--set new fog algorithm
ac.setFogAlgorithm(ac.FogAlgorithm.New) 


function calculate_inair_material()

	local a=hsv.new(0,0,0)
	local b=hsv.new(0,0,0)

	if __weather_defs[__weather_id_past]["inair_material"] == nil then 

		__weather_defs[__weather_id_past]["inair_material"] = { color=hsv.new(210, 0.0, 1.00), dense=0.00, granulation = 0.0 }
	end

	if __weather_defs[__weather_id_future]["inair_material"] ==nil then

		__weather_defs[__weather_id_future]["inair_material"] = { color=hsv.new(210, 0.0, 1.00), dense=0.00, granulation = 0.0 }
	end
	
	-- prevent access to source by copying single values
	a.h = __weather_defs[__weather_id_past]["inair_material"].color.h
	a.s = __weather_defs[__weather_id_past]["inair_material"].color.s
	a.v = __weather_defs[__weather_id_past]["inair_material"].color.v

	b.h = __weather_defs[__weather_id_future]["inair_material"].color.h
	b.s = __weather_defs[__weather_id_future]["inair_material"].color.s
	b.v = __weather_defs[__weather_id_future]["inair_material"].color.v

	if angle_diff(a.h, b.h) > 0.5 then
		-- if hue differs too much, make saturation = 0, when __weather_change_momentum = 0.5

		a.s = a.s * math.max(0, (0.5 - __weather_change_momentum) * 2)
		b.s = b.s * math.max(0, ((__weather_change_momentum - 0.5) * 2))
	end

	--ac.debug("### calculate_inair_material a.s", a.s)
	--ac.debug("### calculate_inair_material b.s", b.s)

	local sat_span = math.max(1, b.s)/math.max(1, a.s)
	
	__inair_material.color = mixHSV2(a, b, math.pow(__weather_change_momentum, sat_span))
	__inair_material.dense = math.lerp(__weather_defs[__weather_id_past]["inair_material"].dense, __weather_defs[__weather_id_future]["inair_material"].dense, __weather_change_momentum)
	__inair_material.granulation = math.lerp(__weather_defs[__weather_id_past]["inair_material"].granulation, __weather_defs[__weather_id_future]["inair_material"].granulation, __weather_change_momentum)
end

function calculate_cloud_density()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["clouds"][1] ~= nil then a = __weather_defs[__weather_id_past]["clouds"][1] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["clouds"][1] ~= nil then b = __weather_defs[__weather_id_future]["clouds"][1] end
	if b==nil or b<0 then

		b = 0
	end

	__cloud_transition_density = math.min(1, math.max(0, math.lerp(a,b,__weather_change_momentum)))

	if _l_config__clouds__render_method == 1 then 

		__cloud_transition_density = math.max(0, math.pow(__cloud_transition_density, 1.2) - 0.02) * 1.05
	end
end

function calculate_fog_dense()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["fog_dense"] ~= nil then a = __weather_defs[__weather_id_past]["fog_dense"] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["fog_dense"] ~= nil then b = __weather_defs[__weather_id_future]["fog_dense"] end
	if b==nil or b<0 then

		b = 0
	end

	__fog_dense = math.lerp(a,b,__weather_change_momentum)
end

function calculate_humidity()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["humidity"] ~= nil then a = __weather_defs[__weather_id_past]["humidity"] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["humidity"] ~= nil then b = __weather_defs[__weather_id_future]["humidity"] end
	if b==nil or b<0 then

		b = 0
	end

	__humidity = math.lerp(a,b,__weather_change_momentum)
	__humidity = math.max(__humidity, ta_humidity_offset)
end

function calculate_overcast()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["overcast"] ~= nil then a = __weather_defs[__weather_id_past]["overcast"] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["overcast"] ~= nil then b = __weather_defs[__weather_id_future]["overcast"] end
	if b==nil or b<0 then

		b = 0
	end

	__overcast = math.lerp(a,b,__weather_change_momentum)
end

function calculate_rain()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["rain"] ~= nil then a = __weather_defs[__weather_id_past]["rain"] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["rain"] ~= nil then b = __weather_defs[__weather_id_future]["rain"] end
	if b==nil or b<0 then

		b = 0
	end

	if a < b then
		__rain = math.lerp(a,b,math.pow(__weather_change_momentum, 10))
	else
		__rain = math.lerp(a,b,math.pow(__weather_change_momentum, 0.3))
	end
end

function calculate_badness()

	local a=-1
	local b=-1

	if __weather_defs[__weather_id_past]["badness"] ~= nil then a = __weather_defs[__weather_id_past]["badness"] end
	if a==nil or a<0 then

		a = 0
	end

	if __weather_defs[__weather_id_future]["badness"] ~= nil then b = __weather_defs[__weather_id_future]["badness"] end
	if b==nil or b<0 then

		b = 0
	end

	__badness = math.lerp(a,b,__weather_change_momentum)
end

function calculate_WFX()

	local a=-1
	local b=-1

	if SOL__config("weather", "use_lightning_effect") == true then

		a=-1
		b=-1

		-- lightning
		if __weather_defs[__weather_id_past]["WFX__lightning"] ~= nil then a = __weather_defs[__weather_id_past]["WFX__lightning"] end
		if a==nil or a<0 then

			a = 0
		end

		if __weather_defs[__weather_id_future]["WFX__lightning"] ~= nil then b = __weather_defs[__weather_id_future]["WFX__lightning"] end
		if b==nil or b<0 then

			b = 0
		end

		-- use always the smaller value
		if a < b and __weather_change_momentum < 0.9 then
			b = a
		elseif a > b and __weather_change_momentum > 0.1 then
			a = b
		end

		--ac.debug("###", math.lerp(a,b,__weather_change_momentum))
		SOL__WFX_set_lightning(math.lerp(a,b,__weather_change_momentum))
	end
end


local init = false
local first_time_onboard = false
local weather__changed = false

function update__weather()

	__night__effects_multiplier = SOL__config("night", "effects_multiplier")
	__night__brightness_adjust  = SOL__config("night", "brightness_adjust")
	local _l_config__cpu_split  = SOL__config("performance", "use_cpu_split")

	cpu_split = cpu_split + 1
	if cpu_split > cpu_split_count then

		cpu_split = 1
	end

	-- track dependent fix of brightness, to avoid too bright textures / sol_track_adaptions.lua
	local l__ta_exp_fix = night_compensate(ta_exp_fix)

	-- try to adapt the tracks horizont contour via ta_sun_dawn and ta_sun_dusk
	__track__horizont_contour_dynamic_fix = (interpolate_day_time(ta_sun_dawn, (ta_sun_dawn+ta_sun_dusk)*0.5, ta_sun_dusk)-1)
	__track__horizont_contour_static_fix  = (ta_sun_dawn+ta_sun_dusk)*0.5


	
	if first_time_onboard == false then

		if ac.isInteriorView() == true then

			first_time_onboard = true
			start_dim = os.clock()
		else

			if start_dim == nil then start_dim = os.clock() end
		end
	end
	start_dim = math.max(0, math.min(1, (os.clock() - start_dim) * 5 ))




	------------------------------------------------------------------------------------
	-- controller integration
	------------------------------------------------------------------------------------
	__condition   = ac.getConditionsSet()
	_l_controller_version = __condition.variableC or 2.1
	_l_controller_version = math.round(_l_controller_version*10)*0.1
	
	if __CW__.CustomWeather__.use == true then

		if __weather_id_past ~= 999 or __weather_id_future ~= 999 then

			__weather_id_past   = 999
			__weather_id_future = 999

			-- reset weather without controller
			reset_weather(false)
		end

		__temperature 	 	= __CW__.CustomWeather__temperature.ambient
		__temperature_road  = __CW__.CustomWeather__temperature.road

		__wind_direction = __CW__.CustomWeather__wind.direction
		__wind_speed 	 = __CW__.CustomWeather__wind.speed

		if _l_controller_version >= 2.1 then
			__humidity 		 = __CW__.CustomWeather__Pollutions.Humidity
			__fog_dense		 = __CW__.CustomWeather__Pollutions.Mist
		end
	else

		__condition.transition   = math.min(1, math.max(0, __condition.transition))
		--if replay_force_change == true and __condition.transition == 1 then __condition.transition = 0
		--else
		replay_force_change = false
		--end

		__temperature 		= __condition.temperatures.ambient or 20
		__temperature 		= math.min(40, math.max(0, __temperature))
		__temperature_road 	= __condition.temperatures.road or 20
		__temperature_road  = math.min(80, math.max(0, __temperature_road))

		__wind_direction = __condition.wind.direction or 0
		__wind_speed 	 = ((__condition.wind.speedFrom or 0) + __condition.wind.speedTo)*0.5

		if _l_controller_version >= 2.1 then
			__humidity 		 = math.max(0, math.min(1, __condition.humidity or 0.0))
			__fog_dense		 = math.max(0, math.min(1, __condition.variableA or 0.0))
		end
--[[
		if __condition.transition > 0.05 and __calc_bug__ then
			__weather__force__reset = true
		end
]]		


		if ac.isInReplayMode() == true then
			local diff = math.abs(__weather_change_momentum - __condition.transition)
			if diff > 0.25 then

				if (diff > 0.95) and __condition.transition < 0.01 then
					-- a weather change happend, do not reset
					replay_force_change = false
				else
					__weather_change_momentum = __condition.transition
					replay_force_change = true
					reset_weather()
				end
				
			end
		end

		--prevent weather transition check if its been recognized while replay
		if replay_force_change == false then 

			if __weather_id_past == 102 and __weather_defs[__condition.currentType+1] == nil and
			__weather_id_future == 102 and __weather_defs[__condition.upcomingType+1] == nil then

			--do nothing when the weather is not defined - 102 is already running	

			elseif  ((__weather_id_past   ~= __condition.currentType+1  and __weather_defs[__weather_id_past] ~= nil) or
					(__weather_id_future ~= __condition.upcomingType+1 and __weather_defs[__weather_id_future] ~= nil)) or
					init == true then
				
				if (__weather_id_future == __condition.currentType+1) and
					__condition.transition < 0.01 and
					init == false then

					if math.abs(__weather_change_momentum - __condition.transition) < 0.9 then
						-- if weather jumping around, maybe from switching in Sol Planner
						reset_weather()
					else

						if __condition.currentType ~= __condition.upcomingType then
							-- swap future to past for next weather

							-- !!! set the momentum 08.12.2021 - for 2d clouds !!!
							__weather_change_momentum = __condition.transition

							weather__change_weather(true, false)

							weather__changed = true
						else
							__weather_id_past   = __condition.currentType+1
							__weather_id_future = __condition.upcomingType+1
						end
					end

				elseif (__weather_id_past == __condition.currentType+1 and __weather_id_future ~= __condition.upcomingType+1) and
				__condition.transition < 0.01 and

					init == false --[[and
					weather__changed == false]] then
					-- if weather change has not started yet, but upcomming weather changes, just reinit the future
					weather__change_weather(false, false)
					--ac.debug("####", "only future init")

					weather__changed = true
				else	 
					--ac.debug("####", "reset "..os.clock())
					
					reset_weather()
					init = false

					-- reset AE in filter
					init_ae()

					weather__changed = true
				end
			else
				-- if weather has not changed
				if __weather_id_past == __condition.currentType+1 and __weather_id_future == __condition.upcomingType+1 then
					if math.abs(__weather_change_momentum - __condition.transition) > 0.1 then
						-- but transition made a jump
						reset_weather()
						--ac.debug("####", "reset "..os.clock())
					end
				end

			end

			-- reset weather changing blocker
			if __condition.transition > 0.01 then weather__changed = false end

			-- always check for the right clouds -> if transition time was to short, to change all clouds
			if _l_config__clouds__render_method == 0 then
				check_momentum()
				--check__clouds_density()
			elseif _l_config__clouds__render_method == 1 then

			end

			__weather_change_momentum = __condition.transition
		end
		

		if SOL__config("debug", "weather_change") == true then
			ac.debug("Change: Transition",string.format('%.3f', __weather_change_momentum))
			if __weather_defs[__weather_id_past] then
				ac.debug("Change: W. Current", __weather_defs[__weather_id_past]["name"])
			else
				ac.debug("Change: W. Upcoming", "undefined")
			end
			if __weather_defs[__weather_id_future] then
				ac.debug("Change: W. Upcoming", __weather_defs[__weather_id_future]["name"])
			else
				ac.debug("Change: W. Upcoming", "undefined")
			end
		end
	end
	------------------------------------------------------------------------------------

	if _l_config__cpu_split==false or cpu_split_first_cycle==true or cpu_split == 1 then
		-- calculate the modulators
		calculate_inair_material()
		if _l_config__clouds__render_method < 2 then calculate_cloud_density() end
		if _l_controller_version < 2.1 then
			calculate_fog_dense()
			calculate_humidity()
		end
		calculate_overcast()
		--calculate_water_on_road()
		calculate_rain()
		calculate_badness()
		calculate_WFX()


		--[[
		if __CSP_version >= 627 then -- since version 1.25.69
			if ac.isRainFxActive() == true then

				if weather__set_rain_automatically == true then

					if __rain > 0.05 then
						ac.setRainAmount(__rain)
					else
						ac.setRainAmount(0.0)
					end
				else

					if weather__set_rain_amount >= 0 then

						ac.setRainAmount(weather__set_rain_amount)
						__rain = weather__set_rain_amount
					else

						__rain = ac.getRainAmount()
					end
				end
			end
		end
		]]
	end
	

	--limit the modulators
	__inair_material.dense  = math.min( 3.0, math.max(0, __inair_material.dense) )
	__inair_material.granulation  = math.min( 1.0, math.max(0, __inair_material.granulation) )
	__fog_dense = math.min( 1.0, math.max(0, __fog_dense) )
	__overcast  = math.min( 1.0, math.max(0, __overcast) )


	-- WATER
	__water_on_road = math.min( 1.0, math.max( 0, __water_on_road ) )
	ac.setTrackCondition("wfx_WET", __water_on_road)

	if ac.setTrackConditionInput then
		local ambi_darkness = 1 - math.max(0, math.min(1, __ambient_color_raw.v * 0.1 - 0.16))
		ac.setTrackConditionInput('AMBIENT', ambi_darkness)
	end


	
	--lower fata morgana
	local lfm_effect = math.min(1.1, math.max(0, (__temperature_road-20))*0.031) * math.min(1, math.max(0, 1-math.pow((__wind_speed*0.025),2)))
	--ac.setExtraAsphaltReflectionsMultiplier(lfm_effect)
	lfm_effect = math.pow(lfm_effect, 3)
	ac.setTrackHeatFactor(lfm_effect)


	--calculate track based smog multi 0..1
	__smog = interpolate_day_time(ta_smog_morning, ta_smog_noon, ta_smog_evening)
				 * math.min(1, math.max(0, SOL__config("sky", "smog")))
				 * (1-math.min(1, 1.5*__inair_material.dense))

	--add smog with high or low temperatures
	__smog = math.min(1, __smog + __IntD(0.1,0.3)*math.abs(1-temp_interpol_unipolar(17, 1, -0.5)))
	__smog = math.pow(__smog, 1.25)
	__smog = __smog * (1-math.pow(__fog_dense, 0.5))

	local _l_smog = math.min(1, __smog * SOL__config("sky", "smog"))

	local fog_night = __smog
	fog_night = fog_night * (1.5*(_l_smog))



	--debug
	if SOL__config("debug", "weather") == true then

		ac.debug("Weather",string.format('Temp: %.2f/%.2F °C, Wind speed: %.2f km/h',__temperature, __temperature_road, __wind_speed))
		ac.debug("Weather: Fog dense", string.format('%.2f', __fog_dense))
		ac.debug("Weather: Rain amount", string.format('%.2f', __rain))
	end

	-- get altitude from CM
	local cm_extern_altitude = ac.getAltitude()
	if cm_extern_altitude ~= nil then

		__CM__altitude = cm_extern_altitude + __altitude__fix
		
	end
	
	--__CM__altitude = 400
	if SOL__config("debug", "camera") == true then ac.debug("Camera: Altitude", string.format('%.2f m', __CM__altitude)) end


 

	if _l_config__cpu_split==false or cpu_split_first_cycle==true or cpu_split == 2 then
	    
	    update_skysim_dome()
	end
	
	if _l_config__cpu_split==false or cpu_split_first_cycle==true or cpu_split == 3 then
		
		gfx__update_pollution()
		gfx__update_sunlight()
	end

	if _l_config__cpu_split==false or cpu_split_first_cycle==true or cpu_split == 4 then

		gfx__update_ambient()
		gfx__update_fog()
	end


	cpu_split_first_cycle = false
end

function update__weather__every_frame()

	gfx__update_directional_ambient_light()

	--local refl_adapt_to_sky = math.max(0.25, math.pow(SOL__config("nerd__sky_adjust","SunIntensityFactor"), 0.5))
	local _l_config__ref_bright = SOL__config("gfx", "reflections_brightness") * (1.25 + 0.25*__overcast - 0.125*weather__get_cloud_shadow())
	if nopp__use_sol_without_postprocessing then
		_l_config__ref_bright = _l_config__ref_bright * 1.25
	end
	
	if __CSP_version >= 1199 then --1.65.41 / addded reflections manipulation
		--ac.setReflectionsBrightness(_l_config__ref_bright * day_compensate(2.5) / math.max(0.01, refl_adapt_to_sky))
		ac.setReflectionsBrightness(_l_config__ref_bright * day_compensate(2.5))
		ac.setReflectionsSaturation(SOL__config("gfx", "reflections_saturation"))
	end
end