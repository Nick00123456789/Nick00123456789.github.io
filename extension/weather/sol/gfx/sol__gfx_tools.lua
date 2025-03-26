local _l_THA = ac.getRealTrackHeadingAngle()

function gfx__get_sky_color(vec, compensate_reflections, include_sky, include_moon, compensate_THA)

	compensate_THA = compensate_THA or false

	include_sky = include_sky or true
	include_moon = include_moon or false

	if ac.calculateSkyColorV2 == nil then
		return rgb(0,0,0)
	else

		local vec_corrected

		if _l_THA ~= 0 and compensate_THA then
			local angle = vec32sphere(vec)
			angle[1] = angle[1] - _l_THA
			vec_corrected = sphere2vec3(angle[1], angle[2])
		else
			vec_corrected = vec
		end
	
		local sky_c = ac.calculateSkyColorV2(vec_corrected, include_sky, include_moon)

		--prevent nan return of ac.calculateSkyColor
		if sky_c.r~=sky_c.r then sky_c.r = 0 end
		if sky_c.g~=sky_c.g then sky_c.g = 0 end
		if sky_c.b~=sky_c.b then sky_c.b = 0 end

		sky_c.r = math.max(0, sky_c.r)
		sky_c.g = math.max(0, sky_c.g)
		sky_c.b = math.max(0, sky_c.b)

		if compensate_reflections and compensate_reflections == true then
			sky_c = sky_c * (0.4/SOL__config("nerd__sky_adjust", "GradientStyle"))
		end

		--sky_c:sub(rgb(0,-0.05,0)*sky_c:getLuminance()) --do a luminance dependent green filter

		return sky_c
	end
end
