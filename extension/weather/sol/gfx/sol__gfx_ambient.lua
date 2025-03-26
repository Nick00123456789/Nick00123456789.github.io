





-- A look up table (LUT) for the basic ambient light sunangle dependency
-- Color is based on HSV 
--[[
	HSV Model:
	H: Hue (0=red, 60=yellow, 120=green, 180=cyan, 240=blue, 315=magenta)
	S: Saturation
	V: Value
]]
-- Index is sunangle
local _l_ambient_LUT = {
          -- H       S       V     
	{  -90,  225.0,  0.800,   0.0   },
	{  -20,  225.0,  0.800,   0.01  },
	{  -17,  225.0,  0.800,   0.03  },
	{  -14,  225.0,  0.800,   0.06  },
	{  -11,  225.0,  0.800,   0.1   },
	{   -9,  225.0,  0.700,   0.4   },
	{   -6,  225.0,  0.600,   1.0   },
	{   -3,  225.0,  0.550,   3.0   },
	{   -2,  225.0,  0.530,   4.5   },
	{   -1,  225.0,  0.510,   6.0   },
	{    0,  225.0,  0.430,   7.5   },
	{    1,  225.0,  0.425,   8.5   },
	{    2,  225.0,  0.420,   9.5   },
	{    3,  225.0,  0.415,  10.0   },
	{    6,  225.0,  0.415,  11.0   },
	{    9,  225.0,  0.415,  12.0   },
	{   12,  225.0,  0.415,  12.5   },
	{   17,  224.0,  0.415,  13.5   },
	{   23,  222.0,  0.415,  14.5   },
	{   35,  220.0,  0.415,  15.0   },
	{   60,  219.0,  0.415,  15.5   },
	{   75,  219.0,  0.415,  15.5   },
	{   90,  219.0,  0.415,  15.5   },
}
local _l_Ambient_lut
local _l_AmbientCPP = LUT:new(_l_ambient_LUT, {1})

-- basic temperature dependency curve
-- Index is temperature
local _l_ambient_temp_LUT = {
           --  H    S     V         
	{    0,    1.0, 1.30, 1.05  },
	{   10,    1.0, 1.10, 1.04  },
	{   17,    1.0, 1.00, 1.03  },
	{   24,    1.0, 0.95, 1.02  },
	{   32,    1.0, 0.91, 1.01  },
	{   40,    1.0, 0.85, 1.00  },
}	
local _l_AmbientTemp_lut
local _l_AmbientTempCPP = LUT:new(_l_ambient_temp_LUT)


local _l_AMBIENT_LIGHT = hsv(0,0,1)
function GFX__get_ambient_light_HSV()
	return hsv(_l_AMBIENT_LIGHT.h,_l_AMBIENT_LIGHT.s,_l_AMBIENT_LIGHT.v)
end
function GFX__set_ambient_light_HSV(color)
	local r,g,b = HSVToRGB( color.h, color.s, 0.5 )
	ac.setAmbientColor( rgbm(r, g, b, color.v) )
end


