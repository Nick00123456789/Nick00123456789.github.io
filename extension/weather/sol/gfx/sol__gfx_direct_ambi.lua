

function gfx__update_directional_ambient_light()

	-- directional ambient light
	-- update every frame, because of camera dependency
	
	if __CSP_version >= 997 then --0.1.49

		local _l_config__ambient__use_directional_ambient_light = SOL__config("ambient", "use_directional_ambient_light")
		local _l_config__use_overcast_sky_ambient_light = SOL__config("ambient", "use_overcast_sky_ambient_light")
	
		local vec_ambi_overcast = nil
		local color_ambi_overcast = nil

		local vec_ambi_directional = nil
		local color_ambi_directional = nil

		if _l_config__ambient__use_directional_ambient_light then

			vec_ambi_directional = vec3(__lightDir.x, __lightDir.y, __lightDir.z)
			vec_ambi_directional.y = 0.0
			local sky_ambi_color = math.lerp(gfx__get_sky_color(vec_ambi_directional, true)*__IntN(0,1,100), __sun_color:toRgb(), __IntD(0,1,0.5) * (1-__overcast))

			sky_ambi_color:add(__sun_color:toRgb() * 0.5 * (1-0.85*weather__get_cloud_shadow()) * (1-__overcast) * (1-sun_compensate(0)) * from_twilight_compensate(0) )

			sky_ambi_color = sky_ambi_color * (1-__overcast*0.75) * (1-sun_compensate(0)*0.5*(1-weather__get_cloud_shadow())) * 0.35 * ((1-weather__get_cloud_shadow())*0.2+0.8)
			sky_ambi_color = sky_ambi_color * (1 + 1*weather__get_cloud_shadow()*sun_compensate(0))
			color_ambi_directional = sky_ambi_color * SOL__config("nerd__directional_ambient_light", "Level")

			--vec_ambi.y = math.max(0.1, __lightDir.y*0.67)
		end
		if _l_config__use_overcast_sky_ambient_light then

			vec_ambi_overcast = vec3(__camDir.x * -1, __camDir.y, __camDir.z * -1)
			vec_ambi_overcast.y = 1
			local sky_ambi_color = gfx__get_sky_color(vec_ambi_overcast, true) * 2.5
			sky_ambi_color = hsv(sky_ambi_color:getHue(), sky_ambi_color:getSaturation(), __IntD(0,sky_ambi_color:getLuminance(),0.7)*sun_compensate(0)*__overcast):toRgb()

			color_ambi_overcast = sky_ambi_color * SOL__config("nerd__overcast_sky_ambient_light", "Level")
		end

		local vec_ambi = nil
		local color_ambi = nil
		local mix = math.pow(__overcast, 4-3*sun_compensate(0))

		if _l_config__ambient__use_directional_ambient_light and _l_config__use_overcast_sky_ambient_light then
			vec_ambi   = math.lerp(vec_ambi_directional,   vec_ambi_overcast,   mix)
			color_ambi = math.lerp(color_ambi_directional, color_ambi_overcast, mix)
		elseif _l_config__ambient__use_directional_ambient_light then
			vec_ambi   = vec_ambi_directional
			color_ambi = color_ambi_directional
		elseif _l_config__use_overcast_sky_ambient_light then		
			vec_ambi   = vec_ambi_overcast
			color_ambi = color_ambi_overcast
		end

		if vec_ambi and color_ambi then

			if __SOL_LIGHTNING_RUNNING then
				color_ambi:add(__SOL_LIGHTNING_COLOR)
				vec_ambi = math.lerp(vec_ambi, __SOL_LIGHTNING_DIR, #__SOL_LIGHTNING_COLOR/math.max(0.1, #color_ambi))
			end

			--color_ambi = rgb(1,1,1)*5
			if color_ambi then ac.setExtraAmbientColor(color_ambi*math.pow(solar__get_light_damping(), 2.5)*__PPoff__brightness__regulation) end
			if vec_ambi then ac.setExtraAmbientDirection(vec_ambi) end
		end
	end
end