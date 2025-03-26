













local _l_horizon_offset = ta_horizon_offset--*from_twilight_compensate(0)

local _l_blue_height   = 1.25
local blue_sky_booster = SOL__config("sky", "blue_strength")

local sky_add_blue = ac.SkyExtraGradient()
sky_add_blue.color = rgb.new(0,0.5,0.8)
sky_add_blue.exponent  = 1.0
sky_add_blue.direction = vec3(0,-1,0)
sky_add_blue.sizeFull  = 1.3 * _l_blue_height
sky_add_blue.sizeStart = 1.0
sky_add_blue.isAdditive = true
sky_add_blue.isIncludedInCalculate = true

local sky_sub_blue = ac.SkyExtraGradient()
sky_sub_blue.color = rgb.new(0,0.5,0.8)
sky_sub_blue.exponent  = 1.0
sky_sub_blue.direction = vec3(0,-1,0)
sky_sub_blue.sizeFull  = 1.3 * _l_blue_height
sky_sub_blue.sizeStart = 1.0
sky_sub_blue.isAdditive = true
sky_sub_blue.isIncludedInCalculate = true

local sky_dark_blue = ac.SkyExtraGradient()
sky_dark_blue.color = rgb.new(0,0.5,0.8)
sky_dark_blue.exponent  = 0.5
sky_dark_blue.direction = vec3(0,-1,0)
sky_dark_blue.sizeFull  = 1.35 * _l_blue_height
sky_dark_blue.sizeStart = 0.9
sky_dark_blue.isAdditive = false
sky_dark_blue.isIncludedInCalculate = true

local sky_bright_blue = ac.SkyExtraGradient()
sky_bright_blue.color = rgb.new(0,0.5,0.8)
sky_bright_blue.exponent  = 1.5
sky_bright_blue.direction = vec3(0,-1,0)
sky_bright_blue.sizeFull  = 1.6 * _l_blue_height
sky_bright_blue.sizeStart = 0.5
sky_bright_blue.isAdditive = true
sky_bright_blue.isIncludedInCalculate = true

local sky_bright_hori = ac.SkyExtraGradient()
sky_bright_hori.color = rgb.new(1,1,1)
sky_bright_hori.exponent  = 1.5
sky_bright_hori.direction = vec3(0,1,0)
sky_bright_hori.sizeFull  = 1.5
sky_bright_hori.sizeStart = 0.6
sky_bright_hori.isAdditive = true
sky_bright_hori.isIncludedInCalculate = true

local sky_dark_hori = ac.SkyExtraGradient()
sky_dark_hori.color = rgb.new(1,1,1)
sky_dark_hori.exponent  = 1.5
sky_dark_hori.direction = vec3(0,1,0)
sky_dark_hori.sizeFull  = 1.5
sky_dark_hori.sizeStart = 0.6
sky_dark_hori.isAdditive = false
sky_dark_hori.isIncludedInCalculate = true

ac.addSkyExtraGradient(sky_add_blue)
ac.addSkyExtraGradient(sky_sub_blue)
ac.addSkyExtraGradient(sky_dark_blue)
ac.addSkyExtraGradient(sky_bright_blue)
ac.addSkyExtraGradient(sky_bright_hori)
ac.addSkyExtraGradient(sky_dark_hori)

local sky_overcast = ac.SkyExtraGradient()
sky_overcast.color = rgb.new(1,1,1) * 2
sky_overcast.exponent  = 1.5
sky_overcast.direction = vec3(0,-1,0)
sky_overcast.sizeFull  = 1.5
sky_overcast.sizeStart = 0.3
sky_overcast.isAdditive = false
sky_overcast.isIncludedInCalculate = true

local sky_overcast_low = ac.SkyExtraGradient()
sky_overcast_low.color = rgb.new(0,0,0)
sky_overcast_low.exponent  = 1.0
sky_overcast_low.direction = vec3(0,1,0)
sky_overcast_low.sizeFull  = 0.9
sky_overcast_low.sizeStart = 0.1
sky_overcast_low.isAdditive = false
sky_overcast_low.isIncludedInCalculate = true

ac.addSkyExtraGradient(sky_overcast)
ac.addSkyExtraGradient(sky_overcast_low)




local atmosphere_gradient = ac.SkyExtraGradient()
atmosphere_gradient.color = rgb(0,0,0)
atmosphere_gradient.exponent  = 1.25
atmosphere_gradient.direction = vec3(0,1,0)
atmosphere_gradient.sizeFull  = 1.00
atmosphere_gradient.sizeStart = 0.85
atmosphere_gradient.isAdditive = true
atmosphere_gradient.isIncludedInCalculate = true

ac.addSkyExtraGradient(atmosphere_gradient)


local night_sky_gradient = ac.SkyExtraGradient()
night_sky_gradient.color = rgb(1,0,1)
night_sky_gradient.exponent  = 1.25
night_sky_gradient.direction = vec3(0,-1,0)
night_sky_gradient.sizeFull  = 2.00
night_sky_gradient.sizeStart = 0.85
night_sky_gradient.isAdditive = true
night_sky_gradient.isIncludedInCalculate = true

if night_sky_gradient.color:getLuminance() > 0 then
	ac.addSkyExtraGradient(night_sky_gradient)
end


