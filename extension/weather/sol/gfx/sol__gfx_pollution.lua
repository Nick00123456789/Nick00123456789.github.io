------------------------------------------------------------------------------------
-- external light pollution



-- Light pollution globals and initial values
__extern_illumination = hsv( 0,0.0,0.0	)
__extern_illumination_mix = 0.0
__extern_illumination_position = vec3(0,0,0)
__extern_illumination_radius = 0
__extern_illumination_offset = 0

-- add an extra gradient for light pollution
local checked_extern_illumination_values = false
local extern_illumination_values_available = false


local extern_illumination_horizont_gradient = ac.SkyExtraGradient()
extern_illumination_horizont_gradient.color 	   = __extern_illumination:toRgb()
extern_illumination_horizont_gradient.exponent  = 1.0
extern_illumination_horizont_gradient.direction = vec3(0,-1,0)
extern_illumination_horizont_gradient.sizeFull  = 1.0
extern_illumination_horizont_gradient.sizeStart = 0.001
extern_illumination_horizont_gradient.isAdditive = true
extern_illumination_horizont_gradient.isIncludedInCalculate = false
ac.addSkyExtraGradient(extern_illumination_horizont_gradient)

--[[
local extern_illumination_top_gradient = ac.SkyExtraGradient()
extern_illumination_top_gradient.color 	   = __extern_illumination:toRgb()
extern_illumination_top_gradient.exponent  = 1.0
extern_illumination_top_gradient.direction = vec3(0,-1,0)
extern_illumination_top_gradient.sizeFull  = 1.0
extern_illumination_top_gradient.sizeStart = 0.001
extern_illumination_top_gradient.isAdditive = true
extern_illumination_top_gradient.isIncludedInCalculate = false
ac.addSkyExtraGradient(extern_illumination_top_gradient)
]]

local _l_pollution_mix_LUT = {
           -- clouds      ambient      gradient         
	{   0,    0.0,        0.00,        0.00  },
	{ 0.5,   0.25,        0.50,        0.40  },
	{   1,    0.5,        1.00,        0.70  },
	{   2,    1.0,        1.50,        1.25  },
	{   4,    1.3,        3.00,        1.50  },
	{   8,    1.5,        7.00,        2.00  },
	{  16,    1.7,        9.50,        3.00  },
	{ 100,    2.0,       12.00,        3.50  },
}
local _l_mix_lut
local _l_mix_lutCPP = LUT:new(_l_pollution_mix_LUT)

function pollution__get_mix_multis()

	return _l_mix_lut
end


