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
	time_holding  = 0,

	-- change to next weather in n seconds / if -1 -> no change
	time_changing = 30,

	-- temperatures
	temperature_ambient = 25,
	temperature_road = 32,

	-- wind
	wind_speed = 10
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Windy",
	time_holding  = 0,
	time_changing = 30, 
	temperature_ambient = 22,
	temperature_road = 29,
	wind_speed = 20
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "Rain",
	time_holding  = 180,
	time_changing = 300,
	temperature_ambient = 19,
	temperature_road = 24,
	wind_speed = 35
})

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "LightRain",
	time_holding  = 0,
	time_changing = 60, 
	temperature_ambient = 18,
	temperature_road = 22,
	wind_speed = 25
})

-- 27 min

for i=1, 5 do
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = random({"BrokenClouds", "LightRain", "Rain", "Squalls"}),
		time_holding  = 0,
		time_changing = 60, 
		temperature_ambient = random(18, 22),
		temperature_road = random(20, 25),
		wind_speed = random(15, 35)
	})
end

-- 32 min

for i=1, 5 do
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = random({"LightRain", "Rain", "Squalls"}),
		time_holding  = 0,
		time_changing = 60, 
		temperature_ambient = random(15, 20),
		temperature_road = random(18, 23),
		wind_speed = random(15, 25)
	})
end

-- 38 min

for i=1, 5 do
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = random({"Rain", "HeavyRain"}),
		time_holding  = 0,
		time_changing = 60, 
		temperature_ambient = random(12, 18),
		temperature_road = random(14, 20),
		wind_speed = random(15, 25)
	})
end

-- 42 min till here

__SOL_WEATHER_PLAN:add_weather_slot({
	weather = "HeavyRain",
	time_holding  = 0,
	time_changing = -1, 
	temperature_ambient = 14,
	temperature_road = 18,
	wind_speed = random(25, 35)
})