_l_basic_skyshader_sun_LUT = {
         -- RefrIndex, sunSideBright, turbidity, rayleigh, Depol, DirG, gamma, sat,  lumi,   sunint,
	{ -90,   0,        0.00,          0.0,        0.0,     0.50,  0.90, 1.00,  1.00, 0.00,    50,     },
	{ -20,   5,        0.00,          0.0,        0.0,     0.50,  0.90, 1.00,  1.00, 0.005,   50,     },
	{ -17,  10,        0.00,          1.0,        0.1,     0.50,  0.90, 1.50,  1.00, 0.01,   100,     },
	{ -14,  15,        0.00,          3.0,        0.8,     0.50,  0.80, 1.60,  1.00, 0.05,   200,     },
	{ -11,  20,        0.50,          5.0,        1.2,     0.50,  0.70, 1.50,  1.00, 0.20,   300,     },
	{  -9,  25,        1.00,         10.0,        0.8,     0.40,  0.60, 1.60,  0.90, 0.50,   400,     },
	{  -6,  27,        1.00,         12.0,        0.6,     0.30,  0.40, 1.70,  0.75, 0.75,   450,     },
	{  -3,  28,        1.00,         15.0,        0.8,     0.10,  0.30, 1.60,  0.50, 1.00,   500,     },
	{  -2,  29,        1.00,         14.0,        0.5,     0.10,  0.35, 1.50,  0.80, 0.98,   600,     },
	{  -1,  30,        1.00,         13.0,        0.5,     0.10,  0.40, 1.40,  0.95, 0.95,   700,     },
	{   0,  31,        1.00,         15.0,        0.6,     0.10,  0.45, 1.30,  1.00, 0.90,   770,     },
	{   1,  34,        1.00,         20.0,        0.7,     0.15,  0.42, 1.20,  1.00, 0.88,   750,     },
	{   2,  37,        1.00,         10.0,        0.6,     0.25,  0.40, 1.15,  1.01, 0.84,   700,     },
	{   3,  40,        1.00,          5.0,        0.5,     0.27,  0.45, 1.10,  1.02, 1.00,   650,     },
	{   6,  41,        1.00,          4.0,        0.4,     0.29,  0.75, 1.30,  1.04, 0.85,   480,     },
	{   9,  42,        1.00,          2.0,        0.3,     0.31,  0.55, 1.20,  1.06, 1.00,   360,     },
	{  11,  43,        1.00,          1.0,        0.2,     0.30,  0.40, 1.15,  1.08, 1.00,   280,     },
	{  14,  44,        1.00,          0.0,        0.1,     0.25,  0.30, 1.10,  1.10, 1.00,   250,     },
	{  17,  45,        1.00,          0.0,        0.0,     0.20,  0.20, 1.08,  1.10, 1.00,   250,     },
	{  20,  45,        1.00,          0.0,        0.1,     0.15,  0.10, 1.06,  1.10, 1.00,   250,     },
	{  30,  45,        1.00,          0.0,        0.3,     0.15,  0.00, 1.03,  1.10, 1.00,   250,     },
	{  50,  45,        1.00,          0.0,       -0.5,     0.15,  0.00, 1.00,  1.00, 1.00,   250,     },
	{  90,  45,        1.00,          0.0,       -0.5,     0.15,  0.00, 1.00,  1.00, 1.00,   250,     },
}
local _l_sun_base
local _l_sun_baseCPP = LUT:new(_l_basic_skyshader_sun_LUT)

_l_basic_skyshader_oppo_LUT = {
         -- RefrIndex, sunSideBright, turbidity, rayleigh, Depol, DirG, gamma, sat,  lumi,   sunint, 
	{ -90,   4,        0.50,          0.0,        0.00,    0.00,  0.00, 1.00,  1.00, 0.00,    10,    },
	{ -20,   5,        0.50,          0.0,        0.00,    0.00,  0.00, 1.00,  1.00, 0.05,    20,    },
	{ -17,   6,        0.50,          0.0,        0.00,    0.00,  0.00, 1.00,  1.00, 0.10,    50,    },
	{ -14,   7,        0.50,          0.0,        0.00,    0.00,  0.00, 1.00,  1.00, 0.15,   100,    },
	{ -11,   8,        0.50,          1.0,        1.00,    0.00,  0.00, 1.25,  1.00, 0.20,   300,    },
	{  -9,   9,        0.50,          2.0,        3.00,    0.00,  0.00, 1.50,  1.00, 0.25,   400,    },
	{  -6,  10,        0.50,          3.0,        7.00,    0.00,  0.00, 1.75,  1.25, 0.30,   400,    },
	{  -3,  12,        0.60,          4.0,        9.00,    0.00,  0.00, 2.50,  1.00, 1.00,   400,    },
	{  -2,  14,        0.70,          5.0,        8.00,    0.00,  0.00, 2.20,  0.50, 1.70,   450,    },
	{  -1,  16,        0.80,          6.0,        6.00,    0.05,  0.00, 1.90,  0.40, 2.50,   500,    },
	{   0,  20,        0.90,          7.0,        4.00,    0.10,  0.00, 1.60,  0.30, 3.00,   550,    },
	{   1,  25,        1.00,          8.0,        2.00,    0.15,  0.00, 1.58,  0.25, 1.70,   600,    },
	{   2,  30,        1.00,          9.0,        1.00,    0.20,  0.00, 1.56,  0.30, 1.40,   650,    },
	{   3,  35,        1.00,         10.0,        0.50,    0.25,  0.00, 1.54,  0.40, 1.15,   700,    },
	{   6,  41,        1.00,          8.0,        0.10,    0.30,  0.00, 1.53,  0.50, 1.00,   700,    },
	{   9,  42,        1.00,          6.0,       -0.00,    0.25,  0.00, 1.51,  1.00, 1.00,   700,    },
	{  11,  43,        1.00,          4.0,       -0.10,    0.20,  0.00, 1.50,  1.10, 1.00,   800,    },
	{  14,  44,        1.00,          2.0,       -0.20,    0.20,  0.00, 1.45,  1.20, 1.00,   770,    },
	{  17,  45,        1.00,          0.0,       -0.30,    0.20,  0.00, 1.40,  1.25, 1.00,   750,    },
	{  20,  45,        1.00,          0.0,       -0.50,    0.20,  0.00, 1.30,  1.10, 1.00,   700,    },
	{  30,  45,        1.00,          0.0,       -0.50,    0.20,  0.00, 1.20,  1.00, 1.00,   600,    },
	{  50,  45,        1.00,          0.0,       -0.50,    0.20,  0.00, 1.10,  0.90, 1.00,   450,    },
	{  90,  45,        1.00,          0.0,       -0.50,    0.20,  0.00, 1.00,  0.70, 1.00,   200,    },
}
local _l_oppo_base
local _l_oppo_baseCPP = LUT:new(_l_basic_skyshader_oppo_LUT)

