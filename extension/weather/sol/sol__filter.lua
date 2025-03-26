local _l_ppf__godrays_length      	= ppfilter__get_value("GODRAYS", "LENGTH") or 5
local _l_ppf__godrays_angle_att   	= ppfilter__get_value("GODRAYS", "ANGLE_ATTENUATION") or 15
local _l_ppf__godrays_glare_ratio 	= ppfilter__get_value("GODRAYS", "GLARE_RATIO") or 0.05
local _l_ppf__godrays_map_threshold = ppfilter__get_value("GODRAYS", "DEPTH_MASK_THRESHOLD") or 1

n=1
local godrays = {
	{  -180, 0 },
	{ -89.5, 0 },
	{   -88, 1 },
	{     0, 1 },
}
local godraysCPP = LUT:new(godrays, nil, true)


n=1
local dazzle = {
	{  -180, 0 },
	{   -90, 0 },
	{   -89, 0.5 },
	{   -88, 0.75 },
	{   -86, 0.85 },
	{   -83, 0.95 },
	{   -80, 1 },
	{   -55, SOL__config("sun", "dazzle_zenith_multi") },
	{     0, SOL__config("sun", "dazzle_zenith_multi") },
}
local dazzleCPP = LUT:new(dazzle, nil, true)


local n = 1
local _l_PP_AE_Target = {
-- sun-angle  AE-target  
	{ -180,	  0.020,  },
	{ -108,	  0.020,  },
	{ -102,	  0.020,  },
	{  -99,	  0.020,  },
	{  -96,	  0.050,  },
	{  -93,	  0.100,  },
	{  -90,	  0.250,  },
	{  -87,	  0.32,	  },
	{  -84,	  0.40,	  },
	{  -81,	  0.45,	  },
	{  -75,	  0.50,	  },
	{    0,	  0.52,	  },
}
local _l_PP_AE_TargetCPP = LUT:new(_l_PP_AE_Target, nil, true)

-- reset lights
ac.setWeatherLightsMultiplier(1)
ac.setGlowBrightness(0.5)

local filter_tonemap = ac.ColorCorrectionHsb { hue=0, saturation=1.0, brightness=1.0, keepLuminance=true }
ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filter_tonemap

