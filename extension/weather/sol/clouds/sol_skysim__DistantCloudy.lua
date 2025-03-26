

local inair_mfog_mod = 0
local cloud_fog_modifier = 0
local spectral_filter
local __overcast_mod = 1
local gain_mod = 1
local sun_intensity = 1
local _l_config__clouds__opacity_multiplier = 1

local _l_sun_light_LUT = {
	{-180,   0, 0.0, 1.00 },
	{-105,   0, 0.0, 1.00 },
	{ -98,   0, 0.0, 0.00 },
	{-97.5, 5, 0.80, 0.00 },
	{ -94, 10, 0.90, 4.00 },
	{ -90, 13, 1.00, 5.50 },
	{ -85, 17, 1.05, 6.00 },
	{ -80, 22, 0.92, 4.20 },
	{ -75, 30, 0.53, 3.50 },
	{ -70, 43, 0.46, 3.50 },
	{ -60, 44, 0.35, 3.50 },
	{ -45, 48, 0.35, 3.50 },
	{ -30, 50, 0.35, 3.50 },
	{   0, 50, 0.35, 3.50 },
}
local _l_sun__LUT = {}
local _l_sunCPP = LUT:new(_l_sun_light_LUT, {1}, true)
local _l_custom_sun_light = rgb(1,1,1)

local _l_improved_light_with_low_sun_LUT = {
	{-180, 0.00 },
	{ -96, 0.00 },
	{ -93, 1.00 },
	{ -90, 1.00 },
	{ -75, 1.00 },
	{ -70, 1.00 },
	{ -60, 1.00 },
	{ -50, 1.00 },
	{   0, 1.00 },
}
local _l_improved_light_with_low_sun = 0
local _l_improved_light_with_low_sunCPP = LUT:new(_l_improved_light_with_low_sun_LUT, nil, true)


function Build_DistantCloudy_Pattern(layer, style, water)

	local stack = Stack:new()
	local n = 15*style

	local rnd_water
	local rnd_water_up   = water * 0.125
  	local rnd_water_down = water * -0.45

	local distance = 1
	
	for ii=1, 3 do
		for i=1, n*ii do

			distance = 0.5+rnd(0.5) + ii

			rnd_water = math.lerp(rnd_water_down, rnd_water_up, math.pow(math.random(), 1-0.5*water) )

			stack:add({
				{ "pos", sphere2vec3(i*360/n+rnd(45), (3.6+0.2*style)-0.80*(distance-1)-0.25*ta_horizon_offset+rnd(0.5*style)) * (9000+3000*distance) },
				{ "size", 6000-1200*distance },
				{ "water", water },
				{ "style", style },
			})
		end
	end

	return stack
end



function Create_DistantCloudy_Layer(layer)

	layer.static = true
	layer.radius = 12000
end

function Update_DistantCloudy_Layer(layer)

	if ta_exp_fix < 1 then
		gain_mod =  math.pow(1/ta_exp_fix, ta_exp_fix*0.25)
	elseif ta_exp_fix > 1 then
		gain_mod =  math.pow(1/ta_exp_fix, 1/math.pow(ta_exp_fix, 4))
	end


	cloud_fog_modifier = math.max(0.00, gfx__get_fog_dense(15000))
	
	_l_sun__LUT = _l_sunCPP:get() --interpolate__plan(_l_sun_light_LUT, {1})
    _l_custom_sun_light  = hsv( _l_sun__LUT[1],
                                _l_sun__LUT[2],
								_l_sun__LUT[3] * (1 - __overcast)):toRgb()

	_l_improved_light_with_low_sun = _l_improved_light_with_low_sunCPP:get()[1] --interpolate__plan(_l_improved_light_with_low_sun_LUT)
	

	spectral_filter = gfx__get_distance_spectral_filter()
					/ math.pow(math.max(1, blue_sky_cloud_sat), 2)

	__overcast_mod = __overcast * sun_compensate(0)

	sun_intensity = math.pow(SOL__config("nerd__sky_adjust", "SunIntensityFactor"), 0.5 - 0.5*__overcast)

	_l_config__clouds__opacity_multiplier = SOL__config("clouds", "opacity_multiplier")
				