n = 1
_l_basic_skyshader_sunbright_LUT = {
            -- sun-v     blue-boost  shader-dir  blue-dir   hori-glow-dir   sun-bloom
	{ -90,        0.0,   0.000,         0,       90,        90,             0.0003            },
	{ -20,        0.0,   0.000,         0,       87,        90,             0.0003            },
	{ -17,        0.0,   0.000,         0,       82,        90,             0.0003            },
	{ -14,        0.0,   0.005,         0,       79,        90,             0.0003            },
	{ -11,        0.0,   0.015,         0,       76,        93,             0.0003            },
	{  -9,        1.0,   0.025,        20,       75,        96,             0.0003            },
	{  -6,        2.0,   0.035,        30,       76,       100,             0.0003            },
	{  -3,        4.0,   0.040,        40,       77,       104,             0.0003            },
	{  -2,        8.0,   0.050,        15,       78,       107,             0.0003            },
	{  -1,       12.0,   0.070,         0,       79,       109,             0.0003            },
	{   0,       16.0,   0.100,         0,       80,       110,             0.0003            },
	{   1,        8.5,   0.120,        15,       81,       110,             0.0003            },
	{   2,        4.8,   0.150,        35,       82,       110,             0.0004            },
	{   3,        3.6,   0.200,        40,       83,       109,             0.0005            },
	{ 4.5,        4.2,   0.225,        42,       84,       108,             0.0006            },
	{   6,        4.7,   0.250,        45,       85,       107,             0.0012            },
	{   9,        2.9,   0.300,        60,       88,       103,             0.0020            },
	{  11,        2.1,   0.350,        70,       90,        99,             0.0050            },
	{  14,        1.4,   0.400,        73,       90,        95,             0.0100            },
	{  17,        1.2,   0.500,        75,       90,        94,             0.0150            },
	{  20,        1.1,   0.600,        75,       90,        93,             0.0200            },
	{  30,        1.0,   0.800,        75,       90,        92,             0.0200            },
	{  50,        1.0,   1.000,        75,       90,        91,             0.0200            },
	{  90,        1.0,   1.000,        75,       90,        90,             0.0200            },
}
local _l_sun_bright
local _l_sun_brightCPP = LUT:new(_l_basic_skyshader_sunbright_LUT)
_l_sun_brightCPP:setCurve(0.4)

-- a LUT to compensate the sky shaders behavior with sunangles between 1° and -9°
-- This will compensate the darkening of the horizont by using ac.setSkyV2YOffset()
_l_smog_ctr_LUT = {
	{ -90.00,   1.00   },
	{ -17.00,   1.00   },
	{ -14.00,   1.10   },
	{ -11.00,   1.50   },
	{  -9.00,   1.70   },
	{  -6.00,   3.40   },
	{  -5.50,   3.30   },
	{  -5.00,   3.05   },
	{  -4.50,   2.95   },
	{  -4.00,   2.65   },
	{  -3.50,   2.40   },
	{  -3.25,   2.20   },
	{  -3.00,   2.10   },
	{  -2.75,   1.85   },
	{  -2.50,   1.60   },
	{  -2.00,   1.40   },
	{  -1.75,   1.20   },
	{  -1.50,   1.10   },
	{  -1.25,   1.05   },
	{  -1.00,   0.90   },
	{  -0.80,   0.75   },
	{  -0.60,   0.60   },
	{  -0.40,   0.50   },
	{  -0.20,   0.40   },
	{   0.00,   0.30   },
	{   0.20,   0.20   },
	{   0.40,   0.10   },
	{   0.60,   0.00   },
	{  90.00,   0.00   },
}
local _l_smog_ctr
local _l_smog_ctrCPP = LUT:new(_l_smog_ctr_LUT)
_l_smog_ctrCPP:setCurve(1.5)

ac.setSkyUseV2(true)

local tonemapping_function = 2
local ppfilter_tmf = ppfilter__get_value("TONEMAPPING", "FUNCTION")
if ppfilter_tmf ~= nil then
	tonemapping_function = tonumber(ppfilter_tmf) 
end


local _l_sky_color_mod = {
    h = 0,
    s = 1,
    v = 1,
    scale = 1,
}
function sky__get__color_mod()
	return _l_sky_color_mod
end

blue_sky_atmosphere_color = rgb(0,0,0)
blue_sky_cloud_adaption = 1
blue_sky_cloud_opacity = 1
blue_sky_cloud_lev = 1
blue_sky_cloud_sat = 1
blue_sky_cloud_sat_limit = 1

-- a global table to make a custom sky preset in the Sol custom config
SOL__custom_sky_preset = {

	hue = 0,
	saturation = 1,
	level = 1,
	booster = 1,
	atmosphere_color = rgb(0,0,0),
	cloud_adaption = 1,
	cloud_opacity = 1,
	cloud_level = 1,
	cloud_saturation = 1,
	cloud_saturation_limit = 2
}

local _l_sky_dist_fog = {

	distance 	= 30000, -- the distance in meters
	blend 		= 0.85, -- at the full distance, the fog is mixed by this value
	density 	= 1.75, -- a multiplier for the mixing
	exponent 	= 0.75, -- lower values will make the near fog denser
	backlit 	= 0.05, -- fog is litten from behind by the sun
	sky 		= 0.0, -- maximum pollution of the sky by this particular fog
	night 		= 0.0, -- an offset to be more visible in the night
	color 		= hsv(220, 0.5, 2.5):toRgb() -- the fog's color, HSV model
}

