
-- take the textures from base implementation

if SOL__config("performance", "only_use_smaller_textures") == false then
	if file_exists("extension\\weather\\sol\\space\\starmap_16k.dds") ==  true then
		ac.setSkyStarsMap("extension\\weather\\sol\\space\\starmap_16k.dds")
	elseif file_exists("extension\\weather\\sol\\space\\starmap_8k.dds") ==  true then
		ac.setSkyStarsMap("extension\\weather\\sol\\space\\starmap_8k.dds")	
	elseif file_exists("extension\\weather\\sol\\space\\starmap_4k.dds") ==  true then
		ac.setSkyStarsMap("extension\\weather\\sol\\space\\starmap_4k.dds")
	end
elseif file_exists("extension\\weather\\sol\\space\\starmap_4k.dds") ==  true then
	ac.setSkyStarsMap("extension\\weather\\sol\\space\\starmap_4k.dds")
end

if file_exists("extension\\weather\\sol\\space\\moon.png") ==  true then
	ac.setSkyMoonTexture("extension\\weather\\sol\\space\\moon.png")
end

local sol__angle__display = 0 --90 base view convertion to edit plans

-- If sun's angle is below this value, shadow rendering is switched off
local sun__minimum_shadow_cast_angle = 1.0


ac.setSkyMoonDepthSkip(true)


__moon_sun_balance = 0.0 -- 0 = sun is dominant
__moonlight_color = hsv.new(0,0,0)
__moonlight_color__withoutCloudCover = rgb.new(0,0,0)

-- moon bloom --
--- 7 ---
-- managed in solar_system
moon_bloom_blue = ac.SkyExtraGradient()
moon_bloom_blue.color = rgb.new(0,0,0)
moon_bloom_blue.exponent  = 1
moon_bloom_blue.direction = vec3(0,1,0)
moon_bloom_blue.sizeFull  = 4.0
moon_bloom_blue.sizeStart = 0.1
moon_bloom_blue.isAdditive = true
moon_bloom_blue.isIncludedInCalculate = false
ac.addSkyExtraGradient(moon_bloom_blue)


__solar_eclipse = 1
__lunar_eclipse = 1

n=1
local _l_Stars_LUT = {
            -- lev   exp    
	{  -90,    2.0,  3.60  },
	{  -20,    1.8,  3.20  },
	{  -18,    1.7,  3.50  },
	{  -12,    1.2,  5.00  },
	{   -9,   0.70,  8.00  },
	{   -6,   0.25, 10.00  },
	{   -3,   0.00,  6.00  },
	{   90,   0.00,  3.00  },
}
local _l_Stars_lut
local _l_Stars_lutCPP = LUT:new(_l_Stars_LUT, nil, true)


local _l_SUN_COLOR = nil
function GFX__get_sun_light_HSV()
	return hsv(__sun_color.h,__sun_color.s,__sun_color.v)
end
function GFX__set_sun_light_HSV(color)
	--backup sun
	_l_SUN_COLOR = hsv(color.h,color.s,color.v)
end


function solar__get_sun_facing()

	--reverse CAM
	local cam = vec32sphere(__camDir*-1)
	local sun = vec32sphere(ac.getSunDirection())

	local diff = angle_diff(sun[1], cam[1])

	return diff
end

local _l_light_damping = 1
function solar__get_light_damping()
	return _l_light_damping
end

