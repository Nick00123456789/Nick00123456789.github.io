--!!! in LUA the "--" is for comment !!!


--[[ avialable weather types :
NoClouds
Clear, FewClouds, ScatteredClouds
Windy, BrokenClouds, OvercastClouds
Fog, Mist, Smoke, Haze
Sand, Dust
LightDrizzle, Drizzle, HeavyDrizzle
LightRain, Rain, HeavyRain
LightThunderstorm, Thunderstorm, HeavyThunderstorm
Squalls, Tornado, Hurricane
LightSleet, Sleet, HeavySleet
LightSnow, Snow, HeavySnow
Hail
]]

local current, last = nil, nil

for i=1, 100 do -- create 20 weather slots

	-- prevent duplicated weather
	repeat
		current = random({"NoClouds",
					  	  "Clear", "FewClouds", "ScatteredClouds",
					  	  "Windy", "BrokenClouds", "OvercastClouds",
					  	  "Fog", "Mist", "Smoke", "Haze",
					  	  "Sand", "Dust",
					  	  "LightDrizzle", "Drizzle", "HeavyDrizzle",
					  	  "LightRain", "Rain", "HeavyRain",
					  	  "LightThunderstorm", "Thunderstorm", "HeavyThunderstorm",
					  	  "Squalls", "Tornado", "Hurricane",
					  	  "LightSleet", "Sleet", "HeavySleet",
					  	  "LightSnow", "Snow", "HeavySnow",
					  	  "Hail"})
	until last == nil or current ~= last

	last = current

	__SOL_WEATHER_PLAN:add_weather_slot({
		-- weather type
		weather = current,
		time_holding  = 0,
		time_changing = 1,
		temperature_ambient = random(15,20),
		temperature_road = random(15,24),
		wind_direction = random(0, 360),
		wind_speed = random(10,30)
	})
end