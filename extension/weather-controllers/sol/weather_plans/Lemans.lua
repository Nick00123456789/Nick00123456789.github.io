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

local time_multiplier = ac.getTimeMultiplier()
if time_multiplier == 0 then
	time_multiplier = 1
end

for i=1, 30 do
	__SOL_WEATHER_PLAN:add_weather_slot({
		weather = random({"Clear", "FewClouds", "ScatteredClouds", "Windy", "BrokenClouds", "OvercastClouds", "LightDrizzle", "Drizzle", "LightRain", "Rain", "LightSleet"}),
		time_holding  = random(1200, 3600) / time_multiplier,
		time_changing = random(300, 1200) / math.sqrt(time_multiplier),
		temperature_ambient = nil,
		temperature_road = nil,
		wind_direction = random(0, 360),
		wind_speed = random(2, 20),
	})
end

if debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+/(.+)$")) == nil then
			ac.debug("Loaded", debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+\\(.+)$")))
		else
			ac.debug("Loaded", debug.getinfo(1, 'S').source:sub(1, -5):match(("^.+/(.+)$")))
		end
ac.debug("Time multiplier", ac.getTimeMultiplier())