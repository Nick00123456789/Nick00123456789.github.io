
-- Documents folder to save sol_config.ini
local _l_Documents_Folder = ""
if file_exists(__sol__path.."__Win7__DocumentsFolderFix.lua") then
    dofile (__sol__path.."__Win7__DocumentsFolderFix.lua")
    if __CustomDocumentsFolder then
        if __CustomDocumentsFolder ~= "" then
            _l_Documents_Folder = __CustomDocumentsFolder.."\\Assetto Corsa\\cfg"
        end
    end
end
if _l_Documents_Folder == "" then
    _l_Documents_Folder = ac.getFolder(5)
    
    local found = false
    if _l_Documents_Folder then
        local tmp = string.find(_l_Documents_Folder, "Assetto")
        if tmp then
            if tmp >= 1 then
                _l_Documents_Folder = _l_Documents_Folder.."\\Sol"
                found = true
            end
        end
    end

    if not found then
        -- if usernames are not ASCII compatible, set it to the Sol path
        _l_Documents_Folder = ""..__sol__path
    end
end

local transition_period = false --__CONFIG__ALLOW__DIRECT__ACCESS
local _l_config_parse
local _l_config_backup
local _l_custom_config_control = {}
local _l_config_session_changes = {}
local _l_CM_SharedBackup = "sol.TempConfig"
local _l_allowCustomConfigInterfaceFeedback = true

function config_manager__reset_Sol()

    config_manager__StopCustomConfigFeedback()
    __configAppInterface:resetAfterSendWasRecieved()
    --[[
    local f=io.open(__sol__path.."reset_dummy.lua","w+")
    if f~=nil then
        io.output(f)
        io.write("Parameter Reset -> "..config_manager__reset_Sol)
        io.close(f)
    end
    ]]
end

