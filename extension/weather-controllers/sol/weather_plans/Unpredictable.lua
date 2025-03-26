--[[ avialable weather types :
LightThunderstorm, Thunderstorm, HeavyThunderstorm
LightDrizzle, Drizzle, HeavyDrizzle
LightRain, Rain, HeavyRain
LightSnow, Snow, HeavySnow
LightSleet, Sleet, HeavySleet
Clear, FewClouds, ScatteredClouds, BrokenClouds, OvercastClouds
Fog, Mist, Smoke, Haze
Sand, Dust
Squalls, Tornado, Hurricane
Windy
Hail
]]

-- add a weather in the sequence by calling add_weather_slot()


local current, last = nil, nil
local rain, rain_mod

for i=1, 20 do -- create 20 weather slots

	-- prevent duplicated weather
	repeat
		current = random({"ScatteredClouds", "Windy", "BrokenClouds", "OvercastClouds", "Squalls",
						  "ScatteredClouds", "Windy", "BrokenClouds", "OvercastClouds", "Squalls", -- doubled chance for non rainy weather
						  "LightRain", "Rain", "HeavyRain", "LightDrizzle", "Drizzle", "HeavyDrizzle"})
	until last == nil or current ~= last

	last = current

	-- get the predefined rain amount of the certain weather
	rain = SOL__WEATHER__get__rain_amount(current)
	rain_mod = 0.1-0.05*rain -- if rain is already set, lower rain modulation
	rain = rain + random(-0.2 - (1-rain)*0.2, 0.2) -- add a random component to the predefined rain amount
	

	__SOL_WEATHER_PLAN:add_weather_slot({
		-- weather type
		weather = current,
		time_holding  = 0,--random(0, 90),
		time_changing = random(120, 180),
		temperature_ambient = random(15,20),
		temperature_road = random(15,24),
		wind_direction = random(0, 360),
		wind_speed = random(10,30),

		-- set the new rain amount
		rain_amount = rain,
		rain_mod_min = -rain_mod, -- bottom value of random rain modulation
		rain_mod_max = rain_mod, -- upper value of random rain modulation
		rain_mod_speed = 20, -- rain modulation is randomly changed for this time
	})
end