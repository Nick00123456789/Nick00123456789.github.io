

local inair_mfog_mod = 0
local cloud_fog_modifier = 0

local _l_sun_light_LUT = {
	{-180,  0, 0.00, 1.00 },
	{-105,   0, 0.0, 1.00 },
	{ -98,   0, 0.0, 0.00 },
	{-97.5,10, 0.35, 0.00 },
	{ -94, 40, 0.90, 0.50 },
	{ -90, 20, 0.95, 1.70 },
	{ -85, 15, 1.30, 4.00 },
	{ -80, 25, 2.00, 3.00 },
	{ -75, 35, 1.20, 3.00 },
	{ -70, 43, 0.46, 3.00 },
	{ -60, 44, 0.26, 3.00 },
	{ -45, 48, 0.24, 3.00 },
	{ -30, 50, 0.21, 3.00 },
	{   0, 50, 0.20, 3.00 },
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
_l_improved_light_with_low_sun = 0
local _l_improved_light_with_low_sunCPP = LUT:new(_l_improved_light_with_low_sun_LUT, nil, true)


function Build_DistantHaze_Pattern(layer, style, water)

	local stack = Stack:new()
	local n = 6

	for i=1, n do
		stack:add({
			{ "pos", sphere2vec3(i*360/n, 15+rnd(2)) * 1000 },
			{ "size", 5000 },
			{ "water", water },
			{ "style", style },
		})
	end

	return stack
end



function Create_DistantHaze_Layer(layer)

	layer.static = true
end

function Update_DistantHaze_Layer(layer)

	cloud_fog_modifier = gfx__get_fog_dense(10000)
	
	_l_sun__LUT = _l_sunCPP:get() -- interpolate__plan(_l_sun_light_LUT, {1})
    _l_custom_sun_light  = hsv( _l_sun__LUT[1],
                                _l_sun__LUT[2] * (1 + 0.5*layer.dense),
                                _l_sun__LUT[3]):toRgb()
    _l_custom_sun_light  = _l_custom_sun_light * (1 - __overcast)

    local temp = interpolate__plan(_l_improved_light_with_low_sun_LUT)
    _l_improved_light_with_low_sun = temp[1]
end




function Create_DistantHaze_Cloud(cloud)

	local accloud = cloudsstorage__get_free_cloud(1) --ac.SkyCloud()

	cloud.ac_clouds_count = cloud.ac_clouds_count + 1


	accloud:setTexture('\\clouds\\2d\\hazy\\hazy1.dds')
    accloud.size = vec2(cloud.size, cloud.size*0.25)

    accloud.position = cloud.pos
    accloud.material = cloud.material

    accloud.occludeGodrays = false
    accloud.useCustomLightColor = true
    accloud.useCustomLightDirection = false

    accloud.opacity = 1.00 * cloud.style


    local c_r = rnd(0.10)
    cloud.ac_cloud_color[cloud.ac_clouds_count] = hsv(220,
                      0.2 + 0.1 * c_r,
                      1 + c_r):toRgb()

    
    accloud.color = cloud.ac_cloud_color[cloud.ac_clouds_count]


    cloud.ac_cloud_pos_offset[cloud.ac_clouds_count] = vec3(0,0,0)
    cloud.ac_clouds[cloud.ac_clouds_count] = accloud

end

function Update_DistantHaze_Cloud(cloud, everything)

	local custom_light

	vec_simple = cloud.pos - __camPos
	vec_simple:normalize()
	s_c3 = vec_diff(__lightDir, vec_simple, 1.0)
	s_c3 = math.min(1, math.max(0,  s_c3 ))


	--cloud.material.baseColor = rgb(1, 1, 1)

	local pos = vec3(cloud.pos.x, 0, cloud.pos.z)
	local cloud_color = gfx__get_sky_color(pos, true) * (2-1.0*cloud.water_filled)
	local fog   	  = math.max(0.2, ac.calculateSkyFog(vec3(cloud.vec_simple.x,0.4,cloud.vec_simple.z))-0.1)
      
	local _l_humid = gfx__get_humidity()

	--cloud_color:add(__sun_color:toRgb() * 0.4)
	cloud_color = cloud_color:toHsv()

	--cloud_color.h = math.max(0, cloud_color.h - 50) 
	cloud_color.s = cloud_color.s *4* (0.5 - 0.35*cloud.style)--(0.7 + (0.5 - 0.5 * math.max(0, 1-__inair_material.color.s)) * __overcast)
	cloud_color.v = cloud_color.v * (2
								   --math.pow(2.2 - cloud.style, 2)
								   --* (sun_compensate(0.25)+s_c3)
								   --+ 0.75 * sun_compensate(0)
								    ) * (1-0.0*fog)

	cloud_color = cloud_color:toRgb()  
	--add sunlight
	--cloud_color:add(_l_custom_sun_light * (1-0.80*night_compensate(0)) * (1.0 - 0.95*cloud.style) * s_c3 * (1-sun_compensate(0)) )  
	
	cloud.material.baseColor = cloud_color * 1--0.275

	cloud.material.frontlitMultiplier = 0--*from_twilight_compensate(0)
	cloud.material.frontlitDiffuseConcentration = 1
	cloud.material.backlitMultiplier = (1-0.97*night_compensate(0)) * 1 * (1-cloud.style)
	cloud.material.backlitExponent = 0.5*from_twilight_compensate(5)
	cloud.material.backlitOpacityMultiplier = 0
	cloud.material.backlitOpacityExponent = 10
	cloud.material.specularPower = 0
	cloud.material.specularExponent = 2

	cloud.material.fogMultiplier = cloud_fog_modifier
	--ac.debug("###", fog)

	custom_light = _l_custom_sun_light

	local opac = math.min(1, (0.1 + 0.90*cloud.style + 0.35 * __smog))  * cloud.transition 

	for i=1, cloud.ac_clouds_count do

		c = cloud.ac_clouds[i]

		if everything then

			if __sun_angle > -7.5 then 
				c.customLightColor = custom_light
			else
				c.customLightColor = __lightColor*5*_l_custom_sun_light
			end

			c.color = cloud.ac_cloud_color[i]

			c.opacity = opac
		end
	end
	

end