local _l_config = {

    performance = {
        use_cpu_split = { value=false },
        only_use_smaller_textures = { value=false, reset=_G["config_manager__reset_Sol"] },

        __index__ = 1,
    },

    monitor_compensation = {
        blacklevel = { value=0, min=0,max=30,type=1 },
        colors_whitebalance = { value=0, min=-10,max=10,type=1 },

        __index__ = 2,
    },

    ppoff = {
        brightness = { value=1.00, min=0.25,max=1.75 },

        __index__ = 3,
    }, 

    pp = {
        brightness = { value=1.00, min=0.25,max=1.75 },
        contrast = { value=1.00, min=0.8,max=1.2 },
        saturation = { value=1.00, min=0.0,max=2.0 },

        brightness_sun_link = { value=1.00, min=0.00,max=4.00 },
        brightness_sun_link_only_interior = { value=false },

        modify_glare = { value=false },
        glare_day_threshold = { value=2.00, min=0.0,max=50.00 },

        modify_godrays = { value=false },
        godrays_singlescreen = { value=true },
        modify_spectrum = { value=false },

        __index__ = 4,
    },

    ae = {
        use_self_calibrating = { value=false },

        control_strength = { value=2.00, min=-1,max=10 },
        control_damping = { value=0.50, min=0,max=1 },
        eye_laziness = { value=1.00, min=0,max=1 },
        alternate_ae_mode = { value=0, min=0,max=1,type=1 },
        interior_multiplier = { value=1, min=0.25,max=4 },

        __index__ = 5,
    },

    headlights = {
        if_sun_angle_is_under = { value=3.00, min=-90,max=90 },
        if_ambient_light_is_under = { value=7.50, min=0,max=15 },
        if_fog_dense_is_over = { value=0.70, min=0,max=1 },
        if_bad_weather = { value=0.50, min=0,max=1 },

        __index__ = 6,
    },

    csp_lights = {
        controlled_by_sol = { value=false },
        multiplier = { value=1.00, min=0,max=4 },

        __index__ = 7,
    },

    weather = {
        HDR_multiplier = { value=1.00, min=0.0,max=2.0 },
        use_lightning_effect = { value=true },

        __index__ = 8,
    },

    sky = {
        blue_preset = { value=1, min=0,max=9,type=1 },
        blue_strength = { value=1.00, min=0,max=2 },
        smog = { value=0.75, min=0,max=2 },
        day__horizon_glow = { value=1.00, min=0,max=10 },
        night__horizon_glow = { value=1.00, min=0,max=10 },

        __index__ = 9,
    },

    clouds = {
        render_method = { value=2, min=0,max=2,type=1, reset=_G["config_manager__reset_Sol"] },
        preload_2d_textures = { value=false, reset=_G["config_manager__reset_Sol"] },
        randomize_with_reset = { value=false, reset=_G["config_manager__reset_Sol"] },
        manual_random_seed = { value=0, min=0,max=1000,type=1, reset=_G["config_manager__reset_Sol"] },

        opacity_multiplier = { value=1.00, min=0,max=1 },
        shadow_opacity_multiplier = { value=1.00, min=0,max=1 },
        distance_multiplier = { value=1.45, min=0.5,max=2, reset=_G["config_manager__reset_Sol"] },
        quality = { value=0.6, min=0.3,max=2, reset=_G["config_manager__reset_Sol"] },
        render_limiter = { value=2, min=0,max=2,type=1 },
        render_per_frame = { value=20, min=1,max=100,type=1 },
        movement_linked_to_time_progression = { value=false },
        movement_multiplier = { value=1.00, min=0,max=10 },

        __index__ = 10,
    },

    sun = {
        size = { value=1.00, min=0.01,max=100 },
        sky_bloom = { value=0.63, min=0,max=2 },
        fog_bloom = { value=1.00, min=0,max=2 },
        modify_speculars = { value=true },
        dazzle_mix = { value=0.00, min=0,max=1 },
        dazzle_strength = { value=0.50, min=0,max=1 },
        dazzle_zenith_multi = { value=0.00, min=0,max=1 },

        __index__ = 11,
    },

    moon = {
        casts_shadows = { value=true },

        __index__ = 12,
    },

    ambient = {
        sun_color_balance = { value=1.0, min=0,max=2 },
        use_directional_ambient_light = { value=true },
        use_overcast_sky_ambient_light = { value=true },
        AO_visibility = { value=1.00, min=0,max=1 },

        __index__ = 13,
    },

    night = {
        effects_multiplier = { value=0.50, min=0,max=1 },
        brightness_adjust = { value=0.35, min=0,max=2 },
        moonlight_multiplier = { value=1.00, min=0,max=10 },
        starlight_multiplier = { value=1.00, min=0,max=10 },

        __index__ = 14,
    },

    nlp = {
        use_light_pollusion_from_track_ini = { value=true },
        radius = { value=5, min=0,max=20 },
        density = { value=0.50, min=0,max=10 },
        Hue = { value=220, min=0,max=360,type=1 },
        Saturation = { value=0.25, min=0,max=2 },
        Level = { value=0.05, min=0,max=1 },

        __index__ = 15,
    },

    gfx = {
        reflections_brightness = { value=1.00, min=0,max=10 },
        reflections_saturation = { value=1.00, min=0,max=10 },

        __index__ = 16,
    },

    sound = {
        wind_volume_interior = { value=0.20, min=0,max=2 },
        wind_volume_exterior = { value=1.00, min=0,max=2 },
        thunder_volume_interior = { value=1.00, min=0,max=2 },
        thunder_volume_exterior = { value=1.00, min=0,max=2 },
        rain_volume_interior = { value=1.00, min=0,max=2 },
        rain_volume_exterior = { value=1.00, min=0,max=2 },

        __index__ = 17,
    },


    debug = {
        runtime = { value=false, reset=_G["config_manager__reset_Sol"] },
        solar_system = { value=true, reset=_G["config_manager__reset_Sol"] },
        weather = { value=false, reset=_G["config_manager__reset_Sol"] },
        weather_change = { value=false, reset=_G["config_manager__reset_Sol"] },
        weather_effects = { value=false, reset=_G["config_manager__reset_Sol"] },
        track = { value=false, reset=_G["config_manager__reset_Sol"] },
        camera = { value=false, reset=_G["config_manager__reset_Sol"] },
        AI = { value=false, reset=_G["config_manager__reset_Sol"] },
        graphics = { value=false, reset=_G["config_manager__reset_Sol"] },
        custom_config = { value=false, reset=_G["config_manager__reset_Sol"] },
        AE = { value=false, reset=_G["config_manager__reset_Sol"] },
        light_pollution = { value=false, reset=_G["config_manager__reset_Sol"] },

        __index__ = 18,
    },

    nerd__sky_adjust = {
	
        Hue = { value=1.00, min=0,max=2 },
        Saturation = { value=1.00, min=0,max=2 },
        Level = { value=1.00, min=0,max=10 },
        
        SunIntensityFactor = { value=1.00, min=0,max=10 },
        
        AnisotropicIntensity = { value=1.00, min=0,max=10 },
        Density = { value=1.00, min=0,max=10 },
        
        Scale = { value=1.00, min=0,max=10 },
        GradientStyle = { value=1.00, min=0.2,max=5 },
        InputYOffset = { value=0.00, min=-2,max=2 },

        __index__ = 19,
    },

    nerd__sun_adjust = {
	
        ls_Hue = { value=1.00, min=0,max=2 },
        ls_Saturation = { value=1.00, min=0,max=2 },
        ls_Level = { value=1.00, min=0,max=10 },
        ap_Level = { value=1.00, min=0,max=10 },

        __index__ = 20,
    },

    nerd__speculars_adjust = {

        Level = { value=1.00, min=0,max=10 },

        __index__ = 21,
    },

    nerd__clouds_adjust = {
	
        Saturation = { value=1.00, min=0,max=10 },
        Saturation_limit = { value=1.00, min=0,max=10 },
        Lit = { value=1.00, min=0,max=10 },
        Contour = { value=1.00, min=0,max=10 },

        __index__ = 22,
    },

    nerd__ambient_adjust = {
	
        Hue = { value=1.00, min=0,max=2 },
        Saturation = { value=1.00, min=0,max=2 },
        Level = { value=1.00, min=0,max=10 },

        __index__ = 23,
    },

    nerd__directional_ambient_light = {

        Level = { value=1.00, min=0,max=10 },

        __index__ = 24,
    },
        
    nerd__overcast_sky_ambient_light = {
        
        Level = { value=1.00, min=0,max=10 },

        __index__ = 25,
    },

    nerd__fog_custom_distant_fog = {

        use = { value=false },
        distance = { value=30000, min=1000,max=50000,type=1 },
        blend = { value=0.85, min=0,max=2 },
        density = { value=1.75, min=0,max=10 },
        exponent = { value=0.75, min=0,max=10 },
        backlit = { value=0.05, min=0,max=1 },
        sky = { value=0.00, min=-4,max=1 },
        sun = { value=1.00, min=0,max=10},
        night = { value=0.00, min=0,max=1 },
            
        Hue = { value=220.00, min=0,max=360,type=1 },
        Saturation = { value=0.50, min=0,max=10 },
        Level = { value=2.50, min=0,max=10 },

        __index__ = 26,
    },

    nerd__moon_adjust = {
	
        low_Hue = { value=32.00, min=0,max=360,type=1 },
        low_Saturation = { value=1.60, min=0,max=10 },
        low_Level = { value=3.60, min=0,max=10 },
        
        high_Hue = { value=210.00, min=0,max=360,type=1 },
        high_Saturation = { value=0.30, min=0,max=10 },
        high_Level = { value=2.00, min=0,max=10 },
        
        mie_Exponent = { value=15, min=0,max=100 },
        mie_Multi = { value=1.50, min=0,max=10 },
        
        ambient_ratio = { value=0.50, min=0,max=10 },

        __index__ = 28,
    },

    nerd__stars_adjust = {
	
        Saturation = { value=1.00, min=0,max=10 },
        Exponent = { value=1.00, min=0,max=10 },

        __index__ = 29,
    },

    nerd__night_sky = {
	
        Hue = { value=220.00, min=0,max=360,type=1 },
        Saturation = { value=0.50, min=0,max=10 },
        Level = { value=0.0, min=0,max=1 },
    
        Size = { value=0.50, min=0,max=1 },

        __index__ = 30,
    },

    nerd__csp_lights_adjust = {

        bounced_day = { value=0.00, min=0,max=10 },
        bounced_night = { value=1.00, min=0,max=10 },
        
        emissive_day = { value=0.65, min=0,max=10 },
        emissive_night = { value=1.00, min=0,max=10 },

        __index__ = 31,
    },
}


