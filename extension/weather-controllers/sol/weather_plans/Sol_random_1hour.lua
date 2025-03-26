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

local weathers = {}
weathers[0] = "LightThunderstorm"
weathers[1] = "Thunderstorm"
weathers[2] = "HeavyThunderstorm"
weathers[3] = "LightDrizzle"
weathers[4] = "Drizzle"
weathers[5] = "HeavyDrizzle"
weathers[6] = "LightRain"
weathers[7] = "Rain"
weathers[8] = "HeavyRain"
weathers[9] = "LightSnow"
weathers[10] = "Snow"
weathers[11] = "HeavySnow"
weathers[12] = "LightSleet"
weathers[13] = "Sleet"
weathers[14] = "HeavySleet"
weathers[15] = "Clear"
weathers[16] = "FewClouds"
weathers[17] = "ScatteredClouds"
weathers[18] = "BrokenClouds"
weathers[19] = "OvercastClouds"
weathers[20] = "Fog"
weathers[21] = "Mist"
weathers[22] = "Smoke"
weathers[23] = "Haze"
weathers[24] = "Sand"
weathers[25] = "Dust"
weathers[26] = "Squalls"
weathers[27] = "Tornado"
weathers[28] = "Hurricane"
weathers[29] = "Cold"
weathers[30] = "Hot"
weathers[31] = "Windy"
weathers[32] = "Hail"
weathers[100] = "NoClouds"

last = weathers[ac.getInputWeatherType()]

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = last,
	time_holding  = 0,
	time_changing = 180,
	temperature_ambient = random(15,20),
	temperature_road = random(15,24),
	wind_direction = random(0, 360),
	wind_speed = random(10,30)
})


for i=1, 20 do -- create 20 weather slots

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
		time_changing = 180,
		temperature_ambient = random(15,20),
		temperature_road = random(15,24),
		wind_direction = random(0, 360),
		wind_speed = random(10,30)
	})
end