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
	-- weather type
	weather = "Clear",

	-- hold this weather for n seconds
	time_holding  = 30,

	-- change to next weather in n seconds / if -1 -> no change
	time_changing = 50,

	-- temperatures
	temperature_ambient = 25,
	temperature_road = 32,

	-- wind
	wind_direction = 0,
	wind_speed = 15
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Windy",
	time_holding  = 12,
	time_changing = 40, 
	temperature_ambient = 22,
	temperature_road = 29
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Squalls",
	time_holding  = 18,
	time_changing = 60,
	temperature_ambient = 17,
	temperature_road = 18
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "LightRain",
	time_holding  = 0,
	time_changing = 30, 
	temperature_ambient = 20,
	temperature_road = 25
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Rain",
	time_holding  = 0,
	time_changing = 30, 
	temperature_ambient = 20,
	temperature_road = 25
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyRain",
	time_holding  = 0,
	time_changing = -1, 
	temperature_ambient = 20,
	temperature_road = 25
})