-- link to old values to write them in the config while transition period

_l_config.performance.use_cpu_split.old = "sol__use_cpu_split"
_l_config.performance.only_use_smaller_textures.old = "sol__only_use_smaller_textures"

_l_config.monitor_compensation.blacklevel.old = "blacklevel__compensation"
_l_config.monitor_compensation.colors_whitebalance.old = "colors_whitebalance"

_l_config.ppoff.brightness.old = "ppoff__brightness"

_l_config.pp.brightness.old = "ppfilter__brightness"
_l_config.pp.contrast.old = "ppfilter__contrast"
_l_config.pp.saturation.old = "ppfilter__saturation"
_l_config.pp.brightness_sun_link.old = "ppfilter__brightness_sun_link"
_l_config.pp.brightness_sun_link_only_interior.old = "ppfilter__brightness_sun_link_only_interior"
_l_config.pp.modify_glare.old = "ppfilter__modify_glare"
_l_config.pp.glare_day_threshold.old = "ppfilter__glare_day_threshold"
_l_config.pp.modify_godrays.old = "ppfilter__modify_godrays"
_l_config.pp.godrays_singlescreen.old = "ppfilter__godrays_singlescreen"
_l_config.pp.modify_spectrum.old = "ppfilter__modify_spectrum"

_l_config.ae.use_self_calibrating.old = "ae__use_self_calibrating"
_l_config.ae.control_strength.old = "ae__control_strength"
_l_config.ae.control_damping.old = "ae__control_damping"
_l_config.ae.eye_laziness.old = "ae__eye_laziness"
_l_config.ae.alternate_ae_mode.old = "ae__alternate_ae_mode"
_l_config.ae.interior_multiplier.old = "ae__interior_multiplier"

_l_config.headlights.if_sun_angle_is_under.old = "headlights__if_sun_angle_is_under"
_l_config.headlights.if_ambient_light_is_under.old = "headlights__if_ambient_light_is_under"
_l_config.headlights.if_fog_dense_is_over.old = "headlights__if_fog_dense_is_over"
_l_config.headlights.if_bad_weather.old = "headlights__if_bad_weather"

_l_config.csp_lights.controlled_by_sol.old = "global_CSP_lights_controlled_by_sol"
_l_config.csp_lights.multiplier.old = "global_CSP_lights_multi"

_l_config.weather.HDR_multiplier.old = "weather__HDR_multiplier"
_l_config.weather.use_lightning_effect.old = "weather__use_lightning_effect"

_l_config.sky.blue_preset.old = "sky__blue_preset"
_l_config.sky.blue_strength.old = "sky__blue_strength"
_l_config.sky.smog.old = "sky__smog"
_l_config.sky.day__horizon_glow.old = "day__horizon_glow"
_l_config.sky.night__horizon_glow.old = "night__horizon_glow"

