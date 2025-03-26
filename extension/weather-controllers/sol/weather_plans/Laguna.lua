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

-- You can randomize things with the random() function

-- To randomize the weather type, use this format
-- random({"Type1", "Type4", "Type15", "Type28"})

-- To randomize a number, use this format to get a random number between 0 and 10
-- random(0, 10) 


-- add a weather in the sequence by calling add_weather_slot()
__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})

__SOL_WEATHER_PLAN:add_weather_slot({
	-- weather type
	weather = random({"Haze", "Windy", "Clear", "Dust"}),

	time_holding  = 180,
	time_changing = 300,

	-- temperatures
	temperature_ambient = random(25.5, 36.5),
	temperature_road = random(30, 38),

	-- wind
	wind_direction = random(0, 360),
	wind_speed = random(5, 30),
})