end






function Create_DistantCloudy_Cloud(cloud)

	local n = math.floor(3+rnd(2)) + 1

	cloud.lastDistance = math.horizontalLength(cloud.pos)

	for i=1, n do

		local accloud = cloudsstorage__get_free_cloud(1) --ac.SkyCloud()

		cloud.ac_clouds_count = cloud.ac_clouds_count + 1

		local tex = i--math.floor(math.random() * 15) + 1
		local tex_file = "far"
		if tex < 10 then tex_file = tex_file.."0" end
		tex_file = tex_file..tex

		accloud:setTexture('\\clouds\\2d\\far\\'..tex_file..'.dds')
		accloud.size = vec2(cloud.size, cloud.size*(0.2+0.075*cloud.water_filled))

		accloud.position = cloud.pos--sphere2vec3(angles[1]+rnd(10), angles[2]) * math.horizontalLength(cloud.pos)
		accloud.material = cloud.material

		accloud.occludeGodrays = false
		accloud.useCustomLightColor = true
		
		accloud.useCustomLightDirection = true
		accloud.customLightDirection = vec3(0,1,0)

		accloud.opacity = 0

		local c_r = rnd(0.10)
		cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(30,
						0.1 + 0.0 * c_r,
						1 + c_r):toRgb()

		
		accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]


		local angles = vec32sphere(cloud.pos:clone():normalize())
		cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = (sphere2vec3(angles[1]+rnd(10), angles[2]) * cloud.lastDistance) - cloud.pos
		cloud.ac_clouds[cloud.ac_clouds_count] = accloud
	end
end




local s_c3
local s_c5
local fog