function update_sky_preset()

	local _l_config__sky__blue_preset = SOL__config("sky", "blue_preset")
	local _l_config__sky__blue_strength = SOL__config("sky", "blue_strength")

    if _l_config__sky__blue_preset == 0 then
    -- flat
        blue_sky_booster = 0
		
		_l_sky_color_mod.v = night_compensate(0.9)

		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.8*sun_compensate(0), __IntD(-0.2, 1.0, 0.7)):toRgb()*day_compensate(0)
		
    elseif _l_config__sky__blue_preset == 1 then
    -- moderate
		blue_sky_booster = 0.10 + 0.50 * _l_config__sky__blue_strength
		
		_l_sky_color_mod.v = night_compensate(0.95)

		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.7*sun_compensate(0), __IntD(-0.2, 1.5, 0.7)):toRgb()*day_compensate(0)
		
        _l_sky_dist_fog = {

			distance 	= 30000,
			blend 		= 0.95,
			density 	= 1.95,
			exponent 	= 1.50,
			backlit 	= 0.05,
			sky 		= 0,
			night 		= 0.0,
			color 		= hsv(220,
							  0.5,
						      1.5+0.50*from_twilight_compensate(0)):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 2 then
    -- nice blue
        blue_sky_booster = _l_config__sky__blue_strength

        _l_sky_color_mod.h = 0.50 * sun_compensate(0)
        _l_sky_color_mod.s = night_compensate(1.05)
		_l_sky_color_mod.v = night_compensate(1.10)

		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.2*sun_compensate(0), __IntD(-0.2, 1.0, 0.5)):toRgb()*day_compensate(0)
		
		blue_sky_cloud_lev = night_compensate(0.9)

        _l_sky_dist_fog = {

			distance 	= 25000,
			blend 		= 0.95,
			density 	= 1.95,
			exponent 	= 0.80+1.20*from_twilight_compensate(0),
			backlit 	= 0.05,
			sky 		= -1.0*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(220,
							  0.5+0.05*from_twilight_compensate(0),
						      1.5+1.0*from_twilight_compensate(0)):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 3 then
    -- dark blue
        blue_sky_booster = 0.3 * _l_config__sky__blue_strength

		_l_sky_color_mod.h = 0.50 * sun_compensate(0)
        _l_sky_color_mod.s = 1+0.1*sun_compensate(0)+0.05*from_twilight_compensate(0)
		_l_sky_color_mod.v = 1.0-0.15*sun_compensate(0)
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.5*sun_compensate(0), __IntD(-0.2, 1.50, 0.5)):toRgb()*day_compensate(0)

		blue_sky_cloud_lev 		= night_compensate(0.975)
		blue_sky_cloud_adaption = 1 - 0.5 * sun_compensate(0)

        _l_sky_dist_fog = {

			distance 	= 25000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75,
			exponent 	= 0.80+0.50*from_twilight_compensate(0),
			backlit 	= 0.05,
			sky 		= -0.2*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(220,
							  0.5+0.05*from_twilight_compensate(0),
						      1.5+0.5*from_twilight_compensate(0)):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 4 then
    -- ACC
        blue_sky_booster = 0.40 * _l_config__sky__blue_strength

        _l_sky_color_mod.h = -0.25 * day_compensate(0)
        _l_sky_color_mod.s = 1 - 0.05 * sun_compensate(0)
		_l_sky_color_mod.v = 1+0.1*sun_compensate(0)
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.7*sun_compensate(0), __IntD(-0.2, 1.5, 0.5)):toRgb()*day_compensate(0)

        _l_sky_dist_fog = {

			distance 	= 30000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75+0.25*from_twilight_compensate(0),
			exponent 	= 0.80+1.20*from_twilight_compensate(0),
			backlit 	= 0.05,
			sky 		= -0.5*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(220,
							  0.5,
						      1.5):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 5 then
    -- TruckSim
        blue_sky_booster = 0.25 * _l_config__sky__blue_strength

        _l_sky_color_mod.s = 1 + 0.25 * sun_compensate(0)
        _l_sky_color_mod.v = 1 - 0.15 * from_twilight_compensate(0)

        blue_sky_cloud_adaption 	= 1 + 0.35 * sun_compensate(0)
        blue_sky_cloud_sat 			= 1 + 0.75 * sun_compensate(0)
		blue_sky_cloud_sat_limit 	= 1 + 0.5 * sun_compensate(0)
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.5*sun_compensate(0), __IntD(-0.2, 2.5, 0.5)):toRgb()*day_compensate(0)

        blue_sky_cloud_lev = night_compensate(0.95)

         _l_sky_dist_fog = {

			distance 	= 30000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75+0.25*from_twilight_compensate(0),
			exponent 	= 0.80+0.70*from_twilight_compensate(0),
			backlit 	= 0.05,
			sky 		= -1.00*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(210,
							  0.63,
						      1.5+0.2*from_twilight_compensate(0)):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 6 then
    -- deep blue
        blue_sky_booster = 1.00 * _l_config__sky__blue_strength

        _l_sky_color_mod.h = 0.25 * day_compensate(0)
        _l_sky_color_mod.s = 1 + 0.15 * from_twilight_compensate(0)
		_l_sky_color_mod.v = 1
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.8*sun_compensate(0), __IntD(-0.2, 1.0, 0.5)):toRgb()*day_compensate(0)

        blue_sky_cloud_adaption 	= 1 + 0.00 * sun_compensate(0)
        blue_sky_cloud_sat 			= 1 + 0.25 * sun_compensate(0)
        blue_sky_cloud_sat_limit 	= 1 + 0.25 * sun_compensate(0)
        blue_sky_cloud_opacity		= 1 - 0.05 * sun_compensate(0)

        blue_sky_cloud_lev = 1

        _l_sky_color_mod.scale = 1+0.25*from_twilight_compensate(0)

        _l_sky_dist_fog = {

			distance 	= 30000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75+0.50*from_twilight_compensate(0),
			exponent 	= 0.80+1.00*from_twilight_compensate(0),
			backlit 	= 0.05,
			sky 		= -1.00*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(220,
							  0.5+0.05*from_twilight_compensate(0),
						      1.5+1.0*from_twilight_compensate(0)):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

	elseif _l_config__sky__blue_preset == 7 then
	-- flight sim
        blue_sky_booster = (0.25+0.75*(1-sun_compensate(0)*from_twilight_compensate(0)))*_l_config__sky__blue_strength

        _l_sky_color_mod.h = 0
        _l_sky_color_mod.s = night_compensate(0.99)
		_l_sky_color_mod.v = night_compensate(0.95)
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 1.0-0.2*sun_compensate(0), __IntD(-0.2, 2.0, 0.6)):toRgb()*day_compensate(0)

        _l_sky_color_mod.scale = 1+1.5*from_twilight_compensate(0)

        blue_sky_cloud_lev = 1

        local fog_day = from_twilight_compensate(0) * sun_compensate(0.75)

        _l_sky_dist_fog = {

			distance 	= 35000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75+0.35*from_twilight_compensate(0),
			exponent 	= 0.80+1.30*from_twilight_compensate(0),
			backlit 	= 0.05+0.10*from_twilight_compensate(0),
			sky 		= -0.5*from_twilight_compensate(0),
			night 		= 0.0,
			color 		= hsv(210+10*fog_day,
							  0.5+0.025*sun_compensate(0),
						      1.5+5.0*fog_day):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    elseif _l_config__sky__blue_preset == 8 then
    -- custom sky preset

    	_l_sky_color_mod.h 			= SOL__custom_sky_preset.hue 
		_l_sky_color_mod.s 			= SOL__custom_sky_preset.saturation 
		_l_sky_color_mod.v 			= SOL__custom_sky_preset.level 

		blue_sky_atmosphere_color:set(SOL__custom_sky_preset.atmosphere_color)
		
    	blue_sky_booster 			= SOL__custom_sky_preset.booster

    	blue_sky_cloud_adaption 	= SOL__custom_sky_preset.cloud_adaption 
    	blue_sky_cloud_opacity		= SOL__custom_sky_preset.cloud_opacity 
		blue_sky_cloud_lev 			= SOL__custom_sky_preset.cloud_level 
		blue_sky_cloud_sat 		 	= SOL__custom_sky_preset.cloud_saturation 
		blue_sky_cloud_sat_limit 	= SOL__custom_sky_preset.cloud_saturation_limit

	elseif _l_config__sky__blue_preset == 9 then
    -- PPoff
        blue_sky_booster = 0.75 * _l_config__sky__blue_strength

        _l_sky_color_mod.h = 0
        _l_sky_color_mod.s = 1.35
		_l_sky_color_mod.v = night_compensate(0.65)
		
		blue_sky_atmosphere_color = hsv(30+15*sun_compensate(0), 0.9-0.2*sun_compensate(0), __IntD(-0.2, 1.5, 0.6)):toRgb()*day_compensate(0)


        blue_sky_cloud_adaption 	= 1
        blue_sky_cloud_sat 			= 1
        blue_sky_cloud_sat_limit 	= 1
        blue_sky_cloud_opacity		= 1

        blue_sky_cloud_lev = night_compensate(1.00)

        _l_sky_dist_fog = {

			distance 	= 35000,
			blend 		= 0.95+0.05*from_twilight_compensate(0),
			density 	= 1.75,
			exponent 	= 0.80,
			backlit 	= 0.05,
			sky 		= 0,
			night 		= 0.0,
			color 		= hsv(220,
							  0.5,
						      1.0):toRgb()
		}
		if not SOL__config("nerd__fog_custom_distant_fog", "use") then gfx__set_custom_distant_fog(_l_sky_dist_fog) end

    end
end


function update_skysim_dome()

	local day = __IntD(0,1,0.7)

	local reflections_multi = SOL__config("nerd__sky_adjust", "GradientStyle")

	local smog = math.pow((__smog or 0), 2.0)*1.5 + 1.5*math.max(0, (SOL__config("sky", "smog") or 0)-1)

	local _l_humid = gfx__get_humidity()
	local _l_dist_fog_multi = 2.0*math.min(1, math.max(0, 1-gfx__get_fog_dense(15000)))

	smog = math.max(smog, _l_humid*0.8*from_twilight_compensate(0))
	smog = math.max(smog, __inair_material.dense*2.5*from_twilight_compensate(0))

	local _l_overcast_damp = math.max(0, 1-1.3*__overcast)
	local _l_overcast_sky_level = (1.0-(-1.25*__overcast+0.08*math.pow(__overcast*2.5, 3)+0.25*sun_compensate(1.6)*__badness)) * day_compensate(0.25)
	_l_overcast_sky_level = math.lerp(1, _l_overcast_sky_level, __overcast)
	local _l_overcast_amount = __overcast
	local l__ta_exp_fix 	 = night_compensate(ta_exp_fix)
	if nopp__use_sol_without_postprocessing == true then
		l__ta_exp_fix = 1
	end

	local scale = sun_compensate(1.5) * day_compensate(1.5) * _l_sky_color_mod.scale

	local ppoffgamma = 1
	local ppoff_skyHue = 1
	local ppoff_skySat = 1
	local ppoff_skyLev = 1
	if nopp__use_sol_without_postprocessing then

		local _l_config__ppoff_brightness = SOL__config("ppoff", "brightness")

		ppoffgamma = 1+2*sun_compensate(0)

		ppoff_skyHue = ppoff_skyHue * 0.99
        ppoff_skySat = ppoff_skySat / math.max(0.1, 1-(0.1*(1-_l_config__ppoff_brightness)))
        ppoff_skyLev = ppoff_skyLev * 0.68 * (1-(0.2*(1-_l_config__ppoff_brightness)))
	end

	local _l_config__sun__sky_bloom = SOL__config("sun", "sky_bloom") * (1-math.pow(_l_overcast_amount, 1.5))


	_l_sun_base     = _l_sun_baseCPP:get() --interpolate__plan(_l_basic_skyshader_sun_LUT)
	_l_oppo_base    = _l_oppo_baseCPP:get() --interpolate__plan(_l_basic_skyshader_oppo_LUT)
	_l_sun_bright   = _l_sun_brightCPP:get() --interpolate__plan(_l_basic_skyshader_sunbright_LUT, nil, nil, 0.4)
	_l_smog_ctr     = _l_smog_ctrCPP:get() --interpolate__plan(_l_smog_ctr_LUT, nil, nil, 1.5)

    -- update all sky preset variables
    update_sky_preset()


    local vec_blue = sphere2vec3(__sun_heading, _l_sun_bright[4])
    vec_blue = vec_blue *-1
    sky_add_blue.direction = vec_blue
    sky_sub_blue.direction = vec_blue
    sky_dark_blue.direction = vec_blue
    sky_bright_blue.direction = vec_blue


	local _l_blue_booster = blue_sky_booster *
							(1-math.pow(_l_humid, 0.5)) *
							_l_sun_bright[2] *
							_l_overcast_damp *
							SOL__config("nerd__sky_adjust", "Saturation") *
							ppoff_skySat

	local blue_hue_shift = 5*(1-sun_compensate(0))*math.max(0,1-blue_sky_booster*0.5)							
	local _l_blue_sat = math.max(0, 1.0 - 1.25*smog - 0.2*_l_humid)
	
	sky_add_blue.color     = hsv(190+blue_hue_shift,2.0 * _l_blue_sat, 1.00):toRgb() -- overall sat
	sky_sub_blue.color     = hsv( 40+blue_hue_shift,(1.0+2*_l_humid) * _l_blue_sat,-2.00):toRgb() -- blue top sat > lower 0 
	sky_dark_blue.color    = hsv(190+blue_hue_shift,0.5 * _l_blue_sat, 0.15 - 2.5*_l_humid):toRgb() -- top darkening
	sky_bright_blue.color  = hsv(210+blue_hue_shift,2.0 * _l_blue_sat, 0.60):toRgb() -- top enlighter


	local _l_blue_mix = 1-_l_blue_booster
	sky_add_blue.color    = math.lerp(sky_add_blue.color,    rgb(0,0,0), math.max(_l_blue_mix, math.min(1, smog) ))
	sky_sub_blue.color    = math.lerp(sky_sub_blue.color,    rgb(0,0,0), math.max(_l_blue_mix, math.min(1, smog) ))
	sky_dark_blue.color   = math.lerp(sky_dark_blue.color,   rgb(1,1,1), math.max(_l_blue_mix, math.min(1, smog) ))
	sky_bright_blue.color = math.lerp(sky_bright_blue.color, rgb(0,0,0), math.max(_l_blue_mix, math.min(1, smog) ))



	--########## Overcast #############
	
	local _l_overcast_blue = math.lerp(_l_overcast_amount, math.max(0, math.min(1, (-0.60+_l_overcast_amount)*2.5)), sun_compensate(0))
	local _l_dist_color = _l_sky_dist_fog.color:toHsv()
	local _l_white = rgb(1,1,1)
	
	sky_overcast.color = hsv(_l_dist_color.h, _l_dist_color.s*0.35*_l_overcast_blue, 1):toRgb()
	sky_overcast.color = math.lerp( rgb(0.8,1.0,1.2):adjustSaturation(day_compensate(0))*5, sky_overcast.color, sun_compensate(0))
	
	sky_overcast.color = math.lerp(_l_white, sky_overcast.color, _l_overcast_amount)
	sky_overcast.color:sub(rgb(0.60,0.595,0.605)*__badness)
	sky_overcast.color:scale(from_twilight_compensate(1-_l_overcast_amount))

	sky_overcast.sizeFull  = 1.5-0.25*__badness

	-- if tonemapping does not wash out horizon, do a little bit of overcast to it
	if tonemapping_function ~= 2 then
		_l_overcast_amount = math.max(0.1, _l_overcast_amount)
	end

	sky_overcast_low.color = math.lerp( _l_white-rgb(0.85,0.80,0.7)*__badness,
										hsv(_l_dist_color.h-5, _l_dist_color.s*0.25*_l_overcast_blue, 2.5-_l_overcast_amount-0.4*_l_overcast_blue):toRgb(),
										_l_overcast_amount)
	sky_overcast_low.color = math.lerp( rgb(0.8,0.9,1.0):adjustSaturation(night_compensate( from_twilight_compensate(2) ))*2, sky_overcast_low.color, sun_compensate(0))
	sky_overcast_low.color = math.lerp(_l_white, sky_overcast_low.color, _l_overcast_amount)
	sky_overcast_low.color = math.lerp(from_twilight_compensate(0) * 2 * _l_white, sky_overcast_low.color, from_twilight_compensate(1-_l_overcast_amount))

	if tonemapping_function ~= 2 then
		sky_overcast_low.color = sky_overcast_low.color * (1.2 - 0.2*_l_overcast_amount)
	end
	

	--sky_overcast_low.color = hsv(_l_dist_color.h, _l_dist_color.s*(1.0-0.8*from_twilight_compensate(0)), 1.25-0.25*sun_compensate(0)):toRgb()

	blue_sky_atmosphere_color = math.lerp(blue_sky_atmosphere_color, rgb(-0.01,0.00,0.02), __badness*(1-sun_compensate(0))) * (1-0.75*__overcast)
	

	--########## Atmosphere ###########
	atmosphere_gradient.color:set( blue_sky_atmosphere_color
								 * (1-0.8 * _l_overcast_amount * from_twilight_compensate(0))
								 * from_twilight_compensate(0)
								 * SOL__config("nerd__sky_adjust", "Level") * _l_sky_color_mod.v * ppoff_skyLev
								 * _l_dist_fog_multi
								/ math.pow(ppoffgamma, 0.5)
								)



	--########## Night Sky ###########

	local night_sky_color = hsv.new(SOL__config("nerd__night_sky", "Hue"), 
						  			SOL__config("nerd__night_sky", "Saturation"), 
									SOL__config("nerd__night_sky", "Level") * math.max(0, 1-1.35*__overcast)):toRgb()
									  
	night_sky_color = math.lerp( rgb(0,0,0), night_sky_color, night_compensate(0))

	night_sky_gradient.color = night_sky_color
	night_sky_gradient.sizeFull  = 10 - 9*math.pow(SOL__config("nerd__night_sky", "Size"), 0.1)



	-- sunsided brightening of the horizont
	local _l_config__day__horizon_glow = SOL__config("sky", "day__horizon_glow")
	local _l_config__night__horizon_glow = SOL__config("sky", "night__horizon_glow")

	local _l_hori_bright = math.max(0, 1-smog)
						 * math.lerp( (0.1 + (0.2 + (night_compensate(0)*0.02))*__night__brightness_adjust)*_l_config__night__horizon_glow*2.5,
									  _l_config__day__horizon_glow*3*sun_compensate(0.1),
									  from_twilight_compensate(0))
						 * (1 - 0.75*_l_overcast_amount)
	
	sky_bright_hori.sizeFull  = 2.0 + (0.05 * math.pow(_l_hori_bright, 0.90))
    sky_bright_hori.color = math.lerp(hsv(__sun_color.h,__sun_color.s*(5-4.9*_l_overcast_amount)/math.pow(1.065,_l_config__day__horizon_glow),__sun_color.v*0.1):toRgb(),
									  rgb(1,1.4,2),
									  night_compensate(0)) * _l_hori_bright
	local vec_hori_glow = sphere2vec3(__sun_heading, _l_sun_bright[5])
	sky_bright_hori.direction = vec_hori_glow


	-- sun opposite darken of the horizont with twilight
	sky_dark_hori.color = rgb(1,1,1) * from_twilight_compensate(1 - 0.5*_l_overcast_amount)
	local vec_hori_glow = sphere2vec3(__sun_heading, 80)
	sky_dark_hori.direction = vec_hori_glow



	ac.setSkyV2RefractiveIndex(ac.SkyRegion.Sun,      1.00000 + (-0.0003 + 0.0003*SOL__config("nerd__sky_adjust", "AnisotropicIntensity")) + 0.0002*__fog_dense + 0.0001*__humidity + 0.00001*_l_sun_base[1]) -- main value / gradient --higher > less saturated horizont
	ac.setSkyV2RefractiveIndex(ac.SkyRegion.Opposite, 1.00000 + (-0.0003 + 0.0003*SOL__config("nerd__sky_adjust", "AnisotropicIntensity")) + 0.0002*__fog_dense + 0.00001*_l_oppo_base[1])

 	ac.setSkyV2MieKCoefficient(ac.SkyRegion.Sun,      vec3(0.686, 0.678, 0.666)*_l_sun_base[2]) -->use for sun side brightness
 	ac.setSkyV2MieKCoefficient(ac.SkyRegion.Opposite, vec3(0.686, 0.678, 0.666)*_l_oppo_base[2])


 	--height
    ac.setSkyV2NumMolecules(ac.SkyRegion.Sun,      2.542e25 * (2.5 - 1.0*math.pow(smog, 0.5))  ) --colorful horizont/blueness day
    ac.setSkyV2NumMolecules(ac.SkyRegion.Opposite, 2.542e25 * (2.5 - 1.0*math.pow(smog, 0.5))  )

    ac.setSkyV2MieCoefficient(ac.SkyRegion.Sun, (-_l_sun_bright[6]+_l_sun_bright[6]*_l_config__sun__sky_bloom) + (0.001-0.0005*smog) ) --> sun bloom
    ac.setSkyV2MieCoefficient(ac.SkyRegion.Opposite, 0.005)

    --ac.setSkyV2MieCoefficient(ac.SkyRegion.All, -0.04)


	-- Varying with presets:
	local _l_turp = 1.0 + (-20.0 + 20.0*SOL__config("nerd__sky_adjust", "Density")) + 5*math.pow(math.min(0.5, smog), 5) + 30.0*_l_smog_ctr[1]*smog
	local _l_turb_sun = math.lerp(0, _l_turp + _l_sun_base[3], from_twilight_compensate(1-_l_overcast_amount))
	local _l_turb_opp = math.lerp(0, _l_turp + _l_oppo_base[3], from_twilight_compensate(1-_l_overcast_amount))

	ac.setSkyV2Turbidity(ac.SkyRegion.Sun, _l_turb_sun)
	ac.setSkyV2Turbidity(ac.SkyRegion.Opposite, _l_turb_opp)
    
	local _l_ray = 1.25 + math.max(0.5*smog,  night_compensate(sun_compensate(_l_config__day__horizon_glow)-1)) 
	local _l_ray_sun = math.lerp(0.0, _l_ray + _l_sun_base[4],  sun_compensate(1-_l_overcast_amount))
	local _l_ray_opp = math.lerp(0.0, _l_ray + _l_oppo_base[4], sun_compensate(1-_l_overcast_amount))

	ac.setSkyV2Rayleigh(ac.SkyRegion.Sun, _l_ray_sun)
	ac.setSkyV2Rayleigh(ac.SkyRegion.Opposite, _l_ray_opp)

    
    ac.setSkyV2DepolarizationFactor(ac.SkyRegion.Sun,      _l_sun_base[5]+0.1*smog) --washed out hori height
    ac.setSkyV2DepolarizationFactor(ac.SkyRegion.Opposite, _l_oppo_base[5]+0.1*smog)

    ac.setSkyV2MieDirectionalG(ac.SkyRegion.All,      _l_sun_base[6])
    --ac.setSkyV2MieDirectionalG(ac.SkyRegion.Opposite, _l_oppo_base[6])


    ac.setSkyV2MieV(ac.SkyRegion.Sun, math.lerp(4.00, 3.936, sun_compensate(0)) + 0.1*smog)
    ac.setSkyV2MieV(ac.SkyRegion.Opposite, 3.936)
    
    ac.setSkyV2YOffset(ac.SkyRegion.Sun, SOL__config("nerd__sky_adjust", "InputYOffset") + 0.00*_l_horizon_offset + 0.02*_l_smog_ctr[1]*smog)
    ac.setSkyV2YOffset(ac.SkyRegion.Opposite, SOL__config("nerd__sky_adjust", "InputYOffset"))
    ac.setSkyV2YScale(ac.SkyRegion.All, scale*SOL__config("nerd__sky_adjust", "Scale"))

    --ac.debug("####", smog)


    local blue_hue = 0.0 + SOL__config("nerd__sky_adjust", "Hue") * ppoff_skyHue + _l_sky_color_mod.h--min=0, def=1, max=2
    local blue_sat = 0.0 + SOL__config("nerd__sky_adjust", "Saturation") * ppoff_skySat--min=0, def=1, max=1.6
    local blue_lev = 0.0 + SOL__config("nerd__sky_adjust", "Level") * ppoff_skyLev --min=0, def=1, max=2

    blue_sat = blue_sat * math.max(0, (1 - 1.2*_l_overcast_amount)) * math.pow(reflections_multi, 0.07*from_twilight_compensate(0))							
    blue_hue = blue_hue + (blue_sat-1)*0.4


	--color control
    ac.setSkyV2Gamma(ac.SkyRegion.Sun,      ppoffgamma*(math.lerp(_l_sun_base[7],  5, _l_overcast_amount) + math.min(1.0, smog) + 0.5*blue_sat + 1.30*math.max(0, blue_lev-1)))--horizont smog / altitude(less)
    ac.setSkyV2Gamma(ac.SkyRegion.Opposite, ppoffgamma*(math.lerp(_l_oppo_base[7], 5, _l_overcast_amount) + math.min(1.0, smog) + 0.5*blue_sat + 1.30*math.max(0, blue_lev-1)))
    

    ac.setSkyV2Saturation(ac.SkyRegion.Sun,       math.max(0, _l_sun_base[8]  - 0.20*smog) * _l_sky_color_mod.s * (1 - 0.8*_l_overcast_amount))
    ac.setSkyV2Saturation(ac.SkyRegion.Opposite,  math.max(0, _l_oppo_base[8] - 0.07*smog) * _l_sky_color_mod.s * (1 - 0.8*_l_overcast_amount))

    local sky_bright = 1.075
	sky_bright = sky_bright * interpolate__value(0.9, 1.0,  __CM__altitude, 0, 1000, 300)
	sky_bright = sky_bright * interpolate_day_time(1.09,1.0,0.95) 
	sky_bright = math.min(5, sky_bright) * SOL__config("nerd__sky_adjust", "Level") * ppoff_skyLev
	sky_bright = math.lerp(0.2, sky_bright, __solar_eclipse)
	sky_bright = sky_bright * _l_overcast_sky_level
	--ac.debug("###", sky_bright)
	sky_bright = math.max(0, 1+2.5*(sky_bright-1))
	sky_bright = sky_bright * blue_lev * _l_sky_color_mod.v
	sky_bright = sky_bright * __PPoff__brightness__regulation 

    ac.setSkyV2Luminance(ac.SkyRegion.Sun,       sky_bright*(math.lerp(_l_sun_base[9],  (2-1.0*__badness)*sun_compensate(0.1)*from_twilight_compensate(0), _l_overcast_amount)*0.1 - 0.05*math.max(0, blue_sat-1)) * blue_lev * _l_sky_color_mod.v )
    ac.setSkyV2Luminance(ac.SkyRegion.Opposite,  sky_bright*(math.lerp(_l_oppo_base[9], (2-1.0*__badness)*sun_compensate(0.1)*from_twilight_compensate(0), _l_overcast_amount)*0.1 - 0.05*math.max(0, blue_sat-1)) * blue_lev * _l_sky_color_mod.v )


    --ac.setSkyV2Primaries(vec3(6.8e-7, 5.5e-7, 4.5e-7)*1)
    local sky_color_sun = hsv(20-15*night_compensate(0)+10*blue_hue, 0.05 + 0.30*blue_sat, 1.0 + 0.25*blue_sat)
    sky_color_sun = sky_color_sun:toRgb() * 0.00000065 * (1-0.5*_l_overcast_amount) 
    ac.setSkyV2Primaries(ac.SkyRegion.Sun,      vec3(sky_color_sun.r, sky_color_sun.g, sky_color_sun.b))

    local sky_color_oppo = hsv(10+5*sun_compensate(0)+10*blue_hue, 0.00 + 0.40*blue_sat, 1.1 + 0.25*blue_sat)
    sky_color_oppo = sky_color_oppo:toRgb() * 0.00000065 * (1-(0.5-0.25*(1-sun_compensate(0)))*_l_overcast_amount)
	ac.setSkyV2Primaries(ac.SkyRegion.Opposite, vec3(sky_color_oppo.r, sky_color_oppo.g, sky_color_oppo.b))
	

    ac.setSkyV2RayleighZenithLength(ac.SkyRegion.Sun,      8400+2000*_l_config__sun__sky_bloom)
    ac.setSkyV2RayleighZenithLength(ac.SkyRegion.Opposite, 8400)

    ac.setSkyV2MieZenithLength(ac.SkyRegion.Sun,      34000 + (50000*math.max(0, blue_sat-1)))
    ac.setSkyV2MieZenithLength(ac.SkyRegion.Opposite, 30000 + (50000*math.max(0, blue_sat-1)))

	local hdr_multi = 0.5*(weather__get_hdr_multiplier() - 1)*from_twilight_compensate(0)
	local _l_intensity_base = 1
							* _l_overcast_sky_level
							* reflections_multi
							* 3
							* math.lerp(SOL__config("nerd__sky_adjust", "SunIntensityFactor"), 1, 0.5*_l_overcast_amount)
							* (1+hdr_multi)
    ac.setSkyV2SunIntensityFactor(ac.SkyRegion.Sun,      math.lerp(_l_sun_base[10],  300*sun_compensate(0.1)*day_compensate(0), _l_overcast_amount)
    												   * (1-0.08*smog)
													   * _l_intensity_base
													)
    ac.setSkyV2SunIntensityFactor(ac.SkyRegion.Opposite, math.lerp(_l_oppo_base[10], 300*sun_compensate(0.1)*day_compensate(0), _l_overcast_amount)
    													 * (1-0.24*smog)
														 
														 * _l_intensity_base
														)

    ac.setSkyV2SunIntensityFalloffSteepness(ac.SkyRegion.Sun,      1.25)
    ac.setSkyV2SunIntensityFalloffSteepness(ac.SkyRegion.Opposite, 1.25)

    
    ac.setSkyV2BackgroundLight(ac.SkyRegion.Sun,      0.0)
    ac.setSkyV2BackgroundLight(ac.SkyRegion.Opposite, 0.0)

    ac.setSkyBrightnessMult(math.pow(1/reflections_multi, 0.85))
    ac.setOverallSkyBrightnessMult(1)

    --sun brightness multi
    ac.setSkyV2SunShapeMult(ac.SkyRegion.All, math.max(0, _l_sun_bright[1] * SOL__config("nerd__sun_adjust", "ap_Level") * _l_overcast_damp / scale * (1-0.5*smog)))
    

    


    --sky shader gradient position
    local vec_sky = sphere2vec3(__sun_heading, _l_sun_bright[3])
    ac.setSkyV2GradientDirection(vec_sky)



    ac.setSkyV2Rainbow(0)
    --ac.setSkyV2RainbowSecondary(0.5)
    --ac.setSkyV2RainbowDarkening(0)


    -- generate just a simple color for some other old functions
    __sky_color = hsv(220,0.7,math.max(0.0, _l_sun_base[9]))




--[[

    ac.setSkyV2RefractiveIndex(ac.SkyRegion.All,      1.00028) -- main value / gradient --higher > less saturated horizont


 	ac.setSkyV2MieKCoefficient(ac.SkyRegion.All,      vec3(0.686, 0.678, 0.666)) -->use for sun side brightness



 	--height
    ac.setSkyV2NumMolecules(ac.SkyRegion.All,      2.542e+25  ) --colorful horizont/blueness day


    ac.setSkyV2MieCoefficient(ac.SkyRegion.All, 0.003) --> sun bloom


    -- Varying with presets:
    ac.setSkyV2Turbidity(ac.SkyRegion.All,     10) --sun mie stenght


    ac.setSkyV2Rayleigh(ac.SkyRegion.All,      1.2) -- light in the dome / clearness
    
    
    ac.setSkyV2DepolarizationFactor(ac.SkyRegion.All,      0.175) --washed out hori height


    ac.setSkyV2MieDirectionalG(ac.SkyRegion.All, 0.55)



    blue_hue = 1.0 --min=0, def=1, max=2
    blue_sat = 1.0 --min=0, def=1, max=1.6
    blue_lev = 1.0 --min=0, def=1, max=2

    blue_sat = blue_sat * _l_overcast_damp

    blue_hue = blue_hue + (blue_sat-1)*0.4

    local sky_color_oppo = hsv(15+10*blue_hue, 0.05 + 0.40*blue_sat, 1.1 + 0.25*blue_sat)
    sky_color_oppo = sky_color_oppo:toRgb() * 0.00000065
    ac.setSkyV2Primaries(ac.SkyRegion.All, vec3(sky_color_oppo.r, sky_color_oppo.g, sky_color_oppo.b))
    --ac.setSkyV2Primaries(ac.SkyRegion.All, vec3(6.8e-7, 5.5e-7, 4.5e-7))

    --color control
    ac.setSkyV2Gamma(ac.SkyRegion.All,      2 )--horizont smog / altitude(less)

    
    ac.setSkyV2Saturation(ac.SkyRegion.All,       1.0 )


    ac.setSkyV2Luminance(ac.SkyRegion.All,       0.025  )

    ac.setSkyBrightnessMult(ac.SkyRegion.All,       1 )


    ac.setSkyV2RayleighZenithLength(ac.SkyRegion.All,     15000)


    ac.setSkyV2MieZenithLength(ac.SkyRegion.All,      34000)


    ac.setSkyV2MieV(ac.SkyRegion.All, 3.98)
    ac.setSkyV2YOffset(ac.SkyRegion.All, 0.00)
    ac.setSkyV2YScale(ac.SkyRegion.All, 1)


    ac.setSkyV2SunIntensityFactor(ac.SkyRegion.Sun,      1500.0)
    ac.setSkyV2SunIntensityFactor(ac.SkyRegion.Opposite,      500.0)


    ac.setSkyV2SunIntensityFalloffSteepness(ac.SkyRegion.All,      1.25)

    
    ac.setSkyV2BackgroundLight(ac.SkyRegion.All,      0.0)
]]

end