_l_config.clouds.render_method.old = "clouds__render_method"
_l_config.clouds.preload_2d_textures.old = "clouds__preload_2d_textures"
_l_config.clouds.randomize_with_reset.old = "clouds__randomize_with_reset"
_l_config.clouds.manual_random_seed.old = "clouds__manual_random_seed"

_l_config.clouds.opacity_multiplier.old = "clouds__opacity_multiplier"
_l_config.clouds.shadow_opacity_multiplier.old = "clouds__shadow_opacity_multiplier"
_l_config.clouds.distance_multiplier.old = "clouds__distance_multiplier"
_l_config.clouds.quality.old = "clouds__quality"
_l_config.clouds.render_limiter.old = "clouds__render_limiter"
_l_config.clouds.render_per_frame.old = "clouds__render_per_frame"
_l_config.clouds.movement_linked_to_time_progression.old = "clouds__movement_linked_to_time_progression"
_l_config.clouds.movement_multiplier.old = "clouds__movement_multiplier"

_l_config.sun.size.old = "sun__size"
_l_config.sun.sky_bloom.old = "sun__sky_bloom"
_l_config.sun.fog_bloom.old = "sun__fog_bloom"
_l_config.sun.modify_speculars.old = "sun__modify_speculars"
_l_config.sun.dazzle_mix.old = "sun__dazzle_mix"
_l_config.sun.dazzle_strength.old = "sun__dazzle_strength"
_l_config.sun.dazzle_zenith_multi.old = "sun__dazzle_zenith_multi"

_l_config.moon.casts_shadows.old = "moon_casts_shadows"

_l_config.ambient.sun_color_balance.old = "ambient__sun_color_balance"
_l_config.ambient.use_directional_ambient_light.old = "ambient__use_directional_ambient_light"
_l_config.ambient.use_overcast_sky_ambient_light.old = "ambient__use_overcast_sky_ambient_light"
_l_config.ambient.AO_visibility.old = "ambient__AO_visibility"

_l_config.night.effects_multiplier.old = "night__effects_multiplier"
_l_config.night.brightness_adjust.old = "night__brightness_adjust"
_l_config.night.moonlight_multiplier.old = "night__moonlight_multiplier"
_l_config.night.starlight_multiplier.old = "night__starlight_multiplier"

_l_config.nlp.use_light_pollusion_from_track_ini.old = "nlp__use_light_pollusion_from_track_ini"
_l_config.nlp.radius.old = "nlp__radius"
_l_config.nlp.density.old = "nlp__density"
_l_config.nlp.Hue.old = "nlp__color.Hue"
_l_config.nlp.Saturation.old = "nlp__color.Saturation"
_l_config.nlp.Level.old = "nlp__color.Level"

_l_config.gfx.reflections_brightness.old = "gfx__reflections_brightness"
_l_config.gfx.reflections_saturation.old = "gfx__reflections_saturation"

_l_config.sound.wind_volume_interior.old = "sound__wind_volume_interior"
_l_config.sound.wind_volume_exterior.old = "sound__wind_volume_exterior"
_l_config.sound.thunder_volume_interior.old = "sound__thunder_volume_interior"
_l_config.sound.thunder_volume_exterior.old = "sound__thunder_volume_exterior"
_l_config.sound.rain_volume_interior.old = "sound__rain_volume_interior"
_l_config.sound.rain_volume_exterior.old = "sound__rain_volume_exterior"

_l_config.debug.runtime.old = "sol__debug__runtime"
_l_config.debug.solar_system.old = "sol__debug__solar_system"
_l_config.debug.weather.old = "sol__debug__weather"
_l_config.debug.weather_change.old = "sol__debug__weather_change"
_l_config.debug.weather_effects.old = "sol__debug__weather_effects"
_l_config.debug.track.old = "sol__debug__track"
_l_config.debug.camera.old = "sol__debug__camera"
_l_config.debug.AI.old = "sol__debug__AI"
_l_config.debug.graphics.old = "sol__debug__graphics"
_l_config.debug.custom_config.old = "sol__debug__custom_config"
_l_config.debug.AE.old = "sol__debug__AE"
_l_config.debug.light_pollution.old = "sol__debug__light_pollution"
	
_l_config.nerd__sky_adjust.Hue.old = "nerd__sky_adjust.Hue"
_l_config.nerd__sky_adjust.Saturation.old = "nerd__sky_adjust.Saturation"
_l_config.nerd__sky_adjust.Level.old = "nerd__sky_adjust.Level"
_l_config.nerd__sky_adjust.SunIntensityFactor.old = "nerd__sky_adjust.SunIntensityFactor"
_l_config.nerd__sky_adjust.AnisotropicIntensity.old = "nerd__sky_adjust.AnisotropicIntensity"
_l_config.nerd__sky_adjust.Density.old = "nerd__sky_adjust.Density"
_l_config.nerd__sky_adjust.Scale.old = "nerd__sky_adjust.Scale"
_l_config.nerd__sky_adjust.GradientStyle.old = "nerd__sky_adjust.GradientStyle"
_l_config.nerd__sky_adjust.InputYOffset.old = "nerd__sky_adjust.InputYOffset"

