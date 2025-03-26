


-- A look up table (LUT) for the basic sun light sunangle dependency
-- Color is based on HSV 
--[[
	HSV Model:
	H: Hue (0=red, 60=yellow, 120=green, 180=cyan, 240=blue, 315=magenta)
	S: Saturation
	V: Value
]]
-- Index is sunangle
n = 1 
_l_sunlight_LUT = {
			-- H      S        V
	{   -90,   9,     0.00,    0   },
	{   -11,   9,     0.00,    0   },
	{    -9,   9,     1.30,    2   },
	{    -6,  10,    1.150,    3   },
	{    -3,  11,    1.100,    7   },
	{    -2,  12,    1.060,    8   },
	{    -1,  13,    1.030,    9   },
	{     0,  16,    1.000,   10   },
	{     1,  19,    1.000,   12   },
	{     2,  21,    1.000,   16   },
	{     3,  23,    0.950,   21   },
	{     6,  24,    0.900,   32   },
	{     9,  30,    0.800,   39   },
	{    12,  32,    0.680,   41   },
	{    17,  33,    0.500,   47   },
	{    23,  35,    0.340,   44   },
	{    35,  36,    0.260,   40   },
	{    50,  36.5,  0.247,   32   },
	{    75,  36.5,  0.241,   29   },
	{    90,  36.5,  0.234,   28   },
}	
local _l_Sunlight_lut
local _l_SunlightCPP = LUT:new(_l_sunlight_LUT, { 1 })


-- basic temperature dependency curve
-- Index is temperature
n=1
_l_sunlight_temp_LUT = {
           -- H    S     V         
	{    0,   0.9, 0.80, 1.00  },
	{   10,   1.0, 0.92, 1.00  },
	{   17,   1.0, 0.98, 1.00  },
	{   24,   1.0, 0.99, 1.00  },
	{   32,   0.9, 1.00, 1.02  },
	{   40,   0.8, 1.05, 1.03  },
}
local _l_SunlightTemp_lut
local _l_SunlightTempCPP = LUT:new(_l_sunlight_temp_LUT)


function gfx__update_sunlight()

	-- interpolate the basic ambient light curve
	_l_Sunlight_lut 		= _l_SunlightCPP:get() --interpolate__plan(_l_sunlight_LUT, { 1 })
	
	-- modulate ambient light with temperature
	_l_SunlightTemp_lut 	= _l_SunlightTempCPP:get(__temperature) --interpolate__plan(_l_sunlight_temp_LUT, { 1 }, __temperature)
	for i=1,#_l_Sunlight_lut do
		_l_Sunlight_lut[i]=_l_Sunlight_lut[i]*_l_SunlightTemp_lut[i]	
	end

	local l__ta_exp_fix 	 = night_compensate(ta_exp_fix)

	local ppoff_sunLev = 1
	if nopp__use_sol_without_postprocessing then
		ppoff_sunLev = ppoff_sunLev * 0.19 * SOL__config("ppoff", "brightness")
	end

	local sun_color_balance = SOL__config("ambient", "sun_color_balance")

	__sun_color = hsv.new(_l_Sunlight_lut[1] * SOL__config("nerd__sun_adjust", "ls_Hue"), _l_Sunlight_lut[2], 0.50)

	__sun_color.s = __sun_color.s * interpolate__value(1.1, 0.9,  __CM__altitude, 0, 1000, 300)
	__sun_color.s = math.lerp(__sun_color.s * 0.2, __sun_color.s, __solar_eclipse)
	__sun_color.s = __sun_color.s * SOL__config("nerd__sun_adjust", "ls_Saturation")
	__sun_color.s = __sun_color.s * dawn_exclusive(0.80)
	__sun_color.s = __sun_color.s * (1-(1-l__ta_exp_fix)*0.75)
	__sun_color.s = math.max(0, math.lerp( __sun_color.s, __sun_color.s * 0.5, math.pow(__fog_dense*1.3, 5)))
	__sun_color.s = __sun_color.s * math.lerp(1, 0.2+sun_color_balance*0.8, sun_compensate(0)) --0.75 to adjust it to neutral tones
	__sun_color.s = __sun_color.s * (1 + 0.50*sun_compensate(0)*(weather__get_hdr_multiplier() - 1))

	__sun_color.v = __sun_color.v * _l_Sunlight_lut[3] * interpolate__value(0.9, 1.1,  __CM__altitude, 0, 1000, 300)
	__sun_color.v = __sun_color.v * math.lerp(1, 0.0, math.max(0, __inair_material.dense-0.5) * 1.5)
	__sun_color.v = __sun_color.v * math.pow(math.lerp(0.2, 1.0, __solar_eclipse), 2)
	__sun_color.v = math.max(__sun_color.v, 0)

	__sun_color.v = __sun_color.v * (1-(1-l__ta_exp_fix)*1.00)
	__sun_color.v = math.min(25, __sun_color.v) * SOL__config("nerd__sun_adjust", "ls_Level") * ppoff_sunLev
	__sun_color.v = __sun_color.v * (1+0.05*weather__get_cloud_shadow())
	__sun_color.v = __sun_color.v * math.pow(0.65+0.5*sun_color_balance, 0.5)
	__sun_color.v = __sun_color.v * __PPoff__brightness__regulation
	__sun_color.v = __sun_color.v * (1 + 0.99*sun_compensate(0)*(weather__get_hdr_multiplier() - 1))

	if nopp__use_sol_without_postprocessing == true then
		__sun_color.v = __sun_color.v * __IntD(0.5, 1.75, 0.7)
	end
end