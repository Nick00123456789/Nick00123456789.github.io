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
__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = "ScatteredClouds",

	-- hold this weather for n seconds
	time_holding  = 60,

	-- change to next weather in n seconds / if -1 -> no change
	time_changing = 120,

	-- temperatures
	temperature_ambient = 32,
	temperature_road = 36
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "BrokenClouds",
	time_holding  = 60,
	time_changing = 120,
	temperature_ambient = 27,
	temperature_road = 32})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "OvercastClouds",
	time_holding  = 60,
	time_changing = 120,
	temperature_ambient = 22,
	temperature_road = 25})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "LightThunderstorm",
	time_holding  = 0,
	time_changing = 120,
	temperature_ambient = 24,
	temperature_road = 17})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Thunderstorm",
	time_holding  = 0,
	time_changing = 120,
	temperature_ambient = 21,
	temperature_road = 16})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyThunderstorm",
	time_holding  = 60,
	time_changing = 120,
	temperature_ambient = 19,
	temperature_road = 15})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Rain",
	time_holding  = 120,
	time_changing = 120,
	temperature_ambient = 15,
	temperature_road = 13})