function Update_DistantCloudy_Cloud(cloud, everything)

	if everything then 

		local custom_light

		s_c3 = cloud:getLightSourceRelevance(0.5, 1, 1)
		s_c5 = vec_diff(__lightDir, cloud.vec_simple, 5)*2
		
		--cloud.material.baseColor = rgb(1, 1, 1)

		local pos = vec3(cloud.pos.x, 0, cloud.pos.z)
		--local cloud_color = gfx__get_sky_color(pos, true) * 1
		--cloud_color = math.lerp(cloud_color, hsv(230, 0.7, cloud_color:getLuminance()):toRgb(), 0.75-0.5*cloud.water_filled)
		--cloud_color = cloud_color:toHsv() 

		if nopp__use_sol_without_postprocessing then

			fog = math.max(0.85, gfx__get_fog_dense(cloud.lastDistance * 0.95))
		else
			fog = math.max(0.55, gfx__get_fog_dense(cloud.lastDistance * 0.95))
		end


		local _l_humid = gfx__get_humidity()


		--[[
		local cloud_color = math.lerp(
								hsv(230, 0.0 + 0.2*__overcast, 1.0 + 3*__overcast_mod):toRgb(),
								gfx__get_sky_color(cloud.vec_simple, true),
								(1-__overcast_mod) * math.min(1, math.max(0, blue_sky_cloud_adaption*0.25))
							):toHsv()
		]]

		local cloud_color = gfx__get_sky_color(cloud.vec_simple, true, true, false):toHsv()

		--cloud_color.h = math.max(0, cloud_color.h - 50) 
		--cloud_color.s = cloud_color.s
					  --(0.7 + (0.5 - 0.5 * math.max(0, 1-__inair_material.color.s)) * __overcast)
		
		cloud_color.v = cloud_color.v 
					  * SOL__config("nerd__clouds_adjust", "Lit")
					  * blue_sky_cloud_lev
					  * (1-0.8*__badness)
					  --* (1+1.5*__overcast_mod)
					  * sun_intensity

		cloud_color = cloud_color:toRgb() * from_twilight_compensate(0.0)
		cloud_color:sub(rgb(0.16, 0.14, 0)*(1+3*__overcast)*cloud.water_filled*sun_compensate(0)):scale(1-0.65*cloud.water_filled)
		cloud_color:sub(rgb(0.1,0.075,-0.025) * cloud.water_filled)
		--add sunlight
		--cloud_color:add(_l_custom_sun_light * (1-0.80*night_compensate(0)) * (1.0 - 0.95*cloud.style) * s_c3 * (1-sun_compensate(0)) )  
		
		cloud_color = cloud_color * gain_mod

		local top = cloud_color:toHsv()

		-- compensate topcolor to be white, no matter which color the cloud has
		-- this garanties separate color control of top and bottom part
		top.h = __rev_hue(top.h, -1)
		top.s = top.s * 1 * blue_sky_cloud_sat
		top.v = top.v * (2-s_c5) --sun cover or not 
		top = top:toRgb()--*(1-__overcast)

		top:sub(spectral_filter*top:getLuminance()*0.2*(1-__overcast))


		

		cloud.material.baseColor:set(cloud_color)
		cloud.material.ambientColor:set(top)

		cloud.material.frontlitMultiplier = 0.35 * sun_compensate(0.27) * sun_compensate(s_c3)
		cloud.material.frontlitDiffuseConcentration = (0.70+0.10*cloud.water_filled)* sun_compensate(1+1*s_c3) --math.lerp(0.75, 0.75, sun_compensate(0)) 
		cloud.material.backlitMultiplier = (1+1.25*s_c5) * from_twilight_compensate(0) * 2 * (1-_l_humid) * math.max(0, (1-1.75*cloud.water_filled))--math.max(0, 1-2*cloud.water_filled) * sun_compensate(0.05)
		cloud.material.backlitExponent = 1.5 --* sun_compensate(2) 
		cloud.material.backlitOpacityMultiplier = 2.1--(1+2.0*s_c5) * cloud.water_filled
		cloud.material.backlitOpacityExponent = 3
		--[[cloud.material.specularPower = (4-math.min(4, cloud.water_filled*8*s_c5))
										* sun_compensate(0.1)
										* math.lerp( 0.1-0.1*cloud.water_filled, 2-1.5*cloud.water_filled, sun_compensate(0)) 
		]]
		cloud.material.specularPower = __IntD(0.05, 2-1.5*cloud.water_filled)
										* math.lerp( (1.0-0.8*cloud.water_filled), 1-0*cloud.water_filled, sun_compensate(0))
		cloud.material.specularExponent = 1.25

		cloud.material.fogMultiplier = math.min(1, fog + 0.4*cloud.water_filled)
		--ac.debug("###", fog)

		custom_light = _l_custom_sun_light:clone():scale(7.5)
		custom_light:adjustSaturation( custom_light:getSaturation()*(0.35+0.7*s_c3*(1-0.75*sun_compensate(0))) )
		--custom_light:sub( spectral_filter * math.min(2, cloud_color:getLuminance()*1) * (1-cloud.water_filled))
		custom_light = (1-__overcast)
					 * from_twilight_compensate(0.1)
					 * 1.1
					 * math.lerp(custom_light, math.lerp(custom_light, rgb(0,0,0), cloud.water_filled), (1-sun_compensate(0))*(1-s_c3))
					 * SOL__config("nerd__clouds_adjust", "Lit")

		local custom_light_direction = math.lerp(__lightDir, vec3(0,1,0), (1-(1-sun_compensate(0))*s_c3) * sun_compensate(0) )

		local opac = from_twilight_compensate(1.0)
				* (0.85 - 0.8*fog + (0.8*(1-fog)*cloud.water_filled))
				* math.min(1, (0.8 + 0.20*cloud.style)) 
				* cloud.transition
				* (1-(0.3+0.7*(1-sun_compensate(0)))*__overcast)
				* (1 + 0.6*s_c5)
				* math.max(0.1, sun_compensate(0.7-1.5*s_c3*(1-cloud.water_filled)))
				* _l_config__clouds__opacity_multiplier
		opac = math.min(1.45, opac)

		for i=1, cloud.ac_clouds_count do

			c = cloud.ac_clouds[i]


			if __sun_angle > -7.5 then 
				c.customLightColor = custom_light
				c.customLightDirection = custom_light_direction
			else
				c.customLightColor = __lightColor*5*_l_custom_sun_light
				c.customLightDirection = __lightDir
			end

			c.color = cloud.ac_cloud_color[i]

			c.opacity = opac
			
		end
	
	end
end