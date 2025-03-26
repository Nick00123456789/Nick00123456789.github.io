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

local list = {"NoClouds",
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
"Hail"}

for i=1, #list do

	__SOL_WEATHER_PLAN:add_weather_slot({
		-- weather type
		weather = list[i],
		time_holding  = 0,
		time_changing = 10,
		temperature_ambient = 20,
		temperature_road = 20,
	})
end