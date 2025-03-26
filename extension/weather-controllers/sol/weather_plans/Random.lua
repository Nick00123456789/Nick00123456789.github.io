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
	weather = random({"ScatteredClouds", "Clear", "Mist", "HeavyDrizzle"}),

	-- hold this weather for n seconds
	time_holding  = 10,

	-- change to next weather in n seconds / if -1 -> no change
	time_changing = 60,

	-- temperatures
	temperature_ambient = random(10.5, 29.5),
	temperature_road = random(10, 30),

	-- wind
	wind_direction = 0,
	wind_speed = 30,
})

__SOL_WEATHER_PLAN:add_weather_slot({

	weather = random({"LightRain", "Rain", "HeavyRain"}),

	-- hold the weather for random time between 60 and 120 seconds
	time_holding  = random(60,120),
	time_changing = random(240,300),
	temperature_ambient = random(10,17),
})

__SOL_WEATHER_PLAN:add_weather_slot({

	weather = "OvercastClouds",

	time_holding  = random(120,240),
	time_changing = random(60,180),

	wind_speed = 15,
})

__SOL_WEATHER_PLAN:add_weather_slot({

	weather = random({"LightDrizzle", "LightRain", "LightSleet"}),

	time_holding  = random(60,120),
	time_changing = random(120,240),
	temperature_ambient = random(10,20),
	temperature_road = random(15,25),
	wind_speed = random(5,15),
})