local filter_contrast = ac.ColorCorrectionContrast { value = 1.0 }
ac.weatherColorCorrections[#ac.weatherColorCorrections + 1] = filter_contrast

local ae__exposure_base = -1
local ae__exposure_base_retrieved = false 

local AE__low = 0.3
--local AE__low_block = true
local AE__high = 0.3
--local AE__high_block = true
local AE__average = 0.3
local AE__avg_n = 0
local AE__avg_n_max = 60 * 60 -- 60 FPS, 1 min to capture
local AE__first_time_interior = false

local AE_control_speed = 1.0
local AE_last_drift = 1.0

local last_sun_angle = __sun_angle

local base_glare_threshold = 1

local CSP_lights_control = 0

function init_ae()

	AE__low = ae__exposure_base
	AE__high = ae__exposure_base
	AE__average = ae__exposure_base
	AE__avg_n = 0

	AE_last_drift = 1.0
end

function SOL_filter__get_exposure_base()

	if ae__exposure_base_retrieved == false then return -1 end
	return ae__exposure_base
end

local extern__exposure_base = false
function SOL_filter__set_exposure_base(e)

	ae__exposure_base = e

	if extern__exposure_base == false then
		init_ae()
	end
	extern__exposure_base = true
end

function SOL_filter__get_CSP_light_control()

	return CSP_lights_control
end

local _l_interiorAE_checked = -1
function check_interiorAE_prediction()
	
    if __CSP_version >= 1566 then
		if ac.getCarState and ac.getSimState then
			if ac.getSimState().isSessionStarted then
				local focus = ac.getSimState().focusedCar
				if focus and focus > 1 then
				else
				focus = 1
				end
				if _l_interiorAE_checked ~= focus then
					player = ac.getCarState(focus)
					if player then
						__predictedInteriorAE = math.pow(math.min(1, (player.exposureInside / math.max(1, player.exposureOutside))*2), 0.67)
						_l_interiorAE_checked = focus
					end
				end
			end
		end
	else 
		__predictedInteriorAE = 1
    end
end

function init_glare()

	--base_glare_threshold = ac.getGlareThreshold()
	--ac.debug("####" , base_glare_threshold)
end

local color_temp_init = 0
function init_color_temp()

	if color_temp_init <= 0 then

		local pp_wb = get_parsed_value(__PPFILTER_PARSE, "COLOR", "WHITE_BALANCE")
		if pp_wb ~= nil then
			color_temp_init = pp_wb
		else color_temp_init = 6250
		end

		--if SOL__config("debug", "graphics") == true then ac.debug("Gfx - Color WB read", color_temp_init) end
	end
end


local _l_config__csp_light_ctrl = SOL__config("csp_lights", "controlled_by_sol")

function update__filter(dt)

	local l__ta_exp_fix = night_compensate(ta_exp_fix)
	local _l_config__blacklevel = SOL__config("monitor_compensation", "blacklevel")
	local _l_config__colors_whitebalance = SOL__config("monitor_compensation", "colors_whitebalance")

	local tmp = SOL__config("csp_lights", "controlled_by_sol")
	if _l_config__csp_light_ctrl ~= tmp then
		_l_config__csp_light_ctrl = tmp
		if not tmp then
			ac.setWeatherLightsMultiplier(1)
		end
	end

	_l_config__csp_light = SOL__config("csp_lights", "multiplier") 

	if nopp__use_sol_without_postprocessing then
		_l_config__csp_light = _l_config__csp_light * 1.2
		_l_config__csp_light_ctrl = true
	end

	if extern__exposure_base == false then

		if ae__exposure_base <= 0 then
		
			local pp_exp = get_parsed_value(__PPFILTER_PARSE, "TONEMAPPING", "EXPOSURE")

			if pp_exp ~= nil then 
				ae__exposure_base = pp_exp
				init_ae()

				ae__exposure_base_retrieved = true
			end
		--else
		--	ae__exposure_base = ac.getPpTonemapExposure()
		end
	end
	--ac.debug("###", ae__exposure_base)


	-- start with a fixed value !!!
	local contrast = 1

	if math.abs(__sun_angle - last_sun_angle) > 0.1 then
		-- reset AE calibration if time is moved forward or backward
		init_ae()
		--ac.debug("###-2 init AE")
	end
	last_sun_angle = __sun_angle

	
	check_interiorAE_prediction()
	

	filter_tonemap.brightness = SOL__config("pp", "brightness")
	filter_tonemap.saturation = SOL__config("pp", "saturation")


	--blacklevel mod
	if _l_config__blacklevel > 0 then
	
		-- lower contrast to prevent low clipping
		local offset = (_l_config__blacklevel/math.max(1, math.lerp(700, 380, math.pow(_l_config__blacklevel/30, 0.5))))
		contrast = contrast - offset
		-- compensate brightness
		filter_tonemap.brightness = filter_tonemap.brightness + (offset * 10)
	end


	local godrays_result = godraysCPP:get() --interpolate__plan(godrays)
	if SOL__config("pp", "modify_godrays") == true then

		if SOL__config("pp", "godrays_singlescreen") == true then

			local blinding = 0.0
			--[[ if ac.isInteriorView() == true then

				local angle_cam = vec32sphere(__camDir*-1)
				local angle_sun = vec32sphere(__sunDir)
				blinding = angle_diff(angle_sun[1], angle_cam[1]) + angle_diff(angle_sun[2], angle_cam[2])
				blinding = 3 - math.min(3, blinding*9)

				ac.debug("###", blinding)
			end 

			local sun_rays_color = __lightColor:toHsv()
			sun_rays_color.v = sun_rays_color.v * __IntD(0.05, 0.1, 0.5) * blinding
			sun_rays_color.s = sun_rays_color.s * 0.8 * (1.1-blinding*0.1)
			sun_rays_color.h = sun_rays_color.h * 1.05
			ac.setGodraysCustomColor(sun_rays_color:toRgb())
			]]--

			

			local dazzle_result = dazzleCPP:get() --interpolate__plan(dazzle)
			local dazzle_out_fade = math.pow(dazzle_result[1], 3)

			__dazzle__interpol = SOL__config("sun", "dazzle_mix")
							   * dazzle_result[1]
							   * (1-weather__get_cloud_shadow())
							   * (1 - __overcast)
							   * from_twilight_compensate(0)
			__dazzle__interpol = math.max(0, math.min(1, __dazzle__interpol))					   

			local dazzle__godrays = (25+15*dazzle_out_fade) * SOL__config("sun", "dazzle_strength")
			local dazzle__angleatt = 1
			local dazzle__glareratio = 0.05

			local fov = math.pow(__camFOV / 45, 0.5)
			
			ac.setGodraysLength(fov
							  * math.lerp( _l_ppf__godrays_length, dazzle__godrays , __dazzle__interpol )
							  * godrays_result[1]
							  * __solar_eclipse
							  * math.lerp( 1, 0, math.pow(__fog_dense, 10))
							  * math.lerp( 1, 0, math.min(1, __inair_material.dense))
							  * (1 - __overcast)
							)
			ac.setGodraysAngleAttenuation(math.lerp( _l_ppf__godrays_angle_att, dazzle__angleatt , __dazzle__interpol )
										* math.lerp( 1, 0.1, math.pow(__fog_dense, 10) )
										)
			ac.setGodraysGlareRatio(math.lerp( _l_ppf__godrays_glare_ratio, dazzle__glareratio , __dazzle__interpol )
								  * math.lerp( 1, 0, math.min(1, __inair_material.dense))
								   )

			ac.setGodraysDepthMapThreshold( math.lerp( _l_ppf__godrays_map_threshold, 0.9998 , __dazzle__interpol*dazzle_out_fade ) + 0.000001*night_compensate(0) )
		else

			ac.setGodraysLength(1 * godrays_result[1] * __solar_eclipse)

			ac.setGodraysAngleAttenuation(10)
			ac.setGodraysGlareRatio(1)
		end
	else
--[[
		local gr_l = get_parsed_value(__PPFILTER_PARSE, "GODRAYS", "LENGTH")

		if gr_l ~= nil then 
			ac.setGodraysLength(gr_l * godrays_result[1])
		end
]]
	end
	
	if SOL__config("pp", "modify_glare") == true then

		ac.setGlareThreshold( math.lerp( math.lerp(0.6,
											    math.lerp(0.30, 0, math.min(1, math.pow(__fog_dense*1.1, 2)))
											    , math.min(1, __night__effects_multiplier*1.5))
									  , SOL__config("pp", "glare_day_threshold")
									  , sun_compensate(0))
							)
		
		--ac.setGlareBloomFilterThreshold(0.002)
		--ac.setGlareStarFilterThreshold(0.70)
	end

	if ac.getPpAutoExposureEnabled() == true then
		if SOL__config("ae", "use_self_calibrating") == true then

			--ac.setAutoExposureTarget(0.3)
			ac.setCarExposureActive(false)

			local ae = ac.getAutoExposure()

			AE_control_speed = 1.0

			if ac.isInteriorView() == true then
				-- wait for first cockpit view to start self calibration

				--[[ set values after AE vary
				if AE__low_block == true then
					if ae >= AE__low then
						AE__low_block = false
					end
				else
					AE__low  = math.min(AE__low, ae)
				end

				if AE__high_block == true then
					if ae <= AE__high then
						AE__high_block = false
					end
				else
					AE__high = math.max(AE__high, ae)
				end
				]]

				AE__low  = math.min(AE__low, ae)
				AE__high = math.max(AE__high, ae)

				if AE__avg_n <= AE__avg_n_max then AE__avg_n = AE__avg_n + 1 end
				AE__average = AE__average + ((ae - AE__average) / math.max(0.01, AE__avg_n))
			else
				--if ac.isInteriorView() == true then 
				--	AE__first_time_interior = true
				--else
				--	AE__first_time_interior = false
				--end

				init_ae()
			end

			-- show the AE meassurement
			if SOL__config("debug", "AE") == true then
				
				local s = ""
				local steps = 30
				local step_width = 1/steps
				local f = 0
				local offset = 0.5 / math.max(0.01, AE__average)

				for i=1, steps do

					f = step_width * i 

					if f < AE__low*offset or f > AE__high*offset then s = s.."-"
					elseif f > (AE__average-step_width)*offset and f < (AE__average+step_width)*offset then s = s.."|"
					elseif f < AE__average*offset then s = s.."<"
					else s = s..">"
					end
				end
				ac.debug("AE: Meter",s)
				ac.debug("AE: avg", string.format('%.2f, AE min: %.2f, AE max: %.2f', AE__average, AE__low, AE__high)) 
			end


			local ae_drift = 1.0
			local ae_adapted_drift = 1.0

			--[[ use AE average as the center for drift calculation only while interior view
			if ac.isInteriorView() == true then ae_drift = AE__average/ae
			else ae_drift = AE_last_drift
			end]]
			ae_drift = AE__average/math.max(0.01, ae)

			if ae_drift < AE_last_drift then
				-- ae is falling

				-- simulate the effect of regenerating rhodopsin
				-- use dt (1 sec = 60 fps) for time dependency 
				AE_control_speed = math.lerp(1.0, dt*0.23, SOL__config("ae", "eye_laziness"))
			else

				AE_control_speed = 1.0
			end

			ae_adapted_drift = AE_last_drift + (((ae_drift - AE_last_drift) * AE_control_speed))

			--AE_last_drift = ae_adapted_drift

			local _l_config__ae__control_strength = SOL__config("ae", "control_strength")
			local _l_config__ae__control_damping = SOL__config("ae", "control_damping")

			-- use special ae logic for night, this one is absolute to the meassured AE
			-- and has not adaption to the car. Because its night, the car interior multi makes no big difference
			-- change logic with -10°, then night is proceeded enough to switch unrecognizable
			AE_last_drift = ae_adapted_drift--math.lerp( 3/(ae), ae_adapted_drift, math.min(1, math.max(0, (__sun_angle+10))) )

			local min_ae = math.min(1,math.pow(ae_adapted_drift, 1-_l_config__ae__control_damping))
			local max_ae = math.max(1,math.pow(ae_adapted_drift, 1-_l_config__ae__control_damping))
			--ac.debug("###", AE_last_drift)

			if SOL__config("ae", "alternate_ae_mode") == 1 then

				local target = (day_compensate(0.15) 
							* __IntN((ae__exposure_base)*5.00,(ae__exposure_base)*1.5, 15)
							* (1-(1-__bright_adapt)*0.50))

				if ac.isInteriorView() == false then

					target = target * 0.85
				end 

				ac.setAutoExposureTarget(target)


				-- expand the limits for a better self regulation
				ac.setAutoExposureLimits(0,
										10)

				if ae ~= nil and ae > 0 then
					
					-- neutralize AC's AE controlling - based on an average exposure level of 0.3
					filter_tonemap.brightness = ae__exposure_base / math.max(0.01, ae) -- compensate vanilla AE
					if ac.isInteriorView() then
						filter_tonemap.brightness = filter_tonemap.brightness * SOL__config("ae", "interior_multiplier")
					end
					
					--if ac.isInteriorView() == true then 

						if ae_adapted_drift > 1 then

							__AE_generated = 1 + (max_ae-1)*(_l_config__ae__control_strength) 
						else
							__AE_generated = 1 + (min_ae-1)*(_l_config__ae__control_strength)
						end

					if SOL__config("debug", "AE") == true then

						ac.debug("AE", string.format('%.2f, AE: %.2f', ae_adapted_drift, __AE_generated )) 
					end
				end
			else

				--filter_tonemap.brightness = ae__exposure_base / ae -- compensate vanilla AE
				filter_tonemap.brightness = ae__exposure_base / math.max(0.01, ae) -- compensate vanilla AE

				local lut = _l_PP_AE_TargetCPP:get() --interpolate__plan(_l_PP_AE_Target)
				if lut ~= nil then

					local _l_AE_target_multi = 1
					if ac.isInteriorView() == true then
						-- interior camera
						_l_AE_target_multi = 1.15

						ac.setAutoExposureLimits(0.1 + (0.225 * night_compensate(0)), 0.5)
					else
						-- exterior camera
						_l_AE_target_multi = 0.50 + (0.25 * night_compensate(0))

						ac.setAutoExposureLimits(0.1 + (0.25 * night_compensate(0)), 0.5 + (0.25 * night_compensate(0)))
					end

					ac.setAutoExposureTarget(lut[1] * _l_AE_target_multi)
					
					local _l_PP_AE__value = ae_adapted_drift
					
					local controlled_brightness = (1 - (_l_PP_AE__value-1) * 0.5 * (_l_config__ae__control_strength * 0.5)) 

					filter_tonemap.brightness = filter_tonemap.brightness * (1.00 + (controlled_brightness-1))
					if ac.isInteriorView() then
						filter_tonemap.brightness = filter_tonemap.brightness * SOL__config("ae", "interior_multiplier")
					end

					if SOL__config("debug", "custom_config") == true then

						ac.debug("AE", string.format('%.2f, BRIGHTNESS: %.2f', _l_PP_AE__value, controlled_brightness ))
					end
				end
			end
		else 

			local ae = ac.getAutoExposure()
			
			if SOL__config("ae", "alternate_ae_mode") == 1 then
				filter_tonemap.brightness = ae__exposure_base / math.max(0.01, ae) -- compensate vanilla AE
				__AE_generated = 1 / math.max(0.01, filter_tonemap.brightness)
				if ac.isInteriorView() then
					filter_tonemap.brightness = filter_tonemap.brightness * SOL__config("ae", "interior_multiplier")
				end
			end
		end
	end

	

	__bright_adapt = day_compensate(1+__night__brightness_adjust)
						* SOL__config("pp", "brightness")
						* (1/math.max(0.1, math.pow(l__ta_exp_fix, 0.58)))
						-- more brightness with falling ambient light 
						* math.lerp(1, math.max(1, math.pow(14 / math.max(5, weather__get_ambient_brightness()), 0.75)) , from_twilight_compensate(0))

	--local aoNow = ac.sampleCameraAO()
	--ac.debug("###", aoNow)
	
	local light_sum = (#__lightColor + __sun_color.v) * 0.5
	light_sum = 1-light_sum/math.lerp(30,10,sun_compensate(0))

	local _l_config__brightness_sun_link = SOL__config("pp", "brightness_sun_link")

	if SOL__config("pp", "brightness_sun_link_only_interior") == false or ac.isInteriorView() == true then

		__bright_adapt = __bright_adapt
						 * (1 + from_twilight_compensate(0) * 0.40 * __overcast * _l_config__brightness_sun_link)
						 * (1 + from_twilight_compensate(0) * 1.00 * __badness * _l_config__brightness_sun_link)
						 * (1 + (math.lerp(1,0.0,math.min(1, night_compensate(0) * __night__brightness_adjust)))
						 		* (__IntN(0.95,0.25,75)*__IntD(0.80,0.5,0.5))
						 		* math.max(2.0*(weather__get_cloud_shadow()), light_sum)
						 		* _l_config__brightness_sun_link
						   ) 
						 * night_compensate(1 + (1-sun_compensate(0)) * __IntD(0.15, 0, 0.45) * _l_config__brightness_sun_link)
						 / math.max(0.01, from_twilight_compensate( math.lerp(1, math.min(1.67, math.max(1.0, 1/math.max(0.01, __AE_generated))), math.min(1,_l_config__brightness_sun_link ) ) ) )
		--ac.debug("###", light_sum )	

		if nopp__use_sol_without_postprocessing then 
			__PPoff__brightness__regulation = math.lerp(1, __bright_adapt*0.9, 0.5)
		end			 
	end

	__bright_adapt = math.lerp(1, math.pow(__bright_adapt, 0.5), math.min(1, _l_config__brightness_sun_link))
	--ac.debug("###", __bright_adapt )

	if color_temp_init <= 0 then 
		--color_temp = 6250 * (1+(_l_config__colors_whitebalance/100))
		init_color_temp()
	else

		local color_temp = color_temp_init * (1+(_l_config__colors_whitebalance/50))

		if SOL__config("pp", "modify_spectrum") == true then

			local fog = gfx__get_fog_dense(2000)

			color_temp = temp_interpol(20, color_temp-150, color_temp+280)
			color_temp = color_temp * (1+0.040*__overcast*from_twilight_compensate(0))
									* (1+(0.065 - 0.065*__overcast)*weather__get_cloud_shadow()*from_twilight_compensate(0))
									* (1.10 - 0.10 * SOL__config("weather", "HDR_multiplier"))
			if light_sum < 0 then

				color_temp = color_temp * (1+light_sum*0.02*(1-fog*1.5))
			else
				color_temp = color_temp * (1+light_sum*0.035*(1-fog*1.5))
			end
		end

		ac.setPpWhiteBalanceK(color_temp)
		--if SOL__config("debug", "graphics") == true then ac.debug("Gfx - Color WB mod", color_temp) end
	end

	

	if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Brightness adaption", string.format('%.2f', __bright_adapt)) end

	filter_tonemap.brightness = filter_tonemap.brightness * __bright_adapt * (1 - 0.3*(1-ta_exp_fix))

	contrast = contrast * day_compensate(1+__night__brightness_adjust*0.004) * SOL__config("pp", "contrast")
	filter_contrast.value = (math.min(2.0, math.max(0.5, contrast)))


	-- manage lights with sunset/ambient light, compensate brightness with ta_exp_fix
	if _l_config__csp_light_ctrl == true then

		local ambi_bright = weather__get_ambient_brightness()
		if nopp__use_sol_without_postprocessing then 
			--compensate ambient brightness calculations with PPoff adjustments
			ambi_bright = ambi_bright * 3
		end

		local ppoff_csp_multi = 1 * SOL__config("ppoff", "brightness")
		if nopp__use_sol_without_postprocessing == true then
			ppoff_csp_multi = ppoff_csp_multi * 0.67
		end
		local ppoff_csp_emissives = ppoff_csp_multi
		
		
		
		CSP_lights_control = math.min(1, math.max(0, 
								1/math.max(1, 0.5*ambi_bright + math.pow(0.15*#__lightColor, 2)))
							 )
		
		CSP_lights_control = CSP_lights_control * math.max(0.1, math.pow(l__ta_exp_fix, 0.5)) * _l_config__csp_light
		CSP_lights_control = CSP_lights_control * (1-(0.25*night_compensate(0)*__night__brightness_adjust))
		CSP_lights_control = CSP_lights_control * math.max(0, 1+ 0.5*gfx__get_smog_dense())
		CSP_lights_control = CSP_lights_control * math.max(0, 1+ __inair_material.dense)
		CSP_lights_control = math.lerp(CSP_lights_control, 1, (__bright_adapt-1)*0.2)

		local _l_bounced_multi = math.lerp( SOL__config("nerd__csp_lights_adjust", "bounced_day"),
											SOL__config("nerd__csp_lights_adjust", "bounced_night"),
											math.min(1, CSP_lights_control))

		if SOL__config("debug", "graphics") == true then ac.debug("Gfx: CSP bounced lights", string.format('%.2f', _l_bounced_multi)) end

		ac.setWeatherLightsMultiplier(  _l_bounced_multi * ppoff_csp_multi )
		--ac.setEmissiveMultiplier(ppoff_csp_emissives * math.lerp( global_CSP_emissives_night_maximum, 0.75, from_twilight_compensate(0)) * CSP_lights_control)
		
		local day_emissive_multi = math.lerp(SOL__config("nerd__csp_lights_adjust", "emissive_day"),
											 SOL__config("nerd__csp_lights_adjust", "emissive_night"),
											 math.min(0.5, 0.5*weather__get_cloud_shadow() + 0.3*__overcast))
		
		local _l_emissive_multi = math.lerp( SOL__config("nerd__csp_lights_adjust", "emissive_night"),
											 day_emissive_multi,
											 from_twilight_compensate(0))
		ac.setEmissiveMultiplier(_l_emissive_multi * ppoff_csp_multi)
		
		if SOL__config("debug", "graphics") == true then ac.debug("Gfx: CSP emissive lights", string.format('%.2f', _l_emissive_multi)) end

		
		
		ac.setWeatherTrackLightsMultiplierThreshold(0.01) -- let make lights switch on early for smoothness

		-- cast the global lights condition
		if CSP_lights_control >= 0.2 then
			ac.setTrackCondition("wfx_LIGHTS", math.max((90-__sun_angle), (80 + 10*math.pow(CSP_lights_control, 2))) )
		else
			ac.setTrackCondition("wfx_LIGHTS", (90-__sun_angle))
		end

		if __CSP_version >= 763 then --csp 1.25.183
			local fog = 0.5+0.5*gfx__get_fog_dense(2000)
			ac.setGlowBrightness( CSP_lights_control * math.lerp( fog, (0.3+0.7*fog), __night__effects_multiplier))
		end
	else
		ac.setTrackCondition("wfx_LIGHTS", (90-__sun_angle))
	end

	
--[[
	local sun_cam_look = math.pow(1-vec_diff(__camDir, __sunDir), 75)

	_d(ac.sampleCameraAO(10))
	ac.getCameraOcclusion()
]]



end