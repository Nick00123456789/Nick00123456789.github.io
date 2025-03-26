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
	weather = "Clear",
	time_holding  = 0,
	time_changing = 10, 
	temperature_ambient = 10,
	temperature_road = 15
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Windy",
	time_holding  = 0,
	time_changing = 10, -- a negative change time will stop the sequence
	temperature_ambient = 7,
	temperature_road = 8,
	rain_amount = 1,
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Windy",
	time_holding  = 0,
	time_changing = 10, -- a negative change time will stop the sequence
	temperature_ambient = 7,
	temperature_road = 8,
	rain_amount = 0,
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Windy",
	time_holding  = 0,
	time_changing = 10, -- a negative change time will stop the sequence
	temperature_ambient = 7,
	temperature_road = 8,
	rain_amount = 0.5,
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "OvercastClouds",
	time_holding  = 0,
	time_changing = 10, -- a negative change time will stop the sequence
	temperature_ambient = 8,
	temperature_road = 10
})