function update__solar_system()

	local moon_low  = hsv.new(SOL__config("nerd__moon_adjust", "low_Hue"), 
							SOL__config("nerd__moon_adjust", "low_Saturation"), 
							SOL__config("nerd__moon_adjust", "low_Level")):toRgb()
	local moon_high = hsv.new(SOL__config("nerd__moon_adjust", "high_Hue"),
							SOL__config("nerd__moon_adjust", "high_Saturation"),
							SOL__config("nerd__moon_adjust", "high_Level")):toRgb()

	local __sun_color__backup
	if _l_SUN_COLOR then
		__sun_color__backup = hsv(__sun_color.h,__sun_color.s,__sun_color.v)
		__sun_color = hsv(_l_SUN_COLOR.h,_l_SUN_COLOR.s,_l_SUN_COLOR.v)
	end 

	local _l_config__smog = SOL__config("sky", "smog")

	__solar_eclipse = 1
	__lunar_eclipse = 1

	if __sun_angle > 0 and __moon_angle > -3 then
		-- if sun and moon are visible

		-- calculate a modulator when moon and sun have the same position
		__solar_eclipse = math.pow(math.min(1, ((math.min(0.2, math.abs(__sun_heading - __moon_heading)) * 7.0) +
		                                        (math.min(0.2, math.abs(__sun_angle -   __moon_angle))   * 7.0))), 10)
	elseif __sun_angle < 0 and __moon_angle > -3 then

	  	-- calculate a modulator when moon and sun have exactly the opposite position
		__lunar_eclipse = math.pow(math.min(1, (math.abs(math.abs(__sun_heading - __moon_heading) -180) * 0.85) +
		                                       (math.abs(__sun_angle +   __moon_angle)  * 0.85)), 5)
	

		--ac.debug("###1:",math.abs(math.abs(__sun_heading - __moon_heading) -180) * 1.0)
		--ac.debug("###2:",math.abs(math.abs(__sun_angle +   __moon_angle)  * 1.0))		
	end

	if SOL__config("debug", "solar_system") == true then
		ac.debug("Stellar: Solar eclipse", string.format('%.2f', 1-__solar_eclipse))
		ac.debug("Stellar: Lunar eclipse", string.format('%.2f', 1-__lunar_eclipse))
	end


	local m_sin = math.max(0, math.min(1, __moon_angle*0.125-1 ))
	local m_sin2 = math.max(0, math.min(1, __moon_angle*0.09-1 ))

	local m_r = math.lerp(moon_low.r , moon_high.r , m_sin)
	local m_g = math.lerp(moon_low.g , moon_high.g , m_sin)
	local m_b = math.lerp(moon_low.b , moon_high.b , m_sin)


	local moon_sun_m = math.pow(1-from_twilight_compensate(0), 2) * __sun_color.v * math.pow(__sky_color.v, 0.3)
	moon_sun_m = math.max(moon_sun_m, 0.001)
	
	local moon_effect_multi = 0.03+(__night__effects_multiplier*0.05)


	if __lunar_eclipse < 1.0 then

		m_r = math.lerp(1.00 , m_r , __lunar_eclipse)
		m_g = math.lerp(0.15 , m_g , __lunar_eclipse)
		m_b = math.lerp(   0 , m_b , __lunar_eclipse)
	end

	__moonlight_color__withoutCloudCover = rgb(m_r, m_g, m_b) * 1*math.max(1, moon_sun_m)
															  * (1-0.4*__smog-0.4*math.max(0, _l_config__smog-1))

	local sky_color_behind_moon = gfx__get_sky_color(__moonDir, true, true, false):getLuminance() 
	
	ac.setSkyMoonBaseColor( rgbm(__moonlight_color__withoutCloudCover.r,
								 __moonlight_color__withoutCloudCover.g,
								 __moonlight_color__withoutCloudCover.b,
								 math.max(1, 5*sky_color_behind_moon) * 0.33 ))

	__moonlight_color__withoutCloudCover = __moonlight_color__withoutCloudCover * ac.getMoonFraction()
	-- filter red spectrum for high moon angles
	__moonlight_color__withoutCloudCover:sub(rgb(0.9,0.2,0) * m_sin)
	__moonlight_color__withoutCloudCover = __moonlight_color__withoutCloudCover * (1+2*m_sin)
	
	local moon_opc = math.max(0.05, 1-1.10*math.pow(sky_color_behind_moon, 0.5))
	ac.setSkyMoonOpacity(moon_opc
						* math.max(0,1-1.25*__overcast)
						* (1.0-0.05*__extern_illumination_mix*__extern_illumination_offset)
						* (0.4+0.6*__lunar_eclipse)
						* (1-math.pow(gfx__get_smog_dense(), 2))
						)

	ac.setSkyMoonMieExp(SOL__config("nerd__moon_adjust", "mie_Exponent"))

	local moon_v = math.min(10, __moonlight_color.v * 0.42)
	
	local moon_cover = math.max(0, 
					   math.lerp( 1.0, -0.5, math.pow(__fog_dense, 2) )
  					 * math.lerp(1, -2.8, math.max(0, __inair_material.dense)))
	
	ac.setSkyMoonMieMultiplier(SOL__config("nerd__moon_adjust", "mie_Multi") * math.lerp(0.060,0.15,__night__effects_multiplier) * moon_v * math.pow(m_sin2, 2))
	
	--ac.setSkyMoonMieMultiplier(0)

	-- MOON SKY
	moon_bloom_blue.direction  = __moonDir*-1
	--moon_bloom_white.direction = moon_bloom_blue.direction
	
	moon_bloom_blue.color = hsv(__sky_color.h, __sky_color.s, math.max(1, __sky_color.v)):toRgb() * moon_v * __lunar_eclipse * 6 * math.pow(m_sin2, 2)

	moon_v = moon_v * m_sin

	moon_bloom_blue.sizeFull = math.lerp(8,4,math.min(1, math.max(0, moon_v*0.75))) * (SOL__config("nerd__moon_adjust", "mie_Exponent") * 0.1)
	


	--fade in/out sun
	local sun_moon_light_fade_start = -4.5
	local fade_width = 6 --degrees

	__moonlight_color.v = 0
	__moon_sun_balance  = 0

	if __sun_angle < sun_moon_light_fade_start then
		--nighttime / sun starting to fade with/without the moon

		local moon_v = math.min(1, math.max(0, (__moon_angle+3)/3))
		--ac.debug("###", moon_v)

		-- calculate moon color / fade in from sunangle -2° to 3 degrees
		__moonlight_color = (__moonlight_color__withoutCloudCover * __IntN(1,0.1,10) ):toHsv()

		--__moonlight_color.h = nerd__moon_adjust.high_Hue
		
		-- prevent feedback
		__moonlight_color.v = __moonlight_color.v * math.max(0, (1-0.5*__moonlight_color.s))
												  * (1-gfx__get_fog_dense(4000))
												  * moon_v
												  * moon_effect_multi
												  * (0.5 + 0.33 * __night__brightness_adjust)
												  * SOL__config("night", "moonlight_multiplier")
												  * __lunar_eclipse

		__moonlight_color.s = math.pow(math.min(1, __moonlight_color.s *0.5), 2.5) 

		if __moon_angle > -3.0 then

			if __sun_angle > sun_moon_light_fade_start - fade_width then

				local fade_pos = math.abs(__sun_angle - sun_moon_light_fade_start) / math.max(0.01, fade_width)

				__moon_sun_balance = 0

				--ac.debug("fade_pos",fade_pos)

				if fade_pos < 0.5 then

					local sun_v = math.max(0, math.min(1, 1-fade_pos*2))

					__moonlight_color.v = 0
				
					__moon_sun_balance = 0

					__sun_color.v = __sun_color.v * sun_v

					__lightDir = __sunDir
	    			__lightColor = rgb(0,0,0)

	    			ac.setShadows(ac.ShadowsState.EverythingShadowed)
	    			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","Everything") end

				else
					__moon_sun_balance = 1

					__moonlight_color.v = __moonlight_color.v * math.lerp(0,1, math.min(1, math.max(0, (fade_pos*2)-1)))						  
					
					--__moonlight_color.s = __moonlight_color.s * 0.1

					__lightColor = __moonlight_color:toRgb() * moon_cover * day_compensate(4)
	    			__lightDir   = math.lerp(__sunDir, __moonDir, (fade_pos-0.5)*2)

	    			if SOL__config("moon", "casts_shadows") == true then
		    			ac.setShadows(ac.ShadowsState.On)
		    			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","On") end
		    		else
		    			ac.setShadows(ac.ShadowsState.Off)
		    			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","Off") end
		    		end
				end
			else

				--__moonlight_color.s = __moonlight_color.s * 0.1
				__lightColor = __moonlight_color:toRgb() * moon_cover * day_compensate(4)
	    		__lightDir   = __moonDir

	    		__moon_sun_balance = 1.0

	    		if SOL__config("moon", "casts_shadows") == true then
	    			ac.setShadows(ac.ShadowsState.On)
	    			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","On") end
	    		else
	    			ac.setShadows(ac.ShadowsState.Off)
	    			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","Off") end
	    		end
			end
		else

			__moon_sun_balance = 0

			-- fade out/in sun light for 1° to prevent visible change to EverythingShadowed
			local sun_tangent_fade = math.max(0, math.min(1, __sun_angle-sun__minimum_shadow_cast_angle))
				
			if __sun_angle > sun_moon_light_fade_start - fade_width then

				local fade_pos = math.abs(__sun_angle - sun_moon_light_fade_start) / math.max(0.01, fade_width)
				local sun_v = math.lerp(1,0,math.min(1,fade_pos*2))

				__sun_color.v = __sun_color.v * sun_v
	    	else
				__sun_color.v = 0
				__moonlight_color.v = 0
			end

			__lightColor = __sun_color:toRgb() * sun_tangent_fade
	    	__lightDir   = __sunDir

			ac.setShadows(ac.ShadowsState.EverythingShadowed)
			if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","Everything") end
		end
	else
		--daytime / sun is before the fade to night

	    if __AC_TIME < 43200 then
	    	sun__minimum_shadow_cast_angle = ta_sun_dawn 
	    else
	    	sun__minimum_shadow_cast_angle = ta_sun_dusk 
	    end

	    -- fade out/in sun light for 1° to prevent visible change to EverythingShadowed
	    local sun_tangent_fade = math.max(0, math.min(1, __sun_angle-sun__minimum_shadow_cast_angle))
		--ac.debug("sun_tangent_fade", sun_tangent_fade)

		local color = __sun_color:toRgb() 
		__lightColor  = color * sun_tangent_fade

		if __sun_angle < sun__minimum_shadow_cast_angle then
			ac.setShadows(ac.ShadowsState.EverythingShadowed)
	      	if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","Everything") end
	    else
	      	ac.setShadows(ac.ShadowsState.On)
	      	if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Shadows","On") end
	    end

    	__lightDir = __sunDir

    end

	__lightColor = __lightColor * math.lerp(1,0,math.min(1, math.pow(__overcast*1.25,2)))
	__lightColor = __lightColor * math.max(0, (1-1.5*math.pow(__badness,2)))
	-- less light with fog
	_l_light_damping = math.max(0, (1.00-math.max( 0.6*gfx__get_fog_dense(500), math.pow(gfx__get_smog_dense(), 3) * 1.25 )) )
	__lightColor = __lightColor * _l_light_damping

	if SOL__config("clouds", "render_method") == 0 then
		__lightColor = __lightColor * math.max(0, (1-0.90*weather__get_cloud_shadow()*SOL__config("clouds", "shadow_opacity_multiplier")))
	end

	ac.setLightColor(__lightColor)	
	ac.setLightDirection(__lightDir)	

	if SOL__config("debug", "graphics") == true then ac.debug("Gfx: Light source", string.format('%.2f', #__lightColor)) end

	if SOL__config("sun", "modify_speculars") == true then
		-- dim speculars 2° before sunset/after sunrise
		local speculars_tangent_fade = math.max(0, math.min(1, __sun_angle-(sun__minimum_shadow_cast_angle+2)))
		ac.setSpecularColor(__lightColor * speculars_tangent_fade
										 --* (1-math.min(1,math.max(0, __cloud_transition_density), 1))
										 * math.max(0, 1-1.6*__overcast)
										 * 1.5 * SOL__config("nerd__speculars_adjust", "Level"))
	end

	--ac.setSpecularColor(__lightColor)

	ac.setSkySunMoonSizeMultiplier(1.6*SOL__config("sun", "size"))


	if __sun_angle < 0 then

		-- interpolate the basic ambient light curve
		_l_Stars_lut = _l_Stars_lutCPP:get() --interpolate__plan(_l_Stars_LUT)

		local stars_v = _l_Stars_lut[1]
						* math.lerp(1.0,0,math.min(1,__ambient_color.v*0.2))

						* math.lerp(1,0,math.min(1, __overcast*1.4))
						* math.lerp(1,0,math.min(1, __fog_dense))
						--* (1.0-math.min(0.99, 0.3*__extern_illumination_mix*__extern_illumination_offset))
						* (1.00 + 1.0 * __night__effects_multiplier)
						* (1.00 - 0.25 * m_sin * ac.getMoonFraction())
						* SOL__config("night", "starlight_multiplier")
						* (1-0.25*__smog-0.75*math.max(0, _l_config__smog-1))

		local stars_exp = (1.0 * math.pow(SOL__config("night", "starlight_multiplier"), 0.2))
						* (_l_Stars_lut[2] * (1+1*__smog+1*math.max(0, _l_config__smog-1)))
						--* (1.0+0.10*__extern_illumination_mix*__extern_illumination_offset)
						* SOL__config("nerd__stars_adjust", "Exponent")

		-- Stars
		
		ac.setSkyStarsBrightness(stars_v)
		ac.setSkyStarsSaturation(0.2 * SOL__config("nerd__stars_adjust", "Saturation"))
		ac.setSkyStarsExponent(stars_exp)
--[[		
		ac.setSkyStarsBrightness(2)
		ac.setSkyStarsSaturation(1)
		ac.setSkyStarsExponent(2)
]]
		ac.setSkyPlanetsBrightness(20)
		ac.setSkyPlanetsOpacity(stars_v)
		ac.setSkyPlanetsSizeBase(0.0025)
		ac.setSkyPlanetsSizeVariance(0.5)
		ac.setSkyPlanetsSizeMultiplier(1)
	else

		ac.setSkyStarsBrightness(0)
		ac.setSkyStarsSaturation(0)
		ac.setSkyStarsExponent(3)
		ac.setSkyPlanetsOpacity(0)
	end

	
	if SOL__config("debug", "solar_system") == true then
		ac.debug("Stellar: Sun", string.format('angle: %.2f°, heading: %.2f°', __sun_angle-sol__angle__display, __sun_heading))
		ac.debug("Stellar: Moon", string.format('angle: %.2f°, heading: %.2f°', __moon_angle-sol__angle__display, __moon_heading))
	end

	--local interior_split = vec3.new(1.3,40,250)
	--local exterior_split = vec3.new(8.0, 60.0, 200.0)

	--ac.setShadowsSplits(interior_split, exterior_split)

	if _l_SUN_COLOR then
		--restore sun for post processes
		__sun_color = hsv(__sun_color__backup.h,__sun_color__backup.s,__sun_color__backup.v)
		_l_SUN_COLOR = nil
	end
end