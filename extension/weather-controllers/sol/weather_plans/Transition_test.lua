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

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Clear",
	time_holding  = 0,
	time_changing = 1, -- a negative change time will stop the sequence
	temperature_ambient = 20,
	temperature_road = 20,
	wind_direction = 0,
	wind_speed = 60
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "BrokenClouds",
	time_holding  = 0,
	time_changing = 1, -- a negative change time will stop the sequence
	temperature_ambient = 20,
	temperature_road = 20,
	wind_direction = 0,
	wind_speed = 60
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "BrokenClouds",
	time_holding  = 0,
	time_changing = 1, 
	temperature_ambient = 20,
	temperature_road = 20,
	wind_direction = 0,
	wind_speed = 60
}) 

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "NoClouds",
	time_holding  = 0,
	time_changing = 1, 
	temperature_ambient = 20,
	temperature_road = 20,
	wind_direction = 0,
	wind_speed = 60
}) 

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyThunderstorm",
	time_holding  = 0,
	time_changing = 1, 
	temperature_ambient = 20,
	temperature_road = 20,
	wind_direction = 0,
	wind_speed = 60
}) 