-----------------------------
--- sol custom parameters ---


-- ▌   P E R F O R M A N C E   ▐   
-- #
-- Set this to true, to improve CPU calculation time
sol__use_cpu_split = false --default=false
-- #
-- If set to true, Sol just uses the smaller textures, like the 4k starmap.
-- You need to restart AC to reset VRAM.
sol__only_use_smaller_textures = false --default=false

-----------------------------------------------------------------------------------
-- ▌   MONITOR COMPENSATION   ▐   
-- #
-- To adjust this, please look in the manual
-- chapter "Tweaks and performance improvements / monitor calibration"
-- #
blacklevel__compensation = 0 --min=0,max=30,default=0

--  -10 (cold) ... 0 (neutral) ... 10 (warm)
colors_whitebalance = 0 --min=-10,max=10,default=0

--<br>

-- ▌   POST PROCESSING off   ▐   
-- #
ppoff__brightness = 1.00 --min=0.25,max=1.75,default=1.00

-----------------------------------------------------------------------------------
-- ▌   PP FILTER   ▐   
-- #
ppfilter__brightness = 1.00 --min=0.25,max=1.75,default=1.00
ppfilter__contrast = 1.00 --min=0.8,max=1.2,default=1.00
ppfilter__saturation = 1.00 --min=0.0,max=2.0,default=1.00
-----------------------------------------------------------------------------------
-- With less sun, brightness is increased. This includes clouds shadow too.
-- #
ppfilter__brightness_sun_link = 1.00 --min=0.00,max=4.00,default=1.00
-- #
ppfilter__brightness_sun_link_only_interior = true --default=true
-----------------------------------------------------------------------------------
-- If set to "false", the PP effect is not modified by Sol 
-- #
ppfilter__modify_glare = false --default=false
ppfilter__glare_day_threshold = 2.00 --min=0.0,max=50.00,default=2.00
-- #
ppfilter__modify_godrays = false --default=false
ppfilter__godrays_singlescreen = true --default=true
ppfilter__modify_spectrum = false --default=false

--<br>

-- ▌   AUTO EXPOSURE   ▐   
-- #
-- Use a self calibration to compensate the internal AE multiplier of different
-- cars. After 1-2 minutes the calibration finds an optimal multiplier !!!
-- [AUTO_EXPOSURE] must have ENABLED=1 in the PPfilter to use this !!!
ae__use_self_calibrating = false --default=false
-- #
-- The dynamic of exposure control.
ae__control_strength = 2.00 --min=-1,max=10,default=2.00
-- damping
ae__control_damping = 0.50 --min=0,max=1,default=0.50
-- #
-- Simulates the regeneration of rhodopsin.
-- The adaptation to darkness lasts longer, than to bright light
ae__eye_laziness = 1.00 --min=0,max=1,default=1.00
-- #
-- Use different effects, instead of the standard auto exposure
-- 0: standard brightness control
-- 1: weather__HDR is additionaly modulated depending on AE value
ae__alternate_ae_mode = 0 --min=0,max=1,default=0
-- #
-- Set a custom multiplier/brightness only for interior view
ae__interior_multiplier = 1.00 --min=0.25,max=4.00,default=1.00

--<br>

-- ▌   CSP Lights   ▐   
-- #
-- The headlights will be switched on or off with certain ambient light levels,
-- sun angle, fog_dense levels, or dependent on the weather badness index
-- #
headlights__if_sun_angle_is_under = 3 --min=-90,max=90,default=3
headlights__if_ambient_light_is_under = 7.50 --min=0,max=15,default=7.50
headlights__if_fog_dense_is_over = 0.70 --min=0,max=1,default=0.70
headlights__if_bad_weather = 0.50 --min=0,max=1,default=0.50
-- #
-- #
-- If this is activated, CSP lights appear with sunset and 
-- disappear with sunrise. It will also control CSP's new light's fog glow.
-- Set it to false, if you like to use your own control in
-- sol custom config over ac.setWeatherLightsMultiplier(x) and
-- ac.setGlowBrightness(x).
global_CSP_lights_controlled_by_sol = false --default=false
-- #
-- This multi effects all CSP lights,
-- if global_CSP_lights_controlled_by_sol is activated
global_CSP_lights_multi = 1.00 --min=0,max=4,default=1.00
--<br>

-- ▌   WEATHER   ▐   
-- #
-- increase the brightness differences between sun, sky, clouds and ground
weather__HDR_multiplier = 1.00 --min=0.0,max=2.0,default=1.00
-----------------------------------------------------------------------------------
-- WEATHER EFFECTS
-- #
-- use weather effects (lightning, ...)
weather__use_lightning_effect = true --default=true

