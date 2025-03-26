------------------
-- limit values --
ppfilter__load_basic_custom_config = true

function check_table(set, name, keys)
	local failed = false
	for i=1,#keys do
		if set[keys[i]] == nil then
			set[keys[i]]=1
			failed = true
		end
	end

	if failed then ac.debug("CC warning", "table "..name.." was reinitialized !!!" ) end
end

function sol_check_config()

	sol__use_cpu_split = sol__use_cpu_split or false
	sol__only_use_smaller_textures = sol__only_use_smaller_textures or false

	blacklevel__compensation = math.max(0, math.min(31, blacklevel__compensation))
	colors_whitebalance 	 = math.max(-50, math.min(50, colors_whitebalance))

	ppoff__brightness = math.max(0.25, math.min(1.75, ppoff__brightness))

	ppfilter__brightness = math.max(0.25, math.min(1.75, ppfilter__brightness))
	ppfilter__contrast   = math.max(0.80, math.min(1.20, ppfilter__contrast))

	ppfilter__brightness_sun_link = math.max(0, math.min(4, ppfilter__brightness_sun_link))
	if ppfilter__brightness_sun_link_only_interior ~= true and ppfilter__brightness_sun_link_only_interior ~= false then ppfilter__brightness_sun_link_only_interior = false end

	ppfilter__load_basic_custom_config = true

	
	ppfilter__glare_day_threshold = math.max(0.0, math.min(50, ppfilter__glare_day_threshold))

	if ppfilter__modify_glare ~= true and ppfilter__modify_glare ~= false then ppfilter__modify_glare = true end
	if ppfilter__modify_godrays ~= true and ppfilter__modify_godrays ~= false then ppfilter__modify_godrays = true end
	if ppfilter__modify_spectrum ~= true and ppfilter__modify_spectrum ~= false then ppfilter__modify_spectrum = true end

	if ae__use_self_calibrating ~= true and ae__use_self_calibrating ~= false then ae__use_self_calibrating = true end
	ae__control_strength = math.max(-1, math.min(10, ae__control_strength))
	ae__control_damping  = math.max(0, math.min(1, ae__control_damping))
	ae__eye_laziness = math.max(0, math.min(1, ae__eye_laziness))

	ae__alternate_ae_mode  = math.max(0, math.min(1, ae__alternate_ae_mode))

	headlights__if_sun_angle_is_under 		= math.max(-90, math.min(90, headlights__if_sun_angle_is_under))
	headlights__if_ambient_light_is_under 	= math.max(0, math.min(100, headlights__if_ambient_light_is_under))
	headlights__if_fog_dense_is_over 		= math.max(0, math.min(1, headlights__if_fog_dense_is_over))
	headlights__if_bad_weather 				= math.max(0, math.min(1, headlights__if_bad_weather))

	if global_CSP_lights_controlled_by_sol ~= true and global_CSP_lights_controlled_by_sol ~= false then global_CSP_lights_controlled_by_sol = true end
	global_CSP_lights_multi					= math.max(0, math.min(10, global_CSP_lights_multi))


	weather__HDR_multiplier = math.max(0.1, math.min(10, weather__HDR_multiplier))

	if weather__use_fake_cloud_shadow_effect ~= true and weather__use_fake_cloud_shadow_effect ~= false then weather__use_fake_cloud_shadow_effect = true end
	if weather__use_lightning_effect ~= true and weather__use_lightning_effect ~= false then weather__use_lightning_effect = true end

	-- for compatibility issues
	weather__set_rain_automatically = false
	weather__set_rain_amount = 0
	sol__economic_weather_transition = false

	if __CSP_version < 746 then 
		sky__blue_booster = 0
	else
		sky__blue_booster = math.max(0, math.min(2.0, sky__blue_booster))
		sky__blue_preset = math.max(0, math.min(10, sky__blue_preset))
		sky__blue_strength = math.max(0, math.min(2.0, sky__blue_strength))
	end
	sky__smog = math.max(0, math.min(2, sky__smog))
	day__horizon_glow = math.max(0, math.min(10, day__horizon_glow))
	night__horizon_glow = math.max(0, math.min(10, night__horizon_glow))

	
	clouds__opacity_multiplier = math.max(0, math.min(2, clouds__opacity_multiplier))
	clouds__distance_multiplier = math.max(0.5, math.min(2, clouds__distance_multiplier))
	clouds__quality = math.max(0.3, math.min(2, clouds__quality))
	clouds__render_limiter = math.max(0, math.min(2, clouds__render_limiter))
	clouds__render_per_frame = math.max(1, math.min(100, clouds__render_per_frame))
	if clouds__movement_linked_to_time_progression ~= true and clouds__movement_linked_to_time_progression ~= false then clouds__movement_linked_to_time_progression = false end
	clouds__movement_multiplier = math.max(0, math.min(10, clouds__movement_multiplier))
	

	sun__size = math.max(0.01, math.min(100, sun__size))
	sun__sky_bloom = math.max(0, math.min(2.00, sun__sky_bloom))
	if sun__modify_speculars ~= true and sun__modify_speculars ~= false then sun__modify_speculars = true end
	if moon_casts_shadows ~= true and moon_casts_shadows ~= false then moon_casts_shadows = true end

	sun__dazzle_mix = math.max(0, math.min(1, sun__dazzle_mix))
	sun__dazzle_strength = math.max(0, math.min(1, sun__dazzle_strength))
	sun__dazzle_zenith_multi = math.max(0, math.min(1, sun__dazzle_zenith_multi))

	night__effects_multiplier = math.max(0, math.min(1, night__effects_multiplier))
	night__brightness_adjust = math.max(-10, math.min(10, night__brightness_adjust))
	night__moonlight_multiplier = math.max(0, math.min(10, night__moonlight_multiplier))
	night__starlight_multiplier = math.max(0, math.min(10, night__starlight_multiplier))
	if night__use_light_pollusion_from_track_ini ~= true and night__use_light_pollusion_from_track_ini ~= false then night__use_light_pollusion_from_track_ini = true end


	ambient__sun_color_balance = math.max(0, math.min(2, ambient__sun_color_balance))
	ambient__AO_visibility = math.max(0, math.min(1, ambient__AO_visibility))
	if ambient__use_directional_ambient_light ~= true and ambient__use_directional_ambient_light ~= false then ambient__use_directional_ambient_light = true end
	if ambient__use_overcast_sky_ambient_light ~= true and ambient__use_overcast_sky_ambient_light ~= false then ambient__use_overcast_sky_ambient_light = true end

	gfx__reflections_brightness = math.max(0.0, math.min(10, gfx__reflections_brightness))
	gfx__reflections_saturation = math.max(0.0, math.min(10, gfx__reflections_saturation))

	sound__wind_volume_interior = math.max(0, math.min(2, sound__wind_volume_interior))
	sound__wind_volume_exterior = math.max(0, math.min(2, sound__wind_volume_exterior))
	sound__thunder_volume_interior = math.max(0, math.min(2, sound__thunder_volume_interior))
	sound__thunder_volume_exterior = math.max(0, math.min(2, sound__thunder_volume_exterior))

	if sol__debug__runtime ~= true and sol__debug__runtime ~= false then sol__debug__runtime = false end
	if sol__debug__solar_system ~= true and sol__debug__solar_system ~= false then sol__debug__solar_system = false end
	if sol__debug__weather ~= true and sol__debug__weather ~= false then sol__debug__weather = false end
	if sol__debug__weather_change ~= true and sol__debug__weather_change ~= false then sol__debug__weather_change = false end
	if sol__debug__weather_effects ~= true and sol__debug__weather_effects ~= false then sol__debug__weather_effects = false end
	if sol__debug__track ~= true and sol__debug__track ~= false then sol__debug__track = false end
	if sol__debug__camera ~= true and sol__debug__camera ~= false then sol__debug__camera = false end
	if sol__debug__AI ~= true and sol__debug__AI ~= false then sol__debug__AI = false end
	if sol__debug__graphics ~= true and sol__debug__graphics ~= false then sol__debug__graphics = false end
	if sol__debug__custom_config ~= true and sol__debug__custom_config ~= false then sol__debug__custom_config = false end
	if sol__debug__AE ~= true and sol__debug__AE ~= false then sol__debug__AE = false end
	if sol__debug__light_pollution ~= true and sol__debug__light_pollution ~= false then sol__debug__light_pollution = false end



	--check nerd option tables, maybe some people overwriting them

	check_table(nerd__sky_adjust, "nerd__sky_adjust",
	{ "Hue",
	"Saturation",
	"Level",
	"SunIntensityFactor",
	"AnisotropicIntensity",
	"Density",
	"Scale",
	"GradientStyle",
	"InputYOffset"
	})

	check_table(nerd__sun_adjust, "nerd__sun_adjust",
	{ "ls_Hue",
	"ls_Saturation",
	"ls_Level",
	"ap_Level"})

	check_table(nerd__speculars_adjust, "nerd__speculars_adjust", 
	{ "Level" })

	check_table(nerd__clouds_adjust, "nerd__clouds_adjust",
	{ "Saturation",
	"Saturation_limit",
	"Lit",
	"Contour"})

	check_table(nerd__ambient_adjust, "nerd__ambient_adjust",
	{ "Hue",
	"Saturation",
	"Level"})

	check_table(nerd__directional_ambient_light, "nerd__directional_ambient_light", { "Level" })
	check_table(nerd__overcast_sky_ambient_light, "nerd__overcast_sky_ambient_light", { "Level" })

	check_table(nerd__fog_custom_distant_fog, "nerd__fog_custom_distant_fog",
	{ "distance",
	"blend",
	"density",
	"exponent",
	"backlit",
	"sky",
	"night",
	"Hue",
	"Saturation",
	"Level"})

	check_table(nerd__moon_adjust, "nerd__moon_adjust",
	{ "low_Hue",
	"low_Saturation",
	"low_Level",
	"high_Hue",
	"high_Saturation",
	"high_Level",
	"mie_Exponent",
	"mie_Multi",
	"ambient_ratio"})

	check_table(nerd__stars_adjust, "nerd__stars_adjust",
	{ "Saturation",
	"Exponent"})

	check_table(nerd__csp_lights_adjust, "nerd__csp_lights_adjust", 
	{"bounced_day",
	"bounced_night",
	"emissive_day",
	"emissive_night"})

end


sol_check_config()