_l_config.nerd__sun_adjust.ls_Hue.old = "nerd__sun_adjust.ls_Hue"
_l_config.nerd__sun_adjust.ls_Saturation.old = "nerd__sun_adjust.ls_Saturation"
_l_config.nerd__sun_adjust.ls_Level.old = "nerd__sun_adjust.ls_Level"
_l_config.nerd__sun_adjust.ap_Level.old = "nerd__sun_adjust.ap_Level"

_l_config.nerd__speculars_adjust.Level.old = "nerd__speculars_adjust.Level"

_l_config.nerd__clouds_adjust.Saturation.old = "nerd__clouds_adjust.Saturation"
_l_config.nerd__clouds_adjust.Saturation_limit.old = "nerd__clouds_adjust.Saturation_limit"
_l_config.nerd__clouds_adjust.Lit.old = "nerd__clouds_adjust.Lit"
_l_config.nerd__clouds_adjust.Contour.old = "nerd__clouds_adjust.Contour"

_l_config.nerd__ambient_adjust.Hue.old = "nerd__ambient_adjust.Hue"
_l_config.nerd__ambient_adjust.Saturation.old = "nerd__ambient_adjust.Saturation"
_l_config.nerd__ambient_adjust.Level.old = "nerd__ambient_adjust.Level"

_l_config.nerd__directional_ambient_light.Level.old = "nerd__directional_ambient_light.Level"
_l_config.nerd__overcast_sky_ambient_light.Level.old = "nerd__overcast_sky_ambient_light.Level"

_l_config.nerd__fog_custom_distant_fog.use.old = "nerd__fog_use_custom_distant_fog"
_l_config.nerd__fog_custom_distant_fog.distance.old = "nerd__fog_custom_distant_fog.distance"
_l_config.nerd__fog_custom_distant_fog.blend.old = "nerd__fog_custom_distant_fog.blend"
_l_config.nerd__fog_custom_distant_fog.density.old = "nerd__fog_custom_distant_fog.density"
_l_config.nerd__fog_custom_distant_fog.exponent.old = "nerd__fog_custom_distant_fog.exponent"
_l_config.nerd__fog_custom_distant_fog.backlit.old = "nerd__fog_custom_distant_fog.backlit"
_l_config.nerd__fog_custom_distant_fog.sky.old = "nerd__fog_custom_distant_fog.sky"
_l_config.nerd__fog_custom_distant_fog.night.old = "nerd__fog_custom_distant_fog.night"
_l_config.nerd__fog_custom_distant_fog.Hue.old = "nerd__fog_custom_distant_fog.Hue"
_l_config.nerd__fog_custom_distant_fog.Saturation.old = "nerd__fog_custom_distant_fog.Saturation"
_l_config.nerd__fog_custom_distant_fog.Level.old = "nerd__fog_custom_distant_fog.Level"

_l_config.nerd__moon_adjust.low_Hue.old = "nerd__moon_adjust.low_Hue"
_l_config.nerd__moon_adjust.low_Saturation.old = "nerd__moon_adjust.low_Saturation"
_l_config.nerd__moon_adjust.low_Level.old = "nerd__moon_adjust.low_Level"
_l_config.nerd__moon_adjust.high_Hue.old = "nerd__moon_adjust.high_Hue"
_l_config.nerd__moon_adjust.high_Saturation.old = "nerd__moon_adjust.high_Saturation"
_l_config.nerd__moon_adjust.high_Level.old = "nerd__moon_adjust.high_Level"
_l_config.nerd__moon_adjust.mie_Exponent.old = "nerd__moon_adjust.mie_Exponent"
_l_config.nerd__moon_adjust.mie_Multi.old = "nerd__moon_adjust.mie_Multi"
_l_config.nerd__moon_adjust.ambient_ratio.old = "nerd__moon_adjust.ambient_ratio"

_l_config.nerd__stars_adjust.Saturation.old = "nerd__stars_adjust.Saturation"
_l_config.nerd__stars_adjust.Exponent.old = "nerd__stars_adjust.Exponent"

_l_config.nerd__night_sky.Hue.old = "nerd__night_sky.Hue"
_l_config.nerd__night_sky.Saturation.old = "nerd__night_sky.Saturation"
_l_config.nerd__night_sky.Level.old = "nerd__night_sky.Level"
_l_config.nerd__night_sky.Size.old = "nerd__night_sky.Size"


_l_config.nerd__csp_lights_adjust.bounced_day.old = "nerd__csp_lights_adjust.bounced_day"
_l_config.nerd__csp_lights_adjust.bounced_night.old = "nerd__csp_lights_adjust.bounced_night"
_l_config.nerd__csp_lights_adjust.emissive_day.old = "nerd__csp_lights_adjust.emissive_day"
_l_config.nerd__csp_lights_adjust.emissive_night.old = "nerd__csp_lights_adjust.emissive_night"




