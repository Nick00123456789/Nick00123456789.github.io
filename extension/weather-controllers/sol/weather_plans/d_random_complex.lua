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

math.randomseed(os.clock())

local time_multiplier = ac.getTimeMultiplier()
if time_multiplier == 0 then
	time_multiplier = 1
end

function clear()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"NoClouds", "Clear"}),
			time_holding  = random(1800, 7200) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function almost_clear()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Clear", "FewClouds", "ScatteredClouds"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function mostly_clear()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"FewClouds", "ScatteredClouds", "FewClouds", "ScatteredClouds", "Windy", "BrokenClouds"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function mostly_overcast()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Windy", "BrokenClouds", "OvercastClouds", "Windy", "BrokenClouds", "ScatteredClouds"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function overcast()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"OvercastClouds", "OvercastClouds", "LightDrizzle", "LightRain"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function light_fog()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Windy", "Hail", "Hail", "Mist", "Mist"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function fog()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Haze", "Mist", "Mist", "Fog"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function heavy_fog()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Mist", "Fog", "Fog"}),
			time_holding  = random(1200, 1800) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function occasional_rain()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"ScatteredClouds", "ScatteredClouds", "OvercastClouds", "LightRain"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function rain()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"OvercastClouds", "LightDrizzle", "LightRain", "LightRain", "LightRain", "Rain"}),
			time_holding  = random(1200, 3600) / time_multiplier,
			time_changing = random(300, 1200) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function heavy_rain()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"LightRain", "LightDrizzle", "Drizzle", "Rain", "Rain", "HeavyRain"}),
			time_holding  = random(1200, 1800) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function thunderstorm()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"OvercastClouds", "LightThunderstorm", "LightThunderstorm", "LightRain", "LightRain"}),
			time_holding  = random(1200, 1800) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function heavy_thunderstorm()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Thunderstorm", "HeavyRain", "HeavyThunderstorm", "Thunderstorm"}),
			time_holding  = random(1200, 1800) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function unpredictable()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"Haze", "FewClouds", "Windy", "BrokenClouds", "OvercastClouds", "LightRain", "LightDrizzle", "LightThunderstorm"}),
			time_holding  = random(1200, 1800) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function get_random_weather_plan(tbl)
	if use_dynamic_weather_plan == true then
		local index = math.random(1, #tbl)
		if debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+/(.+)$")) == nil then
			ac.debug("Loaded", debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+\\(.+)$")))
		else
			ac.debug("Loaded", debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+/(.+)$")))
		end
		ac.debug("Current weather plan", tbl[index])
		ac.debug("Time multiplier", ac.getTimeMultiplier())
		_G[tbl[index]]()
	end
end

local weathers = {"clear", "almost_clear", "mostly_clear", "mostly_overcast", "overcast", "light_fog", "fog", "heavy_fog", "occasional_rain", "rain", "heavy_rain", "thunderstorm", "heavy_thunderstorm", "unpredictable"}
get_random_weather_plan(weathers)