function gfx__update_pollution()

	__extern_illumination_offset = 1 -- 1 if pollution position is center of the track, 0 if completely outside

	local tlp = { position=vec3(0,0,0), radius=SOL__config("nlp", "radius")*1000, density=SOL__config("nlp", "density"), tint=hsv(SOL__config("nlp", "Hue"), SOL__config("nlp", "Saturation"), SOL__config("nlp", "Level")):toRgb() }
	
	if SOL__config("nlp", "use_light_pollusion_from_track_ini") == true then 

		local temp = ac.getTrackLightPollution()

		if temp ~= nil then 

			if temp.density == 0 and #temp.tint == 0 then 
				-- if config's night light pollution is not set, take the sol config values
			else 
				tlp = nil
				tlp = table__deepcopy(temp)
			end
		end
	end

	if SOL__config("debug", "light_pollution") == true and tlp ~= nil then

		ac.debug("Light pollution: 1) Position: ", string.format('X: %.0f, Y: %.0f, Z: %.0f', tlp.position.x, tlp.position.y, tlp.position.z)) 
		ac.debug("Light pollution: 2) Density: ", string.format('%.2f', tlp.density))
		ac.debug("Light pollution: 3) Radius: ", string.format('%.2f m', tlp.radius))
		ac.debug("Light pollution: 4) Color: ", string.format('R: %.2f, G: %.2f, B: %.2f', tlp.tint.r, tlp.tint.g, tlp.tint.b))
	end

	local l_track_light_pollution_position_relation = 0

	if tlp ~= nil then

		__extern_illumination = tlp.tint:toHsv()
		if __extern_illumination.v > 2 then 
			-- values are given in RGBA (0..255)
			__extern_illumination.v = __extern_illumination.v / 255 
		end

		--__extern_illumination.v = __extern_illumination.v * (1 - math.pow(day_compensate(0), 1))

		__extern_illumination.s = __extern_illumination.s * math.lerp(1.0, 0.8, gfx__get_fog_dense(5000))
		__extern_illumination.v = __extern_illumination.v * math.lerp(1.0, 0.8, gfx__get_fog_dense(5000))
														  * (1.0 + 0.5 * __night__effects_multiplier)

		__extern_illumination_position 	= validate__vec3(tlp.position, 0,0,0)
		__extern_illumination_radius 	= math.max(1, tlp.radius)

		__extern_illumination_mix 		= math.lerp(tlp.density, 0, day_compensate(0))
		

		-- use track map center vec3(0,0,0) to get offset of pollution center
		--__extern_illumination_position = __extern_illumination_position 

		l_track_light_pollution_position_relation = #(__extern_illumination_position - (__camPos*1.0)) / math.max(500, 1000*math.pow(__extern_illumination_radius*0.002, 0.5))
		l_track_light_pollution_position_relation = 1/math.max(1, l_track_light_pollution_position_relation)

		__extern_illumination_offset = math.max(0, math.min(1, math.pow(l_track_light_pollution_position_relation, 2)))

	 	local weather__illumination__multi = 0.5 + math.min(1, ((0.50 * math.lerp(1.0, 0.5, gfx__get_fog_dense(5000)))
	 										 * (1.00 + __inair_material.dense * (0.5 * (math.min(1, __inair_material.color.v) - 0.5)) )
	 										 + (0.00 * __overcast))
											  * (1.0 + 1.0 * __night__effects_multiplier))
											  
		local _l_mix_lut = _l_mix_lutCPP:get(__extern_illumination_mix) --interpolate__plan(_l_pollution_mix_LUT, nil, __extern_illumination_mix)
		local mix_clouds	= _l_mix_lut[1]
		local mix_ambient	= _l_mix_lut[2]
		local mix_gradient	= _l_mix_lut[3]





		 local pollusion_color = hsv(__extern_illumination.h,
		 							 __extern_illumination.s * math.pow(__extern_illumination_radius * 0.00001, 0.1),
		 							 __extern_illumination.v * math.pow(__extern_illumination_radius * 0.00001, 0.1)):toRgb()
						      * (1-from_twilight_compensate(0))
						      --* weather__illumination__multi
						      * mix_gradient
						      * (0.33 * (1 + __night__brightness_adjust*0.5))
						      * math.max(1,math.pow(l_track_light_pollution_position_relation*0.5,extern_illumination_horizont_gradient.exponent))
						      * (1/math.max(1, __sky_color.v)) -- compensate sky brightness
							  * (0.25 + 0.75*__overcast)
							  * SOL__config("ppoff", "brightness")

		local pos = (__extern_illumination_position - (__camPos*1.0)) * -1
		-- normalize
		pos = pos/#pos
	 	--calculate a very simple curve
		pos.y = -l_track_light_pollution_position_relation
		pos = math.lerp(pos, vec3(0,-1,0),  l_track_light_pollution_position_relation)

	 	extern_illumination_horizont_gradient.direction = pos--vec3(0,-1,0)
	 	extern_illumination_horizont_gradient.exponent  = 1
	 	extern_illumination_horizont_gradient.color = pollusion_color * math.pow(l_track_light_pollution_position_relation, 0.7)
		extern_illumination_horizont_gradient.sizeFull  = math.lerp(2, 0.5, l_track_light_pollution_position_relation)
		extern_illumination_horizont_gradient.sizeStart = 0.1--extern_illumination_gradient.sizeFull * 0.01 * l_track_light_pollution_position_relation
	
		
		
		--cloud light
		__light_pollution__raw = hsv.new(__extern_illumination.h,
										__extern_illumination.s * math.pow(mix_ambient, 0.1),
										__extern_illumination.v * mix_clouds )

		--ambient
		__light_pollution = hsv.new(__extern_illumination.h, 
									__extern_illumination.s,
									__extern_illumination.v 
									* mix_ambient
									* __extern_illumination_offset
									)	
		--[[							
		ac.debug("##_offset", __extern_illumination_offset)
		ac.debug("##_density", __extern_illumination_mix)
		ac.debug("##_radius", __extern_illumination_radius)
		]]
	else

		SOL__set_config("nlp", "use_light_pollusion_from_track_ini", false)
	end
end