function access_global_table_by_string(s, v)

    if s then
        one, two = s:match("([^.]+).([^.]+)")
        if one and two then
            if _G[one] ~= nil then
                if _G[one][two] ~= nil then
                    if v then
                        _G[one][two] = v
                    end
                        
                    return _G[one][two]
                else

                end
            end
        end
    end

    return nil
end

function config_manager__create_defaults()
    -- backup initial values as defaults
    local k, kk
    local v, vv

    for k, v in pairs(_l_config) do
        for kk, vv in pairs(v) do
            if tostring(kk) ~= "__index__" then
                vv.default = vv.value
            end
        end
    end
end
-- execute defaults backup
config_manager__create_defaults()

function config_manager__reset_to_defaults()
    -- overwrite all parameter to default value via shared memory backup
    
    local k, kk
    local v, vv

    for k, v in pairs(_l_config) do
        for kk, vv in pairs(v) do
            if tostring(kk) ~= "__index__" then
                --[[
                vv.value = vv.default

                if transition_period then 
                    if _G[v.old] ~= nil then
                        _G[v.old] = vv.value
                    else
                        access_global_table_by_string(v.old, vv.value)
                    end
                end
                ]]
                -- add it to the temp memory backup
                if _l_config_session_changes[k] == nil then
                    _l_config_session_changes[k] = {}
                end
                _l_config_session_changes[k][kk] = vv.default
            end
        end
    end

    -- put all parameters to temp memory backup, all on default values
    shared_memory_backup__Write(_l_CM_SharedBackup, _l_config_session_changes)

    __configAppInterface:add_order("CMD", {"system","UpConsole","All settings are resetted to default values"})

    -- reset wfx to force everything right
    config_manager__reset_Sol()
end

