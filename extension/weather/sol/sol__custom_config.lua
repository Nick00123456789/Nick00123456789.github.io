
-- buffer for custom config weather dependent variables
local _l_cc_wdv_buffer = {}


local _l_ids = {
 "LightThunderstorm"
,"Thunderstorm"
,"HeavyThunderstorm"
,"LightDrizzle"
,"Drizzle"
,"HeavyDrizzle"
,"LightRain"
,"Rain"
,"HeavyRain"
,"LightSnow"
,"Snow"
,"HeavySnow"
,"LightSleet"
,"Sleet"
,"HeavySleet"
,"Clear"
,"FewClouds"
,"ScatteredClouds"
,"BrokenClouds"
,"OvercastClouds"
,"Fog"
,"Mist"
,"Smoke"
,"Haze"
,"Sand"
,"Dust"
,"Squalls"
,"Tornado"
,"Hurricane"
,"Windy"
,"Hail"
,"NoClouds"
,"Default"
}


local _l_cc__ids = {}
_l_cc__ids["LightThunderstorm"] = 1
_l_cc__ids["Thunderstorm"] = 2
_l_cc__ids["HeavyThunderstorm"] = 3
_l_cc__ids["LightDrizzle"] = 4
_l_cc__ids["Drizzle"] = 5
_l_cc__ids["HeavyDrizzle"] = 6
_l_cc__ids["LightRain"] = 7
_l_cc__ids["Rain"] = 8
_l_cc__ids["HeavyRain"] = 9
_l_cc__ids["LightSnow"] = 10
_l_cc__ids["Snow"] = 11
_l_cc__ids["HeavySnow"] = 12
_l_cc__ids["LightSleet"] = 13
_l_cc__ids["Sleet"] = 14
_l_cc__ids["HeavySleet"] = 15
_l_cc__ids["Clear"] = 16
_l_cc__ids["FewClouds"] = 17
_l_cc__ids["ScatteredClouds"] = 18
_l_cc__ids["BrokenClouds"] = 19
_l_cc__ids["OvercastClouds"] = 20
_l_cc__ids["Fog"] = 21
_l_cc__ids["Mist"] = 22
_l_cc__ids["Smoke"] = 23
_l_cc__ids["Haze"] = 24
_l_cc__ids["Sand"] = 25
_l_cc__ids["Dust"] = 26
_l_cc__ids["Squalls"] = 27
_l_cc__ids["Tornado"] = 28
_l_cc__ids["Hurricane"] = 29
_l_cc__ids["Windy"] = 32
_l_cc__ids["Hail"] = 33
_l_cc__ids["NoClouds"] = 101
_l_cc__ids["Default"] = 999
local _l_cc__ids_count = 0



function cc__init_weather_variables()

	_l_cc_wdv_buffer = {}
	_l_cc__ids_count = #_l_ids

	for i=1, _l_cc__ids_count do

		_l_cc_wdv_buffer[   _l_cc__ids[ _l_ids[i] ]   ] = {}
	end
end

function cc__add_weather_variable(name, default_value)

	for i=1, _l_cc__ids_count do
		_l_cc_wdv_buffer[   _l_cc__ids[ _l_ids[i] ]   ][name] = default_value
	end
end

function cc__set_weather_variable(name, weather, value)

	-- weather id exists
	if _l_cc__ids[weather] then

		-- variable was added
		if _l_cc_wdv_buffer[_l_cc__ids[weather]][name] then

			_l_cc_wdv_buffer[_l_cc__ids[weather]][name] = value
		end
	end

end

function cc__get_weather_variable(name)

	if __weather_id_past == __weather_id_future then

		if _l_cc_wdv_buffer[__weather_id_past] then

			if _l_cc_wdv_buffer[__weather_id_past][name] then

				return _l_cc_wdv_buffer[__weather_id_past][name]
			end
		end
	else
		if _l_cc_wdv_buffer[__weather_id_past] or _l_cc_wdv_buffer[__weather_id_future] then

			if _l_cc_wdv_buffer[__weather_id_past][name] and _l_cc_wdv_buffer[__weather_id_future][name] then

				return math.lerp(_l_cc_wdv_buffer[__weather_id_past][name], _l_cc_wdv_buffer[__weather_id_future][name],  __weather_change_momentum)
			end
		end
	end

	if __CW__.CustomWeather__.use then
		if _l_cc_wdv_buffer[999] and _l_cc_wdv_buffer[999][name] then
			return _l_cc_wdv_buffer[999][name]
		end
	end

	return 0
end
