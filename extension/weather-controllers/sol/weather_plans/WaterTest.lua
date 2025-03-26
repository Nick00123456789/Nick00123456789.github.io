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
	weather = "Windy",

	-- hold this weather for n seconds
	time_holding  = 0,

	-- change to next weather in n seconds / if -1 -> no change
	time_changing = 5,

	-- temperatures
	temperature_ambient = 20,
	temperature_road = 25,

	-- wind
	wind_direction = 0,
	wind_speed = 15
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyRain",
	time_holding  = 60,
	time_changing = 60, 
	temperature_ambient = 16,
	temperature_road = 20
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Clear",
	time_holding  = 60,
	time_changing = -1, -- a negative change time will stop the sequence
	temperature_ambient = 25,
	temperature_road = 22
})