function config_manager__update_design()

    local file = __sol__path.."config\\sol_config_design.txt"
    if not file_exists(file) then return {} end

    local a
    local b

	lines = {}
	for line in io.lines(file) do 
		
        lines[#lines + 1] = line
        
        for k, v in pairs(_l_config) do
            if k then
                for kk, vv in pairs(v) do
                    if kk ~= "__index__" then

                        c1,c2 = string.find(line, " --") --get the start of the comment to doublecheck the parameter name
                        a,b = string.find(line, ""..k.."."..kk)
                        if a and a==1 and b==(c1-1) then
                            if type(vv.value) == "boolean" then
                                if vv.value then
                                    lines[#lines] = ""..k.."."..kk.." --type=boolean,default=true"
                                else
                                    lines[#lines] = ""..k.."."..kk.." --type=boolean,default=false"
                                end
                            else
                                if vv.type and vv.type == 1 then
                                    lines[#lines] = ""..k.."."..kk.." --type=integer,min="..vv.min..",max="..vv.max..",default="..vv.value
                                else    
                                    lines[#lines] = ""..k.."."..kk.." --type=float,min="..vv.min..",max="..vv.max..",default="..vv.value
                                end
                            end
                        end
                    end
                end
            end
        end
	end

    local f=io.open(file,"w+")
    if f~=nil then
        io.output(f)
        for i=1,#lines do
            io.write(lines[i])
            io.write("\n")
        end
        io.close(f)
    end
end

--config_manager__update_design()


function config_manager__save_config__write_section(s, t, initial)

    local k
    local v
--[[
    local write_table = {}
    for k, v in pairs(t) do
        
        write_table[v.__index__] = {}
        write_table[v.__index__][1] = k
        write_table[v.__index__][2] = v
    end

     --write section
     io.write("["..tostring(s).."]\n")
    for i=1, #write_table do

        k = write_table[i][1]
        v = write_table[i][2]

        if tostring(k) ~= "__index__" then

            local value = v.value
            if initial and transition_period then 
                value = v.old
            end

            if type(value) == "boolean" then
                io.write(tostring(k).."="..tostring(value).." ; default="..tostring(v.value))
            else
                io.write(tostring(k).."="..value.." ; min="..v.min..", max="..v.max..", default="..v.value)
            end
            io.write("\n")
        end
    end
    io.write("\n")
]]

    --write section
    io.write("["..tostring(s).."]\n")
    for k, v in pairs(t) do
        
        if tostring(k) ~= "__index__" then

            local value = v.value
            if initial and transition_period then 
                if _G[v.old] ~= nil then
                    value = _G[v.old]
                else
                    local temp = access_global_table_by_string(v.old)
                    if temp then 
                        value = temp
                    end
                end
            end

            if type(value) == "boolean" then
                io.write(tostring(k).."="..tostring(value))
            else
                io.write(tostring(k).."="..value)
            end
            io.write("\n")
        end
    end
    io.write("\n")

end

function config_manager__save_config__write_date()

    io.write("[DATE]\n")

    local date = os.date("*t")

    for k, v in pairs(date) do
        io.write(tostring(k).."="..tostring(v).."\n")
    end
    io.write("\n")
end

function config_manager__store_standard_config_file(withCustomConfigChanges)

    local _l_Sol_Config_INI = _l_Documents_Folder.."\\sol_config.ini"

    config_manager__save_config(_l_Sol_Config_INI, withCustomConfigChanges)

    -- clear the shared memeory temp config
    shared_memory_backup__Clear(_l_CM_SharedBackup)
    _l_config_session_changes = {}

    __configAppInterface:add_order("CMD", {"system","UpConsole","Config stored"})
    __configAppInterface:add_order("CMD", {"system","clearDirty","true"})
end

function config_manager__load_standard_config_file()

    -- clear the shared memeory temp config
    shared_memory_backup__Clear(_l_CM_SharedBackup)
    _l_config_session_changes = {}

    __configAppInterface:add_order("CMD", {"system","UpConsole","Config loaded"})
    __configAppInterface:add_order("CMD", {"system","clearDirty","true"})

    config_manager__reset_Sol()
end

function config_manager__save_config(file, initial)

    if file then

        local source = _l_config_backup

        initial = initial or false
        if initial then source = _l_config end

        local k
        local v

        local write_table = {}
        for k, v in pairs(source) do
            
            if v.__index__ then
                write_table[v.__index__] = {}
                write_table[v.__index__][1] = k
                write_table[v.__index__][2] = v
            else
                ac.debug("Config Write: incorrect index of ", tostring(k))
            end
        end

        local f=io.open(file,"w+")
        if f~=nil then
            io.output(f)

            --Write some date/time stuff
            config_manager__save_config__write_date()

            for i=1, #write_table do

                if write_table[i] ~= nil then

                    k = write_table[i][1]
                    v = write_table[i][2]

                    config_manager__save_config__write_section(k, v, initial)
                end
            end
            io.close(f)
        end 
    end
end


function config_manager__check_parsed_section(s, t)

    local value
    local error = false

    local k
    local v
    
    local section_id = tostring(s)
    for k, v in pairs(t) do
        
        if tostring(k) ~= "__index__" then

            value = get_parsed_value(_l_config_parse, section_id, tostring(k))
            if value then

            else
                error = true
            end

            if transition_period then
                if _G[_l_config[section_id][tostring(k)].old] ~= nil then
                    v.value = _G[_l_config[section_id][tostring(k)].old]
                else
                    v.value = access_global_table_by_string(_l_config[section_id][tostring(k)].old)
                end
            else
                --value = get_parsed_value(_l_config_parse, section_id, tostring(k))
                if value then
                    -- overwrite initial data with ini data
                    if value == "true" then
                        v.value = true
                    elseif value == "false" then
                        v.value = false
                    else 
                        v.value = math.min( v.max, math.max( v.min, value)) 
                    end
                end
            end
        end
    end

    return error
end

function config_manager__initAppValues()

    for k, v in pairs(_l_config) do
        if k then
            for kk, vv in pairs(v) do
                if kk ~= "__index__" then
                    __configAppInterface:add_order("INIT_VALUE", {k,kk,vv.value})
                end
            end
        end
    end
    _l_custom_config_control = {}
    __configAppInterface:clear_order_list_after_send()
end

function config_manager__initLockingConfigApp()
    
    for k, v in pairs(_l_config) do
        if k then
            for kk, vv in pairs(v) do
                if kk ~= "__index__" then
                    if vv.reset ~= nil then
                        __configAppInterface:add_order("CMD", {"UI","LockAfterUse",k,kk,"true"})
                    end
                end
            end
        end
    end
    __configAppInterface:clear_order_list_after_send()
end

function config_manager__read_config(file)

    local _l_Sol_Config_INI = ""

    if file ~= nil then
        _l_Sol_Config_INI = file
    else
        
        _l_Sol_Config_INI = _l_Documents_Folder.."\\sol_config.ini"
    end

    if not file_exists(_l_Sol_Config_INI) then
        -- if there is no config file, create one with default values
        os.execute("mkdir ".."\"".._l_Documents_Folder.."\"")
        config_manager__save_config(_l_Sol_Config_INI, true)
    else
        -- read the config file and set the values in the _l_config table
        local error = false

        _l_config_parse = parse_INI(_l_Sol_Config_INI, "PP")
        if _l_config_parse ~= nil then

            local k
            local v
            
            for k, v in pairs(_l_config) do
               if config_manager__check_parsed_section(k, v) then error=true --[[ac.debug("err "..k, "1")]] end
            end

            if error then
                -- An error occurs, if an entry was missing, it means the config file is outdated.
                -- So recreate it with the custom values plus the new default ones.
                config_manager__save_config(_l_Sol_Config_INI, true)
                ac.debug("Sol config", "updated")
            end
        else
            ac.debug("Couldn't parse sol_config.ini!")
        end

        if transition_period then
            -- while transition_period do a backup per day

            local date = os.date("*t").yday
            local file_date = get_parsed_value(_l_config_parse, "DATE", "yday")

            if file_date ~= nil then
                if date ~= file_date then
                    config_manager__save_config(_l_Sol_Config_INI, true)
                end
            end
        end
    end

    -- try to restore the values of a session which made before a reset
    config_manager__readTempConfig()

    --backup config
    _l_config_backup = table__deepcopy(_l_config)

    --reinit all values of the config App
    config_manager__initAppValues()
    config_manager__initLockingConfigApp()

    --config_manager__update_design()
end

function config_manager__readTempConfig()

    local k, kk
    local v, vv

    _l_config_session_changes = shared_memory_backup__Read(_l_CM_SharedBackup, _l_config_session_changes)
    
    for k, v in pairs(_l_config_session_changes) do
        for kk, vv in pairs(v) do
            if _l_config[k] and _l_config[k][kk] then 
                _l_config[k][kk].value = vv
            end
        end
    end
end

function config_manager__writeTempConfig()

    shared_memory_backup__Write(_l_CM_SharedBackup, _l_config_session_changes)

end

function config_manager__StopCustomConfigFeedback()
    _l_allowCustomConfigInterfaceFeedback = false
end

function SOL__set_config(section, key, value, relative, debug, from_interface, feedback_to_Interface)

    if debug == nil then debug = false end
    if from_interface == nil then from_interface = false end
    if relative == nil then relative = false end
    if feedback_to_Interface == nil then feedback_to_Interface = _l_allowCustomConfigInterfaceFeedback end
    
    local report_back_to_interface = false

    if _l_config[section] ~= nil then
        if _l_config[section][key] ~= nil then
            local v = _l_config[section][key]

            if v.reset and not from_interface then
                ac.debug("Config Set - changing ", ""..section.."|"..key.." is not allowed in custom configs!")
            elseif type(v.value) == type(value) then

                if type(v.value)=="number" then
                    value = math.min( v.max, math.max( v.min, value))
                end

                if not from_interface then
                    -- command comes from custom config

                    -- create an entry to check controlling
                    _l_custom_config_control[section.."."..key] = { value, relative }
                else
                    -- backup config paramter
                    _l_config_backup[section][key].value = value

                    -- command comes from within Sol or Sol_config App
                    if _l_custom_config_control[section.."."..key] ~= nil then
                        -- parameter was modified by custom config
                        
                        if not _l_custom_config_control[section.."."..key][2] then
                            return value
                        else
                       
                        end
                    end

                    if _l_config_session_changes[section] == nil then
                        _l_config_session_changes[section] = {}
                    end
                end
                
                if v.reset == nil then
                    -- only set the configs value, if the parameter has no reset function
                    if type(v.value)=="number" then
                        
                        v.value = value
                        -- if a parameter is changed in a custom config    
                        if _l_custom_config_control[section.."."..key] then
                            if _l_custom_config_control[section.."."..key][2] then
                                --relative change
                                v.value = math.min( v.max, math.max( v.min, _l_config_backup[section][key].value * _l_custom_config_control[section.."."..key][1] ))
                                if from_interface then
                                    --report the relative change back to the interface
                                    report_back_to_interface = true
                                end
                            end
                        end
                    else
                        v.value = value
                    end

                    if transition_period then
                        if _G[v.old] ~= nil then
                            _G[v.old] = v.value
                        else
                            access_global_table_by_string(v.old, v.value)
                        end
                    end

                    if debug then ac.debug("Set Config "..section.."."..key, v.value) end

                    if from_interface then
                        _l_config_session_changes[section][key] = _l_config_backup[section][key].value
                        -- backup everything in the shared memory to recall it after the reset
                        config_manager__writeTempConfig()
                    end
                else
                    -- if the parameter has a reset function, only put it in the shared memory backup
                    if from_interface then
                        _l_config_session_changes[section][key] = value
                        -- backup everything in the shared memory to recall it after the reset
                        config_manager__writeTempConfig()
                    end
                end

                

                if v.reset and from_interface then
                    -- only reset if call comes from within Sol or an App and not by a custom config
                    
                    local tmp = ""
                    if type(v.value)=="number" then
                        tmp = tmp..v.value
                    elseif v.value then
                        tmp = tmp.."true"
                    else
                        tmp = tmp.."false"
                    end  
                    v.reset(section.."."..key..":"..tmp)
                end

                if feedback_to_Interface then
                    if not from_interface then
                        __configAppInterface:add_order("SET_VALUE", {section,key,v.value,relative})
                    else
                        __configAppInterface:add_order("INIT_VALUE", {section,key,_l_config_backup[section][key].value})
                    end
                end

                if report_back_to_interface then
                    __configAppInterface:add_order("SET_VALUE", {section,key,v.value,true})
                end

                return v.value
            else
                ac.debug("!!! Config Set", ""..section.."|"..key.." is "..type(v.value).." NOT "..type(value).." !")
            end
        else
            ac.debug("!!! Config Set", "Key "..key.." is not part of Section "..section.." !")
        end
    else
        ac.debug("!!! Config Set", "Section "..section.." is not part of Sol config !")
    end

    return 0
end

function SOL__config(section, key)

    if _l_config[section] and _l_config[section][key] then
--[[  
        if transition_period then
            if _G[_l_config[section][key].old] ~= nil then
                return _G[_l_config[section][key].old]
            else
                return access_global_table_by_string(_l_config[section][key].old)
            end
        end
]] 
        if _l_config[section][key].value == nil then
            ac.debug("!!! Config Set", "Section "..section.."|"..key.." VALUE IS NIL")
        else
            return _l_config[section][key].value
        end
    else
        ac.debug("!!! Config Set", "Section "..section.."|"..key.." INVALID")
    end
    return nil
end