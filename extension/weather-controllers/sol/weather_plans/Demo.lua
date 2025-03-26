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


-- add a weather in the sequence by calling add_weather_slot()
__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "ScatteredClouds",
	time_holding  = 5,
	time_changing = 60, 
	temperature_ambient = 20,
	temperature_road = 25,
	wind_direction = 0,
	wind_speed = 15
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "BrokenClouds",
	time_holding  = 0,
	time_changing = 60, -- a negative change time will stop the sequence
	temperature_ambient = 17,
	temperature_road = 18
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyRain",
	time_holding  = 60,
	time_changing = -1, -- a negative change time will stop the sequence
	temperature_ambient = 17,
	temperature_road = 18
})