-----------------------------------------------------------------------------------
-- ▌   CLOUD/SKY SYSTEM   ▐
-- #
-- Clouds Render Methods:
-- 0 = 2d clouds
-- 1 = 3d clouds (tweaked code from Ilja's "Default" implementation)
-- 2 = 3d clouds (Sol's advanced cloud system)
clouds__render_method = 2 --min=0,max=2,default=2
-- #
-- #
-- Set this to true and all 2d cloud texture will be preloaded.
-- This reduces stutter in dynamic weather, if VRAM is big enough.
clouds__preload_2d_textures = false --default=false
-- #
-- ▌   CLOUDS RANDOMIZATION   ▐
-- #
-- If set to true, clouds are randomized with every reset.
clouds__randomize_with_reset = false --default=false
-- Use this as a preset of different fixed cloud positions.
clouds__manual_random_seed = 0 --min=0,max=1000,default=0

--<br>

-- ▌   SKY   ▐   
-- #
-- ### Sky Blue Preset ###
-- 0 - flat
-- 1 - moderate
-- 2 - nice blue
-- 3 - dark blue
-- 4 - ACC
-- 5 - Truck Sim
-- 6 - deep blue
-- 7 - flight sim
-- 8 - custom / custom_config
-- 9 - PPoff
sky__blue_preset = 1 --min=0,max=9,default=1
sky__blue_strength = 1.00 --min=0,max=2,default=1.00
-- #
-- Smog simulation multiplier.
-- There are induvidual settings for the tracks. 
sky__smog = 0.75 --min=0,max=2,default=0.75

-- #
-- the brightness of the horizont while day
day__horizon_glow = 1.00 --min=0,max=10,default=1.00
-- #
-- the brightness of the horizont while night
night__horizon_glow = 1.00 --min=0,max=10,default=1.00

--<br>


-- ▌   CLOUDS   ▐
-- #
clouds__opacity_multiplier = 1.00 --min=0,max=2,default=1.00
-- #
clouds__shadow_opacity_multiplier = 1.00 --min=0,max=1,default=1.00
-- #
clouds__distance_multiplier = 1.45 --min=0.5,max=2,default=1.45
-- #
clouds__quality = 0.60 --min=0.3,max=2,default=0.60
-----------------------------------------------------------------------------------
-- CLOUDS optimizations
-- #
-- Limit clouds rendering per frame to:
-- 0 = no limit, 1 = only clouds in FOV, 2 = clouds__render_per_frame
-- If set to 1, all clouds in the FOV will be rendered every frame, the
-- remaining clouds will be rendered per clouds__render_per_frame
clouds__render_limiter = 2 --min=0,max=2,default=2
-- #
-- To lower cpu consumption, color calculation can be reduced by limiting the
-- clouds to render per frame. Notice, you will see the updating then!
clouds__render_per_frame = 10 --min=1,max=100,default=10
-----------------------------------------------------------------------------------
-- #
clouds__movement_linked_to_time_progression = false --default=false
-- #
clouds__movement_multiplier = 1.00 --min=0,max=10,default=1.00
--<br>

-- ▌   STELLAR   ▐   
-- #
-- size of moon and sun
sun__size = 1.00 --min=0.01,max=100,default=1.00
-- #
-- litten atmosphere by the sun
sun__sky_bloom = 0.63 --min=0.0,max=2.0,default=0.63
-- litten fog by sun
sun__fog_bloom = 1.00 --min=0.0,max=2.0,default=1.00
-- #
-- modify sun reflecting on objects with specular
sun__modify_speculars = true --default=true
-- #
-- If set to false, the moonlight will not cause shadows.
-- This will save gpu consumption.
moon_casts_shadows = true --default=true

-----------------------------------------------------------------------------------
-- Sun Dazzle Effect
-- #
-- ppfilter__modify_godrays (page 1) must be activated !
-- #
-- dazzle ratio
sun__dazzle_mix = 0.00 --min=0.0,max=1.0,default=0.0
-- maximum effect strength
sun__dazzle_strength = 0.50 --min=0.0,max=1.0,default=0.5
-- the amount of dazzle with sun above 65°
sun__dazzle_zenith_multi = 0 --min=0.0,max=1.0,default=0.0
--<br>

-- ▌   AMBIENT   ▐   
ambient__sun_color_balance = 1.00 --min=0.0,max=2.0,default=1.00
-- #
ambient__use_directional_ambient_light = true --default=true
ambient__use_overcast_sky_ambient_light = true --default=true
-- #
ambient__AO_visibility = 1.00 --min=0.0,max=1.0,default=1.0

-----------------------------------------------------------------------------------
-- ▌   NIGHT   ▐   
-- #
-- seemless blend from night without additional effects to
-- maximum Sols's night effects.
night__effects_multiplier = 0.50 --min=0,max=1,default=0.50
-- #
-- adjust the ambient brightness from dusk till dawn
night__brightness_adjust = 0.35 --min=0,max=2,default=0.35
-- #
-- the brightness of the moonlight
night__moonlight_multiplier = 1.00 --min=0,max=10,default=1.00
-- #
-- the brightness of the stars
night__starlight_multiplier = 1.00 --min=0,max=10,default=1.00

--<br>

-- ▌   NIGHT LIGHT POLLUTION   ▐   
-- #
-- use light pollusion from the lighting ini
nlp__use_light_pollusion_from_track_ini = true --default=true
-- #
-- #
-- Default night light pollusion, when not used from track.
-- #
-- Radius in km
nlp__radius = 5 --min=0,max=20,default=5
-- #
-- Density
nlp__density = 0.50 --min=0,max=10,default=0.50
-- #
-- Color
nlp__color = {
	
Hue = 220, --min=0,max=360,default=220
Saturation = 0.25, --min=0,max=2,default=0.25
Level = 0.05, --min=0,max=1,default=0.05
}

--<br>

-- ▌   GRAPHICS   ▐   
-- #
gfx__reflections_brightness = 1.00 --min=0.0,max=10,default=1.00
gfx__reflections_saturation = 1.00 --min=0.0,max=10,default=1.00
-- #
-- #

-- ▌   SOUND   ▐
-- #
-- Sounds are dependent to the AC MASTER volume
-- # 
sound__wind_volume_interior = 0.20 --min=0,max=2,default=0.20
sound__wind_volume_exterior = 1.00 --min=0,max=2,default=1.00
sound__thunder_volume_interior = 1.00 --min=0,max=2,default=1.00
sound__thunder_volume_exterior = 1.00 --min=0,max=2,default=1.00
-- # 
sound__rain_volume_interior = 1.00 --min=0,max=2,default=1.00
sound__rain_volume_exterior = 1.00 --min=0,max=2,default=1.00


--<br>


-- ▌   DEBUG OPTIONS   ▐   
-- #
sol__debug__runtime = false --default=false
-- sun, moon...
sol__debug__solar_system = true --default=true
-- temperature, wind, ambient light... 
sol__debug__weather = false --default=false
-- dynamic weather plan 
sol__debug__weather_change = false --default=false
-- weather effects 
sol__debug__weather_effects = false --default=false
-- id, altitude
sol__debug__track = false --default=false
-- direction, altitude 
sol__debug__camera = false --default=false
-- headlights 
sol__debug__AI = false --default=false
-- shadows 
sol__debug__graphics = false --default=false
-- custom config 
sol__debug__custom_config = false --default=false
-- Auto exposure 
sol__debug__AE = false --default=false
-- external light pollution from track's lighting 
sol__debug__light_pollution = false --default=false

--<br>


























--   N E R D - O P T I O N S

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--!! 
--!! I will not give any support for this
--!! Change this to your own needs, if you like to play with the core values of Sol
--!!
--!! I put this in, because i also like to play, BUT NO SUPPORT from me for this....
--!!
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- ▌   NERD SKY   ▐   
-- #
nerd__sky_adjust = {
	
Hue = 1.00, --min=0,max=2,default=1.00
Saturation = 1.00, --min=0,max=2,default=1.00
Level = 1.00, --min=0,max=10,default=1.00

SunIntensityFactor = 1.00, --min=0,max=10,default=1.00

AnisotropicIntensity = 1.00, --min=0,max=10,default=1.00
Density = 1.00, --min=0,max=10,default=1.00

Scale = 1.00, --min=0,max=10,default=1.00
GradientStyle = 1.00, --min=0.2,max=5,default=1.00
InputYOffset = 0.00, --min=-2,max=2,default=0.00
}

--<br>

-- ▌   NERD SUN   ▐   
-- #
nerd__sun_adjust = {
	
-- light source
ls_Hue = 1.00, --min=0,max=2,default=1.00
ls_Saturation = 1.00, --min=0,max=10,default=1.00
ls_Level = 1.00, --min=0,max=10,default=1.00

-- appearance
ap_Level = 1.00, --min=0,max=10,default=1.00
}

-----------------------------------------------------------------------------------
-- NERD SPECULARS
-- #
nerd__speculars_adjust = {

Level = 1.00, --min=0,max=10,default=1.00
}

--<br>

-- ▌   NERD CLOUDS   ▐   
-- #
nerd__clouds_adjust = {
	
Saturation = 1.00, --min=0,max=10,default=1.00
Saturation_limit = 0.90, --min=0,max=2,default=0.90
Lit = 1.00, --min=0,max=10,default=1.00
Contour = 1.00, --min=0,max=10,default=1.00
}

--<br>

-- ▌   NERD AMBIENT   ▐   
-- #
nerd__ambient_adjust = {
	
Hue = 1.00, --min=0,max=2,default=1.00
Saturation = 1.00, --min=0,max=10,default=1.00
Level = 1.00, --min=0,max=10,default=1.00
}

-- #
nerd__directional_ambient_light = {

Level = 1.00, --min=0,max=10,default=1.00
}

nerd__overcast_sky_ambient_light = {

Level = 1.00, --min=0,max=10,default=1.00
}

--<br>

-- ▌   NERD FOG   ▐   
-- #
nerd__fog_use_custom_distant_fog = false --default=false

-- #
nerd__fog_custom_distant_fog = {

distance = 30000, --min=1000,max=50000,default=30000
blend = 0.85, --min=0,max=2,default=0.85
density = 1.75, --min=0,max=10,default=1.75
exponent = 0.75, --min=0,max=10,default=0.75
backlit = 0.05, --min=0,max=1,default=0.05
sky = 0.00, --min=-4,max=1,default=0.00
night = 0.00, --min=0,max=1,default=0.00
	
Hue = 220, --min=0,max=360,default=220.00
Saturation = 0.50, --min=0,max=10,default=0.5
Level = 2.50, --min=0,max=10,default=2.50
}


--<br>

-- ▌   NERD MOON   ▐   
-- #
nerd__moon_adjust = {
	
low_Hue = 32, --min=0,max=359,default=32
low_Saturation = 1.60, --min=0,max=10,default=1.60
low_Level = 3.60, --min=0,max=10,default=3.60

high_Hue = 210, --min=0,max=359,default=210
high_Saturation = 0.30, --min=0,max=10,default=0.30
high_Level = 2.00, --min=0,max=10,default=2.00

mie_Exponent = 15.00, --min=0,max=100,default=15.0
mie_Multi = 1.50, --min=0,max=10,default=1.50

ambient_ratio = 0.50 --min=0,max=10,default=0.50
}

-- ▌   NERD STARS   ▐   
-- #
nerd__stars_adjust = {
	
Saturation = 1.00, --min=0,max=10,default=1.00
Exponent = 1.00, --min=0,max=10,default=1.00
}

--<br>

-- ▌   NERD NIGHT SKY   ▐   
-- #
nerd__night_sky = {
	
Hue = 220, --min=0,max=360,default=220.00
Saturation = 0.50, --min=0,max=10,default=0.5
Level = 0.00, --min=0,max=1,default=0.00

Size = 0.50, --min=0,max=1,default=0.5
}

-- ▌   NERD CSP Lights   ▐   
-- #
nerd__csp_lights_adjust = {

bounced_day = 0.00, --min=0,max=10,default=0.00
bounced_night = 1.00, --min=0,max=10,default=1.00

emissive_day = 0.65, --min=0,max=10,default=0.65
emissive_night = 1.00, --min=0,max=10,default=1.00
}




-- performance presets
--[[

performancepresets = {
    sol__use_cpu_split = false --low=true, high=false, ultra=false
    clouds__distance_multiplier = 1.45, --low=1.0, high=1.60, ultra=1.75
    clouds__quality = 0.60  --low=0.4, high=0.80, ultra=1.00
    clouds__render_per_frame = 20  --low=15, high=25, ultra=35
}
nightpresets = {
    night__brightness_adjust = 0.35 --low=0.0, high=0.7, ultra=1.0
    night__moonlight_multiplier = 1.0 --low=1.0, high=2.0, ultra=4.0
    night__starlight_multiplier = 1.0 --low=0.5, high=2.0, ultra=4.0
}
firstpage = {
    sol__use_cpu_split,
    clouds__distance_multiplier,
    clouds__quality,
    clouds__render_per_frame,
}
]]

-- ▌     TRACK CONFIG options     ▐
--  \extension\config\tracks\loaded\ks_red_bull_ring.ini (layout_gp)
-- [LIGHTING] section
-- "BOUNCED_LIGHT_MULT" only as combined value here
--#
LIGHTING__LIT_MULT=1.00  --min=0.00,max=5.00,default=1.00
LIGHTING__SPECULAR_MULT=1  --min=0.00,max=5.00,default=1.00
LIGHTING__CAR_LIGHTS_LIT_MULT=1.00  --min=0.00,max=5.00,default=1.00
LIGHTING__TRACK_AMBIENT_GROUND_MULT=0.50  --min=0.50,max=2.00,default=0.50
LIGHTING__TERRAIN_SHADOWS_THRESHOLD=0.00  --min=0.00,max=5.00,default=0.00