function gfx__update_ambient()

	-- get the amount of light bounce by the clouds
	if SOL__config("clouds", "render_method") == 2 then
		__sky_light_bounce = math.min(1, sky_get_clouds_light_bounce())
	else
		__sky_light_bounce = 0
	end
			
	-- interpolate the basic ambient light curve
	_l_Ambient_lut 		= _l_AmbientCPP:get() --interpolate__plan(_l_ambient_LUT, { 1 })
	
	-- modulate ambient light with temperature
	_l_AmbientTemp_lut 	= _l_AmbientTempCPP:get(__temperature) --interpolate__plan(_l_ambient_temp_LUT, { 1 }, __temperature)
	for i=1,#_l_Ambient_lut do
		_l_Ambient_lut[i]=_l_Ambient_lut[i]*_l_AmbientTemp_lut[i]	
	end

	local l__ta_exp_fix 	 = night_compensate(ta_exp_fix)
	local night_bright_value = math.lerp(__night__brightness_adjust, 0, day_compensate(0))
	local _l_smog = math.min(1, __smog * SOL__config("sky", "smog"))


	local ppoff_ambLev = 1
	if nopp__use_sol_without_postprocessing then
		ppoff_ambLev = ppoff_ambLev * 0.35 * SOL__config("ppoff", "brightness")
	end

	local _l_overcast_bright
	local _l_overcast_sat
	local _l_overcast_damp
	if __overcast <= 0.8 then
		_l_overcast_bright = 0.8 * __overcast
		_l_overcast_sat = 0.8 * __overcast
		_l_overcast_damp = 0.5 * __overcast
	else
		_l_overcast_bright = 0.64 - 4.0*(__overcast - 0.8)
		_l_overcast_sat = 0.64 + 0.2*(__overcast - 0.8)
		_l_overcast_damp = 0.4 + 3.0*(__overcast - 0.8)
	end

	local sun_color_balance = SOL__config("ambient", "sun_color_balance")

	--pick sky color
	--follow the sun to get more ambient ligth for dusk and dawns
	local ambientColor = hsv.new(215, 0, 1)

	ambientColor.h = _l_Ambient_lut[1]
	ambientColor.s = _l_Ambient_lut[2]
	ambientColor.s = ambientColor.s * (1-(_l_overcast_sat * __overcast) * sun_compensate(0) ) * (1-0.15*weather__get_cloud_shadow()*(1-__overcast))
	
	-- just get the color from the sky, brightness is done by plan, take 1 as start
	ambientColor.v = _l_Ambient_lut[3] * (1-_l_smog)

	-- calculate the light pollution with inluences of fog and cloud density
	local t_hsv

	t_hsv = ambientColor:toRgb()
	t_hsv = ( t_hsv:add(__inair_material.color:toRgb()*0.05*from_twilight_compensate(0)) ):toHsv()
	t_hsv.s = t_hsv.s * math.lerp(math.lerp(1.0,0.5,math.min(1.5, __fog_dense)), 1, from_twilight_compensate(0))

	

	t_hsv.h = t_hsv.h * SOL__config("nerd__ambient_adjust", "Hue")

	--t_hsv.s = t_hsv.s * 0.82 -- readjust saturation, because of less smog influence 
	t_hsv.s = t_hsv.s * SOL__config("nerd__ambient_adjust", "Saturation") * math.max(0, 1-night_bright_value*0.35) * math.max(0, (1-(0.25*__smog*SOL__config("sky", "smog"))))
	t_hsv.s = t_hsv.s * math.lerp(1, math.pow(sun_color_balance*1.25, 0.3), sun_compensate(0))
	t_hsv.s = t_hsv.s * (1 - 0.25*weather__get_cloud_shadow()*sun_compensate(0))
	if nopp__use_sol_without_postprocessing == true then
		t_hsv.s = t_hsv.s * (1 - 0.5*(1-sun_compensate(0)))
		t_hsv.s = t_hsv.s / math.pow(__PPoff__brightness__regulation, 1+3*sun_compensate(0))
	end
	t_hsv.s = t_hsv.s * (1 + 0.50*sun_compensate(0)*(weather__get_hdr_multiplier() - 1))
	--t_hsv.s = t_hsv.s * math.min(5.00, (1+0.25*from_twilight_compensate(0)*__badness))

	t_hsv.v = t_hsv.v * math.lerp(1,__IntN(0.5,1.0),math.pow(__fog_dense, 2.0)) 
	t_hsv.v = t_hsv.v * math.lerp(1.0,0.5,math.min(1.5, __inair_material.dense*from_twilight_compensate(0)/__inair_material.color.v))
	t_hsv.v = t_hsv.v * math.lerp(0.15, 1.0, __solar_eclipse)
	t_hsv.v = t_hsv.v * math.lerp(1.00, 1-0.35*(1-sun_compensate(0)), _l_overcast_damp) -- loss of ambient light with overcast
	t_hsv.v = t_hsv.v * math.max(0.00, (1-(0.5 + 0.3*__overcast)*day_compensate(0.5)*__badness))
	t_hsv.v = math.max(0, t_hsv.v + (night_bright_value))
	t_hsv.v = t_hsv.v + __moonlight_color.v*SOL__config("nerd__moon_adjust", "ambient_ratio")*(1-__overcast)

	-- backup ambient color before it could be modified from start dim or custom config
	__ambient_color_raw = hsv.new(t_hsv.h, t_hsv.s, t_hsv.v)

	t_hsv.v = math.min(25, t_hsv.v) * SOL__config("nerd__ambient_adjust", "Level") *  ppoff_ambLev
	t_hsv.v = t_hsv.v * l__ta_exp_fix
	t_hsv.v = t_hsv.v * (1-0.50*_l_smog)
	
	t_hsv.v = t_hsv.v * math.lerp(1, 0.9+0.1*sun_color_balance, sun_compensate(0))
	--removed it, because light bounce produce too much ambient ligth with overcast
	t_hsv.v = t_hsv.v * (1 + 0.35*__sky_light_bounce*night_compensate(__IntD(-1,1,0.7)))
	t_hsv.v = t_hsv.v * (1 + 0.25*weather__get_cloud_shadow()*sun_compensate(0))
	t_hsv.v = t_hsv.v * (1 - 0.50*sun_compensate(0)*(weather__get_hdr_multiplier() - 1))

	if nopp__use_sol_without_postprocessing == true then
		t_hsv.v = t_hsv.v * math.pow(__PPoff__brightness__regulation, 1+0.25*sun_compensate(0))
		t_hsv.v = t_hsv.v * (1 + (__PPoff__brightness__regulation - 1) * night_compensate(0))
	end

	-- ############### t_hsv = hsv(210,0.1,10)
	
	-- add night light pollution at least
	local result = (t_hsv:toRgb()*0.5):add(__light_pollution:toRgb())
	
	__ambient_color = (result*2):toHsv()
	_l_AMBIENT_LIGHT = __ambient_color:clone()

	local _l_config__ambient__AO_visibility = SOL__config("ambient", "AO_visibility")

	ac.setAmbientColor( rgbm(result.r, result.g, result.b, _l_config__ambient__AO_visibility  ) )
	ac.setBaseAmbientColor(rgbm(result.r, result.g, result.b, (1-_l_config__ambient__AO_visibility)  ))
end