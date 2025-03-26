
if not __CONFIG__ALLOW__DIRECT__ACCESS then

    -- ### backward compatibility to old sol config system 
    sol__use_cpu_split = false
    sol__only_use_smaller_textures = false

    blacklevel__compensation = 0
    colors_whitebalance = 0

    ppoff__brightness = 0

    ppfilter__brightness = 0
    ppfilter__contrast = 0
    ppfilter__saturation = 0
    ppfilter__brightness_sun_link = 0
    ppfilter__brightness_sun_link_only_interior = false
    ppfilter__modify_glare = false
    ppfilter__glare_day_threshold = 0
    ppfilter__modify_godrays = false
    ppfilter__godrays_singlescreen = false
    ppfilter__modify_spectrum = false

    ae__use_self_calibrating = false
    ae__control_strength = 0
    ae__control_damping = 0
    ae__eye_laziness = 0
    ae__alternate_ae_mode = 0

    headlights__if_sun_angle_is_under = 3
    headlights__if_ambient_light_is_under = 7.50
    headlights__if_fog_dense_is_over = 0.70
    headlights__if_bad_weather = 0.50
    global_CSP_lights_controlled_by_sol = false
    global_CSP_lights_multi = 0
    weather__HDR_multiplier = 0
    weather__use_lightning_effect = false

    clouds__render_method = 0
    clouds__preload_2d_textures = false
    clouds__randomize_with_reset = false
    clouds__manual_random_seed = 0

    sky__blue_preset = 0
    sky__blue_strength = 0 
    sky__smog = 0
    day__horizon_glow = 0
    night__horizon_glow = 0

    clouds__opacity_multiplier = 0 
    clouds__shadow_opacity_multiplier = 0
    clouds__distance_multiplier = 0
    clouds__quality = 0
    clouds__render_limiter = 0
    clouds__render_per_frame = 0
    clouds__movement_linked_to_time_progression = false
    clouds__movement_multiplier = 0

    sun__size = 0
    sun__sky_bloom = 0
    sun__fog_bloom = 0
    sun__modify_speculars = false
    moon_casts_shadows = false

    sun__dazzle_mix = 0
    sun__dazzle_strength = 0
    sun__dazzle_zenith_multi = 0

    ambient__sun_color_balance = 0
    ambient__use_directional_ambient_light = false
    ambient__use_overcast_sky_ambient_light = false
    ambient__AO_visibility = 0

    night__effects_multiplier = 0
    night__brightness_adjust = 0
    night__moonlight_multiplier = 0
    night__starlight_multiplier = 0

    nlp__use_light_pollusion_from_track_ini = false
    nlp__radius = 0
    nlp__density = 0
    nlp__color = {Hue = 0,Saturation = 0,Level = 0,}

    gfx__reflections_brightness = 0
    gfx__reflections_saturation = 0
    sound__wind_volume_interior = 0
    sound__wind_volume_exterior = 0
    sound__thunder_volume_interior = 0 
    sound__thunder_volume_exterior = 0 
    sound__rain_volume_interior = 0
    sound__rain_volume_exterior = 0

    sol__debug__runtime = false
    sol__debug__solar_system = false
    sol__debug__weather = false
    sol__debug__weather_change = false
    sol__debug__weather_effects = false
    sol__debug__track = false
    sol__debug__camera = false
    sol__debug__AI = false
    sol__debug__graphics = false
    sol__debug__custom_config = false
    sol__debug__AE = false
    sol__debug__light_pollution = false

    nerd__sky_adjust = {Hue = 0,Saturation = 0,Level = 0,
    SunIntensityFactor = 0,AnisotropicIntensity = 0,Density = 0,Scale = 0,GradientStyle = 0,InputYOffset = 0,}
    nerd__sun_adjust = {ls_Hue = 0,ls_Saturation = 0,ls_Level = 0,ap_Level = 0,}
    nerd__speculars_adjust = {Level = 0,}
    nerd__clouds_adjust = {Saturation = 0,Saturation_limit = 0,Lit = 0,Contour = 0,}
    nerd__ambient_adjust = {Hue = 0,Saturation = 0,Level = 0,}
    nerd__directional_ambient_light = {Level = 0}
    nerd__overcast_sky_ambient_light = {Level = 0}
    nerd__fog_use_custom_distant_fog = false
    nerd__fog_custom_distant_fog = {
    distance = 0,blend = 0,density = 0,exponent = 0,backlit = 0,sky = 0,night = 0,	
    Hue = 0,Saturation = 0,Level = 0,}
    nerd__moon_adjust = {	low_Hue = 0, low_Saturation = 0, low_Level = 0, 
    high_Hue = 0,high_Saturation = 0,high_Level = 0, 
    mie_Exponent = 0, mie_Multi = 0, ambient_ratio = 0}
    nerd__stars_adjust = {Saturation = 0, Exponent = 0,}
    nerd__csp_lights_adjust = {bounced_day = 0, bounced_night = 0,emissive_day = 0,emissive_night = 0,}

    -- for compatibility issues
	weather__set_rain_automatically = false
	weather__set_rain_amount = 0
	sol__economic_weather_transition = false
end


-- do some compatibilities for post Sol 1.6
-- all following variables are no more existent
nerd__sky_blue_booster_adjust = { Hue = 0, Saturation = 0, Level = 0 }
nerd__static_ambient_adjust = { Vert_Level = 0, Hori_Level = 0 }
nerd__sun_adjust["ap_Hue"]=1
nerd__sun_adjust["ap_Saturation"]=1
nerd__sun_adjust["ap_MieExp=1"]=1
nerd__sky_adjust["ZenithOffset"]=0