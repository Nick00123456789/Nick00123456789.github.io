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

local weathers = {}
weathers[0] = "LightThunderstorm"
weathers[1] = "Thunderstorm"
weathers[2] = "HeavyThunderstorm"
weathers[3] = "LightDrizzle"
weathers[4] = "Drizzle"
weathers[5] = "HeavyDrizzle"
weathers[6] = "LightRain"
weathers[7] = "Rain"
weathers[8] = "HeavyRain"
weathers[9] = "LightSnow"
weathers[10] = "Snow"
weathers[11] = "HeavySnow"
weathers[12] = "LightSleet"
weathers[13] = "Sleet"
weathers[14] = "HeavySleet"
weathers[15] = "Clear"
weathers[16] = "FewClouds"
weathers[17] = "ScatteredClouds"
weathers[18] = "BrokenClouds"
weathers[19] = "OvercastClouds"
weathers[20] = "Fog"
weathers[21] = "Mist"
weathers[22] = "Smoke"
weathers[23] = "Haze"
weathers[24] = "Sand"
weathers[25] = "Dust"
weathers[26] = "Squalls"
weathers[27] = "Tornado"
weathers[28] = "Hurricane"
weathers[29] = "Cold"
weathers[30] = "Hot"
weathers[31] = "Windy"
weathers[32] = "Hail"
weathers[100] = "NoClouds"

local time_multiplier = ac.getTimeMultiplier()
if time_multiplier == 0 then
	time_multiplier = 1
end

function clear()
	for i=1, 24 do
		__SOL_WEATHER_PLAN:add_weather_slot({
			weather = random({"NoClouds", "Clear"}),
			time_holding  = random(900, 3600) / time_multiplier,
			time_changing = random(300, 900) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			weather = random({"Windy", "BrokenClouds", "OvercastClouds","Windy", "BrokenClouds", "ScatteredClouds"}),
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
		time_holding  = random(600, 1200) / time_multiplier,
		time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			weather = random({"OvercastClouds", "LightDrizzle", "LightRain", "LightRain", "LightRain"}),
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			weather = random({"LightRain", "Rain", "Rain", "HeavyRain"}),
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
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
			time_holding  = random(600, 1200) / time_multiplier,
			time_changing = random(300, 600) / math.sqrt(time_multiplier),
			temperature_ambient = nil,
			temperature_road = nil,
			wind_direction = random(0, 360),
			wind_speed = random(2, 20),
		})
	end
end

function set_first_slot(input_weather)
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = input_weather,
		time_holding  = random(600, 1200) / time_multiplier,
		time_changing = random(300, 600) / math.sqrt(time_multiplier),
		temperature_ambient = nil,
		temperature_road = nil,
		wind_direction = random(0, 360),
		wind_speed = random(2, 20),
	})
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

local input_weather = weathers[ac.getInputWeatherType()]
ac.debug("Chosen weather", input_weather)
set_first_slot(input_weather)

if input_weather == "NoClouds" then
	local w = {"clear", "almost_clear"}
	get_random_weather_plan(w)
elseif input_weather == "Clear" then
	local w = {"clear", "almost_clear", "mostly_clear"}
	get_random_weather_plan(w)
elseif input_weather == "FewClouds" or input_weather == "ScatteredClouds" then
	local w = {"almost_clear", "mostly_clear", "mostly_overcast"}
	get_random_weather_plan(w)
elseif input_weather == "Windy" or input_weather == "BrokenClouds" then
	local w = {"mostly_clear", "mostly_overcast", "overcast", "occasional_rain", "unpredictable"}
	get_random_weather_plan(w)
elseif input_weather == "OvercastClouds" or input_weather == "LightDrizzle" or input_weather == "LightRain" or input_weather == "LightSleet" or input_weather == "LightThunderstorm" then
	local w = {"mostly_overcast", "overcast", "occasional_rain", "rain", "thunderstorm", "unpredictable"}
	get_random_weather_plan(w)
elseif input_weather == "Rain" or input_weather == "HeavyRain" or input_weather == "Drizzle" or input_weather == "HeavyDrizzle" or input_weather == "Sleet" or input_weather == "HeavySleet" or input_weather == "Thunderstorm" or input_weather == "HeavyThunderstorm" or input_weather == "LightSnow" or input_weather == "Squalls" or input_weather == "Hurricane" or input_weather == "Tornado" then
	local w = {"rain", "thunderstorm", "heavy_rain", "heavy_thunderstorm", "unpredictable"}
	get_random_weather_plan(w)
elseif input_weather == "Hail" or input_weather == "Mist" or input_weather == "Haze" then
	local w = {"light_fog", "fog"}
	get_random_weather_plan(w)
elseif input_weather == "Fog" or input_weather == "Snow" or input_weather == "HeavySnow" then
	local w = {"fog", "heavy_fog"}
	get_random_weather_plan(w)
else
	get_random_weather_plan({"unpredictable"})
end